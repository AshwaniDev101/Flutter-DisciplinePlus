import 'package:discipline_plus/core/utils/helper.dart';
import 'package:discipline_plus/pages/dietpage/core/food_manager.dart';
import 'package:flutter/material.dart';


import '../../models/diet_food.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  _DietPageState createState() => _DietPageState();
}

// class DietFood {
//   final String name;
//   final int kcal;
//   final int quantity;
//   final String mealType;
//   final DateTime time;
//
//   DietFood(this.name, this.kcal, this.quantity, this.mealType, this.time);
// }

class _DietPageState extends State<DietPage> {
  // Progress tracking
  final double _progress = 0;
  final double _maxProgress = 1500;

  // Date and pagination
  final DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;

  // DietFood lists
  // final List<DietFood> _DietFoodList = [
  //   DietFood(id:"temp id", name: 'Apple',kcal: 95,quantity: 1,mealType: "Breakfast", time: DateTime.now()),
  //   DietFood(id:"temp id", name: 'Grilled Chicken',kcal: 250,quantity: 1,mealType: "Lunch", time: DateTime.now()),
  //   DietFood(id:"temp id", name: 'Salad',kcal: 150,quantity: 1,mealType: "Dinner", time: DateTime.now()),
  //
  // ];
  // final List<DietFood> _DietFoodEatenList = [];

  @override
  void initState() {
    super.initState();
    // _updateProgress();
  }

  // void _updateProgress() {
  //   final total = _DietFoodEatenList.fold<int>(0, (sum, f) => sum + f.kcal * f.quantity);
  //   setState(() => _progress = total.toDouble());
  // }
  //
  // void _moveItem(int index, bool fromEaten) {
  //   setState(() {
  //     if (fromEaten) {
  //
  //       FoodManager.r
  //       final item = _DietFoodEatenList.removeAt(index);
  //       _DietFoodList.add(item);
  //     } else {
  //       final item = _DietFoodList.removeAt(index);
  //       _DietFoodEatenList.add(item);
  //     }
  //     _updateProgress();
  //   });
  // }

  void _onHeaderSwipe(DragUpdateDetails details) {
    if (details.delta.dx < -10 && _currentIndex < 1) {
      _goToPage(_currentIndex + 1);
    } else if (details.delta.dx > 10 && _currentIndex > 0) {
      _goToPage(_currentIndex - 1);
    }
  }

  void _goToPage(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Color _getProgressColor() {
    final ratio = _progress / _maxProgress;
    if (ratio < 0.6) return Colors.green;
    if (ratio < 0.9) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          // Header with progress + swipe/tap control

          SafeArea(child: Text("")),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: _onHeaderSwipe,
            child: Column(
              children: [
                Container(
                  // color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderTab('DietFood', 0),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            height: 130, // Increased from 150
                            width: 130,  // Increased from 150
                            child: CircularProgressIndicator(
                              value: _progress / _maxProgress,
                              strokeWidth: 15, // Increased from 10
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${_progress.toInt()}',
                                style: const TextStyle(
                                  fontSize: 32, // Increased from 20
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '/ ${_maxProgress.toInt()} kcal',
                                style: TextStyle(
                                  fontSize: 16, // Increased from 12
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildHeaderTab('Eaten', 1),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fat: 100g", style: TextStyle(fontSize: 12),),
                      Text("Nutrition: 130g", style: TextStyle(fontSize: 12),),
                      Text("Curbs: 220g", style: TextStyle(fontSize: 12),),
                    ],),
                ),
              ],
            ),



          ),



          // PageView content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildListView(FoodManager.instance.watchAvailableFood(), false),
                _buildListView(FoodManager.instance.watchConsumedFood(), true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDietFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeaderTab(String label, int index) {
    final selected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.blue : Colors.black87,
        ),
      ),
    );
  }




  Widget _buildListView(Stream<List<DietFood>> stream, bool isEaten) {
    return StreamBuilder<List<DietFood>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No items yet"));
        }

        final list = snapshot.data!;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final DietFood dietFood = list[index];
            return Dismissible(

              key: Key(dietFood.hashCode.toString()),
              background: Container(color: Colors.redAccent),
              onDismissed: (dir) {
                // index, isEaten
                FoodManager.instance.addToConsumedFood(dietFood);

              },
              confirmDismiss: (dir) async {
                return false;
              },

              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(dietFood.name),
                  subtitle: Text(
                    "${dietFood.kcal} kcal • ${dietFood.quantity}g • ${dietFood.mealType} • ${dietFood.time.hour}:${dietFood.time.minute.toString().padLeft(2, '0')}",
                  ),
                  trailing: isEaten
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.fastfood, color: Colors.orange),
                ),
              ),
            );
          },
        );
      },
    );
  }


  // Widget _buildListView(List<DietFood> list, bool isEaten) {
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(8),
  //     itemCount: list.length,
  //     itemBuilder: (context, index) {
  //       final item = list[index];
  //       return Dismissible(
  //         key: Key(item.hashCode.toString()),
  //         background: Container(color: Colors.redAccent),
  //         onDismissed: (_) => _moveItem(index, isEaten),
  //         child: Card(
  //           margin: const EdgeInsets.symmetric(vertical: 6),
  //           child: ListTile(
  //             leading: Icon(_iconForMeal(item.mealType)),
  //             title: Text(item.name),
  //             subtitle: Text(
  //                 '${item.kcal * item.quantity} kcal (${item.quantity}x)'),
  //             trailing: Text(DateFormat('HH:mm').format(item.time)),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  IconData _iconForMeal(String type) {
    switch (type) {
      case 'Breakfast':
        return Icons.breakfast_dining;
      case 'Lunch':
        return Icons.lunch_dining;
      case 'Dinner':
        return Icons.dinner_dining;
      default:
        return Icons.breakfast_dining_rounded;
    }
  }

  void _showAddDietFoodDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '', calories = '', quantity = '1', mealType = 'Breakfast';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New DietFood'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: mealType,
                  items: ['Breakfast', 'Lunch', 'Dinner', 'Snack']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) => mealType = v!,
                  decoration: const InputDecoration(labelText: 'Meal Type'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'DietFood Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => name = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Calories'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => calories = v!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  initialValue: '1',
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => quantity = v!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                setState(() {
                  final newfood = DietFood(
                    id:generateReadableTimestamp(),
                      name: name,
                    kcal: int.parse(calories),
                    quantity: int.parse(quantity),
                    mealType:mealType,
                    time: DateTime.now()
                  );

                  FoodManager.instance.addToAvailableFood(newfood);
                  // _DietFoodList.add(newfood);
                  // _updateProgress();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
