import 'package:flutter/material.dart';

/// Simple habit model for demo purposes.
/// completedDates stores dates in 'yyyy-MM-dd' format for easy comparison.
class Habit {
  final String id;
  final String title;
  final Color color;
  final IconData icon;
  final Set<String> completedDates; // set of 'yyyy-MM-dd'
  Habit({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? <String>{};
}

/// Utility to format DateTime into a stable key used by the model.
String _dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Example usage:
/// Place `const HabitTrackerDemo()` somewhere in your app body to try it out.
class HabitTrackerDemo extends StatelessWidget {
  const HabitTrackerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker Demo')),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: HabitTrackerCard(),
        ),
      ),
    );
  }
}

/// The detailed habit tracker dashboard card
class HabitTrackerCard extends StatefulWidget {
  const HabitTrackerCard({super.key});

  @override
  State<HabitTrackerCard> createState() => _HabitTrackerCardState();
}

class _HabitTrackerCardState extends State<HabitTrackerCard> {
  // Mock data — replace with your repository/provider later.
  final List<Habit> _habits = [
    Habit(
      id: 'h1',
      title: 'Morning Run',
      color: Colors.orange,
      icon: Icons.directions_run,
      completedDates: {_dateKey(DateTime.now().subtract(const Duration(days: 1))), _dateKey(DateTime.now())},
    ),
    Habit(
      id: 'h2',
      title: 'Read (30 min)',
      color: Colors.blue,
      icon: Icons.book,
      completedDates: {_dateKey(DateTime.now().subtract(const Duration(days: 2)))},
    ),
    Habit(
        id: 'h3',
        title: 'Meditation',
        color: Colors.green,
        icon: Icons.self_improvement,
        completedDates: {} // none yet
    ),
    Habit(
      id: 'h4',
      title: 'Practice Coding (DSA)',
      color: Colors.purple,
      icon: Icons.code,
      completedDates: {_dateKey(DateTime.now())},
    ),
  ];

  DateTime get _today => DateTime.now();

  /// Toggle completion for a habit for the given date (default: today)
  void _toggleDoneToday(Habit habit) {
    final key = _dateKey(_today);
    setState(() {
      if (habit.completedDates.contains(key)) {
        habit.completedDates.remove(key);
      } else {
        habit.completedDates.add(key);
      }
    });
  }

  /// Whether habit is done on a given date
  bool _isDoneOn(Habit habit, DateTime date) {
    return habit.completedDates.contains(_dateKey(date));
  }

  /// Compute current streak ending today (consecutive days up to today)
  int _currentStreak(Habit habit) {
    int streak = 0;
    DateTime cursor = DateTime(_today.year, _today.month, _today.day);
    while (_isDoneOn(habit, cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Compute longest streak in history
  int _longestStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;
    // parse dates
    final dates = habit.completedDates
        .map((s) {
      final parts = s.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    })
        .toSet()
        .toList()
      ..sort();
    int best = 1;
    int current = 1;
    for (var i = 1; i < dates.length; i++) {
      final diff = dates[i].difference(dates[i - 1]).inDays;
      if (diff == 1) {
        current++;
        if (current > best) best = current;
      } else if (diff > 1) {
        current = 1;
      }
    }
    return best;
  }

  /// Returns last 7 dates including today (oldest first)
  List<DateTime> _last7Days() {
    final list = <DateTime>[];
    for (var i = 6; i >= 0; i--) {
      final d = DateTime(_today.year, _today.month, _today.day).subtract(Duration(days: i));
      list.add(d);
    }
    return list;
  }

  /// Overall progress: how many habits completed today
  double get _overallProgress {
    if (_habits.isEmpty) return 0.0;
    final completed = _habits.where((h) => _isDoneOn(h, _today)).length;
    return completed / _habits.length;
  }

  /// Short weekday label
  String _shortDayLabel(DateTime d) {
    const names = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return names[d.weekday % 7];
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _habits.where((h) => _isDoneOn(h, _today)).length;
    final total = _habits.length;
    final overall = _overallProgress;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: title and date
            Column(
              children: [
                Text(
                  'Habits',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_today.day}-${_today.month}-${_today.year}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Top row: overall circular progress + stats
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular overall progress
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // background ring
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 10,
                          valueColor: AlwaysStoppedAnimation(Colors.grey[200]!),
                        ),
                      ),
                      // progress ring
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: overall),
                          duration: const Duration(milliseconds: 600),
                          builder: (context, val, _) => CircularProgressIndicator(
                            value: val,
                            strokeWidth: 10,
                            valueColor: AlwaysStoppedAnimation(
                              overall < 0.4 ? Colors.orange : (overall < 0.9 ? Colors.blue : Colors.green),
                            ),
                          ),
                        ),
                      ),
                      // center content
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(overall * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            '$completedCount / $total',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // Stats column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today Completed', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                      const SizedBox(height: 6),
                      Text(
                        '$completedCount of $total habits',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      // quick streak summary (max and average across habits)
                      Row(
                        children: [
                          _StatChip(
                            label: 'Avg Streak',
                            value: _habits.isEmpty ? '0' : (_habits.map(_currentStreak).reduce((a, b) => a + b) ~/ _habits.length).toString(),
                            color: Colors.deepPurple,
                            icon: Icons.whatshot,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Longest',
                            value: _habits.isEmpty ? '0' : _habits.map(_longestStreak).reduce((a, b) => a > b ? a : b).toString(),
                            color: Colors.green,
                            icon: Icons.star,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Habit list with weekly mini-calendar and toggle
            Column(
              children: _habits.map((habit) {
                final currStreak = _currentStreak(habit);
                final longest = _longestStreak(habit);
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: habit.color.withOpacity(0.15),
                      child: Icon(habit.icon, color: habit.color),
                    ),
                    title: Text(
                      habit.title,
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        // 7-day mini calendar
                        Row(
                          children: _last7Days().map((d) {
                            final done = _isDoneOn(habit, d);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Column(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: done ? habit.color.withOpacity(0.95) : Colors.transparent,
                                      border: Border.all(color: done ? habit.color : Colors.grey.shade300),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: done
                                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _shortDayLabel(d),
                                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 8),
                        // Streak info
                        Text(
                          'Streak: $currStreak  •  Longest: $longest',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Toggle button for today
                        IconButton(
                          onPressed: () => _toggleDoneToday(habit),
                          icon: Icon(
                            _isDoneOn(habit, _today) ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: _isDoneOn(habit, _today) ? habit.color : Colors.grey,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currStreak > 0 ? '🔥 $currStreak' : '',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Footer: action row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Hook: open detail screen / manage habits
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Manage Habits'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Quick mark all done for today (demo)
                    setState(() {
                      final key = _dateKey(_today);
                      for (final h in _habits) {
                        h.completedDates.add(key);
                      }
                    });
                  },
                  icon: const Icon(Icons.done_all),
                  label: const Text('Mark All Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small stat chip used in the header area
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
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
