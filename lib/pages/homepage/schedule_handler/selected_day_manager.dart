import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class SelectedDayManager {

  SelectedDayManager._();


  // All days in order
  static const List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  static final ValueNotifier<String> _current =
  ValueNotifier(DateFormat('EEEE').format(DateTime.now()));



  // Read-only for consumers
  static ValueListenable<String> get currentSelectedWeekDay => _current;

  static void setCurrentSelectedDay(String day) {
    if (!_days.contains(day)) return;
    if (_current.value == day) return;
    _current.value = day;
  }

  static void toNextDay() {
    final index = _days.indexOf(_current.value);
    if (index == -1) {
      _current.value = DateFormat('EEEE').format(DateTime.now());
      return;
    }
    final next = _days[(index + 1) % _days.length]; // wraps safely
    _current.value = next;
  }

  static void toPreviousDay() {
    final index = _days.indexOf(_current.value);
    if (index == -1) {
      _current.value = DateFormat('EEEE').format(DateTime.now());
      return;
    }
    final prev = _days[(index - 1 + _days.length) % _days.length]; // wraps safely
    _current.value = prev;
  }
}

