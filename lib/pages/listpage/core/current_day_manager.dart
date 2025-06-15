import 'package:intl/intl.dart';

class CurrentDayManager {

  CurrentDayManager._privateConstructor();
  static final CurrentDayManager _instance = CurrentDayManager._privateConstructor();
  factory CurrentDayManager() => _instance;


  static String currentWeekDay = DateFormat('EEEE').format(DateTime.now());

  static String getCurrentDay() => currentWeekDay;

  static void setWeekday(String weekDayName)
  {
    currentWeekDay = weekDayName;
  }
}
