import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_settings.dart';
import '../../../../core/utils/helper.dart';
import '../../../../models/food_stats.dart';
import '../../../../widget/edit_delete_option_menu.dart';

class CalorieHistoryListview extends StatelessWidget {
  final Map<int, FoodStats> monthStats;
  final DateTime pageDateTime;

  final void Function(DateTime) onEdit;
  final void Function(DateTime) onDelete;

  const CalorieHistoryListview(
      {required this.pageDateTime, required this.monthStats, required this.onEdit, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: monthStats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final dayKeys = monthStats.keys.toList()..sort((a, b) => b.compareTo(a));
        final day = dayKeys[index];
        var cardDateTime = DateTime(pageDateTime.year, pageDateTime.month, day);
        return _DayCard(
            dateTime: cardDateTime,
            // dateTime: widget.pageDateTime,
            foodStats: monthStats[day]!,
            editDeleteOptionMenu: EditDeleteOptionMenu(
              onDelete: () => onDelete(cardDateTime),
              onEdit: () => onEdit(cardDateTime),
            ));
      },
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime dateTime;
  final FoodStats foodStats;
  final EditDeleteOptionMenu editDeleteOptionMenu;

  const _DayCard({
    // super.key,
    required this.dateTime,
    required this.foodStats,
    required this.editDeleteOptionMenu,
  });

  @override
  Widget build(BuildContext context) {
    String weekdayName = DateFormat('EEEE').format(dateTime);

    final cardDay = dateTime.day;
    final cardMonth = DateFormat.MMMM().format(dateTime);
    final cardYear = DateFormat.y().format(dateTime);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 2,
            child: editDeleteOptionMenu,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  '$cardDay $cardMonth, $cardYear ($weekdayName)',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 4-column row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Progress Circle
                    _buildProgressCircle(),

                    const SizedBox(width: 8),

                    // Column 2: Calories info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${foodStats.calories} kcal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '/${AppSettings.atMostProgress}',
                              style: TextStyle(
                                fontSize: 10,
                                // fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        if (foodStats.calories > AppSettings.atMostProgress)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
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
                              '+${foodStats.calories - AppSettings.atMostProgress}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Column 3: Nutrient chips
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          _buildNutrientChip('Protein', foodStats.proteins, Colors.pink.shade300),
                          _buildNutrientChip('Carbs', foodStats.carbohydrates, Colors.orange.shade300),
                          _buildNutrientChip('Fats', foodStats.fats, Colors.amber.shade400),
                          _buildNutrientChip('Vitamins', foodStats.vitamins, Colors.green.shade300),
                          _buildNutrientChip('Minerals', foodStats.minerals, Colors.blue.shade300),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    final progress = (foodStats.calories / AppSettings.atMostProgress).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 36,
          width: 36,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            value: 1,
            color: Colors.grey.shade200,
          ),
        ),
        SizedBox(
          height: 36,
          width: 36,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            value: progress,
            color: getProgressColor(foodStats),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          "${(progress * 100).toStringAsFixed(0)}%",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildNutrientChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 2.5, backgroundColor: color),
          const SizedBox(width: 2),
          Text(
            '$label: $value',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
