class FoodStats {
  final int proteins;
  final int carbohydrates;
  final int fats;
  final int vitamins;
  final int minerals;
  final int calories;

  FoodStats({
    required this.proteins,
    required this.carbohydrates,
    required this.fats,
    required this.vitamins,
    required this.minerals,
    required this.calories,
  });

  FoodStats sum(FoodStats other) {
    return FoodStats(
      proteins: proteins + other.proteins,
      carbohydrates: carbohydrates + other.carbohydrates,
      fats: fats + other.fats,
      vitamins: vitamins + other.vitamins,
      minerals: minerals + other.minerals,
      calories: calories + other.calories,
    );
  }

  FoodStats subtract(FoodStats other) {
    return FoodStats(
      proteins: proteins - other.proteins,
      carbohydrates: carbohydrates - other.carbohydrates,
      fats: fats - other.fats,
      vitamins: vitamins - other.vitamins,
      minerals: minerals - other.minerals,
      calories: calories - other.calories,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'proteins': proteins,
      'carbohydrates': carbohydrates,
      'fats': fats,
      'vitamins': vitamins,
      'minerals': minerals,
      'calories': calories,
    };
  }

  factory FoodStats.fromMap(Map<String, dynamic> map) {
    return FoodStats(
      proteins: map['proteins'] as int,
      carbohydrates: map['carbohydrates'] as int,
      fats: map['fats'] as int,
      vitamins: map['vitamins'] as int,
      minerals: map['minerals'] as int,
      calories: map['calories'] as int,
    );
  }
}
