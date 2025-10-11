import 'dart:async';

// import 'package:rxdart/rxdart.dart';

import 'package:discipline_plus/database/repository/diet_food_repository.dart';
import 'package:rxdart/rxdart.dart';

import '../../database/services/firebase_diet_food_service.dart';
import '../../models/diet_food.dart';
import '../../models/food_stats.dart';

class FoodManager {
  FoodManager._internal();
  static final FoodManager _instance = FoodManager._internal();
  static FoodManager get instance => _instance;


  final DietFoodRepository _dietFoodRepository = DietFoodRepository(FirebaseDietFoodService.instance);


  /// Watches both available foods and consumed foods,
  /// and merges them into a single stream where each
  /// available food also contains its consumed count.
  Stream<List<DietFood>> watchMergedFoodList() {
    return Rx.combineLatest2<List<DietFood>, List<DietFood>, List<DietFood>>(
      _watchAvailableFood(),  // Stream of all available foods
      _watchConsumedFood(),   // Stream of consumed foods
          (availableList, consumedList) {

        // Create a quick lookup map of consumed food counts by ID
        final consumedMap = {
          for (final food in consumedList) food.id: food.count,
        };

        // Merge the two lists:
        // For each available food, check if it exists in consumedMap
        // If yes, use its consumed count; otherwise, set count to 0
        return availableList.map((food) {
          final consumedCount = consumedMap[food.id] ?? 0;
          return food.copyWith(count: consumedCount);
        }).toList();
      },
    );
  }


  Stream<List<DietFood>> _watchAvailableFood() {

    return _dietFoodRepository.watchAvailableFood();
  }
  Stream<List<DietFood>> _watchConsumedFood() {

    return _dietFoodRepository.watchConsumedFood(DateTime.now());
  }


  Stream<FoodStats?> watchConsumedFoodStats() {

    return _dietFoodRepository.watchConsumedFoodStats(DateTime.now());
  }


  // Add to available food list
  void addToAvailableFood(DietFood food) {
    _dietFoodRepository.addAvailable(food);
  }

  void addToConsumedFood(FoodStats latestFoodStatsData, DietFood food) {
    _dietFoodRepository.addConsumed(latestFoodStatsData,food, DateTime.now());
  }

  void subtractFromConsumedFood(FoodStats latestFoodStatsData, DietFood food) {
    _dietFoodRepository.subtractConsumed(latestFoodStatsData,food, DateTime.now());
  }
  // Remove from available food list
  void removeFromAvailableFood(DietFood food) {
    _dietFoodRepository.deleteAvailable(food.id);
  }
  // void removeFromConsumedFood(FoodStats latestFoodStatsData, DietFood food) {
  //   _dietFoodRepository.deleteConsumed(latestFoodStatsData, food, DateTime.now());
  // }

  // Edit available food
  void editAvailableFood(DietFood food) {
    _dietFoodRepository.updateAvailable(food.id, food);
  }
  // void editConsumedFood(DietFood food) {
  //   _dietFoodRepository.updateConsumed(food.id, food, DateTime.now());
  // }

}
