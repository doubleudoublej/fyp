import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Simple Firebase Storage helper for uploading audio files and listing them.
class StorageService {
  final FirebaseStorage _storage;

  /// If your Firebase app is configured with a storage bucket in
  /// `firebase_options.dart`, this will use that. You can also pass a
  /// `storageBucket` like `gs://...` to target a specific bucket.
  StorageService({String? storageBucket})
    : _storage = storageBucket != null
          ? FirebaseStorage.instanceFor(bucket: storageBucket)
          : FirebaseStorage.instance;

  /// Upload raw bytes to [path] with [contentType] and return the download URL.
  Future<String> uploadBytes(
    String path,
    Uint8List bytes, {
    String? contentType,
  }) async {
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: contentType);
    final task = ref.putData(bytes, metadata);
    final snapshot = await task.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  /// List all files under [prefix] (e.g. 'forum_audios'). Returns their
  /// Storage References.
  Future<List<Reference>> listAllFiles(String prefix) async {
    final ref = _storage.ref(prefix);
    final result = await ref.listAll();
    return result.items;
  }

  /// Choose a random file under [prefix] and return its download URL, or
  /// null if no file exists.
  Future<String?> getRandomFileDownloadUrl(String prefix) async {
    final items = await listAllFiles(prefix);
    if (items.isEmpty) return null;
    final rand = Random().nextInt(items.length);
    final chosen = items[rand];
    return await chosen.getDownloadURL();
  }
}
