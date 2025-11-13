// Web-only recording helpers are used when running on the web.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

// The following import is only used on web. Guarded at runtime with kIsWeb.
import 'dart:html' as html;
import 'package:firebase_auth/firebase_auth.dart';
import '../services/storage_service.dart';

class VoicePage extends StatefulWidget {
  const VoicePage({super.key});

  @override
  State<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends State<VoicePage> with TickerProviderStateMixin {
  bool isRecording = false;
  bool isGiftAnimating = false;
  late AnimationController _giftController;
  late Animation<double> _giftFallAnimation;
  late Animation<double> _giftOpenAnimation;

  // Web-specific recording state (kept here so the UI/design isn't changed)
  html.MediaRecorder? _recorder;
  html.MediaStream? _stream;
  final List<html.Blob> _chunks = [];
  String? _lastBlobUrl;
  String? _lastUploadedUrl;
  bool _isUploading = false;
  // Playback state
  html.AudioElement? _player;
  bool _isPlayingAudio = false;
  final StorageService _storageService = StorageService(
    storageBucket: 'gs://fyp-mha.firebasestorage.app',
  );

  @override
  void initState() {
    super.initState();
    _giftController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _giftFallAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _giftController,
        curve: const Interval(0.0, 0.7, curve: Curves.bounceOut),
      ),
    );

    _giftOpenAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _giftController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _giftController.dispose();
    // stop any active recorder stream
    try {
      _stream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    // stop and remove player
    try {
      _player?.pause();
      _player?.remove();
    } catch (_) {}
    super.dispose();
  }

