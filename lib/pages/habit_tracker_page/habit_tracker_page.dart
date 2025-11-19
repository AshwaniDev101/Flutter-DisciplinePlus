import 'package:flutter/material.dart';

/// Simple Habit model. `completedDates` stores days as 'yyyy-MM-dd' strings.
class Habit {
  final String id;
  final String title;
  final Color color;
  final IconData icon;
  final Set<String> completedDates;

  Habit({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? <String>{};
}

String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

const List<String> _weekdayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/// Entry page for the habit tracker — shows a vertical list of habit cards.
class HabitTrackerPage extends StatefulWidget {
  const HabitTrackerPage({super.key});

  @override
  State<HabitTrackerPage> createState() => _HabitTrackerPageState();
}

class _HabitTrackerPageState extends State<HabitTrackerPage> {
  final DateTime _now = DateTime.now();
  late final int _daysInMonth;
  late final List<DateTime> _monthDays;

  // Example habits: replace with your data source later
  final List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    _monthDays = List.generate(
      _daysInMonth,
          (i) => DateTime(_now.year, _now.month, i + 1),
    );

    // Seed example habits
    _habits.addAll([
      Habit(
        id: 'h1',
        title: 'Morning Run',
        color: Colors.orange,
        icon: Icons.directions_run,
        completedDates: {
          _dateKey(DateTime(_now.year, _now.month, _now.day)), // today
          _dateKey(DateTime(_now.year, _now.month, _now.day - 1)),
        },
      ),
      Habit(
        id: 'h2',
        title: 'Read (30 min)',
        color: Colors.blue,
        icon: Icons.menu_book,
        completedDates: {
          _dateKey(DateTime(_now.year, _now.month, (_now.day - 2).clamp(1, _daysInMonth))),
        },
      ),
      Habit(
        id: 'h3',
        title: 'Meditation',
        color: Colors.green,
        icon: Icons.self_improvement,
      ),
      Habit(
        id: 'h4',
        title: 'Practice Coding',
        color: Colors.purple,
        icon: Icons.code,
      ),
    ]);
  }

  bool _isDoneOn(Habit habit, DateTime day) => habit.completedDates.contains(_dateKey(day));

  void _toggle(Habit habit, DateTime day) {
    final key = _dateKey(day);
    setState(() {
      if (habit.completedDates.contains(key)) {
        habit.completedDates.remove(key);
      } else {
        habit.completedDates.add(key);
      }
    });
  }

  int _currentStreak(Habit habit) {
    int streak = 0;
    DateTime cursor = DateTime(_now.year, _now.month, _now.day);
    while (_isDoneOn(habit, cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _longestStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    final dates = habit.completedDates
        .map((s) {
      final p = s.split('-');
      return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    })
        .toList()
      ..sort();
    int longest = 1;
    int current = 1;
    for (var i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > longest) longest = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return longest;
  }

  double _habitProgress(Habit habit) {
    if (_monthDays.isEmpty) return 0.0;
    final completed = habit.completedDates.where((k) {
      // count only dates in this month
      return k.startsWith('${_now.year.toString().padLeft(4, '0')}-${_now.month.toString().padLeft(2, '0')}');
    }).length;
    return completed / _monthDays.length;
  }

  void _markAllToday() {
    final todayKey = _dateKey(DateTime(_now.year, _now.month, _now.day));
    setState(() {
      for (final h in _habits) {
        h.completedDates.add(todayKey);
      }
    });
  }

  void _clearAllToday() {
    final todayKey = _dateKey(DateTime(_now.year, _now.month, _now.day));
    setState(() {
      for (final h in _habits) {
        h.completedDates.remove(todayKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _habits.length;
    final todayCompleted = _habits.where((h) => _isDoneOn(h, DateTime(_now.year, _now.month, _now.day))).length;
    final overallProgress = total == 0 ? 0.0 : todayCompleted / total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        actions: [
          IconButton(
            tooltip: 'Mark all done today',
            onPressed: _markAllToday,
            icon: const Icon(Icons.done_all),
          ),
          IconButton(
            tooltip: 'Clear today',
            onPressed: _clearAllToday,
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _buildHeader(overallProgress, todayCompleted, total),
            const SizedBox(height: 12),
            ..._habits.map((h) => _buildHabitCard(h)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double overallProgress, int doneCount, int total) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        child: Row(
          children: [
            SizedBox(
              width: 86,
              height: 86,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation(Colors.grey.shade200),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: overallProgress),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      final color = value < 0.4
                          ? Colors.orange
                          : (value < 0.9 ? Colors.blue : Colors.green);
                      return CircularProgressIndicator(
                        value: value,
                        strokeWidth: 10,
                        valueColor: AlwaysStoppedAnimation(color),
                      );
                    },
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${(overallProgress * 100).toInt()}%',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('$doneCount / $total', style: const TextStyle(fontSize: 12)),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today • ${_now.day}-${_now.month}-${_now.year}',
                      style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 6),
                  const Text('Your Habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _StatChip(label: 'Total', value: '$total', color: Colors.indigo, icon: Icons.list),
                      _StatChip(label: 'Done Today', value: '$doneCount', color: Colors.green, icon: Icons.check_circle),
                      _StatChip(label: 'Month Days', value: '$_daysInMonth', color: Colors.teal, icon: Icons.calendar_today),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHabitCard(Habit habit) {
    final curr = _currentStreak(habit);
    final longest = _longestStreak(habit);
    final progress = _habitProgress(habit);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: habit.color.withOpacity(0.14),
                  child: Icon(habit.icon, color: habit.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(habit.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Streak: $curr  •  Longest: $longest', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                    ],
                  ),
                ),
                // small progress indicator
                SizedBox(
                  width: 56,
                  height: 56,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation(Colors.grey.shade200),
                      ),
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation(habit.color),
                      ),
                      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // weekday labels (aligned to each day cell)
            SizedBox(
              height: 22,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _monthDays.map((d) {
                    return Container(
                      width: 56,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(right: 6),
                      child: Text(
                        _weekdayShort[d.weekday % 7],
                        style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // day circles (scrollable horizontally)
            SizedBox(
              height: 68,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _monthDays.map((d) {
                    final done = _isDoneOn(habit, d);
                    return GestureDetector(
                      onTap: () => _toggle(habit, d),
                      child: Container(
                        width: 56,
                        margin: const EdgeInsets.only(right: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: done ? habit.color : Colors.transparent,
                                borderRadius: BorderRadius.circular(44),
                                border: Border.all(color: done ? habit.color : Colors.grey.shade300, width: 1.4),
                                boxShadow: done
                                    ? [
                                  BoxShadow(
                                    color: habit.color.withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                                    : null,
                              ),
                              child: Center(
                                child: done
                                    ? const Icon(Icons.check, size: 20, color: Colors.white)
                                    : Text('${d.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('${d.day}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // action row
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: habit.color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // quick toggle today for this habit
                    _toggle(habit, DateTime(_now.year, _now.month, _now.day));
                  },
                  icon: Icon(_isDoneOn(habit, DateTime(_now.year, _now.month, _now.day)) ? Icons.done : Icons.radio_button_unchecked),
                  label: Text(_isDoneOn(habit, DateTime(_now.year, _now.month, _now.day)) ? 'Done Today' : 'Mark Today'),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    // Mark entire month for this habit (demo convenience)
                    setState(() {
                      for (final d in _monthDays) {
                        habit.completedDates.add(_dateKey(d));
                      }
                    });
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Mark Month'),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'clear') {
                      setState(() {
                        for (final d in _monthDays) {
                          habit.completedDates.remove(_dateKey(d));
                        }
                      });
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'clear', child: Text('Clear month')),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

/// Small reusable stat chip used in the header.
class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          ],
        )
      ]),
    );
  }
}
