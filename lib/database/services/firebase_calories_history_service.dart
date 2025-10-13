import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../models/food_stats.dart';

/// A Firebase service for fetching user's calorie history.
///
/// This service is designed for structured Firestore data:
/// users/{userId}/history/{year}/{month}/{day}/foodStats
class FirebaseCaloriesHistoryService {
  // Singleton instance
  FirebaseCaloriesHistoryService._();
  static final instance = FirebaseCaloriesHistoryService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String _root = 'users';
  final String _userId = 'user1'; // TODO: Replace with dynamic user ID later.

  /// Fetches [FoodStats] for all days in a specific [year] and [month].
  ///
  /// Returns a map where the key is the day of the month and the value is [FoodStats].


  Future<Map<int, FoodStats>> getFoodStatsForMonth({
    required int year,
    required int month,
  }) async {
    final monthRef = _firestore
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(year.toString())
        .collection(month.toString());

    final snapshot = await monthRef.get();

    final Map<int, FoodStats> statsMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final day = int.tryParse(doc.id);

      if (day != null && data['foodStats'] != null) {
        try {
          statsMap[day] = FoodStats.fromMap(data['foodStats']);
        } catch (e) {

          debugPrint('Invalid foodStats data for day $day: $e');
        }
      }
    }

    final reversedMap = Map.fromEntries(
      statsMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return reversedMap;
  }

  /// Fetches all [FoodStats] for a given [year].
  ///
  /// Returns a nested map: `{ month: { day: FoodStats } }`.
  /// Only includes months that contain at least one valid entry.
  Future<Map<int, Map<int, FoodStats>>> getFoodStatsForYear({
    required int year,
  }) async {
    final yearRef = _firestore
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(year.toString());

    final Map<int, Map<int, FoodStats>> yearlyStats = {};

    // Run month fetches in parallel for efficiency
    final monthFutures = List.generate(12, (index) async {
      final month = index + 1;
      final monthRef = yearRef.collection(month.toString());
      final snapshot = await monthRef.get();

      final Map<int, FoodStats> monthMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final day = int.tryParse(doc.id);

        if (day != null && data['foodStats'] != null) {
          try {
            monthMap[day] = FoodStats.fromMap(data['foodStats']);
          } catch (_) {}
        }
      }

      if (monthMap.isNotEmpty) yearlyStats[month] = monthMap;
    });

    await Future.wait(monthFutures);
    return yearlyStats;
  }
}
