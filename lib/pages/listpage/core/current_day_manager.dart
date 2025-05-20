import 'package:intl/intl.dart';

class CurrentDayManager {

  CurrentDayManager._privateConstructor();
  static final CurrentDayManager _instance = CurrentDayManager._privateConstructor();
  factory CurrentDayManager() => _instance;


  static String currentWeekDay = DateFormat('EEEE').format(DateTime.now());

  // static int _currentIndex = 0;

  // static final List<String> days = [
  //   'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  // ];

  // static int length() => days.length;

  // static int getCurrentIndex() => _currentIndex;
  //
  // static void setIndex(int index) {
  //   if (index >= 0 && index < days.length) {
  //     _currentIndex = index;
  //   }
  // }



  // static void goLeft() {
  //   _currentIndex = (_currentIndex - 1 + days.length) % days.length;
  // }
  //
  // static void goRight() {
  //   _currentIndex = (_currentIndex + 1) % days.length;
  // }

  static String getCurrentDay() => currentWeekDay;

  static void setWeekday(String weekDayName)
  {
    currentWeekDay = weekDayName;
  }
}
