import 'dart:async';

import 'package:discipline_plus/core/utils/helper.dart';
import 'package:discipline_plus/database/services/firebase_diet_food_service.dart';
import 'package:discipline_plus/models/food_stats.dart';
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
  // final DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;



  FoodStats? _latestFoodStatsData;
  final foodStatsController = StreamController<FoodStats?>.broadcast();
  void initFoodStatsStream() {
    FirebaseDietFoodService.instance.watchConsumedFoodStats(DateTime.now()).listen((data) {
      _latestFoodStatsData = data;
      foodStatsController.add(data);
    });
  }
  Stream<FoodStats?> get foodStatsStream => foodStatsController.stream;




  @override
  void initState() {
    super.initState();
    initFoodStatsStream();
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

          SafeArea(child: Text("")),

          StreamBuilder<FoodStats?>(

            // stream: FirebaseDietFoodService.instance.watchConsumedFoodStats(DateTime.now()),
            stream: foodStatsStream,
            builder: (context, snapshot) {
              final stats = snapshot.data;

              final progress = stats?.calories ?? 0;
              final maxProgress = 2000; // Replace with user goal or app setting

              return Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 130,
                          width: 130,
                          child: CircularProgressIndicator(
                            value: progress / maxProgress,
                            strokeWidth: 15,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(_getProgressColor()),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$progress',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/ $maxProgress kcal',
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
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Fat: ${stats?.fats ?? 0}g", style: const TextStyle(fontSize: 12)),
                        Text("Protein: ${stats?.proteins ?? 0}g", style: const TextStyle(fontSize: 12)),
                        Text("Carbs: ${stats?.carbohydrates ?? 0}g", style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              );
            },
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
                  "${dietFood.foodStats.calories} kcal • ${dietFood.quantity}g • ${dietFood.time.hour}:${dietFood.time.minute.toString().padLeft(2, '0')}",
                ),

                  trailing: isEaten
                      ? IconButton(icon: Icon(Icons.delete),
                      onPressed: (){

                        if (_latestFoodStatsData!=null){
                          FoodManager.instance.removeFromConsumedFood(_latestFoodStatsData!, dietFood);
                        }


                      },)
                      : IconButton(icon: Icon(Icons.add),
                      onPressed: (){


                        if (_latestFoodStatsData!=null){
                          FoodManager.instance.addToConsumedFood(_latestFoodStatsData!, dietFood);
                        }



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

  void _showAddDietFoodDialog() {
    final formKey = GlobalKey<FormState>();
    String name = '', calories = '', quantity = '1';
    String proteins = '0', carbohydrates = '0', fats = '0', vitamins = '0', minerals = '0';

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
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Proteins'),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onSaved: (v) => proteins = v!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Carbs'),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onSaved: (v) => carbohydrates = v!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Fats'),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onSaved: (v) => fats = v!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Vitamins'),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onSaved: (v) => vitamins = v!,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Minerals'),
                          keyboardType: TextInputType.number,
                          initialValue: '0',
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                          onSaved: (v) => minerals = v!,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                setState(() {

                  final newDietFood = DietFood(
                    id: generateReadableTimestamp(),
                    name: name,
                    quantity: int.parse(quantity),
                    time: DateTime.now(),
                    foodStats: FoodStats(
                      proteins: int.parse(proteins),
                      carbohydrates: int.parse(carbohydrates),
                      fats: int.parse(fats),
                      vitamins: int.parse(vitamins),
                      minerals: int.parse(minerals),
                      calories: int.parse(calories),
                    ),
                  );
                  FoodManager.instance.addToAvailableFood(newDietFood);
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
