
import '../../models/initiative.dart';
import '../services/firebase_weekly_schedule_service.dart';

class WeeklyScheduleRepository {
  final _service = FirebaseWeeklyScheduleService.instance;

  WeeklyScheduleRepository._internal();

  static final WeeklyScheduleRepository instance = WeeklyScheduleRepository._internal();

  /// Listen to all initiatives for a given [weekDayName]
  Stream<Map<String, InitiativeCompletion>> watchWeekDay(String weekDayName) {
    return _service.watchWeekDay(weekDayName);
  }

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
