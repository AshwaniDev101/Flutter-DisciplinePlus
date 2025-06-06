import 'package:discipline_plus/core/utils/helper.dart';
import 'package:discipline_plus/pages/dietpage/core/food_manager.dart';
import 'package:flutter/material.dart';


import '../../models/diet_food.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  _DietPageState createState() => _DietPageState();
}


class _DietPageState extends State<DietPage> {
  // Progress tracking
  final double _progress = 0;
  final double _maxProgress = 1500;

  // Date and pagination
  final DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;



  @override
  void initState() {
    super.initState();
    // _updateProgress();
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
          Column(
            children: [
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 130,
                      width: 130,
                      child: CircularProgressIndicator(
                        value: _progress / _maxProgress,
                        strokeWidth: 15,
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
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '/ ${_maxProgress.toInt()} kcal',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),

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


          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabButton('Available', 0),
                    _buildTabButton('Consumed', 1),
                  ],
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentIndex = index),
                    children: [
                      _buildListView(FoodManager.instance.watchAvailableFood(), false),
                      _buildListView(FoodManager.instance.watchConsumedFood(), true),
                    ],
                  ),
                ),
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



  Widget _buildTabButton(String title, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
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
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(dietFood.name),
                subtitle: Text(
                  "${dietFood.kcal} kcal • ${dietFood.quantity}g • ${dietFood.mealType} • ${dietFood.time.hour}:${dietFood.time.minute.toString().padLeft(2, '0')}",
                ),

                  trailing: isEaten
                      ? IconButton(icon: Icon(Icons.delete),
                      onPressed: (){
                        FoodManager.instance.removeFromConsumedFood(dietFood);

                      },)
                      : IconButton(icon: Icon(Icons.add),
                      onPressed: (){
                        FoodManager.instance.addToConsumedFood(dietFood);

                      }

                  )

                // trailing: isEaten
                //     ? Icon(Icons.check_circle, color: Colors.green)
                //     : Icon(Icons.fastfood, color: Colors.orange),
              ),
            );
          },
        );
      },
    );
  }


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
