import 'package:flutter/material.dart';
import 'package:discipline_plus/models/food_stats.dart';
import '../../../database/repository/calories_repository.dart';


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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Calorie History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.pink[300],
        iconTheme: const IconThemeData(color: Colors.white),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Day $day',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.pink.shade400,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stat.calories} kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.pink.shade100, thickness: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutrientChip('Protein', stat.proteins, Colors.pink.shade300),
                _buildNutrientChip('Carbs', stat.carbohydrates, Colors.orange.shade300),
                _buildNutrientChip('Fats', stat.fats, Colors.amber.shade400),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutrientChip('Vitamins', stat.vitamins, Colors.green.shade300),
                _buildNutrientChip('Minerals', stat.minerals, Colors.blue.shade300),
                const SizedBox(width: 60), // for symmetry
              ],
            ),
          ],
        ),
      ),
    );


    // return Card(
    //   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //   elevation: 2,
    //   child: Padding(
    //     padding: const EdgeInsets.all(12),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text(
    //           'Day $day',
    //           style: theme.textTheme.titleMedium?.copyWith(
    //             fontWeight: FontWeight.bold,
    //             color: Colors.orangeAccent.shade700,
    //           ),
    //         ),
    //         const SizedBox(height: 6),
    //         Text('Calories: ${stat.calories}'),
    //         Text('Proteins: ${stat.proteins} | Carbs: ${stat.carbohydrates} | Fats: ${stat.fats}'),
    //         Text('Vitamins: ${stat.vitamins} | Minerals: ${stat.minerals}'),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildNutrientChip(String label, int value, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
        ),
      ],
    );
  }
}
