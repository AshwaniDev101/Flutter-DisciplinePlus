
class DietFood {
  final String id;
  final String name;
  final int kcal;
  final int quantity; // Number of servings or grams
  final String mealType; // e.g. 'Breakfast', 'Lunch', 'Dinner', 'Snack'
  final DateTime time;

  DietFood({
    required this.id,
    required this.name,
    required this.kcal,
    required this.quantity,
    required this.mealType,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'kcal': kcal,
      'quantity': quantity,
      'mealType': mealType,
      'time': time.toIso8601String(),
    };
  }

  factory DietFood.fromMap(Map<String, dynamic> map) {
    return DietFood(
      id: map['id'] ?? '', // fallback if id is not present
      name: map['name'] as String,
      kcal: map['kcal'] as int,
      quantity: map['quantity'] as int,
      mealType: map['mealType'] as String,
      time: DateTime.parse(map['time']),
    );
  }
}
