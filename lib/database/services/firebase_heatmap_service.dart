import 'package:cloud_firestore/cloud_firestore.dart';

/// A unified service to manage dynamic heatmaps (e.g., diet, workout, mood)
/// stored under: users/{userId}/heatmap/{year}/{month}/{activityId}
class FirebaseHeatmapService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String userId;

  // Private constructor for instances
  FirebaseHeatmapService._(this.userId);

  /// Get an instance scoped to a specific user
  static FirebaseHeatmapService instance(String userId) => FirebaseHeatmapService._(userId);

  /// Reference to a single activity's heatmap document
  DocumentReference<Map<String, dynamic>> _heatmapDoc({
    required int year,
    required int month,
    required String activityId,
  }) {
    return _db
        .collection(_root)
        .doc(userId)
        .collection('heatmap')
        .doc('$year')
        .collection('$month')
        .doc(activityId);
  }

  /// Reference to the collection of all activity heatmaps in a month
  CollectionReference<Map<String, dynamic>> _monthCollection({
    required int year,
    required int month,
  }) {
    return _db
        .collection(_root)
        .doc(userId)
        .collection('heatmap')
        .doc('$year')
        .collection('$month');
  }

  /// ----------------------------------------------------------------------
  /// WATCHERS
  /// ----------------------------------------------------------------------

  /// Stream a single activity's heatmap (day->value map)
  Stream<Map<String, dynamic>> watchHeatmap({
    required int year,
    required int month,
    required String activityId,
  }) {
    return _heatmapDoc(year: year, month: month, activityId: activityId)
        .snapshots()
        .map((snap) => snap.data() ?? <String, dynamic>{});
  }

  /// Stream all activity heatmaps for a month
  /// Returns a map: { activityId: { day: value, ... }, ... }
  Stream<Map<String, Map<String, dynamic>>> watchAllHeatmapsInMonth({
    required int year,
    required int month,
  }) {
    return _monthCollection(year: year, month: month)
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
    required int year,
    required int month,
    required String activityId,
  }) async {
    final snap = await _heatmapDoc(year: year, month: month, activityId: activityId).get();
    return snap.data() ?? <String, dynamic>{};
  }

  /// Fetch all heatmaps in a month once
  Future<Map<String, Map<String, dynamic>>> getAllHeatmapsInMonth({
    required int year,
    required int month,
  }) async {
    final snap = await _monthCollection(year: year, month: month).get();
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
    required String activityId,
    required int year,
    required int month,
    required String day,
    required dynamic value,
  }) async {
    await _heatmapDoc(year: year, month: month, activityId: activityId)
        .set({day: value}, SetOptions(merge: true));
  }

  /// Update multiple days at once for an activity
  Future<void> updateEntries({
    required String activityId,
    required int year,
    required int month,
    required Map<String, dynamic> dayValues,
  }) async {
    await _heatmapDoc(year: year, month: month, activityId: activityId)
        .set(dayValues, SetOptions(merge: true));
  }

  /// Overwrite the entire heatmap document for an activity
  Future<void> overwriteHeatmap({
    required String activityId,
    required int year,
    required int month,
    required Map<String, dynamic> fullData,
  }) async {
    await _heatmapDoc(year: year, month: month, activityId: activityId)
        .set(fullData, SetOptions(merge: false));
  }

  /// ----------------------------------------------------------------------
  /// DELETIONS
  /// ----------------------------------------------------------------------

  /// Delete a single activity heatmap
  Future<void> deleteHeatmap({
    required String activityId,
    required int year,
    required int month,
  }) async {
    await _heatmapDoc(year: year, month: month, activityId: activityId)
        .delete();
  }

  /// Delete all activity heatmaps for a month (batch)
  Future<void> deleteAllHeatmapsInMonth({
    required int year,
    required int month,
  }) async {
    final batch = _db.batch();
    final snap = await _monthCollection(year: year, month: month).get();
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
    required int year,
    required int month,
    required Map<String, Map<String, dynamic>> updates,
  }) async {
    final batch = _db.batch();
    updates.forEach((activityId, dayValues) {
      final ref = _heatmapDoc(year: year, month: month, activityId: activityId);
      batch.set(ref, dayValues, SetOptions(merge: true));
    });
    await batch.commit();
  }
}
