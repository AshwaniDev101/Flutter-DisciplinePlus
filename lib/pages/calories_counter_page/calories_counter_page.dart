import 'package:discipline_plus/pages/calories_counter_page/widgets/calorie_progress_bar_dashboard.dart';
import 'package:discipline_plus/pages/calories_counter_page/widgets/global_food_listview.dart';
import 'package:flutter/material.dart';
import '../../models/diet_food.dart';
import 'add_edit_diet_food_dialog.dart';
import 'food_manager.dart';


/// The main page that allows users to view, add, edit, and delete foods,
/// while tracking their total calorie consumption in real time.
class CaloriesCounterPage extends StatefulWidget {
  const CaloriesCounterPage({super.key});

  @override
  State<CaloriesCounterPage> createState() => _CaloriesCounterPageState();
}

class _CaloriesCounterPageState extends State<CaloriesCounterPage> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.grey[50],



      // ===== BODY =====
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            /// Displays a progress bar showing how much of the daily calorie goal is consumed.
            CalorieProgressBarDashboard(
              stream: FoodManager.instance.watchConsumedFoodStats(),
                onClickAdd:(){
                  AddEditDietFoodDialog.show(context, onAdd: (DietFood food) {
                              _addFood(food);
                            });
                },
                onClickBack: (){
                  Navigator.pop(context);
                },
            ),

            const SizedBox(height: 14),

            /// Displays all available and consumed foods in a unified list.
            /// Handles edit and delete actions via callbacks.
            GlobalFoodList(
              stream: FoodManager.instance.watchMergedFoodList(),
              onEdit: (DietFood food) {
                AddEditDietFoodDialog.show(
                  context,
                  food: food,
                  onAdd: (DietFood food) => _editFood(food),
                );
              },
              onDeleted: (DietFood food) {
                _deleteFood(food);
              },
            ),

            searchBar()

          ],
        ),
      ),
    );
  }

  // ===== CRUD OPERATIONS =====

  /// Adds a new [DietFood] item to the database
  /// and shows a confirmation snackbar.
  void _addFood(DietFood food) {
    FoodManager.instance.addToAvailableFood(food);
    _showSnack('${food.name} added!');
  }

  /// Updates an existing [DietFood] entry in the database.
  void _editFood(DietFood food) {
    FoodManager.instance.updateAvailableFood(food);
    _showSnack('${food.name} edited!');
  }

  /// Removes a [DietFood] item from the database.
  void _deleteFood(DietFood food) {
    FoodManager.instance.removeFromAvailableFood(food);
    _showSnack('${food.name} deleted!');
  }

  // ===== HELPER METHODS =====

  /// Displays a simple snackbar for user feedback.
  void _showSnack(String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(message)),
    // );
  }

  Widget searchBar() {
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Material(
        elevation: 4, // adds shadow
        // borderRadius: BorderRadius.circular(16),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none, // removes the default border
            ),
            suffixIcon:IconButton(onPressed: (){}, icon: Icon(Icons.add))
          ),
        ),
      ),
    );
  }



}
