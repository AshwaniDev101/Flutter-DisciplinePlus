
import 'package:flutter/material.dart';

import '../../../models/diet_food.dart';
import '../../../models/food_stats.dart';
import '../core/food_manager.dart';

class FoodListView extends StatelessWidget {
  final Stream<List<DietFood>> stream;
  final bool isConsumed;
  final FoodStats latestStats;

  const FoodListView({
    Key? key,
    required this.stream,
    required this.isConsumed,
    required this.latestStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return StreamBuilder<List<DietFood>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final foods = snapshot.data;
        if (foods == null || foods.isEmpty) {
          return const Center(child: Text('No items yet'));
        }

        return ListView.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            final time = food.time;
            final timeStr =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

            return Card(
              key: ValueKey(food.id),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(food.name),
                subtitle: Text(
                  '${food.foodStats.calories} kcal • ${food.count}g • $timeStr',
                ),
                trailing: IconButton(
                  icon: Icon(isConsumed ? Icons.delete : Icons.add),
                  onPressed: () {
                    if (isConsumed) {
                      FoodManager.instance.removeFromConsumedFood(
                        latestStats,
                        food,
                      );
                    } else {
                      FoodManager.instance.addToConsumedFood(
                        latestStats,
                        food,
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
