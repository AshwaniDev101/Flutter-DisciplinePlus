import 'app_time.dart';

class StudyBreak {
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
    return StudyBreak(
      title: map['title'] ?? 'Break',
      completionTime: AppTime.fromMap(map['completionTime']),
    );
  }


}

// class ShortBreak extends StudyBreak {
//   const ShortBreak() : super(title: 'Short break', completionTime: const AppTime(0, 10));
// }
//
// class LongBreak extends StudyBreak {
//   const LongBreak() : super(title: 'Long break', completionTime: const AppTime(0, 20));
// }