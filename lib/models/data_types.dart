

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

  @override
  String toString() {
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour >= 12 ? 'PM' : 'AM';
    return "${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
  }

  bool get isZero => hour == 0 && minute == 0;

  Map<String, dynamic> toMap() => {
    'hour': hour,
    'minute': minute,
  };

  factory AppTime.fromMap(Map<String, dynamic> map) {
    return AppTime(
      map['hour'] as int,
      map['minute'] as int,
    );
  }
}

abstract class BaseInitiative {
  final String id;
  final AppTime dynamicTime;
  final String title;
  final AppTime completionTime;
  bool _isComplete = false;

  BaseInitiative({
    String? id,
    AppTime? dynamicTime,
    required this.title,
    required this.completionTime,
    bool isComplete = false,

  })  : id = id ?? _generateReadableId(),
        dynamicTime = dynamicTime ?? const AppTime(0, 0) {
    _isComplete = isComplete;


  }

  bool get isComplete => _isComplete;
  set isComplete(bool v) => _isComplete = v;

  static String _generateReadableId() {
    final now = DateTime.now();
    return "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_${_twoDigits(now.hour)}:${_twoDigits(now.minute)}.${now.millisecond}_${now.microsecond}";
  }
  static String _twoDigits(int n) => n.toString().padLeft(2, '0');



  /// common fields to map
  Map<String, dynamic> baseToMap() => {
    'id': id,
    'title': title,
    'isComplete': isComplete,
    'dynamicTime': dynamicTime.toMap(),
    'completionTime': completionTime.toMap(),
  };
}

class Initiative extends BaseInitiative {
  final StudyBreak studyBreak;

  Initiative({
    String? id,
    AppTime? dynamicTime,
    required String title,
    required AppTime completionTime,
    this.studyBreak = const ShortBreak(),
    bool isComplete = false,
  }) : super(
    id: id,
    dynamicTime: dynamicTime,
    title: title,
    completionTime: completionTime,
    isComplete: isComplete,
  );

  String get type => studyBreak.title;

  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'type': 'single',
      'studyBreak': studyBreak.toMap(),
    };
  }

  /// Deserialize from map
  factory Initiative.fromMap(Map<String, dynamic> map) {
    return Initiative(
      id: map['id'] as String?,
      title: map['title'] as String,
      completionTime: AppTime.fromMap(Map<String, dynamic>.from(map['completionTime'])),
      dynamicTime: AppTime.fromMap(Map<String, dynamic>.from(map['dynamicTime'])),
      isComplete: map['isComplete'] as bool? ?? false,
      studyBreak: StudyBreak.fromMap(Map<String, dynamic>.from(map['studyBreak'])),
    );
  }
}

class InitiativeGroup extends BaseInitiative {
  final List<Initiative> initiativeList;

  InitiativeGroup({
    String? id,
    AppTime? dynamicTime,
    required String title,
    required this.initiativeList,
    bool isComplete = false,
  }) : super(
    id: id,
    dynamicTime: dynamicTime,
    title: title,
    completionTime: _calculateCompletionTime(initiativeList),
    isComplete: isComplete,
  );

  // Calculate total sum of all sub items, to display in the header
  static AppTime _calculateCompletionTime(List<Initiative> list) {
    final total = list.fold<int>(0, (sum, i) => sum + i.completionTime.hour * 60 + i.completionTime.minute);
    return AppTime(total ~/ 60, total % 60);
  }

  bool hasInitiatives() => initiativeList.isNotEmpty;


  Map<String, dynamic> toMap() {
    return {
      ...baseToMap(),
      'type': 'group',
      'children': initiativeList.map((i) => i.toMap()).toList(),
    };
  }

  /// Deserialize from map
  factory InitiativeGroup.fromMap(Map<String, dynamic> map) {
    final children = (map['children'] as List)
        .map((e) => Initiative.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return InitiativeGroup(
      id: map['id'] as String?,
      title: map['title'] as String,
      dynamicTime: AppTime.fromMap(Map<String, dynamic>.from(map['dynamicTime'])),
      initiativeList: children,
      isComplete: map['isComplete'] as bool? ?? false,
    );
  }
}


abstract class StudyBreak {
  final String title;
  final AppTime completionTime;

  const StudyBreak({
    this.title = 'Break',
    this.completionTime = const AppTime(0, 5),
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'completionTime': completionTime.toMap(),
  };

  factory StudyBreak.fromMap(Map<String, dynamic> map) {
    switch (map['title'] as String) {
      case 'Short break':
        return ShortBreak();
      case 'Long break':
        return LongBreak();
      default:
        return ShortBreak();
    }
  }
}

class ShortBreak extends StudyBreak {
  const ShortBreak() : super(title: 'Short break', completionTime: const AppTime(0, 10));
}

class LongBreak extends StudyBreak {
  const LongBreak() : super(title: 'Long break', completionTime: const AppTime(0, 20));
}