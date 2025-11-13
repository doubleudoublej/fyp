import 'package:firebase_database/firebase_database.dart';
import 'database_service.dart';

class ForumService {
  final DatabaseService _db;

  ForumService({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService();

  /// Stream of all forum posts under /forum/posts
  Stream<DatabaseEvent> postsStream() => _db.onValue('forum/posts');

  /// Create a new post. Returns the new post key.
  Future<String> createPost({
    required String authorUid,
    required String author,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now().toUtc();
    final data = {
      'authorUid': authorUid,
      'author': author,
      'title': title,
      'content': content,
      'timestamp': now.toIso8601String(),
    };
    final ref = await _db.push(path: 'forum/posts', data: data);
    return ref.key!;
  }

  /// Add a comment to a post
  Future<void> addComment({
    required String postId,
    required String authorUid,
    required String author,
    required String content,
  }) async {
    final now = DateTime.now().toUtc();
    final data = {
      'authorUid': authorUid,
      'author': author,
      'content': content,
      'timestamp': now.toIso8601String(),
    };
    await _db.push(path: 'forum/posts/$postId/comments', data: data);
  }

  /// Convenience to convert a DB timestamp to friendly string
  static String timeAgoFromIso(String iso) {
    try {
      final t = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(t);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }
}
