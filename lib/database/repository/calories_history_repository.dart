import 'package:discipline_plus/models/food_stats.dart';
import '../../database/services/firebase_calories_history_service.dart';

/// Repository for calorie data
/// This abstracts Firebase and provides a single place to get data
class CaloriesHistoryRepository {
  // Singleton
  CaloriesHistoryRepository._();
  static final instance = CaloriesHistoryRepository._();

  final _firebaseService = FirebaseCaloriesHistoryService.instance;

  /// Get food stats for a specific month
  Future<Map<int, FoodStats>> getMonthStats({
    required int year,
    required int month,
  }) async {
    try {
      final data = await _firebaseService.getFoodStatsForMonth(
        year: year,
        month: month,
      );
      return data;
    } catch (e) {
      // Handle errors if needed, e.g., logging
      rethrow;
    }
  }

  /// Get food stats for a full year
  /// Returns a map of { month : { day : FoodStats } }
  Future<Map<int, Map<int, FoodStats>>> getYearStats({
    required int year,
  }) async {
    try {
      final data = await _firebaseService.getFoodStatsForYear(year: year);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  // /// Optional: get total calories for a month
  // Future<int> getTotalCaloriesForMonth({
  //   required int year,
  //   required int month,
  // }) async {
  //   final monthStats = await getMonthStats(year: year, month: month);
  //   return monthStats.values.fold(0, (sum, stat) => sum + stat.calories);
  // }

  // /// Optional: get average calories per day in a month
  // Future<double> getAverageCaloriesForMonth({
  //   required int year,
  //   required int month,
  // }) async {
  //   final monthStats = await getMonthStats(year: year, month: month);
  //   if (monthStats.isEmpty) return 0;
  //   final total = monthStats.values.fold(0, (sum, stat) => sum + stat.calories);
  //   return total / monthStats.length;
  // }
}
