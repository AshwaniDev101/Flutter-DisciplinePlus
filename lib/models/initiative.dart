import 'package:discipline_plus/models/study_break.dart';
import 'app_time.dart';

class Initiative {
  final String id;
  final String title;
  final AppTime completionTime;
  final AppTime dynamicTime;
  bool isComplete;
  final StudyBreak studyBreak;
  final int index;

  Initiative({
    String? id,
    required this.title,
    required this.completionTime,
    this.dynamicTime = const AppTime(0, 0),
    this.isComplete = false,
    this.studyBreak = const ShortBreak(),
    required this.index,
  }) : id = id ?? _generateReadableId();

  static String _generateReadableId() {
    final now = DateTime.now();
    return "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_${_twoDigits(now.hour)}:${_twoDigits(now.minute)}.${now.millisecond}_${now.microsecond}";
  }

  static String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isComplete': isComplete,
      'dynamicTime': dynamicTime.toMap(),
      'completionTime': completionTime.toMap(),
      'studyBreak': studyBreak.toMap(),
      'index': index, // Add index to map
    };
  }

  factory Initiative.fromMap(Map<String, dynamic> map) {
    return Initiative(
      id: map['id'] as String?,
      title: map['title'] as String,
      completionTime: AppTime.fromMap(Map<String, dynamic>.from(map['completionTime'])),
      dynamicTime: AppTime.fromMap(Map<String, dynamic>.from(map['dynamicTime'])),
      isComplete: map['isComplete'] as bool? ?? false,
      studyBreak: StudyBreak.fromMap(Map<String, dynamic>.from(map['studyBreak'])),
      index: map['index'] as int? ?? 0, // Safely load index or default to 0
    );
  }
}
