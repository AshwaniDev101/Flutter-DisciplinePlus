import 'package:discipline_plus/models/food_stats.dart';

class DietFood {
  final String id;
  final String name;
  final int quantity; // Number of servings or grams
  final DateTime time;
  final FoodStats foodStats;

  DietFood({
    required this.id,
    required this.name,
    required this.quantity,
    required this.time,
    required this.foodStats,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'time': time.toIso8601String(),
      'foodStats': foodStats.toMap(),
    };
  }

  factory DietFood.fromMap(Map<String, dynamic> map) {
    return DietFood(
      id: map['id'] ?? '',
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      time: DateTime.parse(map['time']),
      foodStats: FoodStats.fromMap(map['foodStats']),
    );
  }
}
