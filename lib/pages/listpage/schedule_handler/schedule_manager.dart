

import 'package:discipline_plus/database/services/firebase_schedule_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../../database/repository/schedule_repository.dart';
import '../../../models/initiative.dart';
import 'schedule_day_controller.dart';
import 'schedule_helpers.dart';

/// The [ScheduleManager] is responsible for managing and streaming the initiatives
/// scheduled for each day of the week.
///
/// It maintains a local cache of daily initiatives for quick access and
/// exposes reactive streams that update whenever the active day changes or
/// the underlying data changes in the repository.
///
/// Key responsibilities:
/// - Fetch and stream initiatives for the currently selected day.
/// - Handle switching between weekdays seamlessly.
/// - Provide CRUD operations (add, update, delete) for initiatives.
/// - Compute utility data such as completion rate and next initiative.
///
/// Unlike [ScheduleCompletionManager], which tracks completion states globally,
/// this manager focuses on organizing and providing the daily schedule
/// in a reactive and easy-to-consume way.
///
/// Example usage:
/// ```dart
/// // Listen to initiatives for the current day
/// ScheduleManager.instance.schedule$.listen((initiatives) {
///   // initiatives are updated whenever the day changes or data updates
/// });
///
/// // Switch to another day
/// ScheduleManager.instance.changeDay('Monday');
///
/// // Access cached data
/// final next = ScheduleManager.instance.getNext(2);
/// ```
///
/// Think of this manager as the “daily planner” that organizes initiatives
/// and keeps them ready for UI consumption.

class ScheduleManager {
  ScheduleManager._internal();
  static final ScheduleManager _instance = ScheduleManager._internal();
  static ScheduleManager get instance => _instance;

  final _repository = ScheduleRepository(FirebaseScheduleService.instance);
  final _dayController = ScheduleDayController();

  List<Initiative> _cache = [];

  late final Stream<List<Initiative>> schedule$ = _dayController.day$
      .distinct()
      .switchMap((day) => _repository.watchAll(day))
      .map((list) {
    _cache = list;
    return list;
  })
      .shareReplay(maxSize: 1);

  // UnmodifiableListView<Initiative> get cache => UnmodifiableListView(_cache);



  // Switch active day
  void changeDay(String newDay) => _dayController.changeDay(newDay);

  // CRUD
  Future<void> addInitiativeIn(String day, Initiative ini) => _repository.add(day, ini);
  Future<void> update(String day, Initiative ini) => _repository.update(day, ini.id, ini);
  Future<void> deleteInitiativeFrom(String day, String id) => _repository.delete(day, id);


  // Utilities (delegated)
  // double get completionRate => ScheduleHelpers.calculateCompletion(_cache);
  Initiative? getNext(int index) => ScheduleHelpers.nextInitiative(_cache, index);
  int get length => _cache.length;
  String get currentDay => _dayController.currentDay;
}


