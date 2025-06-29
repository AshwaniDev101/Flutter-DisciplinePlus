

import 'package:discipline_plus/pages/listpage/core/current_day_manager.dart';
import 'package:discipline_plus/pages/listpage/core/snap_scrolling.dart';
import 'package:discipline_plus/pages/listpage/logic/schedule_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/refresh_reload_notifier.dart';
import '../../../core/utils/helper.dart';
import '../../../database/repository/heatmap_repository.dart';
import '../../../database/services/firebase_heatmap_service.dart';
import '../../../models/heatmap_data.dart';

class HeatmapRow extends StatefulWidget {
  const HeatmapRow({super.key});

  @override
  State<HeatmapRow> createState() => _HeatmapRowState();
}

class _HeatmapRowState extends State<HeatmapRow> {
  late DateTime currentDate;
  late DateTime today;
  DateTime? selectedDate;

  final ScrollController _scrollController = ScrollController();

  final HeatmapRepository _heatmapRepository = HeatmapRepository(FirebaseHeatmapService.instance('user1'));


  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    currentDate = DateTime(today.year, today.month);


  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  Color getColorForHeat(int level) {
    switch (level) {
        case 0: return hexToColorWithOpacity("#EBEDF0", 100);
      case 1: return hexToColorWithOpacity("#38d9a9", 10);
      case 2: return hexToColorWithOpacity("#38d9a9", 20);
      case 3: return hexToColorWithOpacity("#38d9a9", 40);
      case 4: return hexToColorWithOpacity("#38d9a9", 50);
      case 5: return hexToColorWithOpacity("#38d9a9", 70);
      case 6: return hexToColorWithOpacity("#38d9a9", 90);
      case 7: return hexToColorWithOpacity("#38d9a9", 100);
      default: return Colors.grey;
    }
  }



  void goToPreviousMonth() => setState(() {
    currentDate = DateTime(currentDate.year, currentDate.month - 1);

  });

  void goToNextMonth() => setState(() {
    currentDate = DateTime(currentDate.year, currentDate.month + 1);

  });

  void jumpToToday() => setState(() {
    currentDate = DateTime(today.year, today.month);

  });

  void _onDateTap(int day) => setState(() {
    selectedDate = DateTime(currentDate.year, currentDate.month, day);

    var week = getWeekdayName(selectedDate!);

    CurrentDayManager.setWeekday(week);
    // Load data for different days
    ScheduleManager.instance.changeDay(week);

  });

  String getWeekdayName(DateTime datetime)
  {
    return DateFormat('EEEE').format(datetime);
  }

  bool _isToday(int day) =>
      day == today.day &&
          currentDate.month == today.month &&
          currentDate.year == today.year;

  bool _isSelected(int day) =>
      selectedDate != null &&
          selectedDate!.day == day &&
          selectedDate!.month == currentDate.month &&
          selectedDate!.year == currentDate.year;



  void moveCursorToCurrent() {
    if (currentDate.year == today.year && currentDate.month == today.month) {


      int index;
      if (today.day <= 8) {
        index = 0; // Show from Day 1
      } else {
        index = today.day - 8; // Show from Today -7
      }

      double itemWidth = 44;  // your ListView items: 40 + 2 margin left + 2 margin right
      double offset = index * itemWidth;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          offset,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;

    return Column(
      children: [
        // _buildHeader(),
        _buildDaysList(daysInMonth),
        // _buildHeatLegend(),
        // if (selectedDate != null) _buildSelectedDateInfo(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: goToPreviousMonth,
          ),
          Text(
            "${getMonthName(currentDate.month)} ${currentDate.year}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: goToNextMonth,
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: jumpToToday,
          ),
        ],
      ),
    );
  }

  Widget _buildDaysList(int daysInMonth) {
    return SizedBox(
      height: 80,
      child: StreamBuilder<Map<String, Map<String, dynamic>>>(
        stream: _heatmapRepository.watchAllHeatmapsInMonth(year: 2025, month: 6,),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return const Text("Error loading data");
          }

          final allHeatmaps = snapshot.data ?? {};
          final specificActivityMap = allHeatmaps['diet_heatmap'] ?? {};


          WidgetsBinding.instance.addPostFrameCallback((_) {
            moveCursorToCurrent();
          });



          return ListView.builder(
            controller: _scrollController,
            physics: SnappingScrollPhysics(itemWidth:44.0), // Use 44.0 as the item width + margins (matches your ListView items)
            scrollDirection: Axis.horizontal,
            itemCount: daysInMonth,
            itemBuilder: (context, index) {
              final day = index + 1;
              final date = DateTime(currentDate.year, currentDate.month, day);
              // final heatLevel = heatLevelMap['${date.year}-${date.month}-${date.day}'] ?? 0;
              final isToday = _isToday(day);
              final isSelected = _isSelected(day);

              return GestureDetector(
                onTap: () => _onDateTap(day),
                child: Container(
                  // width: 35,
                  width: 40,
                  color: Colors.transparent,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 3 Letter Weekday name example: 'Mon', 'Tue', 'Wed' .... etc
                      Text(
                        DateFormat('EEE').format(date),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? Colors.orange
                              : isSelected
                              ? Colors.blue
                              : Colors.black,
                        ),
                      ),
                      // it give date from 1 to 31
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? Colors.orange
                              : isSelected
                              ? Colors.blue
                              : Colors.black,
                          // color: isSelected ? Colors.blue : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Circle
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          // color: getColorForHeat(specificActivityMap[day.toString()]),
                          color: getColorForHeat(specificActivityMap[day.toString()] ?? 0),//#38d9a9
                          // color: hexToColorWithOpacity("#38d9a9", 50),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getBorderColor(isToday, isSelected),
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getBorderColor(bool isToday, bool isSelected) {
    if (isToday) return Colors.orange;
    if (isSelected) return Colors.blue;
    return Colors.transparent;
  }


  Widget _buildHeatLegend() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: List.generate(6, (level) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: getColorForHeat(level),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('Level $level'),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedDateInfo() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Selected Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}",
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  String getMonthName(int month) => DateFormat('MMMM').format(DateTime(0, month));
}

