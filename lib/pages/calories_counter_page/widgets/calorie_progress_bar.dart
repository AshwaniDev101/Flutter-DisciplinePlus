
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../core/utils/helper.dart';
import '../../../models/food_stats.dart';

class CalorieProgressBar extends StatefulWidget {


  final Stream<FoodStats?> stream;
  const CalorieProgressBar({required this.stream, super.key});

  @override
  State<CalorieProgressBar> createState() => _CalorieProgressBarState();
}

class _CalorieProgressBarState extends State<CalorieProgressBar> {


  final atMostProgress = 1600;
  final max = 2000;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FoodStats?>(
      stream: widget.stream,
      initialData: FoodStats.empty(),
      builder: (context, snapshot) {
        final stats = snapshot.data!;

        final progress = stats.calories;



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
                        value: progress / atMostProgress,
                        strokeWidth: 15,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(_getProgressColor(stats)),
                        // valueColor: AlwaysStoppedAnimation(Colors.blue),
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



  Color _getProgressColor(FoodStats? latestStats) {
    if (latestStats == null) {
      return Colors.grey; // default color when data isn't ready
    }

    final kcal = latestStats.calories;

    if (kcal > 2000) {
      return Colors.red;
    } else if (kcal > 1600) {
      return Colors.orange;
    } else {


      return getColorForHeat(calculatePercentage(kcal,1600));
    }
  }

  double calculatePercentage(int current, int total) {
    if (total == 0) return 0; // avoid division by zero
    return (current / total) * 100;
  }

  Color getColorForHeat(double percentage) {
    percentage = percentage.clamp(0, 100);
    return hexToColorWithOpacity("#38d9a9", percentage);
  }




}


