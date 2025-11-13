import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;

import 'package:firebase_storage/firebase_storage.dart';

/// ArticlesHelper using Firebase Storage instead of Firestore.
///
/// Storage layout expected:
/// - articles/index.json            -> JSON array of article metadata (id, title, subtitle, author, readTime, category)
/// - articles/{id}.md               -> Markdown content for the article
class ArticlesService {
  final FirebaseStorage _storage;

  ArticlesService({String? storageBucket})
    : _storage = storageBucket != null
          ? FirebaseStorage.instanceFor(bucket: storageBucket)
          : FirebaseStorage.instance;

  /// Fetch article metadata from `articles/index.json` stored in Firebase Storage.
  Future<List<Map<String, dynamic>>> fetchArticleMetadata() async {
    try {
      final ref = _storage.ref('articles/index.json');
      // allow up to 1MB for the index.json
      final data = await ref.getData(1024 * 1024);
      if (data == null) return [];
      final s = utf8.decode(data);
      final decoded = jsonDecode(s) as List<dynamic>;
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on FirebaseException catch (_) {
      // If Storage read fails (object-not-found or permission issue) fallback to
      // bundled assets (assets/articles/index.json) so the app still works offline
      // or during testing.
      try {
        final s = await rootBundle.loadString('assets/articles/index.json');
        final decoded = jsonDecode(s) as List<dynamic>;
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Get a full article by id. Returns metadata + 'content' key with markdown string.
  Future<Map<String, dynamic>?> getArticleById(String id) async {
    try {
      final metaList = await fetchArticleMetadata();
      final meta = metaList.firstWhere(
        (m) => m['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      final ref = _storage.ref('articles/$id.md');
      // allow up to 2MB per article
      final data = await ref.getData(2 * 1024 * 1024);
      final content = data == null ? null : utf8.decode(data);
      final result = Map<String, dynamic>.from(meta);
      result['id'] = id;
      result['content'] = content ?? '';
      return result;
    } on FirebaseException catch (_) {
      // fallback to bundled asset
      try {
        final s = await rootBundle.loadString('assets/articles/$id.md');
        final metaList = await fetchArticleMetadata();
        final meta = metaList.firstWhere(
          (m) => m['id'] == id,
          orElse: () => <String, dynamic>{},
        );
        final result = Map<String, dynamic>.from(meta);
        result['id'] = id;
        result['content'] = s;
        return result;
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Seed articles into Storage: writes article markdown files and a generated index.json.
  /// Each map in [articles] should include at minimum an 'id' and may include metadata fields
  /// such as title, subtitle, author, readTime, category, and content (markdown string).
  Future<void> seedArticles(List<Map<String, dynamic>> articles) async {
    final index = <Map<String, dynamic>>[];
    for (final a in articles) {
      final id =
          a['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString();
      final meta = <String, dynamic>{};
      meta['id'] = id;
      for (final k in ['title', 'subtitle', 'author', 'readTime', 'category']) {
        if (a.containsKey(k)) meta[k] = a[k];
      }
      index.add(meta);

      // upload content if present
      if (a.containsKey('content')) {
        final content = a['content']?.toString() ?? '';
        final bytes = Uint8List.fromList(utf8.encode(content));
        final ref = _storage.ref('articles/$id.md');
        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'text/markdown'),
        );
      }
    }

    // upload index.json
    final idxRef = _storage.ref('articles/index.json');
    final idxBytes = Uint8List.fromList(utf8.encode(jsonEncode(index)));
    await idxRef.putData(
      idxBytes,
      SettableMetadata(contentType: 'application/json'),
    );
  }
}
