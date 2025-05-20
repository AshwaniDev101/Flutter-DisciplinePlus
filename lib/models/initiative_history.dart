import 'initiative.dart';

class InitiativeHistory {
  final String id;
  final List<Initiative> initiatives;
  final int totalNumberOfInitiatives;
  final int completedInitiatives;
  final int percentage;

  InitiativeHistory({
    required this.id,
    required this.initiatives,
    required this.totalNumberOfInitiatives,
    required this.completedInitiatives,
  }) : percentage = totalNumberOfInitiatives == 0
      ? 0
      : ((completedInitiatives / totalNumberOfInitiatives) * 100).round();

  factory InitiativeHistory.fromMap(Map<String, dynamic> json) {
    var list = (json['initiatives'] as List<dynamic>)
        .map((e) => Initiative.fromMap(e as Map<String, dynamic>))
        .toList();

    int total = list.length;
    int completed = list.where((i) => i.isComplete).length;

    return InitiativeHistory(
      id: json['id'] as String,
      initiatives: list,
      totalNumberOfInitiatives: total,
      completedInitiatives: completed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'initiatives': initiatives.map((i) => i.toMap()).toList(),
    'totalNumberOfInitiatives': totalNumberOfInitiatives,
    'completedInitiatives': completedInitiatives,
    'percentage': percentage,
  };
}
