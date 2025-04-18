import 'app_time.dart';

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