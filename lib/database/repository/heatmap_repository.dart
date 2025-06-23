import '../../models/heatmap_data.dart';
import '../services/firebase_heatmap_service.dart';

class HeatmapRepository {
  final FirebaseHeatmapService _service;

  HeatmapRepository(this._service);

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

  Stream<Map<String, Map<String, dynamic>>> watchAllHeatmapsInMonth({
    required int year,
    required int month,
  }) {
    return _service.watchAllHeatmapsInMonth(
      year: year,
      month: month,
    );
  }

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

  Future<Map<String, Map<String, dynamic>>> getAllInMonth({
    required int year,
    required int month,
  }) async {
    return await _service.getAllHeatmapsInMonth(
      year: year,
      month: month,
    );
  }

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

  Future<void> overwriteHeatmap({
    required String activityId,
    required int year,
    required int month,
    required Map<int, dynamic> dayHeatLevel,
  }) async {
    final data = {
      for (var entry in dayHeatLevel.entries) entry.key.toString(): entry.value
    };
    await _service.overwriteHeatmap(
      activityId: activityId,
      year: year,
      month: month,
      fullData: data,
    );
  }

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

  Future<void> deleteAllInMonth({
    required int year,
    required int month,
  }) async {
    await _service.deleteAllHeatmapsInMonth(
      year: year,
      month: month,
    );
  }

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