// lib/repositories/week_repository.dart

import '../../models/initiative.dart';
import '../services/firebase_week_service.dart';


class ScheduleRepository {
  final FirebaseWeekService _service;

  ScheduleRepository(this._service);

  /// Listen to all initiatives for a given [day]
  Stream<List<Initiative>> watchAll(String day) {
    return _service.streamForDay(day);
  }

  /// Fetch current snapshot (one-time) for [day]
  Future<List<Initiative>> fetchInitiatives(String day) {
    return _service.streamForDay(day).first;
  }

  /// Add a new initiative to [day]
  Future<void> add(String day, Initiative ini) {
    return _service.addInitiative(day, ini);
  }

  /// Delete initiative by [id] from [day]
  Future<void> remove(String day, String id) {
    return _service.deleteInitiative(day, id);
  }

  /// Update an existing initiative in [day]
  Future<void> update(String day, String id, Initiative ini) {
    return _service.updateInitiative(day, id, ini);
  }

  /// Mark an initiative complete/incomplete on [day]
  Future<void> markComplete(String day, String id, Initiative ini, bool isComplete) {
    ini.isComplete = isComplete;
    return _service.updateInitiative(day, id, ini);
  }

  /// Reorder the list under [day] by updating each Initiative.index
  Future<void> reorderDayList(String day, List<Initiative> list) {
    return _service.reorderDayList(day, list);
  }
}
