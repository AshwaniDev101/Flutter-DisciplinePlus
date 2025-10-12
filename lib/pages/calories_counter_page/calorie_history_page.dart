import 'package:flutter/material.dart';
import 'package:discipline_plus/models/food_stats.dart';
import '../../database/repository/calories_repository.dart';


class CalorieHistoryPage extends StatefulWidget {
  const CalorieHistoryPage({super.key});

  @override
  State<CalorieHistoryPage> createState() => _CalorieHistoryPageState();
}

class _CalorieHistoryPageState extends State<CalorieHistoryPage> {
  late final Future<Map<int, FoodStats>> _future;

  @override
  void initState() {
    super.initState();
    _future = CaloriesRepository.instance.getMonthStats(year: 2025, month: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Calorie History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.orangeAccent.shade700,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<int, FoodStats>>(
          future: _future,
          builder: (context, snapshot) => _buildSnapshot(
            snapshot,
                (stats) {
              final dayKeys = stats.keys.toList()..sort();
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _future = CaloriesRepository.instance.getMonthStats(year: 2025, month: 10);
                  });
                },
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemCount: dayKeys.length,
                  itemBuilder: (context, index) {
                    final day = dayKeys[index];
                    return DayCard(day: day, stat: stats[day]!);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Helper to handle FutureBuilder states
  Widget _buildSnapshot<T>(
      AsyncSnapshot<T> snapshot, Widget Function(T data) builder) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(
        child: Text(
          'Error: ${snapshot.error}',
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    } else if (!snapshot.hasData || (snapshot.data is Map && (snapshot.data as Map).isEmpty)) {
      return const Center(
        child: Text(
          'No data found',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    } else {
      return builder(snapshot.data!);
    }
  }
}

/// Card widget representing a single day's food stats
class DayCard extends StatelessWidget {
  final int day;
  final FoodStats stat;

  const DayCard({super.key, required this.day, required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Day $day',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent.shade700,
              ),
            ),
            const SizedBox(height: 6),
            Text('Calories: ${stat.calories}'),
            Text('Proteins: ${stat.proteins} | Carbs: ${stat.carbohydrates} | Fats: ${stat.fats}'),
            Text('Vitamins: ${stat.vitamins} | Minerals: ${stat.minerals}'),
          ],
        ),
      ),
    );
  }
}
