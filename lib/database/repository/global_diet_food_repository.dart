import 'package:discipline_plus/models/diet_food.dart';

import '../services/firebase_global_diet_food_service.dart';

class GlobalDietFoodRepository {

  final FirebaseGlobalDietFoodService _service;
  GlobalDietFoodRepository(this._service);

  Stream<List<DietFood>> watchAvailableFood() {
    return _service.watchGlobalFoodList();
  }

  Stream<List<DietFood>> watchConsumedFood(DateTime date) {
    return _service.watchConsumedFood(date);
  }

  // Stream<FoodStats?> watchConsumedFoodStats(DateTime date) {
  //   return _service.watchDietStatistics(date);
  // }

  Future<void> addAvailable(DietFood food) {
    return _service.addGlobalFoodList(food);
  }

  Future<void> deleteAvailable(String id) {
    return _service.deleteFromGlobalFoodList(id);
  }

  Future<void> updateAvailable(String id, DietFood food) {
    return _service.updateInGlobalFoodListItem(id, food);
  }





}
