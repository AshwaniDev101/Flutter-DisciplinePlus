
import 'package:discipline_plus/models/diet_food.dart';
import 'package:discipline_plus/pages/calories_counter/calorie_history_page/widgets/calorie_history_listview.dart';
import 'package:flutter/material.dart';
import 'package:discipline_plus/models/food_stats.dart';
import '../../../core/utils/app_settings.dart';
import '../../../database/repository/food_history_repository.dart';
import '../calorie_counter_page/calories_counter_page.dart';

/// Main page displaying calorie history for a month
class CalorieHistoryPage extends StatefulWidget {
  final DateTime pageDateTime;

  const CalorieHistoryPage({required this.pageDateTime, super.key});

  @override
  State<CalorieHistoryPage> createState() => _CalorieHistoryPageState();
}

class _CalorieHistoryPageState extends State<CalorieHistoryPage> {
  Map<int, FoodStats> _monthStatsMap = {};
  int _excessCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadMonthStats();
  }

  Future<void> _loadMonthStats() async {
    _monthStatsMap = await FoodHistoryRepository.instance.getMonthStats(
      year: widget.pageDateTime.year,
      month: widget.pageDateTime.month,
    );

    _excessCalories = _calculateNetExcess(_monthStatsMap);
    setState(() {}); // Rebuild after loading
  }

  int _calculateNetExcess(Map<int, FoodStats> monthStats) {
    int total = 0; // start from zero

    for (var food in monthStats.values) {
      total += food.calories - AppSettings.atMaxCalories;
      // print("Total ${total} => ${AppSettings.atMaxCalories} - ${food.calories} = ${food.calories - AppSettings.atMaxCalories}");
    }
    return total;
  }

  Widget _buildExcessLabel() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            _excessCalories > 0 ? "Kcal Gained : " : "Kcal Lost : (${_monthStatsMap.length} Days) : ",
            style: TextStyle(fontSize: 12),
          ),
          Text("$_excessCalories",
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: _excessCalories > 0 ? Colors.red : Colors.green)),
          SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    double count = 0;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          title: const Text(
            'Calorie History',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 2,
          backgroundColor: Colors.pink[300],
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'settings') {
                  print('Settings selected');
                } else if (value == 'add') {



                  // Run test
                  FoodHistoryRepository.instance.changeConsumedCount(count++, 
                      DietFood(id: '-1', name: 'Test $count', time: DateTime.now(), 
                          foodStats: FoodStats(proteins: 0, carbohydrates: 0, fats: 0, vitamins: 0, minerals: 0, calories: 1)), DateTime(2025, 10, 25));



                } else if (value == 'test2') {
                  print('Test 2 selected');
                }
              },
              itemBuilder: (BuildContext context) => [

                const PopupMenuItem(
                  value: 'add',
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: Colors.pink),
                      SizedBox(width: 10,),
                      Text('Add', style: TextStyle(color: Colors.pink),),
                    ],
                  ),
                ),

                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.grey[600]),
                      const SizedBox(width: 10,),
                      Text('Settings', style: TextStyle(color: Colors.grey[600]),),
                    ],
                  ),
                ),

              ],
            ),
          ]),
      body: SafeArea(
        child: Column(
          children: [
            _buildExcessLabel(),
            _monthStatsMap.isEmpty
                ? const Center(child: Text('No data found'))
                : Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadMonthStats,
                      child: CalorieHistoryListview(
                        pageDateTime: widget.pageDateTime,
                        monthStats: _monthStatsMap,
                        onEdit: (DateTime cardDateTime) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalorieCounterPage(pageDateTime: cardDateTime),
                            ),
                          ).then((_){
                            _loadMonthStats();
                          });
                        },
                        onDelete: (DateTime cardDateTime) async {
                          await FoodHistoryRepository.instance.deleteFoodStats(date: cardDateTime);
                          setState(() {
                            _monthStatsMap.remove(cardDateTime.day);
                          });
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
