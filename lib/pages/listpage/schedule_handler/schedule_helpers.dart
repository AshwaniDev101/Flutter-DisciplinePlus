import '../../../models/initiative.dart';

class ScheduleHelpers {

  static Initiative? nextInitiative(List<Initiative> list, int currentIndex) {
    final nextIndex = currentIndex + 1;
    return (nextIndex >= 0 && nextIndex < list.length)
        ? list[nextIndex]
        : null;
  }
}
