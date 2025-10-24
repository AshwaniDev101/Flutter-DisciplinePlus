


import 'package:rxdart/rxdart.dart';
import '../../../../database/repository/weekly_schedule_repository.dart';
import '../../../../managers/selected_day_manager.dart';
import '../../../../models/initiative.dart';


/// The [ScheduleManager] is responsible for managing and streaming the initiatives
/// scheduled for each day of the week.

class ScheduleManager {
  ScheduleManager._internal();
  static final ScheduleManager _instance = ScheduleManager._internal();
  static ScheduleManager get instance => _instance;

  final _repository = WeeklyScheduleRepository.instance;
  final _dayController = ScheduleDayController();

  Map<String, InitiativeCompletion> _cache = {};

  late final Stream<Map<String, InitiativeCompletion>> schedule$ = _dayController.day$
      .distinct()
      .switchMap((day) => _repository.watchDay(day))
      .map((list) {
    _cache = list;
    return list;
  })
      .shareReplay(maxSize: 1);

  // UnmodifiableListView<Initiative> get cache => UnmodifiableListView(_cache);



  // Switch active day
  void changeDay(String newDay) => _dayController.changeDay(newDay);

  // CRUD
  Future<void> addInitiativeIn(String weekDayName, String initiativeID) => _repository.add(weekDayName, initiativeID);
  // Future<void> update(String weekDayName, Initiative ini) => _repository.update(weekDayName, ini.id, ini);
  Future<void> deleteInitiativeFrom(String weekDayName, String id) => _repository.delete(weekDayName, id);


  // Utilities (delegated)
  // double get completionRate => ScheduleHelpers.calculateCompletion(_cache);
  // Initiative? getNext(int index) => ScheduleHelpers.nextInitiative(_cache, index);
  int get length => _cache.length;
  String get currentDay => _dayController.currentDay;
}

class ScheduleDayController {

  // Create a stream (_daySubject) that starts with the current weekday string (e.g., "Thursday").
  final BehaviorSubject<String> _daySubject =
  BehaviorSubject.seeded(SelectedDayManager.currentSelectedWeekDay.value);

  Stream<String> get day$ => _daySubject.stream;
  String get currentDay => _daySubject.value;

  void changeDay(String newDay) {
    if (_daySubject.value != newDay) {
      _daySubject.add(newDay);
    }
  }
}



