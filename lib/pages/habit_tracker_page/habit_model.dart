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
}

String dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
