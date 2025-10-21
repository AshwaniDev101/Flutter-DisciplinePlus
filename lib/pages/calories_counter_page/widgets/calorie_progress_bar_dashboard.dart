import 'package:discipline_plus/pages/calories_counter_page/calorie_history_page/calorie_history_page.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/helper.dart';
import '../../../core/utils/app_settings.dart';
import '../../../models/food_stats.dart';

class CalorieProgressBarDashboard extends StatefulWidget {
  final void Function() onClickAdd;
  final void Function() onClickBack;

  final DateTime currentDateTime;
  final Stream<FoodStats?> stream;

  const CalorieProgressBarDashboard(
      {required this.currentDateTime,required this.stream, super.key, required this.onClickAdd, required this.onClickBack});

  @override
  State<CalorieProgressBarDashboard> createState() =>
      _CalorieProgressBarDashboardState();
}

class _CalorieProgressBarDashboardState
    extends State<CalorieProgressBarDashboard> {



  Widget _getTitle()
  {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Text('Calorie Counter',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800])),
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

        final stats = snapshot.data ?? FoodStats.empty();
        final caloriesCount = stats.calories;

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


                  Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      SizedBox(width: 20,),
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
                                      height: 80,
                                      width: 80,

                                      child: CircularProgressIndicator(
                                        value: caloriesCount / AppSettings.atMostProgress,
                                        strokeWidth: 12,
                                        backgroundColor: Colors.grey.shade200,
                                        valueColor:
                                            AlwaysStoppedAnimation(getProgressColor(stats)),
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$caloriesCount',
                                          style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[500]!),
                                        ),
                                         Text('${AppSettings.atMostProgress} kcal',
                                            style: TextStyle(fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),


                              ],
                            ),
                          ),






                        ],
                      ),
                      SizedBox(width: 20,),
                      // Elevated button and Excess Label
                      Column(
                        children: [


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

                          SizedBox(height: 4,),
                          _getExcessCaloriesLabel(caloriesCount)

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


  Widget _getExcessCaloriesLabel(int caloriesCount) {
    int diff = caloriesCount - AppSettings.atMostProgress;

    // Add "+" sign only for positive numbers
    String formatted = '${diff > 0 ? '+$diff' : '$diff'} kcal';


    return                             Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        formatted,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );


  }



}
