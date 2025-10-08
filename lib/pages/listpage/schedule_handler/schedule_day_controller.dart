
import 'package:rxdart/rxdart.dart';

import '../../managers/current_day_manager.dart';

class ScheduleDayController {
  final BehaviorSubject<String> _daySubject =
  BehaviorSubject.seeded(CurrentDayManager.currentWeekDay);

  Stream<String> get day$ => _daySubject.stream;
  String get currentDay => _daySubject.value;

  void changeDay(String newDay) {
    if (_daySubject.value != newDay) {
      _daySubject.add(newDay);
    }
  }
}
