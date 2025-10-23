import '../services/firebase_heatmap_service.dart';

/// A repository for managing heatmap data.
/// This class provides a singleton instance to interact with the Firebase heatmap service.
class HeatmapRepository {
  final _service = FirebaseHeatmapService.instance;

  HeatmapRepository._internal();

  static final instance = HeatmapRepository._internal();

  /// Watches for changes in the heatmap data for a specific activity in a given month and year.
  /// Returns a stream of heatmap data.
  Stream<Map<String, dynamic>> watchHeatmap({
    required int year,
    required int month,
    required String activityId,
  }) {
    return _service.watchHeatmap(
      year: year,
      month: month,
      activityId: activityId,
    );
  }

  /// Watches for changes in all heatmaps for a given month and year.
  /// Returns a stream of all heatmap data.
  Stream<Map<String, Map<String, dynamic>>> watchAllHeatmapsInMonth({
    required int year,
    required int month,
  }) {
    return _service.watchAllHeatmapsInMonth(
      year: year,
      month: month,
    );
  }

  /// Retrieves the heatmap data for a specific activity in a given month and year.
  /// Returns a single snapshot of the heatmap data.
  Future<Map<String, dynamic>> getActivityHeatmap({
    required int year,
    required int month,
    required String activityId,
  }) async {
    return await _service.getHeatmap(
      year: year,
      month: month,
      activityId: activityId,
    );
  }

  /// Retrieves all heatmap data for a given month and year.
  /// Returns a single snapshot of all heatmap data.
  Future<Map<String, Map<String, dynamic>>> getAllInMonth({
    required int year,
    required int month,
  }) async {
    return await _service.getAllHeatmapsInMonth(
      year: year,
      month: month,
    );
  }

  /// Updates a single entry in the heatmap for a specific activity and date.
  Future<void> updateEntry({
    required String activityId,
    required DateTime date,
    required dynamic value,
  }) async {
    await _service.updateEntry(
      activityId: activityId,
      year: date.year,
      month: date.month,
      day: date.day.toString(),
      value: value,
    );
  }

  /// Updates multiple entries in the heatmap for a specific activity and month.
  Future<void> updateEntries({
    required String activityId,
    required int year,
    required int month,
    required Map<int, dynamic> dayHeatLevel,
  }) async {
    final map = {for (var e in dayHeatLevel.entries) e.key.toString(): e.value};
    await _service.updateEntries(
      activityId: activityId,
      year: year,
      month: month,
      dayValues: map,
    );
  }

  /// Overwrites the entire heatmap for a specific activity and month.
  Future<void> overwriteHeatmap({
    required String activityId,
    required int year,
    required int month,
    required Map<int, dynamic> dayHeatLevel,
  }) async {
    final data = {for (var entry in dayHeatLevel.entries) entry.key.toString(): entry.value};
    await _service.overwriteHeatmap(
      activityId: activityId,
      year: year,
      month: month,
      fullData: data,
    );
  }

  /// Updates multiple heatmaps for different activities in a single batch operation.
  Future<void> batchUpdateMultiple({
    required int year,
    required int month,
    required Map<String, Map<int, dynamic>> updates,
  }) async {
    final mapped = {
      for (var entry in updates.entries) entry.key: {for (var e in entry.value.entries) e.key.toString(): e.value}
    };
    await _service.batchUpdateMultipleActivities(
      year: year,
      month: month,
      updates: mapped,
    );
  }

  /// Deletes the heatmap for a specific activity and month.
  Future<void> delete({
    required String activityId,
    required int year,
    required int month,
  }) async {
    await _service.deleteHeatmap(
      activityId: activityId,
      year: year,
      month: month,
    );
  }

  /// Deletes all heatmaps for a given month.
  Future<void> deleteAllInMonth({
    required int year,
    required int month,
  }) async {
    await _service.deleteAllHeatmapsInMonth(
      year: year,
      month: month,
    );
  }
}
