import 'package:flutter/cupertino.dart';

import '../../../models/food_stats.dart';

class CalorieProgress extends StatelessWidget {
  final FoodStats stats;
  CalorieProgress(this.stats);
  @override
  Widget build(_) {
    final ratio = stats.calories/2000;
    return Stack( /* your circular indicator + labels */ );
  }
}