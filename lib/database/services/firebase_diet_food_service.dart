import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discipline_plus/models/diet_food.dart';
import 'package:discipline_plus/models/food_stats.dart';

class FirebaseDietFoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton
  FirebaseDietFoodService._();
  static final instance = FirebaseDietFoodService._();

  final String userId = 'user1'; // Make dynamic later

  /// Watch available food list
  Stream<List<DietFood>> watchAvailableFood() {
    return _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        // .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DietFood.fromMap(data);
    }).toList());
  }

  /// Watch consumed food list for specific date
  Stream<List<DietFood>> watchConsumedFood(DateTime date) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}')
        .collection('food_consumed_list')
        // .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) {
      final data = doc.data();
      data['id'] = doc.id;

      print("Printing doc ${data}");
      return DietFood.fromMap(data);
    }).toList());
  }


  Stream<FoodStats?> watchConsumedFoodStats(DateTime date) {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}');

    return ref.snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['foodStats'] != null) {
          return FoodStats.fromMap(Map<String, dynamic>.from(data['foodStats']));
        }
      }
      return null;
    });
  }



  /// Add food to available list
  Future<void> addAvailableFood(DietFood food) {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        .doc(food.id);
    final map = food.toMap()..remove('id');
    return ref.set(map);
  }

  /// Add food to consumed list
  Future<void> addConsumedFood(FoodStats latestFoodStatsData, DietFood food, DateTime date) {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}')
        .collection('food_consumed_list')
        .doc(food.id);
    final map = food.toMap()..remove('id');

    // add data to calories counter
    _updateConsumedFoodStats(isSum:true,latestFoodStatsData, food.foodStats, date);
    return ref.set(map);
  }

  /// Delete food from available list
  Future<void> deleteAvailableFood(String id) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        .doc(id)
        .delete();
  }

  /// Delete food from consumed list
  Future<void> deleteConsumedFood(FoodStats latestFoodStatsData, DietFood dietFood, DateTime date) {

    _updateConsumedFoodStats(isSum:false,latestFoodStatsData, dietFood.foodStats, date);
    return _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}')
        .collection('food_consumed_list')
        .doc(dietFood.id)
        .delete();
  }

  /// Update food in available list
  Future<void> updateAvailableFood(String id, DietFood food) {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('food_list')
        .doc(id);
    final map = food.toMap()..remove('id');
    return ref.update(map);
  }

  /// Update food in consumed list
  Future<void> updateConsumedFood(String id, DietFood food, DateTime date) {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}')
        .collection('food_consumed_list')
        .doc(id);
    final map = food.toMap()..remove('id');
    return ref.update(map);
  }



  Future<void> _updateConsumedFoodStats(
      FoodStats latestFoodStatsData,
      FoodStats newFoodStats,
      DateTime date, {
        required bool isSum,
      }) async {

    FoodStats updatedFoodStats;

    if (isSum) {
      updatedFoodStats = latestFoodStatsData.sum(newFoodStats);
    } else {
      updatedFoodStats = latestFoodStatsData.subtract(newFoodStats);
    }

    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}');

    final map = {
      'foodStats': updatedFoodStats.toMap(),
    };

    await ref.set(map, SetOptions(merge: true));
  }





}
