

import 'package:discipline_plus/pages/listpage/core/current_day_manager.dart';
import 'package:discipline_plus/pages/listpage/core/snap_scrolling.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/refresh_reload_notifier.dart';
import '../../../core/utils/helper.dart';
import '../../../database/repository/overall_heatmap_repository.dart';
import '../../../database/services/firebase_overall_heatmap_service.dart';
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
  final Map<String, int> heatLevelMap = {};
  final ScrollController _scrollController = ScrollController();

  final OverallHeatmapRepository _heatmapRepository = OverallHeatmapRepository(OverallHeatmapService());


  final List<HeatmapData> yourOverallHeatmapDataList = [
    // HeatmapData(year: 2025, month: 4, date: 1, heatLevel: 0),
    // HeatmapData(year: 2025, month: 4, date: 2, heatLevel: 2),
    // HeatmapData(year: 2025, month: 4, date: 3, heatLevel: 4),
    // HeatmapData(year: 2025, month: 4, date: 4, heatLevel: 3),
    // HeatmapData(year: 2025, month: 4, date: 5, heatLevel: 1),
    // HeatmapData(year: 2025, month: 4, date: 6, heatLevel: 5),
    // HeatmapData(year: 2025, month: 4, date: 7, heatLevel: 2),
    // HeatmapData(year: 2025, month: 4, date: 8, heatLevel: 0),
    // HeatmapData(year: 2025, month: 4, date: 9, heatLevel: 1),
    // HeatmapData(year: 2025, month: 4, date: 10, heatLevel: 3),
  ];

  @override
  void initState() {
    super.initState();
    today = DateTime.now();
    currentDate = DateTime(today.year, today.month);

    // uploadDummyData();
    // Adding function to list of function to refresh them all at once
    RefreshReloadNotifier.instance.register(loadData);
    // loadData();
    moveCursorToCurrent();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  // void uploadDummyData()
  // {
  //
  //   yourOverallHeatmapDataList.forEach((heatmap_data){
  //     _heatmapRepository.addOverallHeatmapData(heatmap_data);
  //   });
  //
  // }

  void loadData() async {
    List<HeatmapData> heatmapList = await _heatmapRepository.getOverallHeatmapData(2025, 4);
    setState(() {
      yourOverallHeatmapDataList.clear();
      yourOverallHeatmapDataList.addAll(heatmapList);
      _updateHeatMap();
    });
  }

  void _updateHeatMap() {
    heatLevelMap.clear();
    for (var data in yourOverallHeatmapDataList) {
      heatLevelMap['${data.year}-${data.month}-${data.date}'] = data.heatLevel;
    }
  }


  // Color getColorForHeat(int level) {
  //   switch (level) {
  //     case 0: return hexToColor("#EBEDF0"); // Grey
  //     case 1: return hexToColor("#003D28"); // Pale green
  //     case 2: return hexToColor("#006642"); // Light green
  //     case 3: return hexToColor("#008F5D"); // Brighter green
  //     case 4: return hexToColor("#00B877"); // Vivid green
  //     case 5: return hexToColor("#00FF9C"); // Most intense green
  //     default: return Colors.grey;
  //   }
  // }



  Color getColorForHeat(int level) {
    switch (level) {
      case 0: return hexToColor("#EBEDF0"); // Grey
      case 1: return hexToColor("#005232"); // Pale green
      case 2: return hexToColor("#007E4D"); // Light green
      case 3: return hexToColor("#00A967"); // Brighter green
      case 4: return hexToColor("#00E08A"); // Vivid green
      case 5: return hexToColor("#00FF9C"); // Most intense green
      default: return Colors.grey;
    }
  }

  void goToPreviousMonth() => setState(() {
    currentDate = DateTime(currentDate.year, currentDate.month - 1);
    _updateHeatMap();
  });

  void goToNextMonth() => setState(() {
    currentDate = DateTime(currentDate.year, currentDate.month + 1);
    _updateHeatMap();
  });

  void jumpToToday() => setState(() {
    currentDate = DateTime(today.year, today.month);
    _updateHeatMap();
  });

  void _onDateTap(int day) => setState(() {
    selectedDate = DateTime(currentDate.year, currentDate.month, day);



    var week = getWeekdayName(selectedDate!);

    // CurrentDayManager.setIndex(2);
    CurrentDayManager.setWeekday(week);

    // Reload data from firebase
    // RefreshReloadNotifier.instance.notifyAll();

    // print("======= ${selectedDate} = ${currentDate.year}, ${currentDate.month}, ${day}, ${week} =================");


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
      child: ListView.builder(
        controller: _scrollController,
        physics: SnappingScrollPhysics(itemWidth:44.0), // Use 44.0 as the item width + margins (matches your ListView items)
        scrollDirection: Axis.horizontal,
        itemCount: daysInMonth,
        itemBuilder: (context, index) {
          final day = index + 1;
          final date = DateTime(currentDate.year, currentDate.month, day);
          final heatLevel = heatLevelMap['${date.year}-${date.month}-${date.day}'] ?? 0;
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
                  // Mon
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
                  // 5
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
                      color: getColorForHeat(heatLevel),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday
                            ? Colors.orange
                            : isSelected
                            ? Colors.blue
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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

