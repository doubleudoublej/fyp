// This file intentionally uses `dart:html` for a web-only demo.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html; // web-only implementation
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';

/// Simple audio record/upload and random-play screen.
///
/// Note: This implementation uses the browser MediaRecorder APIs via
/// `dart:html` and therefore only works on Flutter Web. For mobile
/// (iOS/Android) you'd use a native recorder plugin and then call
/// StorageService.uploadBytes similarly.
class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  final StorageService _storageService = StorageService(
    storageBucket: 'gs://fyp-mha.firebasestorage.app',
  );

  bool _isRecording = false;
  bool _isUploading = false;
  String? _lastUploadedUrl;
  String? _lastBlobUrl; // temporary object URL for last recorded blob (web)

  // Web-specific
  html.MediaRecorder? _recorder;
  html.MediaStream? _stream;
  final List<html.Blob> _chunks = [];

  @override
  void dispose() {
    _stopStreamTracks();
    super.dispose();
  }

  void _stopStreamTracks() {
    try {
      _stream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _stream = null;
  }

  Future<void> _startRecording() async {
    if (!kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recording is currently implemented for Web only.'),
        ),
      );
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    try {
      // Helpful debug message so we know this handler ran (check browser console).
      // ignore: avoid_print
      print('AudioScreen: startRecording invoked');
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Requesting microphone access...')),
        );
      }

      // Guard: some environments/browsers don't expose mediaDevices.
      if (html.window.navigator.mediaDevices == null) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Browser does not support getUserMedia / MediaDevices.',
            ),
          ),
        );
        return;
      }

      final media = await html.window.navigator.mediaDevices!.getUserMedia({
        'audio': true,
      });

      _stream = media;
      _chunks.clear();

      _recorder = html.MediaRecorder(_stream!);
      // MediaRecorder event APIs differ across SDK versions; use addEventListener
      _recorder!.addEventListener('dataavailable', (e) {
        try {
          final data = (e as dynamic).data as html.Blob?;
          if (data != null) _chunks.add(data);
        } catch (_) {}
      });

      _recorder!.addEventListener('stop', (event) async {
        // assemble blob
        final messenger = ScaffoldMessenger.of(context);
        final mountedNow = mounted;

        final blob = html.Blob(_chunks);
        // create an object URL so we can play the recorded audio immediately
        try {
          // Revoke previous blob URL if any
          if (_lastBlobUrl != null) {
            try {
              html.Url.revokeObjectUrl(_lastBlobUrl!);
            } catch (_) {}
          }
          final blobUrl = html.Url.createObjectUrl(blob);
          _lastBlobUrl = blobUrl;
        } catch (_) {}
        // read as array buffer
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        await reader.onLoad.first;
        final res = reader.result;
        // `reader.result` may be a ByteBuffer or a Uint8List depending on
        // the JS interop/runtime. Handle both cases robustly.
        Uint8List bytes;
        if (res is ByteBuffer) {
          bytes = res.asUint8List();
        } else if (res is Uint8List) {
          bytes = res;
        } else if (res is List) {
          bytes = Uint8List.fromList(List<int>.from(res));
        } else {
          throw Exception(
            'Unsupported FileReader.result type: ${res.runtimeType}',
          );
        }

        // Ensure we are signed in before uploading. Many Storage rules
        // require an authenticated user. Try anonymous sign-in if not.
        final auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          try {
            await auth.signInAnonymously();
            // ignore: avoid_print
            print('Signed in anonymously: ${auth.currentUser?.uid}');
          } catch (e) {
            if (mountedNow) {
              messenger.showSnackBar(
                SnackBar(content: Text('Unable to sign in anonymously: $e')),
              );
            }
            // continue and attempt upload anyway; will likely fail with 403
          }
        }

        // upload
        if (mountedNow) setState(() => _isUploading = true);
        final ext = _inferExtensionFromMime(blob.type) ?? '.webm';
        final filename =
            'forum_audios/${DateTime.now().millisecondsSinceEpoch}$ext';
        try {
          // Debug: print size and filename before upload
          // ignore: avoid_print
          print(
            'Audio upload: filename=$filename size=${bytes.length} contentType=${blob.type}',
          );
          final url = await _storageService.uploadBytes(
            filename,
            bytes,
            contentType: blob.type.isNotEmpty ? blob.type : 'audio/webm',
          );
          // ignore: avoid_print
          print('Audio upload completed, url=$url');
          if (mounted) {
            setState(() {
              _lastUploadedUrl = url;
            });
            messenger.showSnackBar(
              const SnackBar(content: Text('Uploaded audio successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            messenger.showSnackBar(
              SnackBar(content: Text('Upload failed: $e')),
            );
          }
        } finally {
          if (mounted) {
            setState(() => _isUploading = false);
          }
        }
      });

      _recorder!.start();
      setState(() => _isRecording = true);
    } catch (e) {
      // Provide friendlier guidance depending on the error.
      String msg = 'Could not start recording';
      try {
        final name = (e as dynamic).name as String?;
        if (name != null) {
          if (name == 'NotAllowedError' || name == 'SecurityError') {
            msg = 'Microphone access was denied by the user or browser.';
          } else if (name == 'NotFoundError') {
            msg = 'No microphone found on this device.';
          } else {
            msg = '$msg: $name';
          }
        } else {
          msg = '$msg: $e';
        }
      } catch (_) {
        msg = '$msg: $e';
      }

      if (mounted) messenger.showSnackBar(SnackBar(content: Text(msg)));
      // Also print to console for debugging.
      // ignore: avoid_print
      print('Recording start error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recorder?.stop();
    } catch (_) {}
    _stopStreamTracks();
    setState(() => _isRecording = false);
  }

  /// Wrapper called by the Record button. Logs immediately to the browser
  /// console and then dispatches to start/stop logic. Using this wrapper
  /// helps ensure the handler runs even if some framework wiring changes.
  void _onRecordPressed() {
    try {
      // Ensure we always emit a console entry when button pressed.
      html.window.console.log('AudioScreen: record button pressed');
    } catch (_) {}

    if (_isRecording) {
      _stopRecording();
    } else {
      // Fire-and-forget startRecording; it will set state when it begins.
      _startRecording();
    }
  }

  String? _inferExtensionFromMime(String mime) {
    if (mime.contains('webm')) return '.webm';
    if (mime.contains('ogg')) return '.ogg';
    if (mime.contains('mpeg') || mime.contains('mp3')) return '.mp3';
    return null;
  }

  Future<void> _playRandom() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isUploading = true);
    try {
      final url = await _storageService.getRandomFileDownloadUrl(
        'forum_audios',
      );
      if (url == null) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('No audio files found')),
          );
        }
        return;
      }
      // Use AudioElement for web playback
      if (kIsWeb) {
        final player = html.AudioElement(url)..autoplay = true;
        player.onEnded.listen((_) => player.remove());
      } else {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Playback implemented for Web only in this demo.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Play failed: $e')));
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _playLastRecording() {
    final messenger = ScaffoldMessenger.of(context);
    final url = _lastBlobUrl ?? _lastUploadedUrl;
    if (url == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No recorded audio available')),
      );
      return;
    }
    if (kIsWeb) {
      final player = html.AudioElement(url)..autoplay = true;
      player.onEnded.listen((_) => player.remove());
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Playback implemented for Web only in this demo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Storage bucket: gs://fyp-mha.firebasestorage.app'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Stop' : 'Record'),
              onPressed: _onRecordPressed,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Get & Play Random Audio'),
                    onPressed: _isUploading ? null : _playRandom,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Last Recording'),
                    onPressed:
                        (_lastBlobUrl == null && _lastUploadedUrl == null)
                        ? null
                        : _playLastRecording,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isUploading) const LinearProgressIndicator(),
            if (_lastUploadedUrl != null) ...[
              const SizedBox(height: 12),
              Text('Last uploaded URL:'),
              SelectableText(_lastUploadedUrl!),
            ],
          ],
        ),
      ),
    );
  }
}
