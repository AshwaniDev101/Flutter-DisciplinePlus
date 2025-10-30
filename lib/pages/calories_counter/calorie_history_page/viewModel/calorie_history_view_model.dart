

import 'package:discipline_plus/core/utils/app_settings.dart';
import 'package:flutter/widgets.dart';

import '../../../../database/repository/food_history_repository.dart';
import '../../../../models/diet_food.dart';
import '../../../../models/food_stats.dart';

class CalorieHistoryViewModel extends ChangeNotifier
{

  final DateTime pageDateTime;

  CalorieHistoryViewModel({required this.pageDateTime});


  Map<int, FoodStats> monthStatsMap = {};
  double excessCalories = 0;







  Future<void> loadMonthStats() async {
    await _loadMonthStats();
  }


  //

  Future<void> _loadMonthStats() async {
    monthStatsMap = await FoodHistoryRepository.instance.getMonthStats(
      year: pageDateTime.year,
      month: pageDateTime.month,
    );

    excessCalories = _calculateNetExcess(monthStatsMap);

    notifyListeners();

  }

 double _calculateNetExcess(Map<int, FoodStats> monthStats) {
    double total = 0; // start from zero

    for (var food in monthStats.values) {

      total += food.calories - AppSettings.atMaxCalories;
      // print("Total ${total} => ${AppSettings.atMaxCalories} - ${food.calories} = ${food.calories - AppSettings.atMaxCalories}");
    }
    return total;
  }

  Future<void> runTest() async {
    await FoodHistoryRepository.instance.changeConsumedCount(
      0,
      DietFood(
        id: '-1',
        name: 'Test 0',
        time: DateTime.now(),
        foodStats: FoodStats(proteins: 0, carbohydrates: 0, fats: 0, vitamins: 0, minerals: 0, calories: 1),
      ),
      DateTime(2025, 10, 25),
    );
    await loadMonthStats();
  }

  void onDelete(DateTime cardDateTime) async
  {
    await FoodHistoryRepository.instance.deleteFoodStats(date: cardDateTime);
    monthStatsMap.remove(cardDateTime.day);
    notifyListeners();
  }


}