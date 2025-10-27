import 'package:discipline_plus/pages/calories_counter/widget/caution_label_widget.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/app_settings.dart';
import '../../../../core/utils/helper.dart';
import '../../../../models/food_stats.dart';
import '../../calorie_history_page/calorie_history_page.dart';
import '../../helper/progress_visuals_helper.dart';

class CalorieProgressBarDashboard extends StatefulWidget {
  final void Function() onClickAdd;
  final void Function() onClickBack;

  final DateTime currentDateTime;
  final Stream<FoodStats?> stream;

  const CalorieProgressBarDashboard(
      {required this.currentDateTime,
      required this.stream,
      super.key,
      required this.onClickAdd,
      required this.onClickBack});

  @override
  State<CalorieProgressBarDashboard> createState() => _CalorieProgressBarDashboardState();
}

class _CalorieProgressBarDashboardState extends State<CalorieProgressBarDashboard> {
  Widget _getTitle() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child:
          Text('Calorie Counter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
    );
  }

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

        final foodStats = snapshot.data ?? FoodStats.empty();
        final caloriesCount = foodStats.calories;

        return SizedBox(
          height: 100,
          // color:Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Add button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: TextButton(
                        onPressed: widget.onClickAdd,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue,
                          // bright background
                          foregroundColor: Colors.white,
                          // text color
                          // padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25), // rounded corners
                          ),
                          shadowColor: Colors.blueAccent,
                          elevation: 1, // gives subtle shadow
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline_rounded),
                            SizedBox(width: 5,),
                            const Text(
                              'New',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top-left Back Icon
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200], // background color
                          shape: BoxShape.circle, // makes it circular
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

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // SizedBox(width: 20,),
                      // Progress Bar
                      Stack(
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
                                      height: 70,
                                      width: 70,
                                      child: CircularProgressIndicator(
                                        value: caloriesCount / AppSettings.atMaxCalories,
                                        strokeWidth: 10,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor: AlwaysStoppedAnimation(getProgressCircleColor(foodStats)),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$caloriesCount',
                                          style: TextStyle(
                                              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]!),
                                        ),
                                        Text('/${AppSettings.atLeastCalories} kcal', style: TextStyle(fontSize: 8)),
                                        Text('Max(${AppSettings.atMaxCalories})', style: TextStyle(fontSize: 6)),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      // Elevated button and Excess Label
                      Column(
                        children: [
                          _getTitle(),

                          ElevatedButton(
                            onPressed: !isSameDate(widget.currentDateTime, DateTime.now())
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CalorieHistoryPage(pageDateTime: widget.currentDateTime),
                                      ),
                                    );
                                  },
                            child: Text(getCurrentDateFormatted(widget.currentDateTime)),
                          ),

                          SizedBox(
                            height: 4,
                          ),
                          // _getExcessCaloriesLabel(caloriesCount)
                          CationLabelWidget(foodStats: foodStats)
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
