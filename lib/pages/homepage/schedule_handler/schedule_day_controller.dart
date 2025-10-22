
import 'package:rxdart/rxdart.dart';
import '../../../managers/selected_day_manager.dart';


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
