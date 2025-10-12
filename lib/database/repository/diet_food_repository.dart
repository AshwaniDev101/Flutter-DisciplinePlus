import 'package:discipline_plus/models/diet_food.dart';
import 'package:discipline_plus/models/food_stats.dart';
import '../services/firebase_diet_food_service.dart';

class DietFoodRepository {

  final FirebaseDietFoodService _service;

  DietFoodRepository(this._service);

  Stream<List<DietFood>> watchAvailableFood() {
    return _service.watchGlobalFoodList();
  }

  Stream<List<DietFood>> watchConsumedFood(DateTime date) {
    return _service.watchConsumedFood(date);
  }

  Stream<FoodStats?> watchConsumedFoodStats(DateTime date) {
    return _service.watchDietStatistics(date);
  }

  Future<void> addAvailable(DietFood food) {
    return _service.addGlobalFoodList(food);
  }

  Future<void> deleteAvailable(String id) {
    return _service.deleteFromGlobalFoodList(id);
  }

  Future<void> updateAvailable(String id, DietFood food) {
    return _service.updateInGlobalFoodListItem(id, food);
  }


  Future<void> changeConsumedCount(double count ,DietFood food, DateTime date) {
    return _service.changeConsumedFoodCount(count,food, date);
  }


  // Future<void> addConsumed(FoodStats latestStats, DietFood food, DateTime date) {
  //   return _service.incrementInConsumedFood(food, date);
  // }
  //
  // Future<void> subtractConsumed(FoodStats latestStats, DietFood food, DateTime date) {
  //   return _service.subtractConsumedFood(food, date);
  // }

  // Future<void> deleteConsumed(FoodStats latestStats, DietFood food, DateTime date) {
  //   return _service.deleteConsumedFood(latestStats, food, date);
  // }
  //
  // Future<void> updateConsumed(String id, DietFood food, DateTime date) {
  //   return _service.updateConsumedFood(id, food, date);
  // }
}
