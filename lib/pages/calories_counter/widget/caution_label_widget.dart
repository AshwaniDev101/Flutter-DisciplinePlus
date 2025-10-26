import 'package:discipline_plus/models/food_stats.dart';

import 'package:flutter/material.dart';

import '../../../core/utils/app_settings.dart';

class CationLabelWidget extends StatelessWidget {
  final FoodStats foodStats;

  const CationLabelWidget({required this.foodStats, super.key});

  @override
  Widget build(BuildContext context) {
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
}
