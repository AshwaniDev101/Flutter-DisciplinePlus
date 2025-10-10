
import 'package:flutter/material.dart';
import '../../../models/food_stats.dart';

class CaloriesStates extends StatefulWidget {
  const CaloriesStates({super.key});

  @override
  State<CaloriesStates> createState() => _CaloriesStatesState();
}

class _CaloriesStatesState extends State<CaloriesStates> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FoodStats?>(
      stream: null,
      initialData: FoodStats.empty(),
      builder: (context, snapshot) {
        final stats = snapshot.data!;

        final progress = stats.calories;
        const maxProgress = 2000;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        value: progress / maxProgress,
                        strokeWidth: 15,
                        backgroundColor: Colors.grey.shade200,
                        // valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$progress',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text('2000 kcal', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fat: ${stats.fats}", style: const TextStyle(fontSize: 12)),
                  Text("Protein: ${stats.proteins}", style: const TextStyle(fontSize: 12)),
                  Text("Minerals: ${stats.minerals}", style: const TextStyle(fontSize: 12)),
                  Text("Carbs: ${stats.carbohydrates}", style: const TextStyle(fontSize: 12)),
                  Text("Vitamins: ${stats.vitamins}", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

            ElevatedButton(child: Text("Date"),
                onPressed: (){

                }
            ),

          ],
        );
      },
    );
  }



  // Color _getProgressColor() {
  //   final ratio = _latestStats.calories / _maxProgress;
  //   if (ratio < 0.6) return Colors.pink.shade300;
  //   if (ratio < 0.9) return Colors.orange;
  //   return Colors.red;
  // }


}