  /// Start recording using browser MediaRecorder (Web only). Keeps the
  /// existing UI/animation but replaces the mock timer with a real microphone
  /// prompt and upload flow. On non-web platforms it shows a friendly
  /// message that recording is not implemented.
  Future<void> startRecording() async {
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
      // Log to console so we can see the handler was fired in browser tools.
      try {
        html.window.console.log('VoicePage: startRecording invoked');
      } catch (_) {}

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Requesting microphone access...')),
        );
      }

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
      _recorder!.addEventListener('dataavailable', (e) {
        try {
          final data = (e as dynamic).data as html.Blob?;
          if (data != null) _chunks.add(data);
        } catch (_) {}
      });

      _recorder!.addEventListener('stop', (event) async {
        final messenger = ScaffoldMessenger.of(context);
        final mountedNow = mounted;

        final blob = html.Blob(_chunks);
        try {
          if (_lastBlobUrl != null) {
            try {
              html.Url.revokeObjectUrl(_lastBlobUrl!);
            } catch (_) {}
          }
          final blobUrl = html.Url.createObjectUrl(blob);
          _lastBlobUrl = blobUrl;
        } catch (_) {}

        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        await reader.onLoad.first;
        final res = reader.result;
        Uint8List bytes;
        if (res is ByteBuffer) {
          bytes = res.asUint8List();
        } else if (res is Uint8List) {
          bytes = res;
        } else if (res is List) {
          bytes = Uint8List.fromList(List<int>.from(res));
        } else {
          if (mountedNow) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(
                  'Unsupported recorder result: ${res.runtimeType}',
                ),
              ),
            );
          }
          return;
        }

        // Ensure authenticated (attempt anonymous if not): many Storage rules
        // require auth.
        final auth = FirebaseAuth.instance;
        if (auth.currentUser == null) {
          try {
            await auth.signInAnonymously();
            try {
              html.window.console.log(
                'Signed in anonymously: ${auth.currentUser?.uid}',
              );
            } catch (_) {}
          } catch (e) {
            if (mountedNow) {
              messenger.showSnackBar(
                SnackBar(content: Text('Unable to sign in anonymously: $e')),
              );
            }
          }
        }

        if (mountedNow) setState(() => _isUploading = true);
        final ext = _inferExtensionFromMime(blob.type) ?? '.webm';
        final filename =
            'forum_audios/${DateTime.now().millisecondsSinceEpoch}$ext';
        try {
          try {
            html.window.console.log(
              'VoicePage: uploading $filename size=${bytes.length}',
            );
          } catch (_) {}
          final url = await _storageService.uploadBytes(
            filename,
            bytes,
            contentType: blob.type.isNotEmpty ? blob.type : 'audio/webm',
          );
          if (mountedNow) {
            setState(() => _lastUploadedUrl = url);
            messenger.showSnackBar(
              const SnackBar(content: Text('Uploaded audio successfully')),
            );
          }
        } catch (e) {
          if (mountedNow) {
            messenger.showSnackBar(
              SnackBar(content: Text('Upload failed: $e')),
            );
          }
        } finally {
          if (mountedNow) setState(() => _isUploading = false);
        }
      });

      _recorder!.start();
      setState(() => isRecording = true);
    } catch (e) {
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

      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      try {
        html.window.console.log('VoicePage recording error: $e');
      } catch (_) {}
    }
  }

  Future<void> _stopStreamTracks() async {
    try {
      _stream?.getTracks().forEach((t) => t.stop());
    } catch (_) {}
    _stream = null;
  }

  Future<void> _stopRecording() async {
    try {
      _recorder?.stop();
    } catch (_) {}
    await _stopStreamTracks();
    if (mounted) setState(() => isRecording = false);
  }

  String? _inferExtensionFromMime(String mime) {
    if (mime.contains('webm')) return '.webm';
    if (mime.contains('ogg')) return '.ogg';
    if (mime.contains('mpeg') || mime.contains('mp3')) return '.mp3';
    return null;
  }

  Future<void> _playRandomAudio() async {
    // If already playing, stop and clean up instead of starting another clip.
    if (_player != null && _isPlayingAudio) {
      try {
        _player?.pause();
        _player?.currentTime = 0;
        _player?.remove();
      } catch (_) {}
      setState(() {
        _player = null;
        _isPlayingAudio = false;
      });
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    if (!kIsWeb) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Playback implemented for Web only in this demo.'),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);
    try {
      final url = await _storageService.getRandomFileDownloadUrl(
        'forum_audios',
      );
      if (url == null) {
        if (mounted)
          messenger.showSnackBar(
            const SnackBar(content: Text('No audio files found')),
          );
        return;
      }
      // Trigger the gift animation together with playback for a nicer UX.
      try {
        // Only trigger if not already animating
        if (!isGiftAnimating) triggerGiftDrop();
      } catch (_) {}

      final player = html.AudioElement(url)..autoplay = true;
      player.onEnded.listen((_) {
        try {
          player.remove();
        } catch (_) {}
        if (mounted)
          setState(() {
            _player = null;
            _isPlayingAudio = false;
          });
      });
      // store player and mark playing state so UI can update
      setState(() {
        _player = player;
        _isPlayingAudio = true;
      });
    } catch (e) {
      if (mounted)
        messenger.showSnackBar(SnackBar(content: Text('Play failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void triggerGiftDrop() {
    setState(() {
      isGiftAnimating = true;
    });

    _giftController.forward().then((_) {
      // Show gift message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎁 Gift Message: You are amazing! ✨'),
          backgroundColor: Colors.purple,
          duration: Duration(seconds: 4),
        ),
      );

      // Reset animation after delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _giftController.reset();
          setState(() {
            isGiftAnimating = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Voice header
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Voice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Gifted Tree Section
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Make tree take up most of available space
                final treeHeight = constraints.maxHeight * 0.8;
                final treeWidth = constraints.maxWidth * 0.9;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Tree illustration - much larger
                    CustomPaint(
                      size: Size(treeWidth, treeHeight),
                      painter: GiftedTreePainter(),
                    ),

                    // Animated gift drop - starts from tree branch
                    if (isGiftAnimating)
                      AnimatedBuilder(
                        animation: _giftFallAnimation,
                        builder: (context, child) {
                          // Gift starts from tree branch position, falls down
                          final startY = treeHeight * 0.3; // Tree branch level
                          final endY = treeHeight * 0.9; // Bottom of screen
                          final currentY =
                              startY +
                              (_giftFallAnimation.value * (endY - startY));

                          return Positioned(
                            top: currentY,
                            child: AnimatedBuilder(
                              animation: _giftOpenAnimation,
                              builder: (context, child) {
                                // Gift disappears when opened
                                if (_giftOpenAnimation.value > 0.8) {
                                  return const SizedBox.shrink(); // Remove gift
                                }

                                return Transform.scale(
                                  scale: 1.0 + (_giftOpenAnimation.value * 0.5),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _giftOpenAnimation.value > 0.5
                                          ? Colors.yellow
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _giftOpenAnimation.value > 0.5
                                            ? '✨'
                                            : '🎁',
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),

          // Action buttons
          Row(
            children: [
              // Record button
              Expanded(
                child: GestureDetector(
                  // Toggle recording: start when idle, stop when recording.
                  onTap: isRecording ? _stopRecording : startRecording,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isRecording
                          ? Colors.red.withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isRecording ? 'Recording...' : 'Record',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Get button
              Expanded(
                child: GestureDetector(
                  // Changed to fetch & play a random audio clip from Storage.
                  // Allow stopping even while not disabled by uploading.
                  onTap: (_isUploading && !_isPlayingAudio)
                      ? null
                      : _playRandomAudio,
                  child: Container(
                    height: 60,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: _isPlayingAudio
                          ? Colors.red.withValues(alpha: 0.8)
                          : isGiftAnimating
                          ? Colors.grey.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isPlayingAudio
                                ? Icons.stop
                                : (isGiftAnimating
                                      ? Icons.hourglass_empty
                                      : Icons.card_giftcard),
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isPlayingAudio
                                ? 'Stop'
                                : (isGiftAnimating ? 'Getting...' : 'Get'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Show last uploaded URL for convenience (if any)
          if (_lastUploadedUrl != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: SelectableText(
                'Last uploaded: ${_lastUploadedUrl!}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Custom painter for the gifted tree
class GiftedTreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Scale tree elements based on canvas size - reduce size to fit screen
    final centerX = size.width / 2;
    final bottomY = size.height * 0.90; // Move closer to bottom
    final trunkWidth = size.width * 0.08; // Slightly narrower trunk
    final trunkHeight = size.height * 0.3; // Shorter trunk
    final mainFoliageRadius = size.width * 0.25; // Smaller main foliage
    final sideFoliageRadius = size.width * 0.16; // Smaller side foliage

    // Draw tree trunk
    paint.color = const Color(0xFF8B4513); // Brown
    final trunkRect = Rect.fromCenter(
      center: Offset(centerX, bottomY - trunkHeight / 2),
      width: trunkWidth,
      height: trunkHeight,
    );
    canvas.drawRect(trunkRect, paint);

    // Draw main tree foliage (large green circle)
    paint.color = const Color(0xFF228B22); // Forest green
    final foliageY = bottomY - trunkHeight - mainFoliageRadius * 0.6;
    canvas.drawCircle(Offset(centerX, foliageY), mainFoliageRadius, paint);

    // Draw smaller foliage circles for depth
    paint.color = const Color(0xFF32CD32); // Lime green
    final sideY = foliageY - mainFoliageRadius * 0.25;
    canvas.drawCircle(
      Offset(centerX - mainFoliageRadius * 0.6, sideY),
      sideFoliageRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + mainFoliageRadius * 0.6, sideY),
      sideFoliageRadius,
      paint,
    );

    // Draw gifts hanging on the tree branches - scale with tree size
    final giftSize = size.width * 0.035; // Smaller gifts proportional to tree
    final giftPositions = [
      Offset(
        centerX - mainFoliageRadius * 0.5,
        foliageY - mainFoliageRadius * 0.2,
      ),
      Offset(
        centerX + mainFoliageRadius * 0.5,
        foliageY - mainFoliageRadius * 0.2,
      ),
      Offset(centerX, foliageY - mainFoliageRadius * 0.7),
      Offset(
        centerX - mainFoliageRadius * 0.25,
        foliageY + mainFoliageRadius * 0.3,
      ),
      Offset(
        centerX + mainFoliageRadius * 0.25,
        foliageY + mainFoliageRadius * 0.3,
      ),
      Offset(
        centerX - mainFoliageRadius * 0.8,
        foliageY + mainFoliageRadius * 0.4,
      ),
      Offset(
        centerX + mainFoliageRadius * 0.8,
        foliageY + mainFoliageRadius * 0.4,
      ),
      Offset(centerX, foliageY + mainFoliageRadius * 0.6),
    ];

    for (int i = 0; i < giftPositions.length; i++) {
      final giftColors = [
        Colors.red,
        Colors.blue,
        Colors.purple,
        Colors.orange,
        Colors.pink,
        Colors.cyan,
      ];
      paint.color = giftColors[i % giftColors.length];

      // Draw gift box
      final giftRect = Rect.fromCenter(
        center: giftPositions[i],
        width: giftSize,
        height: giftSize,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(giftRect, Radius.circular(giftSize * 0.1)),
        paint,
      );

      // Draw gift ribbon
      paint.color = Colors.yellow;
      paint.strokeWidth = giftSize * 0.12;
      canvas.drawLine(
        Offset(giftPositions[i].dx - giftSize / 2, giftPositions[i].dy),
        Offset(giftPositions[i].dx + giftSize / 2, giftPositions[i].dy),
        paint,
      );
      canvas.drawLine(
        Offset(giftPositions[i].dx, giftPositions[i].dy - giftSize / 2),
        Offset(giftPositions[i].dx, giftPositions[i].dy + giftSize / 2),
        paint,
      );
      paint.strokeWidth = 1;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
