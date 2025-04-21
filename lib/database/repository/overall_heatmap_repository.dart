import '../../models/heatmap_data.dart';
import '../services/overall_heatmap/overall_heatmap_service.dart';

class OverallHeatmapRepository {
  final OverallHeatmapService _service;

  OverallHeatmapRepository(this._service);

  // Fetch overall heatmap data for a specific month and year
  Future<List<HeatmapData>> getOverallHeatmapData(int year, int month) async {
    return await _service.getMonthlyHeatmapData(year, month);
  }

  // Save or update overall heatmap data for a specific month and year
  Future<void> addOverallHeatmapData(HeatmapData data) async {
    await _service.saveHeatmapData(data);
  }

  // Update heatmap data for a specific day of the month
  Future<void> updateOverallHeatmapDataForDay(int year, int month, int day, int heatLevel) async {
    await _service.updateDailyHeatLevel(year, month, day, heatLevel);
  }

  // Fetch all heatmap data for a specific year (for all months)
  Future<List<HeatmapData>> getYearlyOverallHeatmapData(int year) async {
    return await _service.getYearlyHeatmapData(year);
  }
}
