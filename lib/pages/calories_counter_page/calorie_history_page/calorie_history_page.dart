import 'package:flutter/material.dart';
import 'package:discipline_plus/models/food_stats.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/helper.dart';
import '../../../core/utils/app_settings.dart';
import '../../../database/repository/calories_history_repository.dart';

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
    _future = CaloriesHistoryRepository.instance.getMonthStats(year: 2025, month: 10);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Calorie History',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
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
              // Reverse the day keys
              final dayKeys = stats.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              // final dayKeys = stats.keys.toList()..sort();
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _future = CaloriesHistoryRepository.instance
                        .getMonthStats(year: 2025, month: 10);
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
    } else if (!snapshot.hasData ||
        (snapshot.data is Map && (snapshot.data as Map).isEmpty)) {
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




    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      // margin: EdgeInsets.zero,
      // clipBehavior: Clip.none,
      color: Colors.white,

      // elevation: 2,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(16),
      // ),
      child: Padding(
        padding: const EdgeInsets.only(left:8,right: 8,bottom: 10,top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [


            Text(
              '$day-${DateFormat.MMMM().format(DateTime.now())}-${DateTime.now().year}',
              style: TextStyle(
                // fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.grey[500],


              ),
            ),



            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [


                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle (light grey)
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        value: 1, // full circle background
                        color: Colors.grey.shade300,
                      ),
                    ),

                    // Foreground circle (actual progress)
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(
                        strokeWidth: 6,
                        value: stat.calories / AppSettings.atMostProgress,
                        color: getProgressColor(stat),
                        strokeCap: StrokeCap.round,
                      ),
                    ),

                    // Optional text inside (like %)
                    Text(
                      "${((stat.calories / AppSettings.atMostProgress) * 100).clamp(0, 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),



                SizedBox(width: 20,),
                Text(
                  '${stat.calories} kcal',
                  style: TextStyle(
                      color: Colors.grey[600],
                      // color: getProgressColor(stat),
                      fontWeight: FontWeight.bold,
                      fontSize: 22
                  ),
                ),

                Text(
                  '/${AppSettings.atMostProgress}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    // fontWeight: FontWeight.w600,
                  ),
                ),

                Spacer(),

                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                  // padding: EdgeInsets.all(2), // control the circle size
                  // constraints: const BoxConstraints(),
                ),


              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.pink.shade100, thickness: 1),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8, // horizontal spacing between chips
              runSpacing: 4, // vertical spacing when chips wrap to next line
              children: [
                _buildNutrientChip('Protein', stat.proteins, Colors.pink.shade300),
                _buildNutrientChip('Carbs', stat.carbohydrates, Colors.orange.shade300),
                _buildNutrientChip('Fats', stat.fats, Colors.amber.shade400),
                _buildNutrientChip('Vitamins', stat.vitamins, Colors.green.shade300),
                _buildNutrientChip('Minerals', stat.minerals, Colors.blue.shade300),
              ],
            )


          ],
        ),
      ),
    );

  }

  Widget _buildNutrientChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }


}
