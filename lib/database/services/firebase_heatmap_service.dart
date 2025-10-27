import 'package:cloud_firestore/cloud_firestore.dart';

/// A unified service to manage dynamic heatmaps (e.g., diet, workout, mood)
/// stored under: users/{userId}/heatmap/{year}/{month}/{heatmapID}
class FirebaseHeatmapService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String userId = 'user1';

  // Private constructor for instances
  FirebaseHeatmapService._();

  /// Get an instance scoped to a specific user
  static final instance = FirebaseHeatmapService._();

  /// Reference to a single activity's heatmap document
  DocumentReference<Map<String, dynamic>> _heatmapDoc({
    required DateTime date,
    required String heatmapID,
  }) {
    return _db
        .collection(_root)
        .doc(userId)
        .collection('heatmap')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc(heatmapID);
  }

  /// Reference to the collection of all activity heatmaps in a month
  CollectionReference<Map<String, dynamic>> _monthCollection({
    required DateTime date,
  }) {
    return _db
        .collection(_root)
        .doc(userId)
        .collection('heatmap')
        .doc('${date.year}')
        .collection('${date.month}');
  }

  /// ----------------------------------------------------------------------
  /// WATCHERS
  /// ----------------------------------------------------------------------

  /// Stream a single activity's heatmap (day->value map)
  Stream<Map<String, dynamic>> watchHeatmap({
    required DateTime date,
    required String heatmapID,
  }) {
    return _heatmapDoc(date: date, heatmapID: heatmapID)
        .snapshots()
        .map((snap) => snap.data() ?? <String, dynamic>{});
  }

  /// Stream all activity heatmaps for a month
  /// Returns a map: { heatmapID: { day: value, ... }, ... }
  Stream<Map<String, Map<String, dynamic>>> watchAllHeatmapsInMonth({
    required DateTime date,
  }) {
    return _monthCollection(date:date)
        .snapshots()
        .map((snap) {
      final result = <String, Map<String, dynamic>>{};
      for (var doc in snap.docs) {
        result[doc.id] = doc.data();
      }
      return result;
    });
  }

  /// ----------------------------------------------------------------------
  /// GETTERS
  /// ----------------------------------------------------------------------

  /// Fetch a single heatmap once
  Future<Map<String, dynamic>> getHeatmap({
    required DateTime date,
    required String heatmapID,
  }) async {
    final snap = await _heatmapDoc(date:date, heatmapID: heatmapID).get();
    return snap.data() ?? <String, dynamic>{};
  }

  /// Fetch all heatmaps in a month once
  Future<Map<String, Map<String, dynamic>>> getAllHeatmapsInMonth({
    required DateTime date,
  }) async {
    final snap = await _monthCollection(date:date).get();
    final result = <String, Map<String, dynamic>>{};
    for (var doc in snap.docs) {
      result[doc.id] = doc.data();
    }
    return result;
  }

  /// ----------------------------------------------------------------------
  /// UPDATES
  /// ----------------------------------------------------------------------

  /// Update or insert a single day entry in an activity heatmap
  Future<void> updateEntry({
    required String heatmapID,
    required DateTime date,
    required String day,
    required dynamic value,
  }) async {
    await _heatmapDoc(date:date, heatmapID: heatmapID)
        .set({day: value}, SetOptions(merge: true));
  }

  /// Update multiple days at once for an activity
  Future<void> updateEntries({
    required String heatmapID,
    required DateTime date,
    required Map<String, dynamic> dayValues,
  }) async {
    await _heatmapDoc(date:date, heatmapID: heatmapID)
        .set(dayValues, SetOptions(merge: true));
  }

  /// Overwrite the entire heatmap document for an activity, which mean deleting the old doc all together
  Future<void> overwriteHeatmap({
    required String heatmapID,
    required DateTime date,
    required Map<String, dynamic> fullData,
  }) async {
    await _heatmapDoc(date:date, heatmapID: heatmapID)
        .set(fullData, SetOptions(merge: false));
  }

  /// ----------------------------------------------------------------------
  /// DELETIONS
  /// ----------------------------------------------------------------------

  /// Delete a single activity heatmap
  Future<void> deleteHeatmap({
    required String heatmapID,
    required DateTime date,
  }) async {
    await _heatmapDoc(date:date, heatmapID: heatmapID)
        .delete();
  }

  /// Delete all activity heatmaps for a month (batch)
  Future<void> deleteAllHeatmapsInMonth({
    required DateTime date,
  }) async {
    final batch = _db.batch();
    final snap = await _monthCollection(date:date).get();
    for (var doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  /// ----------------------------------------------------------------------
  /// EXTRA/BATCH OPERATIONS
  /// ----------------------------------------------------------------------

  /// Batch-update multiple activity heatmaps in one commit
  Future<void> batchUpdateMultipleActivities({
    required DateTime date,
    required Map<String, Map<String, dynamic>> updates,
  }) async {
    final batch = _db.batch();
    updates.forEach((heatmapID, dayValues) {
      final ref = _heatmapDoc(date:date, heatmapID: heatmapID);
      batch.set(ref, dayValues, SetOptions(merge: true));
    });
    await batch.commit();
  }
}
