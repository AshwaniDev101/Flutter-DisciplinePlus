// Represents a simple time structure with hour and minute.
class AppTime {
  final int hour;
  final int minute;

  const AppTime(this.hour, this.minute);

  // Helper method for formatting time as HH:MM
  String remainingTime() {
    if (hour == 0) return "${minute}m";
    if (minute == 0) return "${hour}h";
    return "${hour}h ${minute}m";
  }

  String getTime() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }

  bool get isZero => hour == 0 && minute == 0;
}

// Common base class containing shared properties and logic.
abstract class BaseInitiative {
  final AppTime dynamicTime;
  final String title;
  final AppTime completionTime;

  bool _isComplete = false;

  BaseInitiative({
    AppTime? dynamicTime,
    required this.title,
    required this.completionTime,
    bool isComplete = false,
  }) : dynamicTime = dynamicTime ?? const AppTime(0, 0) {
    _isComplete = isComplete;
  }

  bool get isComplete => _isComplete;
  bool get isNotComplete => !_isComplete;

  set isComplete(bool value) {
    _isComplete = value;
  }
}

class InitiativeGroup extends BaseInitiative {
  final List<Initiative> initiativeList;

  InitiativeGroup({
    AppTime? dynamicTime,
    required String title,
    required this.initiativeList,
    bool isComplete = false,
  }) : super(
    dynamicTime: dynamicTime,
    title: title,
    completionTime: _calculateCompletionTime(initiativeList),
    isComplete: isComplete,
  );

  static AppTime _calculateCompletionTime(List<Initiative> initiatives) {
    int totalMinutes = initiatives.fold(0, (sum, e) {
      return sum + e.completionTime.hour * 60 + e.completionTime.minute;
    });
    return AppTime(totalMinutes ~/ 60, totalMinutes % 60);
  }

  bool hasInitiatives() => initiativeList.isNotEmpty;
  bool hasNoInitiatives() => initiativeList.isEmpty;
}

// Initiative = actual user task
class Initiative extends BaseInitiative {
  final StudyBreak studyBreak;

  Initiative({
    AppTime? dynamicTime,
    required String title,
    required AppTime completionTime,
    this.studyBreak = const ShortBreak(),
    bool isComplete = false,
  }) : super(
    dynamicTime: dynamicTime,
    title: title,
    completionTime: completionTime,
    isComplete: isComplete,
  );

  String get type=> studyBreak.title;

  // bool get hasBreak => !breakTime.isZero;
}


abstract class StudyBreak {
  final String title;
  final AppTime completionTime;

  const StudyBreak({
    this.title = 'Break',
    this.completionTime = const AppTime(0, 5),
  });
}

// Represents a short break.
class ShortBreak extends StudyBreak {
  const ShortBreak() : super(title: 'Short break', completionTime: const AppTime(0, 1));
}

// Represents a long break.
class LongBreak extends StudyBreak {
  const LongBreak() : super(title: 'Long break', completionTime: const AppTime(0, 2));
}