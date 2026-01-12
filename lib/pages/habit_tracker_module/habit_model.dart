import 'package:flutter/material.dart';

class Habit {
  final String id;
  final String title;
  final Color color;
  final IconData icon;
  final Set<String> completedDates; // stored as 'yyyy-M-d' for simplicity

  Habit({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? <String>{};

  factory Habit.fromJson(Map<String, dynamic> jsonData) {
    return Habit(
      id: jsonData['id'],
      title: jsonData['title'],
      color: Color(jsonData['color']),
      icon: IconData(jsonData['icon_code'], fontFamily: 'MaterialIcons'),
      completedDates: Set<String>.from(jsonData['completedDates']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color.value,
      'icon_code': icon.codePoint,
      'completedDates': completedDates.toList(),
    };
  }
}

String dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
