import 'package:discipline_plus/pages/calories_counter/calorie_counter_page/viewModel/calorie_counter_view_model.dart';
import 'package:discipline_plus/pages/calories_counter/calorie_counter_page/widgets/calorie_progress_bar_dashboard.dart';
import 'package:discipline_plus/pages/calories_counter/calorie_counter_page/widgets/global_food_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/diet_food.dart';
import 'new_diet_food/add_edit_diet_food_dialog.dart';

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

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),



        child: _getAppBar(context)
      ),

      body: SafeArea(
        child: Column(
          children: [
            // const SizedBox(height: 14),

            CalorieProgressBarDashboard(
              currentDateTime: vm.pageDateTime,
              stream: vm.watchConsumedFoodStats,
              onClickAdd: () => DietFoodDialog.add(context, (DietFood food) {
                vm.addFood(food);
              }),
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
                  // stream: FoodManager.instance.watchMergedFoodList(vm.pageDateTime),
                  stream: vm.watchMergedFoodList,
                  onEdit: (DietFood food) => DietFoodDialog.edit(
                        context,
                        food,
                        (DietFood food) {
                          vm.editFood(food);
                        },
                      ),
                  onDeleted: (DietFood food) {
                    vm.deleteFood(food);
                  },
                  onQuantityChange: vm.onQuantityChange),
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
                  onChanged: (value) => vm.updateSearchQuery = value),
            ),
            // searchBar()
          ],
        ),
      ),
    );
  }



  Widget _getAppBar(context)
  {
    return  AppBar(
      backgroundColor: Colors.grey[50],
      // elevation: 2, // subtle shadow if you want it to stand out
      title: const Text(
        'Today',
        style: TextStyle(
          color: Colors.blueGrey,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // left icon
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueGrey),
        onPressed: () {
          Navigator.pop(context); // or custom logic
        },
      ),

      // right-side actions (3-dot menu, icons, etc.)
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.blueGrey),
          onPressed: () {
            // search logic
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, color: Colors.blueGrey),
          onSelected: (value) {
            if (value == 'Edit') {
              // handle edit
            } else if (value == 'Delete') {
              // handle delete
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(value: 'Edit', child: Text('Edit')),
            const PopupMenuItem(value: 'Delete', child: Text('Delete')),
          ],
        ),
      ],
    );
  }
}
