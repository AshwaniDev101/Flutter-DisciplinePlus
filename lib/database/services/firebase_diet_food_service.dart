import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discipline_plus/models/diet_food.dart';

class FirebaseDietFoodService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton
  FirebaseDietFoodService._();
  static final instance = FirebaseDietFoodService._();

  final String userId = 'user1'; // replace this with dynamic user ID if needed

  /// Watch available food list
  Stream<List<DietFood>> watchAvailableFood() {
    return _db
        .collection(userId)
        .doc('food_available_list')
        .collection('items')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DietFood.fromMap(data);
    }).toList());
  }

  /// Watch consumed food list
  Stream<List<DietFood>> watchConsumedFood() {
    return _db
        .collection(userId)
        .doc('food_consumed_list')
        .collection('items')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return DietFood.fromMap(data);
    }).toList());
  }

  /// Add food to available list
  Future<void> addAvailableFood(DietFood food) {
    final ref = _db
        .collection(userId)
        .doc('food_available_list')
        .collection('items')
        .doc(food.id);
    final map = food.toMap()..remove('id');
    return ref.set(map);
  }

  /// Add food to consumed list
  Future<void> addConsumedFood(DietFood food) {
    final ref = _db
        .collection(userId)
        .doc('food_consumed_list')
        .collection('items')
        .doc(food.id);
    final map = food.toMap()..remove('id');
    return ref.set(map);
  }

  /// Delete food from available list
  Future<void> deleteAvailableFood(String id) {
    return _db
        .collection(userId)
        .doc('food_available_list')
        .collection('items')
        .doc(id)
        .delete();
  }

  /// Delete food from consumed list
  Future<void> deleteConsumedFood(String id) {
    return _db
        .collection(userId)
        .doc('food_consumed_list')
        .collection('items')
        .doc(id)
        .delete();
  }

  /// Update food in available list
  Future<void> updateAvailableFood(String id, DietFood food) {
    final ref = _db
        .collection(userId)
        .doc('food_available_list')
        .collection('items')
        .doc(id);
    final map = food.toMap()..remove('id');
    return ref.update(map);
  }

  /// Update food in consumed list
  Future<void> updateConsumedFood(String id, DietFood food) {
    final ref = _db
        .collection(userId)
        .doc('food_consumed_list')
        .collection('items')
        .doc(id);
    final map = food.toMap()..remove('id');
    return ref.update(map);
  }
}
