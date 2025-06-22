import '../../models/heatmap_data.dart';
import '../services/firebase_heatmap_service.dart';

class FirebaseHeatmapRepository {
  final FirebaseHeatmapService _service;

  FirebaseHeatmapRepository(this._service);

  // Fetch heatmap data for a single activity
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

  // Add or update a single day in the heatmap
  Future<void> updateEntry({
    required String activityId,
    required int year,
    required int month,
    required int day,
    required dynamic value,
  }) async {
    await _service.updateEntry(
      activityId: activityId,
      year: year,
      month: month,
      day: day.toString(),
      value: value,
    );
  }

  // Update multiple days at once
  Future<void> updateEntries({
    required String activityId,
    required int year,
    required int month,
    required Map<int, dynamic> dayValues,
  }) async {
    final map = {for (var e in dayValues.entries) e.key.toString(): e.value};
    await _service.updateEntries(
      activityId: activityId,
      year: year,
      month: month,
      dayValues: map,
    );
  }

  // Fetch all heatmaps in a month
  Future<Map<String, Map<String, dynamic>>> getAllInMonth({
    required int year,
    required int month,
  }) async {
    return await _service.getAllHeatmapsInMonth(
      year: year,
      month: month,
    );
  }

  // Delete one heatmap
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

  // Batch update multiple activities
  Future<void> batchUpdateMultiple({
    required int year,
    required int month,
    required Map<String, Map<int, dynamic>> updates,
  }) async {
    final mapped = {
      for (var entry in updates.entries)
        entry.key: {
          for (var e in entry.value.entries) e.key.toString(): e.value
        }
    };
    await _service.batchUpdateMultipleActivities(
      year: year,
      month: month,
      updates: mapped,
    );
  }
}
