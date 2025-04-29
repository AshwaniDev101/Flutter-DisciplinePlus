// lib/repositories/week_repository.dart

import '../../models/initiative.dart';
import '../services/week_service/firebase_week_service.dart';


class WeekRepository {
  final FirebaseWeekService _service;

  WeekRepository(this._service);

  /// Listen to all initiatives for a given [day]
  Stream<List<Initiative>> watchInitiatives(String day) {
    return _service.streamForDay(day);
  }

  /// Fetch current snapshot (one-time) for [day]
  Future<List<Initiative>> fetchInitiatives(String day) {
    return _service.streamForDay(day).first;
  }

  /// Add a new initiative to [day]
  Future<void> addInitiative(String day, Initiative ini) {
    return _service.addInitiative(day, ini);
  }

  /// Update an existing initiative in [day]
  Future<void> updateInitiative(String day, Initiative ini) {
    return _service.updateInitiative(day, ini);
  }

  /// Delete initiative by [id] from [day]
  Future<void> removeInitiative(String day, String id) {
    return _service.deleteInitiative(day, id);
  }

  /// Mark an initiative complete/incomplete on [day]
  Future<void> markComplete(String day, Initiative ini, bool isComplete) {
    ini.isComplete = isComplete;
    return _service.updateInitiative(day, ini);
  }

  /// Reorder the list under [day] by updating each Initiative.index
  Future<void> reorderDayList(String day, List<Initiative> list) {
    return _service.reorderDayList(day, list);
  }
}
