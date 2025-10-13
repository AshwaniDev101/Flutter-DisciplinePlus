import 'package:discipline_plus/models/study_break.dart';
import '../core/utils/helper.dart';
import 'app_time.dart';

class Initiative {
  final String id;
  final String title;
  final AppTime completionTime;
  final AppTime dynamicTime;
  bool isComplete;
  final StudyBreak studyBreak;
  int index;

  Initiative({
    String? id,
    required this.title,
    required this.completionTime,
    this.dynamicTime = const AppTime(0, 0),
    this.isComplete = false,
    this.studyBreak = const StudyBreak(),
    required this.index,
  }) : id = id ?? generateReadableTimestamp();





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



  Initiative copyWith({
    String? id,
    String? title,
    AppTime? completionTime,
    AppTime? dynamicTime,
    bool? isComplete,
    StudyBreak? studyBreak,
    int? index,
  }) {
    return Initiative(
      id: id ?? this.id,
      title: title ?? this.title,
      completionTime: completionTime ?? this.completionTime,
      dynamicTime: dynamicTime ?? this.dynamicTime,
      isComplete: isComplete ?? this.isComplete,
      studyBreak: studyBreak ?? this.studyBreak,
      index: index ?? this.index,
    );
  }

}
