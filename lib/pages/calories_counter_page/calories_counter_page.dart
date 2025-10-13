import 'package:discipline_plus/pages/calories_counter_page/widgets/calorie_progress_bar_dashboard.dart';
import 'package:discipline_plus/pages/calories_counter_page/widgets/global_food_listview.dart';
import 'package:flutter/material.dart';
import '../../models/diet_food.dart';
import 'add_edit_diet_food_dialog.dart';
import 'food_manager.dart';

class CaloriesCounterPage extends StatefulWidget {
  const CaloriesCounterPage({super.key});

  @override
  State<CaloriesCounterPage> createState() => _CaloriesCounterPageState();
}

class _CaloriesCounterPageState extends State<CaloriesCounterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Calorie Counter',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.pink[200],

        actions: [
          IconButton(
              onPressed: () {
                AddEditDietFoodDialog.show(context, onAdd: (DietFood food) {
                  FoodManager.instance.addToAvailableFood(food);
                });

              },
              icon: Icon(
                Icons.add,
                color: Colors.white,
              )),

        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //
      //   },
      //   backgroundColor: Colors.pink[300],
      //   child: Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      // ),
      body: SafeArea(
        child: Column(
          children: [


            SizedBox(
              height: 20,
            ),
            CalorieProgressBarDashboard(
              stream: FoodManager.instance.watchConsumedFoodStats(),
            ),
            SizedBox(
              height: 20,
            ),
            GlobalFoodList(
              stream: FoodManager.instance.watchMergedFoodList(),
              onEdit: (DietFood food) {
                AddEditDietFoodDialog.show(context,food: food, onAdd: (DietFood food) {
                  FoodManager.instance.updateAvailableFood(food);
                });
              },
              onDeleted: (DietFood food) {
                FoodManager.instance.removeFromAvailableFood(food);
              },
              // onIncrement:(DietFood food){
              //
              // },
              // onDecrement:(DietFood food){
              //
              // },
            ),

          ],
        ),
      ),
    );
  }
}
