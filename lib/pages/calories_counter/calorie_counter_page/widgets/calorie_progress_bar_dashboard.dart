import 'package:discipline_plus/pages/calories_counter/calorie_history_page/viewModel/calorie_history_view_model.dart';
import 'package:discipline_plus/pages/calories_counter/widget/caution_label_widget.dart';
import 'package:discipline_plus/widget/new_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final textColor = Colors.grey[800];

    return StreamBuilder<FoodStats?>(
      stream: widget.stream,
      initialData: FoodStats.empty(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final foodStats = snapshot.data ?? FoodStats.empty();
        final caloriesCount = foodStats.calories;

        return Card(
          margin: const EdgeInsets.all(12),
          elevation: 2,

          clipBehavior: Clip.antiAlias,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [

                /// Back button (top-left)
                // Positioned(
                //   top: 0,
                //   left: 0,
                //   child: IconButton(
                //     onPressed: widget.onClickBack,
                //     style: IconButton.styleFrom(
                //       backgroundColor: Colors.grey.shade100,
                //     ),
                //     icon: const Icon(Icons.arrow_back, color: Colors.grey, size: 24),
                //   ),
                // ),

                /// Add Button (bottom-right)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: NewButton(
                      label: 'New',
                      onPressed: widget.onClickAdd,
                    ),
                  ),
                ),

                /// Main Content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),

                    /// Progress + Details Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular Progress
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 90,
                              width: 90,
                              child: CircularProgressIndicator(
                                value: caloriesCount / AppSettings.atMaxCalories,
                                strokeWidth: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  getProgressCircleColor(foodStats),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(

                                  '${formatNumber(caloriesCount)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  '/${AppSettings.atLeastCalories} kcal',
                                  style: TextStyle(fontSize: 10, color: textColor),
                                ),
                                Text(
                                  'Max (${AppSettings.atMaxCalories})',
                                  style: TextStyle(fontSize: 8, color: textColor),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(width: 30),

                        // Right Side Info
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: !isSameDate(widget.currentDateTime, DateTime.now())
                                  ? null
                                  : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ChangeNotifierProvider(
                                          create: (_) => CalorieHistoryViewModel(pageDateTime: widget.currentDateTime,),

                                          child: CalorieHistoryPage(),
                                        ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                getCurrentDateFormatted(widget.currentDateTime),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            const SizedBox(height: 8),
                            CationLabelWidget(foodStats: foodStats),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}