import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/heatmap_data.dart';

class OverallHeatmapService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _overallHeatmapCollection =>
      _db.collection('overallHeatmap');

  /// Save or update daily heatmap data for a specific month
  Future<void> saveHeatmapData(HeatmapData data) async {
    try {
      await _overallHeatmapCollection
          .doc('${data.year}-${data.month}')
          .set({
        'year': data.year,
        'month': data.month,
        'days': {
          '${data.date}': data.heatLevel
        },
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save heatmap data: $e');
    }
  }

  /// Fetch all daily heatmap data for a specific month
  Future<List<HeatmapData>> getMonthlyHeatmapData(int year, int month) async {
    try {
      DocumentSnapshot doc = await _overallHeatmapCollection
          .doc('$year-$month')
          .get();

      if (!doc.exists) return [];

      final data = doc.data() as Map<String, dynamic>;
      final days = data['days'] as Map<String, dynamic>? ?? {};

      return days.entries.map((entry) => HeatmapData(
        year: year,
        month: month,
        date: int.parse(entry.key),
        heatLevel: entry.value as int,
      )).toList();
    } catch (e) {
      throw Exception('Failed to fetch monthly heatmap data: $e');
    }
  }

  /// Fetch yearly heatmap data (all months in a year)
  Future<List<HeatmapData>> getYearlyHeatmapData(int year) async {
    try {
      final querySnapshot = await _overallHeatmapCollection
          .where('year', isEqualTo: year)
          .get();

      return querySnapshot.docs.expand((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final days = data['days'] as Map<String, dynamic>? ?? {};
        final month = data['month'] as int;

        return days.entries.map((entry) => HeatmapData(
          year: year,
          month: month,
          date: int.parse(entry.key),
          heatLevel: entry.value as int,
        ));
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch yearly heatmap data: $e');
    }
  }

  /// Update specific day's heat level in a month
  Future<void> updateDailyHeatLevel(int year, int month, int date, int heatLevel) async {
    try {
      await _overallHeatmapCollection
          .doc('$year-$month')
          .update({
        'days.$date': heatLevel,
        'year': year,  // Maintain year in case doc is new
        'month': month, // Maintain month in case doc is new
      });
    } catch (e) {
      throw Exception('Failed to update daily heat level: $e');
    }
  }
}