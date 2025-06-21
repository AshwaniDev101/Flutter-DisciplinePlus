

import 'package:discipline_plus/database/services/firebase_schedule_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../../database/repository/schedule_repository.dart';
import '../../../models/initiative.dart';

class ScheduleManager {
  ScheduleManager._internal();
  static final ScheduleManager _instance = ScheduleManager._internal();
  static ScheduleManager get instance => _instance;


  // final WeekRepository _weekRepository = WeekRepository(FirebaseWeekService.instance);
  final ScheduleRepository _scheduleRepository = ScheduleRepository(FirebaseScheduleService.instance);


  List<Initiative> _latestSchedule = [];



  final BehaviorSubject<List<Initiative>> _initiativesSubject = BehaviorSubject();

  void bindToInitiatives(String day) {
    _scheduleRepository.watchAll(day).listen((list) {
      _initiativesSubject.add(list);
      _latestSchedule = list;
    });
  }


  Stream<List<Initiative>> watchInitiatives() => _initiativesSubject.stream;


  void bindInitiativeStream(Stream<List<Initiative>> stream) {
    stream.listen((data) {
      _latestSchedule = data;
    });
  }


  Future<void> addInitiative(String day, Initiative initiative) async {
    await _scheduleRepository.add(day, initiative);
  }

  Future<void> removeInitiative(String day, String id) async {
    await _scheduleRepository.delete(day,id);

  }

  Future<void> updateInitiative(String day, Initiative updated) async {
    await _scheduleRepository.update(day, updated.id, updated);
  }

  Initiative? getNextInitiative(int currentIndex) {
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