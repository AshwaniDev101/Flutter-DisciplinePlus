import 'dart:async';

import 'package:discipline_plus/core/utils/helper.dart';
import 'package:discipline_plus/database/services/firebase_diet_food_service.dart';
import 'package:discipline_plus/models/food_stats.dart';
import 'package:discipline_plus/pages/calories_counter_page/food_manager.dart';
import 'package:discipline_plus/pages/dietpage/widgets/calorie_history_page.dart';
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
        .watchDietStatistics(DateTime.now())
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
    if (ratio < 0.6) return Colors.pink.shade300;
    if (ratio < 0.9) return Colors.orange;
    return Colors.red;
  }


  void _showAddOrEditDietFoodDialog(DietFood? food) {
    final formKey = GlobalKey<FormState>();
    // Pre-fill values if editing
    String name = food?.name ?? '';
    String calories = food?.foodStats.calories.toString() ?? '';
    String quantity = food?.count.toString() ?? '1';
    String proteins = food?.foodStats.proteins.toString() ?? '0';
    String carbohydrates = food?.foodStats.carbohydrates.toString() ?? '0';
    String fats = food?.foodStats.fats.toString() ?? '0';
    String vitamins = food?.foodStats.vitamins.toString() ?? '0';
    String minerals = food?.foodStats.minerals.toString() ?? '0';

    InputDecoration buildInputDecoration(String label) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 13),
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(
          child: Text(food == null ? 'Add New DietFood' : 'Edit DietFood'),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: buildInputDecoration('DietFood Name'),
                  style: const TextStyle(fontSize: 14),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                  onSaved: (v) => name = v!,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: calories,
                        decoration: buildInputDecoration('Calories'),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        onSaved: (v) => calories = v!,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: quantity,
                        decoration: buildInputDecoration('Quantity'),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 14),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                        onSaved: (v) => quantity = v!,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nutritional Values (per serving)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildNutrientField('Proteins', proteins, (v) => proteins = v!),
                    _buildNutrientField('Carbs', carbohydrates, (v) => carbohydrates = v!),
                    _buildNutrientField('Fats', fats, (v) => fats = v!),
                    _buildNutrientField('Vitamins', vitamins, (v) => vitamins = v!),
                    _buildNutrientField('Minerals', minerals, (v) => minerals = v!),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL', style: TextStyle(fontSize: 13)),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                setState(() {
                  final updatedDietFood = DietFood(
                    id: food?.id ?? generateReadableTimestamp(),
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

                  if (food == null) {
                    FoodManager.instance.addToAvailableFood(updatedDietFood);
                  } else {
                    FoodManager.instance.editAvailableFood(updatedDietFood);
                  }
                });
                Navigator.of(context).pop();
              }
            },
            child: Text(
              food == null ? 'ADD' : 'SAVE',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNutrientField(String label, String value, Function(String?) onSaved) {
    return SizedBox(
      width: 100,
      child: TextFormField(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 11, color: Colors.grey[700]),
          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 12),
        onSaved: onSaved,
        validator: (v) => v!.isEmpty ? 'Req' : null,
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

                  SizedBox(height: 14,),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: ()=> _showAddOrEditDietFoodDialog(null),
        icon: const Icon(Icons.add),
        label: const Text("Add New Item", style: TextStyle(fontSize: 12),),
      ),
    );
  }


  Widget _foodListView({ required Stream<List<DietFood>> stream, required bool isConsumed })
  {

    final List<Color> colorPalette = [
      Colors.pink.shade100,
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.teal.shade100,
      Colors.amber.shade100,
      Colors.orange.shade100,
      Colors.indigo.shade100,
      Colors.cyan.shade100,
    ];




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

        return MediaQuery.removePadding(
          context: context,
          removeTop: true,

          child: ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              // final time = food.time;
              // final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

              Offset tapPosition = Offset.zero;

              final Color barColor = colorPalette[index % colorPalette.length];


              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: ClipRRect(
              borderRadius: BorderRadius.circular(16), // Match Card radius
              child: Stack(

                  children: [




                    Card(
                      key: ValueKey(food.id),
                      margin: EdgeInsets.zero, // Important to remove Card’s default margin
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), // Already clipped by outer ClipRRect
                      ),

                      clipBehavior: Clip.antiAlias,
                      child: Listener(
                        onPointerDown: (PointerDownEvent event) {
                          tapPosition = event.position;
                        },
                        child: InkWell(
                          onLongPress: isConsumed?(){}:() {
                            final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                            showMenu(
                              context: context,
                              position: RelativeRect.fromLTRB(
                                tapPosition.dx,
                                tapPosition.dy,
                                overlay.size.width - tapPosition.dx,
                                overlay.size.height - tapPosition.dy,
                              ),
                              items: const [
                                PopupMenuItem(value: 'edit', child: Text('Edit')),
                                PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ).then((value) {
                              if (value == 'edit') {
                                _showAddOrEditDietFoodDialog(food);
                              } else if (value == 'delete') {
                                FoodManager.instance.removeFromAvailableFood(food);
                              }
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        food.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${food.foodStats.calories} kcal',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: IconButton(
                                  icon: Icon(
                                    isConsumed ? Icons.delete_forever : Icons.add_circle,
                                    color: isConsumed ? Colors.redAccent : Colors.pink.shade200,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    if (isConsumed) {
                                      // FoodManager.instance.removeFromConsumedFood(_latestStats, food);
                                    } else {
                                      // FoodManager.instance.addToConsumedFood(_latestStats, food);
                                    }
                                  },
                                  tooltip: isConsumed ? 'Remove food' : 'Add food',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),


                    Positioned(
                      top: 1,
                      bottom: 1,
                      left: 0,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                        child: Container(
                          width: 10,
                          color: barColor,
                        ),
                      ),
                    ),



                  ],

                ),
              ));










            },
          ),
        );
      },
    );
  }



  /// Builds the stats (progress circle + macros) at top
  Widget _buildStats() {
    return StreamBuilder<FoodStats?>(
      stream: foodStatsStream,
      initialData: FoodStats.empty(),
      builder: (context, snapshot) {
        final stats = snapshot.data!;

        final progress = stats.calories;
        const maxProgress = 2000;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
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
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const Text('2000 kcal', style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(width: 20,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fat: ${stats.fats}", style: const TextStyle(fontSize: 12)),
                  Text("Protein: ${stats.proteins}", style: const TextStyle(fontSize: 12)),
                  Text("Minerals: ${stats.minerals}", style: const TextStyle(fontSize: 12)),
                  Text("Carbs: ${stats.carbohydrates}", style: const TextStyle(fontSize: 12)),
                  Text("Vitamins: ${stats.vitamins}", style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),

            ElevatedButton(child: Text(getTodayDateString()),
                onPressed: (){
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CalorieHistoryPage()),
                  );
                }
            ),

          ],
        );
      },
    );
  }

  String getTodayDateString() {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final yyyy = now.year.toString();
    return '$dd/$mm/$yyyy';
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
          color: isSelected ? Colors.pink.shade300 : Colors.pink.shade50,
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
