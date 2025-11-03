

part of '../home_page.dart';

class _ScheduleListCard extends StatelessWidget {
  const _ScheduleListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {'title': 'Morning Workout', 'done': true},
      {'title': 'Study DSA', 'done': false},
      {'title': 'Flutter Practice', 'done': true},
      {'title': 'Read 10 pages', 'done': false},
    ];

    final completed = tasks.where((t) => t['done'] == true).length;
    final progress = completed / tasks.length;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Center(
              child: Text(
                "Today's Schedule",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Task List
            ...tasks.map((task) {
              final done = task['done'] as bool;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      done ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: done ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task['title'] as String,
                        style: TextStyle(
                          decoration:
                          done ? TextDecoration.lineThrough : null,
                          color: done ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Progress section
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
              minHeight: 8,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "$completed of ${tasks.length} tasks completed (${(progress * 100).toStringAsFixed(0)}%)",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}