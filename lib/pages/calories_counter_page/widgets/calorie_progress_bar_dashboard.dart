import 'package:discipline_plus/pages/calories_counter_page/calorie_history_page/calorie_history_page.dart';
import 'package:flutter/material.dart';
import '../../../models/food_stats.dart';

class CalorieProgressBarDashboard extends StatefulWidget {
  final void Function() onClickAdd;
  final void Function() onClickBack;

  final Stream<FoodStats?> stream;

  const CalorieProgressBarDashboard(
      {required this.stream, super.key, required this.onClickAdd, required this.onClickBack});

  @override
  State<CalorieProgressBarDashboard> createState() =>
      _CalorieProgressBarDashboardState();
}

class _CalorieProgressBarDashboardState
    extends State<CalorieProgressBarDashboard> {
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

        return SizedBox(
          height: 100,
          // color:Colors.white,
          child: Stack(

            children: [
              // Main Center Row
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,

                          child: CircularProgressIndicator(
                            value: progress / atMostProgress,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor:
                                AlwaysStoppedAnimation(_getProgressColor(stats)),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$progress',
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500]!),
                            ),
                             Text('$atMostProgress kcal',
                                style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      child: Text(getCurrentDateFormatted()),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CalorieHistoryPage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Top-left Back Icon

              // Top-left Back Icon
              Positioned(
                top: 0,
                left: 0,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // background color
                      shape: BoxShape.circle,  // makes it circular
                    ),
                    child: IconButton(
                      onPressed: widget.onClickBack,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.grey,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // background color
                      shape: BoxShape.circle,  // makes it circular
                    ),
                    child: IconButton(
                      onPressed: widget.onClickAdd,
                      icon: Icon(
                        Icons.add,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned(
              //   top: 0,
              //   right: 0,
              //   child: Padding(
              //     padding: const EdgeInsets.all(8.0),
              //     child: Container(
              //       decoration: BoxDecoration(
              //         color: Colors.grey[200], // background color
              //         shape: BoxShape.circle,  // makes it circular
              //       ),
              //       child: IconButton(
              //         onPressed: widget.onClickAdd,
              //         icon: Icon(
              //           Icons.settings,
              //           color: Colors.grey[600],
              //           size: 18,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),



            ],
          ),
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
    final day = now.day.toString().padLeft(2, '0'); // Ensure two digits
    final month = now.month.toString().padLeft(2, '0'); // Ensure two digits
    final year = now.year.toString();

    return '$day/$month/$year';
  }
}
