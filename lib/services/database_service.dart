import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Simple Realtime Database helper.
///
/// Notes:
/// - Make sure `Firebase.initializeApp()` is called (usually in `main.dart`) before
///   creating this service.
/// - If you need to target a specific database URL (for example if your project
///   uses a non-default Realtime Database instance), pass `databaseURL` to the
///   constructor.
class DatabaseService {
  final FirebaseDatabase _firebaseDatabase;

  DatabaseService({FirebaseDatabase? firebaseDatabase, String? databaseURL})
    : _firebaseDatabase =
          firebaseDatabase ??
          (databaseURL != null
              ? FirebaseDatabase.instanceFor(
                  app: Firebase.app(),
                  databaseURL: databaseURL,
                )
              : FirebaseDatabase.instance);

  /// Set data at [path]. This overwrites the node at [path].
  Future<void> set({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref(path);
    await ref.set(data);
  }

  /// Update specific children under [path] without overwriting the whole node.
  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref(path);
    await ref.update(data);
  }

  /// Push a new child under [path] and set [data]. Returns the created [DatabaseReference].
  Future<DatabaseReference> push({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference ref = _firebaseDatabase.ref(path).push();
    await ref.set(data);
    return ref;
  }

  /// Read the node at [path] once.
  Future<DatabaseEvent> readOnce(String path) async {
    final DatabaseReference ref = _firebaseDatabase.ref(path);
    return await ref.once();
  }

  /// Convenience to get a Map from [path] if present.
  Future<Map<String, dynamic>?> getMap(String path) async {
    final snapshot = await readOnce(path);
    final value = snapshot.snapshot.value;
    if (value == null) return null;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    // If it's a primitive, wrap it.
    return {'value': value};
  }

  /// Delete the node at [path].
  Future<void> delete(String path) async {
    final DatabaseReference ref = _firebaseDatabase.ref(path);
    await ref.remove();
  }

  /// Stream value changes at [path]. Subscribe to this to get realtime updates.
  Stream<DatabaseEvent> onValue(String path) {
    final DatabaseReference ref = _firebaseDatabase.ref(path);
    return ref.onValue;
  }
}
