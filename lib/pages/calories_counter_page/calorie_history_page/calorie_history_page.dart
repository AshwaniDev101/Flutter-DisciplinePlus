import 'package:discipline_plus/database/services/firebase_food_history_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:discipline_plus/models/food_stats.dart';
import '../../../core/utils/helper.dart';
import '../../../core/utils/app_settings.dart';
import '../../../database/repository/food_history_repository.dart';
import '../../../widget/global_helper_widget_functions.dart';
import '../calories_counter_page.dart';

/// Main page displaying calorie history for a month
class CalorieHistoryPage extends StatefulWidget {
  final DateTime pageDateTime;

  const CalorieHistoryPage({required this.pageDateTime, super.key});

  @override
  State<CalorieHistoryPage> createState() => _CalorieHistoryPageState();
}

class _CalorieHistoryPageState extends State<CalorieHistoryPage> {
  Map<int, FoodStats> _monthStats = {};
  int _excessCalories = 0;

  @override
  void initState() {
    super.initState();
    _loadMonthStats();
  }

  Future<void> _loadMonthStats() async {
    _monthStats = await FoodHistoryRepository.instance.getMonthStats(
      year: widget.pageDateTime.year,
      month: widget.pageDateTime.month,
    );

    _excessCalories = _calculateNetExcess(_monthStats);
    setState(() {}); // Rebuild after loading
  }

  // int _calculateTotalExcess(Map<int, FoodStats> monthStats) {
  //   return monthStats.values
  //       .map((food) => food.calories - AppSettings.atMostProgress)
  //       .where((excess) => excess > 0)
  //       .fold(0, (sum, e) => sum + e);
  // }

  int _calculateNetExcess(Map<int, FoodStats> monthStats) {
    int total = 0; // start from zero

    for (var food in monthStats.values) {
      int allowed = AppSettings.atMostProgress;
      int diff = food.calories - allowed;

      // add or subtract directly
      total += diff;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildExcessLabel(),
            _monthStats.isEmpty
                ? const Center(child: Text('No data found'))
                : Expanded(
                    child: RefreshIndicator(
                      onRefresh: _loadMonthStats,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _monthStats.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final dayKeys = _monthStats.keys.toList()..sort((a, b) => b.compareTo(a));
                          final day = dayKeys[index];
                          return DayCard(
                            day: day,
                            dateTime: widget.pageDateTime,
                            foodStats: _monthStats[day]!,
                            onDelete: (cardDateTime) async {
                              await FoodHistoryRepository.instance.deleteFoodStats(cardDateTime: cardDateTime);
                              setState(() {
                                _monthStats.remove(cardDateTime.day); // 👈 instantly update UI
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildExcessLabel() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            "Excess Calories : ",
            style: TextStyle(fontSize: 16),
          ),
          Text("${_excessCalories}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
          SizedBox(
            width: 10,
          )
        ],
      ),
    );
  }
}

class DayCard extends StatelessWidget {
  final int day;
  final DateTime dateTime;
  final FoodStats foodStats;
  final void Function(DateTime cardDateTime) onDelete;

  const DayCard({
    super.key,
    required this.day,
    required this.dateTime,
    required this.foodStats,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateFormat.MMMM().format(dateTime);
    final currentYear = DateFormat.y().format(dateTime);
    final cardDateTime = DateTime(dateTime.year, dateTime.month, day);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
              top: 8,
              right: 2,
              child: EditDeleteOptionMenuWidget(context,
                  onDelete: () => onDelete(cardDateTime),
                  onEdit: () => _openCaloriesCounterPage(context, cardDateTime))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date
                Text(
                  '$day $currentMonth, $currentYear',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),

                // 4-column row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Column 1: Progress Circle
                    _buildProgressCircle(),

                    const SizedBox(width: 8),

                    // Column 2: Calories info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${foodStats.calories} kcal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '/${AppSettings.atMostProgress}',
                              style: TextStyle(
                                fontSize: 10,
                                // fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                        if (foodStats.calories > AppSettings.atMostProgress)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.6),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '+${foodStats.calories - AppSettings.atMostProgress}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 8),

                    // Column 3: Nutrient chips
                    Expanded(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: [
                          _buildNutrientChip('Protein', foodStats.proteins, Colors.pink.shade300),
                          _buildNutrientChip('Carbs', foodStats.carbohydrates, Colors.orange.shade300),
                          _buildNutrientChip('Fats', foodStats.fats, Colors.amber.shade400),
                          _buildNutrientChip('Vitamins', foodStats.vitamins, Colors.green.shade300),
                          _buildNutrientChip('Minerals', foodStats.minerals, Colors.blue.shade300),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    final progress = (foodStats.calories / AppSettings.atMostProgress).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 36,
          width: 36,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            value: 1,
            color: Colors.grey.shade200,
          ),
        ),
        SizedBox(
          height: 36,
          width: 36,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            value: progress,
            color: getProgressColor(foodStats),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          "${(progress * 100).toStringAsFixed(0)}%",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildNutrientChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 2.5, backgroundColor: color),
          const SizedBox(width: 2),
          Text(
            '$label: $value',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  void _openCaloriesCounterPage(BuildContext context, DateTime cardDateTime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaloriesCounterPage(pageDateTime: cardDateTime),
      ),
    );
  }

  // /// TODO: You can remove this function menus, because it's identical to global InitiativeList option menu and global FoodList option menu,In which both use 'edit' and 'delete', by creating a single helper function, u can use it at both location
  // Widget _buildOptionsButton(BuildContext context,
  //     {required void Function() onDelete, required void Function() onEdit}) {
  //   final key = GlobalKey();
  //   return GestureDetector(
  //     onTap: () async {
  //       final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
  //       final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  //
  //       final position = RelativeRect.fromRect(
  //         Rect.fromPoints(
  //           button.localToGlobal(Offset.zero, ancestor: overlay),
  //           button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
  //         ),
  //         Offset.zero & overlay.size,
  //       );
  //
  //       final selected = await showMenu<String>(
  //         context: context,
  //         position: position,
  //         items: const [
  //           PopupMenuItem<String>(
  //             value: 'edit',
  //             child: Row(
  //               children: [
  //                 Icon(Icons.edit, size: 16, color: Colors.blue),
  //                 SizedBox(width: 6),
  //                 Text('Edit', style: TextStyle(fontSize: 13)),
  //               ],
  //             ),
  //           ),
  //           PopupMenuItem<String>(
  //             value: 'delete',
  //             child: Row(
  //               children: [
  //                 Icon(Icons.delete_outline, size: 16, color: Colors.red),
  //                 SizedBox(width: 6),
  //                 Text('Delete', style: TextStyle(fontSize: 13)),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //
  //       if (selected == 'edit') onEdit();
  //       if (selected == 'delete') onDelete();
  //     },
  //     behavior: HitTestBehavior.translucent,
  //     child: Container(
  //       // color: Colors.redAccent,
  //       key: key,
  //       width: 20,
  //       height: 20,
  //       child: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
  //     ),
  //   );
  // }
}
