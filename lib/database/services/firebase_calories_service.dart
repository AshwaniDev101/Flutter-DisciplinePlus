import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseCaloriesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1';

  // Singleton
  FirebaseCaloriesService._();
  static final instance = FirebaseCaloriesService._();

  /// Reference to the “history” sub-collection under this user.
  CollectionReference<Map<String, dynamic>> get _historyCollection =>
      _db.collection(_root).doc(_userId).collection('history');

  /// Reference to the calories_list document for a given [year] and [month].
  DocumentReference<Map<String, dynamic>> _caloriesDoc(int year, int month) {
    final y = year.toString();
    final m = month.toString();
    return _historyCollection
        .doc(y)
        .collection(m)
        .doc('calories_list');
  }

  /// Streams a `Map<day, calories>` for the given [year] and [month].
  Stream<Map<int, int>> streamMonthlyCalories(int year, int month) {
    return _caloriesDoc(year, month)
        .snapshots()
        .map((snap) {
      final data = snap.data();
      if (data == null) return <int, int>{};
      // convert keys ("01", "02", …) to int
      return data.map((k, v) =>
          MapEntry(int.parse(k), (v as num).toInt())
      );
    });
  }

  /// Fetches the full year’s calories as a map:
  /// { 1: {1:1600, 2:1700, …}, 2: {1:1500, …}, …, 12: {…} }
  Future<Map<int, Map<int, int>>> fetchYearlyCalories(int year) async {
    final result = <int, Map<int, int>>{};
    // iterate through all 12 months
    for (var month = 1; month <= 12; month++) {
      // reuse your fetchMonthlyCalories helper
      final monthly = await fetchMonthlyCalories(year, month);
      // if the month doc doesn’t exist or is empty, monthly will be {}
      result[month] = monthly;
    }
    return result;
  }

  /// Sets or updates the calories for a specific [day] in [year]/[month].
  Future<void> setDayCalories(int year, int month, int day, int calories) {
    final key = day.toString();
    return _caloriesDoc(year, month)
        .set({ key: calories }, SetOptions(merge: true));
  }

  /// Deletes the entry for a specific [day].
  Future<void> deleteDayCalories(int year, int month, int day) {
    final key = day.toString();
    return _caloriesDoc(year, month)
        .update({ key: FieldValue.delete() });
  }

  /// One‐time fetch of the month’s map (no real‐time updates).
  Future<Map<int, int>> fetchMonthlyCalories(int year, int month) async {
    final snap = await _caloriesDoc(year, month).get();
    final data = snap.data();
    if (data == null) return <int, int>{};
    return data.map((k, v) =>
        MapEntry(int.parse(k), (v as num).toInt())
    );
  }
}
