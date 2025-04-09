// Common base class containing shared properties and logic.
abstract class BaseTask {
  AppTime dynamicTime;
  String title;
  AppTime completionTime;

  bool _isDone = false; // Private backing field for isDone.

  BaseTask({
    required this.dynamicTime,
    required this.title,
    required this.completionTime,
    bool isDone = false,
  }) {
    _isDone = isDone;
  }

  // Getter for isDone.
  bool get isDone => _isDone;

  // Setter for isDone.
  set isDone(bool value) {
    // You can add custom logic here if needed.
    _isDone = value;
  }
}

// Undertaking extends BaseTask and adds a list of initiatives.
class Undertaking extends BaseTask {
  List<Initiative> initiatives;

  Undertaking({
    required super.dynamicTime,
    required super.title,
    required super.completionTime,
    required this.initiatives,
    super.isDone,
  });

  /// Returns true if there is at least one initiative.
  bool hasInitiative() => initiatives.isNotEmpty;
}

// Initiative also extends BaseTask.
class Initiative extends BaseTask {
  Initiative({
    required super.dynamicTime,
    required super.title,
    required super.completionTime,
    super.isDone,
  });
}


class AppTime {
  final int hour;
  final int minute;

  const AppTime(this.hour, this.minute);

  
  // Helper method for formatting time as HH:MM
  String remainingTime() {
    if(hour==0){
      return "${minute.toString()}m";
    }
    if (minute==0)
    {
      return "${hour.toString()}h";
    }
    return "${hour.toString()}h ${minute.toString()}m";
  }

  String getTime() {
    return "${hour.toString()}:${minute.toString()}";
  }
}
