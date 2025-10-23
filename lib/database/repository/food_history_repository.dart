import 'package:discipline_plus/models/food_stats.dart';
import '../../database/services/firebase_food_history_service.dart';
import '../../models/diet_food.dart';

/// Repository for calorie data
/// This abstracts Firebase and provides a single place to get data
class FoodHistoryRepository {

  final _service = FirebaseFoodHistoryService.instance;

  FoodHistoryRepository._internal();
  static final instance = FoodHistoryRepository._internal();


  /// Get food stats for a specific month
  Future<Map<int, FoodStats>> getMonthStats({
    required int year,
    required int month,
  }) async {
    try {
      final data = await _service.getFoodStatsForMonth(
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
      final data = await _service.getFoodStatsForYear(year: year);
      return data;
    } catch (e) {
      rethrow;
    }
  }


  /// Deletes a FoodStats document for the specified date.
  ///
  /// This function serves as an abstraction over the Firebase layer,
  /// ensuring that UI components or higher-level business logic do not
  /// directly depend on Firestore APIs. It can later be extended to
  /// include error handling, offline caching, or analytics tracking.
  Future<void> deleteFoodStats ({
    required DateTime cardDateTime,
  }) async {
    try {
      await _service.deleteFoodStats(
        cardDateTime: cardDateTime,
      );
    } catch (e) {
      // Centralized error logging can be added here in future (e.g., Sentry)
      rethrow; // Re-throw so higher layers can handle UI or user notifications
    }
  }


Stream<FoodStats?> watchConsumedFoodStats(DateTime date) {
  return _service.watchDietStatistics(date);
}


  Future<void> changeConsumedCount(double count ,DietFood food, DateTime date) {
    return _service.changeConsumedFoodCount(count,food, date);
  }




}
