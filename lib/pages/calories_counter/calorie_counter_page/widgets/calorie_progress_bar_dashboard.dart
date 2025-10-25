
import 'package:flutter/material.dart';

import '../../../../core/utils/app_settings.dart';
import '../../../../core/utils/helper.dart';
import '../../../../models/food_stats.dart';
import '../../calorie_history_page/calorie_history_page.dart';


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
      padding: const EdgeInsets.all(2.0),
      child: Text('Calorie Counter',
          style: TextStyle(
              fontSize: 12,
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
                        child: const Text(
                          'New',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    // child: Padding(
                    //   padding: const EdgeInsets.all(8.0),
                    //   child: Container(
                    //     decoration: BoxDecoration(
                    //       color: Colors.grey[200], // background color
                    //       shape: BoxShape.circle,  // makes it circular
                    //     ),
                    //     child: IconButton(
                    //       onPressed: widget.onClickAdd,
                    //       icon: Icon(
                    //         Icons.add,
                    //         color: Colors.grey[600],
                    //         size: 18,
                    //       ),
                    //     ),
                    //   ),
                    // ),
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
                                        value: caloriesCount / AppSettings.atLeastCalories,
                                        strokeWidth: 10,
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
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[700]!
                                            ),
                                        ),
                                         Text('/${AppSettings.atLeastCalories} kcal',
                                            style: TextStyle(fontSize: 9)),
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
    int diff = caloriesCount - AppSettings.atLeastCalories;

    // Add "+" sign only for positive numbers
    String formatted = '${diff > 0 ? '+$diff' : '$diff'} kcal';
    // String formatted = '+${diff} kcal';


    return                             Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: diff > 0 ?Colors.red.shade700:Colors.green.shade700,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: diff > 0?Colors.red.withValues(alpha: 0.6):Colors.green.withValues(alpha: 0.6),
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
