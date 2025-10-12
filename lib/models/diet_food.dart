
import 'package:discipline_plus/models/food_stats.dart';

class DietFood {
  final String id;
  final String name;
  final DateTime time;
  final FoodStats foodStats;
  final double count;

  DietFood({
    required this.id,
    required this.name,
    required this.time,
    required this.foodStats,
    this.count = 0, // available food default count = 0
  });

  /// For Available Food: usually no count and no time or default time
  factory DietFood.fromAvailableMap(Map<String, dynamic> map) {
    return DietFood(
      id: map['id'] ?? '',
      name: map['name'] as String,
      time: DateTime.tryParse(map['time'] ?? '') ?? DateTime.now(),
      foodStats: FoodStats.fromMap(map['foodStats']),
      count: 0, // no count for available food
    );
  }

  Map<String, dynamic> toAvailableMap() {
    return {
      'id': id,
      'name': name,
      'time': time.toIso8601String(),
      'foodStats': foodStats.toMap(),
      // no count field for available food
    };
  }

  /// For Consumed Food: includes count and time is relevant
  factory DietFood.fromConsumedMap(Map<String, dynamic> map) {
    return DietFood(
      id: map['id'] ?? '',
      name: '', // placeholder, should be resolved externally
      time: DateTime.parse(map['time']),
      foodStats: FoodStats.empty(), // placeholder, resolve using ID
      count: map['count'] ?? 1,
    );
  }

  Map<String, dynamic> toConsumedMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'count': count,
    };
  }

  DietFood copyWith({
    String? id,
    String? name,
    DateTime? time,
    FoodStats? foodStats,
    double? count,
  }) {
    return DietFood(
      id: id ?? this.id,
      name: name ?? this.name,
      time: time ?? this.time,
      foodStats: foodStats ?? this.foodStats,
      count: count ?? this.count,
    );
  }
}













// import 'package:discipline_plus/models/food_stats.dart';
//
// class DietFood {
//   final String id;
//   final String name;
//   final DateTime time;
//   final FoodStats foodStats;
//   final int count; // optional count for consumed items
//
//   DietFood({
//     required this.id,
//     required this.name,
//     required this.time,
//     required this.foodStats,
//     this.count = 1, // default to 1 if not specified
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'time': time.toIso8601String(),
//       'foodStats': foodStats.toMap(),
//       'count': count,
//     };
//   }
//
//   factory DietFood.fromMap(Map<String, dynamic> map) {
//     return DietFood(
//       id: map['id'] ?? '',
//       name: map['name'] as String,
//       time: DateTime.parse(map['time']),
//       foodStats: FoodStats.fromMap(map['foodStats']),
//       count: map['count'] ?? 1,
//     );
//   }
//
//   DietFood copyWith({
//     String? id,
//     String? name,
//     DateTime? time,
//     FoodStats? foodStats,
//     int? count,
//   }) {
//     return DietFood(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       time: time ?? this.time,
//       foodStats: foodStats ?? this.foodStats,
//       count: count ?? this.count,
//     );
//   }
// }
