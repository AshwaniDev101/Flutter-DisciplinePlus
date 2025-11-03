
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';




part 'cards/habit_home_card.dart';
part 'cards/dashboard_summary_card.dart';
part 'cards/calorie_counter_card.dart';
part 'cards/schedule_list_card.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CalorieCounterCard(),
            _ScheduleListCard(),
            _DashboardSummaryCard(),
            _HabitHomeCard(),

            _ScheduleListCard2(),


          ],
        ),
      ),
    );
  }
}





class _ScheduleListCard2 extends StatelessWidget {
  const _ScheduleListCard2({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      {
        'title': 'Morning Workout',
        'time': '6:30 AM',
        'done': true,
        'icon': Icons.fitness_center
      },
      {
        'title': 'Team Standup Meeting',
        'time': '9:00 AM',
        'done': true,
        'icon': Icons.group
      },
      {
        'title': 'Study DSA',
        'time': '11:00 AM',
        'done': false,
        'icon': Icons.code
      },
      {
        'title': 'Flutter Practice',
        'time': '2:00 PM',
        'done': false,
        'icon': Icons.flutter_dash
      },
      {
        'title': 'Evening Walk',
        'time': '7:00 PM',
        'done': false,
        'icon': Icons.directions_walk
      },
    ];

    final completed = tasks.where((t) => t['done'] == true).length;
    final progress = completed / tasks.length;
    final today = DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      margin: const EdgeInsets.all(16),
      shadowColor: Colors.blueAccent.withOpacity(0.2),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Date
            Center(
              child: Column(
                children: [
                  Text(
                    "Daily Schedule",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    today,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // List of tasks
            ...tasks.map((task) {
              final done = task['done'] as bool;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: done
                      ? Colors.green.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: done
                        ? Colors.greenAccent.withOpacity(0.2)
                        : Colors.blueAccent.withOpacity(0.15),
                    child: Icon(
                      task['icon'] as IconData,
                      color: done ? Colors.green : Colors.blueAccent,
                    ),
                  ),
                  title: Text(
                    task['title'] as String,
                    style: TextStyle(
                      decoration: done ? TextDecoration.lineThrough : null,
                      fontWeight: FontWeight.w500,
                      color: done ? Colors.grey : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    task['time'] as String,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    done
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    color: done ? Colors.green : Colors.grey,
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Divider + Progress section
            Divider(color: Colors.grey[300], thickness: 1),
            const SizedBox(height: 12),
            Text(
              "Progress Summary",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[700],
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              color: progress < 0.5
                  ? Colors.orangeAccent
                  : progress < 0.9
                  ? Colors.lightBlue
                  : Colors.greenAccent,
              minHeight: 10,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "$completed of ${tasks.length} completed • ${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


