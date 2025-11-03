

part of '../home_page.dart';

class _HabitHomeCard extends StatelessWidget {
  const _HabitHomeCard({super.key});

  // --- SAMPLE DATA (replace with real data or wire up via constructor/provider) ---
  List<Map<String, Object>> get _sampleHabits => [
    {'title': 'Morning Run', 'done': true, 'streak': 3, 'longest': 7},
    {'title': 'Read 30 min', 'done': false, 'streak': 0, 'longest': 5},
    {'title': 'Meditation', 'done': true, 'streak': 2, 'longest': 4},
    {'title': 'Code Practice', 'done': false, 'streak': 0, 'longest': 6},
    {'title': 'Evening Walk', 'done': true, 'streak': 1, 'longest': 3},
  ];
  // -------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final habits = _sampleHabits;
    final int total = habits.length;
    final int completed = habits.where((h) => h['done'] == true).length;
    final double progress = total == 0 ? 0.0 : completed / total;

    final int avgStreak = habits.isEmpty
        ? 0
        : (habits.map((h) => (h['streak'] as int)).reduce((a, b) => a + b) ~/ total);
    final int longestStreak = habits.isEmpty
        ? 0
        : habits.map((h) => (h['longest'] as int)).reduce((a, b) => a > b ? a : b);

    final dateText =
        '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "Habits",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateText,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            // Progress and data
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Circular progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 90,
                      width: 90,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation(
                          // color shifts with progress for a nicer feel
                          progress < 0.4 ? Colors.orange : (progress < 0.9 ? Colors.blue : Colors.green),
                        ),
                      ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),

                // Stats column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Completed: $completed / $total",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _miniStat(context, 'Avg Streak', '$avgStreak', Icons.whatshot),
                        const SizedBox(width: 8),
                        _miniStat(context, 'Longest', '$longestStreak', Icons.star),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // quick preview of top 3 habits
                    SizedBox(
                      width: 170,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: habits.take(3).map((h) {
                          final done = h['done'] == true;
                          return Chip(
                              backgroundColor: done ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.08),
                              avatar: Icon(
                                done ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 18,
                                color: done ? Colors.green : Colors.grey,
                              ),
                              label: Text(
                                h['title'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: done ? Colors.black87 : Colors.black54,
                                  decoration: done ? TextDecoration.lineThrough : null,
                                ),
                              ));
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[m];
  }
}
