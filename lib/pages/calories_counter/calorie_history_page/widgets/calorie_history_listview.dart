import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_settings.dart';
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
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(

                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${foodStats.calories} kcal',

                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                              Text(
                                '/${AppSettings.atLeastCalories}',
                                style: TextStyle(
                                  fontSize: 10,
                                  // fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                              Text(
                                'max(${AppSettings.atMaxCalories})',
                                style: TextStyle(
                                  fontSize:8,
                                  // fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],)

                          ],
                        ),
                        // if (foodStats.calories > AppSettings.atMaxCalories)

                        getCautionLabel(foodStats),

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
    final progress = (foodStats.calories / AppSettings.atMaxCalories).clamp(0.0, double.infinity);

    // Decide color based on progress
    Color progressColor;
    if (progress < 0.75) {
      progressColor = Colors.green;
    } else if (progress < 1.0) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      tween: Tween(begin: 0, end: progress > 1.0 ? 1.0 : progress),
      builder: (context, animatedValue, _) {
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
                value: animatedValue,
                color: progressColor,
                strokeCap: StrokeCap.round,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                // color: progress >= 1.0 ? Colors.redAccent : Colors.black,
                color: Colors.black,
              ),
              child: Text("${(progress * 100).toStringAsFixed(0)}%"),
            ),
          ],
        );
      },
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


  Widget getCautionLabel(FoodStats foodStats) {
    final double maxCalories = AppSettings.atMaxCalories.toDouble();
    final double current = foodStats.calories.toDouble();

    final double ratio = current / maxCalories;
    final double diff = current - maxCalories;

    Color bgColor;
    Color shadowColor;
    IconData icon;

    if (ratio < 0.75) {
      // Below 75% — green
      bgColor = Colors.green.shade700;
      shadowColor = Colors.green.withValues(alpha: 0.3);
      icon = Icons.arrow_downward_rounded;
    } else if (ratio < 1.0) {
      // Between 75% and 100% — yellow
      bgColor = Colors.amber.shade700;
      shadowColor = Colors.amber.withValues(alpha: 0.4);
      // icon = Icons.horizontal_rule_rounded;
      icon = Icons.arrow_downward_rounded;
    } else {
      // Above 100% — red
      bgColor = Colors.red.shade700;
      shadowColor = Colors.red.withValues(alpha: 0.6);
      icon = Icons.arrow_upward_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 12),
          Text(
            diff.abs().toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


// Widget getCautionLabel(FoodStats foodStats)
  // {
  //
  //
  //   bool isMaxed = AppSettings.atMaxCalories-foodStats.calories<0;
  //   return  Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
  //     decoration: BoxDecoration(
  //       color: isMaxed?Colors.red.shade700:Colors.green.shade700,
  //       borderRadius: BorderRadius.circular(16),
  //       boxShadow: [
  //         BoxShadow(
  //           color:  isMaxed?Colors.red.withValues(alpha: 0.6):Colors.green.withValues(alpha: 0.3),
  //           blurRadius: 8,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(isMaxed?Icons.arrow_upward_rounded:Icons.arrow_downward_rounded,color: Colors.white,size: 12,),
  //         Text(
  //
  //           '${(foodStats.calories - AppSettings.atMaxCalories).abs()}',
  //           style: const TextStyle(
  //             color: Colors.white,
  //             fontSize: 10,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
