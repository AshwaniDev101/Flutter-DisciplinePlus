
import 'package:discipline_plus/pages/calories_counter_page/calorie_history_page/calorie_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../core/utils/helper.dart';
import '../../../models/food_stats.dart';

class CalorieProgressBarDashboard extends StatefulWidget {


  final Stream<FoodStats?> stream;
  const CalorieProgressBarDashboard({required this.stream, super.key});

  @override
  State<CalorieProgressBarDashboard> createState() => _CalorieProgressBarDashboardState();
}

class _CalorieProgressBarDashboardState extends State<CalorieProgressBarDashboard> {


  final atMostProgress = 1600;
  final max = 2000;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FoodStats?>(
      stream: widget.stream,
      initialData: FoodStats.empty(),
      builder: (context, snapshot) {

        // Safely handle null or loading states
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data ?? FoodStats.empty();
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
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,color: Colors.grey[500]!),
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

            ElevatedButton(child: Text(getCurrentDateFormatted()),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CalorieHistoryPage()
                    ),
                  );
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


      return Colors.greenAccent[400]!;
    }
  }


  String getCurrentDateFormatted() {
    final now = DateTime.now(); // Get current date and time
    final day = now.day.toString().padLeft(2, '0');   // Ensure two digits
    final month = now.month.toString().padLeft(2, '0'); // Ensure two digits
    final year = now.year.toString();

    return '$day/$month/$year';
  }


}


