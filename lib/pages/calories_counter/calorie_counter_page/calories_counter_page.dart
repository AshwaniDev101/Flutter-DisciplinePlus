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

  CalorieCounterPage({Key? key, required this.pageDateTime})
      : super(key: key ?? ValueKey(pageDateTime));

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
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: _getAppBar(context),
      ),
      body: Stack(
        children: [
          /// Scrollable list behind the dashboard
          Positioned.fill(
            child: Container(
              color: Colors.grey[50],
              child: Padding(
                // leave space at the top so items don't overlap dashboard
                padding:
                    const EdgeInsets.only(top: 120, bottom: 20), // tweak to match dashboard height
                child: GlobalFoodList(
                  searchQuery: vm.searchQuery,
                  stream: vm.watchMergedFoodList,
                  onEdit: (DietFood food) => DietFoodDialog.edit(
                    context,
                    food,
                    (DietFood food) => vm.editFood(food),
                  ),
                  onDeleted: vm.deleteFood,
                  onQuantityChange: vm.onQuantityChange,
                ),
              ),
            ),
          ),

          /// Fixed dashboard overlay
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

          /// Search bar fixed at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Search filter',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade400, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade500, width: 1.5),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: (value) => vm.updateSearchQuery = value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAppBar(context) {
    return AppBar(
      backgroundColor: Colors.grey[50],
      // elevation: 2, // subtle shadow if you want it to stand out
      elevation: 0,
      surfaceTintColor: Colors.transparent,
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
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.blueGrey),
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
