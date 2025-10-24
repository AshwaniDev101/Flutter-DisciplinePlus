import 'package:discipline_plus/pages/calories_counter/calorie_counter_page/viewModel/calorie_counter_view_model.dart';
import 'package:discipline_plus/pages/calories_counter/calorie_counter_page/widgets/calorie_progress_bar_dashboard.dart';
import 'package:discipline_plus/pages/calories_counter/calorie_counter_page/widgets/global_food_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/diet_food.dart';
import 'add_edit_diet_food_dialog.dart';
import 'food_manager.dart';

/// The main page that allows users to view, add, edit, and delete foods,
/// while tracking their total calorie consumption in real time.

class CalorieCounterPage extends StatelessWidget {
  final DateTime pageDateTime;

  const CalorieCounterPage({super.key, required this.pageDateTime});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalorieCounterViewModel(pageDateTime: pageDateTime),
      child: _CaloriesCounterPageBody(),
    );
  }
}

class _CaloriesCounterPageBody extends StatelessWidget {


  @override
  Widget build(BuildContext context) {

    final vm = context.watch<CalorieCounterViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),

            CalorieProgressBarDashboard(
              currentDateTime: vm.pageDateTime,
              stream: vm.watchConsumedFoodStats,
              onClickAdd: () {
                AddEditDietFoodDialog.show(context, onDrafted: (DietFood food) {
                  vm.addFood(food);
                });
              },
              onClickBack: () {
                Navigator.pop(context);
              },
            ),

            // const SizedBox(height: 14),

            /// Displays all available and consumed foods in a unified list.
            /// Handles edit and delete actions via callbacks.
            Expanded(
              child: GlobalFoodList(
                searchQuery: vm.searchQuery,
                stream: FoodManager.instance.watchMergedFoodList(vm.pageDateTime),
                onEdit: (DietFood food) {
                  AddEditDietFoodDialog.show(context, food: food, onDrafted: (DietFood editedFood) {
                    vm.editFood(editedFood);
                  });
                },
                onDeleted: (DietFood food) {
                  vm.deleteFood(food);
                },
                onQuantityChange: vm.onQuantityChange
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search filter',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => vm.updateSearchQuery = value
              ),
            ),
            // searchBar()
          ],
        ),
      ),
    );
  }


}
