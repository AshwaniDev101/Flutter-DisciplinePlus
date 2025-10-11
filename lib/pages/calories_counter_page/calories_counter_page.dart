
import 'package:discipline_plus/pages/calories_counter_page/widgets/calorie_progress_bar.dart';
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

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          AddEditDietFoodDialog.show(context, onAdd: (DietFood food){

              FoodManager.instance.addToAvailableFood(food);

          });
        },
        backgroundColor: Colors.pink[300],
        child: Icon(Icons.add,color: Colors.white,),
      ),

      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 30,),
            CalorieProgressBar(),
            SizedBox(height:30,),
            GlobalFoodList(
              stream: FoodManager.instance.watchMergedFoodList(),
              onEdit: (DietFood food){
                FoodManager.instance.editAvailableFood(food);
              },
              onDeleted: (DietFood food){
                FoodManager.instance.removeFromAvailableFood(food);
              },
              // onIncrement:(DietFood food){
              //
              // },
              // onDecrement:(DietFood food){
              //
              // },
            )

          ],
        ),
      ),
    );

  }











}
