// Enum representing the type of task.
enum TaskType {
  undertaking,
  initiative,
  shortBreak,
  longBreak,
}

// Common base class containing shared properties and logic.
abstract class BaseTask {
  final TaskType type;
  final AppTime dynamicTime;
  final String title;
  final AppTime completionTime;

  bool _isComplete = false; // Private backing field for isDone.

  BaseTask({
    required this.type,
    AppTime? dynamicTime,
    required this.title,
    required this.completionTime,
    bool isComplete = false,
  }) : dynamicTime = dynamicTime ?? AppTime(0, 0) {
    _isComplete = isComplete;
  }

  // Getter for isDone.
  bool get isComplete => _isComplete;

  // Setter for isDone.
  set isComplete(bool value) {
    // You can add custom logic here if needed.
    _isComplete = value;
  }
}

// Undertaking extends BaseTask and adds a list of initiatives.
class Undertaking extends BaseTask {
  List<BaseTask> basetask;

  Undertaking({
    AppTime? dynamicTime,
    required String title,
    required AppTime completionTime,
    required this.basetask,
    bool isComplete = false,
  }) : super(
    type: TaskType.undertaking,
    dynamicTime: dynamicTime,
    title: title,
    completionTime: completionTime,
    isComplete: isComplete,
  );

  /// Returns true if there is at least one initiative.
  bool hasInitiative() => basetask.isNotEmpty;
}

// Initiative also extends BaseTask.
class Initiative extends BaseTask {
  Initiative({
    AppTime? dynamicTime,
    required String title,
    required AppTime completionTime,
    bool isComplete = false,
  }) : super(
    type: TaskType.initiative,
    dynamicTime: dynamicTime,
    title: title,
    completionTime: completionTime,
    isComplete: isComplete,
  );
}

// Short break task.
class ShortBreak extends BaseTask {
  ShortBreak({
    AppTime? dynamicTime,
    bool isComplete = false,
  }) : super(
    type: TaskType.shortBreak,
    dynamicTime: dynamicTime,
    title: 'Short break',
    completionTime: AppTime(0, 15),
    isComplete: isComplete,
  );
}

// Long break task.
class LongBreak extends BaseTask {
  LongBreak({
    AppTime? dynamicTime,
    bool isComplete = false,
  }) : super(
    type: TaskType.longBreak,
    dynamicTime: dynamicTime,
    title: 'Long break',
    completionTime: AppTime(0, 30),
    isComplete: isComplete,
  );
}

// Represents a simple time structure with hour and minute.
class AppTime {
  final int hour;
  final int minute;

  const AppTime(this.hour, this.minute);

  // Helper method for formatting time as HH:MM
  String remainingTime() {
    if (hour == 0) {
      return "${minute}m";
    }
    if (minute == 0) {
      return "${hour}h";
    }
    return "${hour}h ${minute}m";
  }

  String getTime() {
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
  }
}
