import 'dart:async';

// import 'package:rxdart/rxdart.dart';

import 'package:rxdart/rxdart.dart';

import '../../../database/services/firebase_diet_food_service.dart';
import '../../../models/diet_food.dart';
import '../../../models/food_stats.dart';

class FoodManager {
  FoodManager._internal();
  static final FoodManager _instance = FoodManager._internal();
  static FoodManager get instance => _instance;


  final FirebaseDietFoodService _dietFoodRepository = FirebaseDietFoodService.instance;

  // Internal lists
  // final List<DietFood> _availableFood = [];
  // final List<DietFood> _consumedFood = [];



  Stream<List<DietFood>> watchMergedFoodList() {
    return Rx.combineLatest2<List<DietFood>, List<DietFood>, List<DietFood>>(
      _watchAvailableFood(),
      _watchConsumedFood(),
          (availableList, consumedList) {
        final consumedMap = {
          for (var food in consumedList) food.id: food.count,
        };

        return availableList.map((food) {
          final count = consumedMap[food.id] ?? 0;
          return food.copyWith(count: count);
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

  // Add to available food list
  void addToAvailableFood(DietFood food) {
    // _availableFood.add(food);
    _dietFoodRepository.addAvailableFood(food);
  }

  void addToConsumedFood(FoodStats latestFoodStatsData, DietFood food) {
    // _availableFood.add(food);
    _dietFoodRepository.addConsumedFood(latestFoodStatsData,food, DateTime.now());
  }
  // Remove from available food list
  void removeFromAvailableFood(DietFood food) {
    // _availableFood.remove(food);
    _dietFoodRepository.deleteAvailableFood(food.id);
  }
  void removeFromConsumedFood(FoodStats latestFoodStatsData, DietFood food) {
    // _consumedFood.remove(food);
    _dietFoodRepository.deleteConsumedFood(latestFoodStatsData, food, DateTime.now());
  }

  // Edit available food
  void editAvailableFood(DietFood food) {
    // final index = _availableFood.indexWhere((element) => element.id == food.id);
    // _availableFood[index] = food;
    _dietFoodRepository.updateAvailableFood(food.id, food);
  }
  void editConsumedFood(DietFood food) {
    // final index = _consumedFood.indexWhere((element) => element.id == food.id);
    // _consumedFood[index] = food;
    _dietFoodRepository.updateConsumedFood(food.id, food, DateTime.now());
  }

}
