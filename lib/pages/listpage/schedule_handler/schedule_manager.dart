
import 'package:discipline_plus/database/services/firebase_schedule_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../../database/repository/schedule_repository.dart';
import '../../../models/initiative.dart';
import 'schedule_day_controller.dart';
import 'schedule_helpers.dart';

/// Controls and streams initiatives for the selected day.
/// Keeps the latest data cached for quick access.
/// This handles all the initiative Lists of all week days (sun, mon, tue, wed, thu, fri, sat)
/// This manager help in switching between days

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

  // Switch active day
  void changeDay(String newDay) => _dayController.changeDay(newDay);

  // CRUD
  Future<void> addInitiativeIn(String day, Initiative ini) => _repository.add(day, ini);
  Future<void> update(String day, Initiative ini) => _repository.update(day, ini.id, ini);
  Future<void> deleteInitiativeFrom(String day, String id) => _repository.delete(day, id);

  // Utilities (delegated)
  double get completionRate => ScheduleHelpers.calculateCompletion(_cache);
  Initiative? getNext(int index) => ScheduleHelpers.nextInitiative(_cache, index);
  int get length => _cache.length;
}


