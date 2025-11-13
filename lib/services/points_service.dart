import 'database_service.dart';

/// Simple wrapper to manage wellness points in Realtime Database.
///
/// Stores points under `users/{uid}/points` as a numeric value.
class PointsService {
  final DatabaseService _db;

  PointsService({DatabaseService? db}) : _db = db ?? DatabaseService();

  /// Stream the integer points value for [uid]. Emits 0 if no value present.
  Stream<int> pointsStream(String uid) {
    return _db.onValue('users/$uid/points').map((event) {
      final v = event.snapshot.value;
      if (v == null) return 0;
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      if (v is double) return v.toInt();
      return 0;
    });
  }

  /// Read points once.
  Future<int> getPoints(String uid) async {
    final ev = await _db.readOnce('users/$uid/points');
    final v = ev.snapshot.value;
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is double) return v.toInt();
    return 0;
  }

  /// Set points (overwrite).
  Future<void> setPoints(String uid, int points) async {
    // write as child value
    await _db.update(path: 'users/$uid', data: {'points': points});
  }

  /// Add delta to points (read-modify-write). Not transactional but fine for
  /// simple use. Could be improved with transactions if needed.
  Future<void> addPoints(String uid, int delta) async {
    final current = await getPoints(uid);
    await setPoints(uid, current + delta);
  }
}
