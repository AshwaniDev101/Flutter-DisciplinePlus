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
      backgroundColor: Colors.white,

      // // ===== APP BAR =====
      // appBar: AppBar(
      //   title: const Text(
      //     'Calorie Counter',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20,
      //       color: Colors.white,
      //     ),
      //   ),
      //   iconTheme: const IconThemeData(color: Colors.white),
      //   backgroundColor: Colors.pink[200],
      //   actions: [
      //     // Add new food item
      //     IconButton(
      //       onPressed: () {
      //         AddEditDietFoodDialog.show(context, onAdd: (DietFood food) {
      //           _addFood(food);
      //         });
      //       },
      //       icon: const Icon(Icons.add, color: Colors.white),
      //     ),
      //   ],
      // ),

      // ===== BODY =====
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

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

            const SizedBox(height: 20),

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
