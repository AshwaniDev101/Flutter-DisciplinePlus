import '../services/firebase_calories_service.dart';

/// Repository for daily calorie totals, using the repository pattern.
class CaloriesRepository {
  final FirebaseCaloriesService _service;

  CaloriesRepository(this._service);

  /// Stream the map of day→calories for a given [year] and [month].
  Stream<Map<int, int>> watchMonthly(int year, int month) {
    return _service.streamMonthlyCalories(year, month);
  }

  /// Fetch the full year’s data as a map of month→(day→calories).
  Future<Map<int, Map<int, int>>> fetchYear(int year) {
    return _service.fetchYearlyCalories(year);
  }

  /// One‐time fetch of a single month’s data.
  Future<Map<int, int>> fetchMonthly(int year, int month) {
    return _service.fetchMonthlyCalories(year, month);
  }

  /// Set or update the calories for a specific day.
  Future<void> setDay(
      int year,
      int month,
      int day,
      int calories,
      ) {
    return _service.setDayCalories(year, month, day, calories);
  }

  /// Delete the calories entry for a specific day.
  Future<void> deleteDay(int year, int month, int day) {
    return _service.deleteDayCalories(year, month, day);
  }
}
