

import 'package:discipline_plus/database/services/firebase_schedule_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../../database/repository/schedule_repository.dart';
import '../../../models/initiative.dart';
import '../core/current_day_manager.dart';

class ScheduleManager {
  ScheduleManager._internal();
  static final ScheduleManager _instance = ScheduleManager._internal();
  static ScheduleManager get instance => _instance;

  // Repository for CRUD operations
  final ScheduleRepository _scheduleRepository = ScheduleRepository(FirebaseScheduleService.instance);


// Local cache of the latest list for indexing
  List<Initiative> _latestSchedule = [];

  //final BehaviorSubject<List<Initiative>> _initiativesSubject = BehaviorSubject<List<Initiative>>.seeded(<Initiative>[]);


  final BehaviorSubject<String> _daySubject =
  BehaviorSubject<String>.seeded(CurrentDayManager.currentWeekDay);

  // Stream<List<Initiative>> watch() => _initiativesSubject.stream;


  // void bindToSchedule(String day) {
  //   _scheduleRepository.watchAll(day).listen((list) {
  //     _initiativesSubject.add(list);
  //     _latestSchedule = list;
  //   });
  // }





  late final Stream<List<Initiative>> schedule$ = _daySubject
      .distinct()
      .switchMap((day) {
    return _scheduleRepository
        .watchAll(day)
        .startWith(<Initiative>[]) // immediate empty list
        .map((list) {
      _latestSchedule = list; // update cache
      return list;
    });
  })
      .shareReplay(maxSize: 1);

  /// Change the day to listen to
  void changeDay(String newDay) {
    if (_daySubject.value != newDay) {
      _daySubject.add(newDay);
    }
  }

  Future<void> addInitiativeIn(String day, Initiative initiative) async {
    await _scheduleRepository.add(day, initiative);
  }

  Future<void> deleteInitiativeFrom(String day, String id) async {
    await _scheduleRepository.delete(day,id);

  }

  Future<void> updateInitiativeIn(String day, Initiative updated) async {
    await _scheduleRepository.update(day, updated.id, updated);
  }

  Initiative? getNextInitiativeFrom(int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= 0 && nextIndex < _latestSchedule.length) {
      return _latestSchedule[nextIndex];
    }
    return null;
  }

  int getNextIndex() {
    int listSize = _latestSchedule.length;
    if (listSize == 0) {
      return 0;
    } else {
      return listSize;
    }
  }

  int getLength() {
    return _latestSchedule.length;
  }

}