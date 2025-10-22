// lib/repositories/weekly_schedule_repository.dart

import '../../models/initiative.dart';
import '../services/firebase_weekly_schedule_service.dart';


class WeeklyScheduleRepository {
  final FirebaseWeeklyScheduleService _service = FirebaseWeeklyScheduleService.instance;

  WeeklyScheduleRepository._internal();
  static final WeeklyScheduleRepository instance = WeeklyScheduleRepository._internal();


  /// Listen to all initiatives for a given [day]
  Stream <Map<String, InitiativeCompletion>> watchDay(String day) {
    return _service.watchDay(day);
  }

  // /// Fetch current snapshot (one-time) for [day]
  // Future<List<Initiative>> fetchInitiatives(String day) {
  //   return _service.watchDay(day).first;
  // }

  /// Add a new initiative to [day]
  Future<void> add(String day, String initiativeID) {
    return _service.addInitiative(day, initiativeID);
  }

  /// Delete initiative by [id] from [day]
  Future<void> delete(String day, String id) {
    return _service.deleteInitiative(day, id);
  }

  /// Update an existing initiative in [day]
  Future<void> completeInitiative(String day, String initiativeID, bool isComplete) {
    return _service.completeInitiative(day, initiativeID, isComplete);
  }

  /// Reorder the list under [day] by updating each Initiative.index
  Future<void> reorderDayList(String day, List<Initiative> list) {
    return _service.reorderDayList(day, list);
  }
}
