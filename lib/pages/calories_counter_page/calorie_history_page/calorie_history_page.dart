import 'package:flutter/material.dart';
import 'package:discipline_plus/models/food_stats.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/helper.dart';
import '../../../core/utils/app_settings.dart';
import '../../../database/repository/calories_history_repository.dart';
import '../calories_counter_page.dart';

/// Main page displaying calorie history for a month
class CalorieHistoryPage extends StatefulWidget {

  final DateTime dateTime;

  const CalorieHistoryPage({required this.dateTime, super.key});

  @override
  State<CalorieHistoryPage> createState() => _CalorieHistoryPageState();
}

class _CalorieHistoryPageState extends State<CalorieHistoryPage> {
  /// Future to fetch month's calorie stats
  late Future<Map<int, FoodStats>> _future;

  @override
  void initState() {
    super.initState();
    _loadMonthStats();
  }

  /// Helper method to initialize or refresh the month stats
  void _loadMonthStats() {
    _future = CaloriesHistoryRepository.instance.getMonthStats(
      year: 2025,
      month: 10,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Calorie History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 2,
        backgroundColor: Colors.pink[300],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<int, FoodStats>>(
          future: _future,
          builder: (context, snapshot) {
            // Loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Error state
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              );
            }

            // No data state
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No data found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            // Has data
            final stats = snapshot.data!;
            final dayKeys = stats.keys.toList()..sort((a, b) => b.compareTo(a));

            return RefreshIndicator(
              onRefresh: () async {
                setState(_loadMonthStats);
              },
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemCount: dayKeys.length,
                itemBuilder: (context, index) {
                  final day = dayKeys[index];
                  return DayCard(day: day, dateTime: widget.dateTime, foodStats: stats[day]!);
                },
              ),
            );
          },
        ),
      ),

    );
  }

}

/// Card representing a single day's food statistics
class DayCard extends StatelessWidget {
  final int day;
  final DateTime dateTime;
  final FoodStats foodStats;


  const DayCard({super.key, required this.day, required this.dateTime, required this.foodStats});

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat.MMMM().format(dateTime);
    final currentYear = DateFormat.y().format(dateTime);


    //Datetime update
    DateTime currentDayDateTime = DateTime(2025, 10, day);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Date label
            Text(
              '$day-$currentMonth-$currentYear',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const SizedBox(height: 6),

            /// Calories progress and total
            Row(
              children: [
                _buildProgressCircle(),
                const SizedBox(width: 20),
                _buildCaloriesInfo(),
                const Spacer(),
                getIconButton(context,currentDayDateTime),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 8),

            /// Nutrient chips
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildNutrientChip('Protein', foodStats.proteins, Colors.pink.shade300),
                _buildNutrientChip('Carbs', foodStats.carbohydrates, Colors.orange.shade300),
                _buildNutrientChip('Fats', foodStats.fats, Colors.amber.shade400),
                _buildNutrientChip('Vitamins', foodStats.vitamins, Colors.green.shade300),
                _buildNutrientChip('Minerals', foodStats.minerals, Colors.blue.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Circular progress showing calories vs maximum
  Widget _buildProgressCircle() {
    final progress = (foodStats.calories / AppSettings.atMostProgress).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            value: 1,
            color: Colors.grey.shade300,
          ),
        ),
        SizedBox(
          height: 50,
          width: 50,
          child: CircularProgressIndicator(
            strokeWidth: 6,
            value: progress,
            color: getProgressColor(foodStats),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          "${(progress * 100).toStringAsFixed(0)}%",
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ],
    );
  }

  /// Calories display with excess indicator if over the limit
  Widget _buildCaloriesInfo() {
    final excess = foodStats.calories - AppSettings.atMostProgress;

    return Row(
      children: [
        Text(
          '${foodStats.calories} kcal',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        Text(
          '/${AppSettings.atMostProgress}',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        const SizedBox(width: 10),
        if (excess > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '+$excess',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
      ],
    );
  }

  /// Nutrient chip widget
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


  void openCaloriesCounterPage(BuildContext context, DateTime currentDayDateTime) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CaloriesCounterPage(currentDayDateTime: currentDayDateTime)),
    );


  }

  IconButton getIconButton(BuildContext context, DateTime currentDayDateTime) {
    return IconButton(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
      onPressed: () async {
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(200, 400, 16, 0), // you can adjust this
          items: [

            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        );

        if (selected == 'edit') {

          openCaloriesCounterPage(context, currentDayDateTime);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Edit option clicked')),
          // );
        } else if (selected == 'delete') {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(content: Text('Deleted successfully')),
          // );
        }
      },
    );
  }


}
