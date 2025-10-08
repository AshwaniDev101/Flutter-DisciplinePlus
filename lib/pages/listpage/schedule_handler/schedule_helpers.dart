import '../../../models/initiative.dart';

class ScheduleHelpers {
  static double calculateCompletion(List<Initiative> list) {
    if (list.isEmpty) return 0;
    final completed = list.where((e) => e.isComplete).length;
    return (completed / list.length) * 100;
  }

  static Initiative? nextInitiative(List<Initiative> list, int currentIndex) {
    final nextIndex = currentIndex + 1;
    return (nextIndex >= 0 && nextIndex < list.length)
        ? list[nextIndex]
        : null;
  }
}
