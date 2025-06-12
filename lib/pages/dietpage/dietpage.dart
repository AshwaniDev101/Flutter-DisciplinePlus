import 'dart:async';

import 'package:discipline_plus/core/utils/helper.dart';
import 'package:discipline_plus/database/services/firebase_diet_food_service.dart';
import 'package:discipline_plus/models/food_stats.dart';
import 'package:discipline_plus/pages/dietpage/core/food_manager.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';


import '../../models/diet_food.dart';

class DietPage extends StatefulWidget {
  const DietPage({super.key});

  @override
  _DietPageState createState() => _DietPageState();
}


class _DietPageState extends State<DietPage> {
  // Progress tracking
  final double _maxProgress = 1500;

  late final Stream<List<DietFood>> _sharedMerged;
  late final Stream<List<DietFood>> _availableStream;
  late final Stream<List<DietFood>> _consumedStream;

  final PageController _pageController = PageController(initialPage: 0);
  int _currentIndex = 0;



  late final StreamSubscription<FoodStats?> _statsSub;
  final _statsSubject = BehaviorSubject<FoodStats>.seeded(FoodStats.empty());

  void initFoodStatsStream() {
    _statsSub = FirebaseDietFoodService
        .instance
        .watchConsumedFoodStats(DateTime.now())
        .listen((data) {

          if(data!=null)
            {
              _statsSubject.add(data);
            }

    });
  }

  Stream<FoodStats?> get foodStatsStream => _statsSubject.stream;
  FoodStats get _latestStats => _statsSubject.value;


  @override
  void dispose() {
    _statsSub.cancel();
    _pageController.dispose();
    super.dispose();
  }



  @override
  void initState() {
    super.initState();

    final merged = FoodManager.instance.watchMergedFoodList();
    _sharedMerged = merged.shareReplay(maxSize: 1);

    _availableStream = _sharedMerged.map(
          (list) => list.where((f) => f.count == 0).toList(),
    );
    _consumedStream = _sharedMerged.map(
          (list) => list.where((f) => f.count > 0).toList(),
    );

    initFoodStatsStream();
  }


  Color _getProgressColor() {
    final ratio = _latestStats.calories / _maxProgress;
    if (ratio < 0.6) return Colors.green;
    if (ratio < 0.9) return Colors.orange;
    return Colors.red;
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
                    count: int.parse(quantity),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          const SafeArea(child: SizedBox(height: 16)),


          _buildStats(),


          Expanded(
            child: Column(
              children: [
                // Tab selector row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTabButton('Available', 0),
                    _buildTabButton('Consumed', 1),
                  ],
                ),

                // PageView of two FoodListViews
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentIndex = i),
                    children: [
                      _foodListView(
                        stream: _availableStream,
                        isConsumed: false,

                      ),
                      _foodListView(
                        stream: _consumedStream,
                        isConsumed: true,

                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),

      // Floating add button
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDietFoodDialog,
        child: const Icon(Icons.add),
      )
    );
  }


  Widget _foodListView({required stream, required isConsumed})
  {

    return StreamBuilder<List<DietFood>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final foods = snapshot.data;
        if (foods == null || foods.isEmpty) {
          return const Center(child: Text('No items yet'));
        }

        return ListView.builder(
          itemCount: foods.length,
          itemBuilder: (context, index) {
            final food = foods[index];
            final time = food.time;
            final timeStr =
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

            return Card(
              key: ValueKey(food.id),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(food.name),
                subtitle: Text(
                  '${food.foodStats.calories} kcal • ${food.count}g • $timeStr',
                ),
                trailing: IconButton(
                  icon: Icon(isConsumed ? Icons.delete : Icons.add),
                  onPressed: () {
                    if (isConsumed) {
                      FoodManager.instance.removeFromConsumedFood(
                        _latestStats,
                        food,
                      );
                    } else {

                      FoodManager.instance.addToConsumedFood(
                        _latestStats,
                        food,
                      );
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Builds the stats (progress circle + macros) at top
  Widget _buildStats() {
    return StreamBuilder<FoodStats?>(
      stream: foodStatsStream,//FirebaseDietFoodService.instance.watchConsumedFoodStats(DateTime.now()),
      initialData: FoodStats.empty(),
      builder: (context, snapshot) {
        final stats = snapshot.data!;

        final progress = stats.calories;
        const maxProgress = 2000;

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
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const Text('/ 2000 kcal', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Fat: ${stats.fats}g", style: const TextStyle(fontSize: 12)),
                  Text("Protein: ${stats.proteins}g", style: const TextStyle(fontSize: 12)),
                  Text("Carbs: ${stats.carbohydrates}g", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Simple tab button
  Widget _buildTabButton(String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


}
