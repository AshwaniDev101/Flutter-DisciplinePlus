import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/helper.dart';
import '../../../models/heatmap_data.dart';

class HeatmapCalender extends StatefulWidget {
  const HeatmapCalender({super.key});

  @override
  State<HeatmapCalender> createState() => _HeatmapCalenderState();
}

class _HeatmapCalenderState extends State<HeatmapCalender> {
  late DateTime currentDate;
  late DateTime today;
  bool isCircle = false;
  Color currentDateColor = Colors.orange;
  DateTime? selectedDate;
  final Map<String, int> heatLevelMap = {};




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
    // _updateHeatMap();

    // RefreshReloadNotifier.instance.register(loadData);


  }



  // void loadData() async {
  //   List<HeatmapData> heatmapList = await _heatmapRepository.getOverallHeatmapData(2025, 4);
  //   setState(() {
  //     yourOverallHeatmapDataList.clear();
  //     yourOverallHeatmapDataList.addAll(heatmapList);
  //     _updateHeatMap();
  //   });
  // }

  void _updateHeatMap() {
    heatLevelMap.clear();
    for (var data in yourOverallHeatmapDataList) {
      heatLevelMap['${data.year}-${data.month}-${data.date}'] = data.heatLevel;
    }
  }


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
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(currentDate.year, currentDate.month + 1, 0).day;
    final firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    final weekdayOfFirstDay = firstDayOfMonth.weekday - 1;

    return Column(
      children: [
        _buildHeader(),
        _buildDayNames(),
        Expanded(child: _buildCalendarGrid(daysInMonth, weekdayOfFirstDay)),
        _buildHeatLegend(),
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
            icon: Icon(Icons.calendar_month),
            onPressed: jumpToToday,
          ),
        ],
      ),
    );
  }

  Widget _buildDayNames() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _DayName("Mon"),
        _DayName("Tue"),
        _DayName("Wed"),
        _DayName("Thu"),
        _DayName("Fri"),
        _DayName("Sat"),
        _DayName("Sun"),
      ],
    );
  }

  Widget _buildCalendarGrid(int daysInMonth, int weekdayOfFirstDay) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.0,
      ),
      itemCount: daysInMonth + weekdayOfFirstDay,
      itemBuilder: (context, index) {
        if (index < weekdayOfFirstDay) return const SizedBox.shrink();

        final day = index - weekdayOfFirstDay + 1;
        final heatLevel = heatLevelMap['${currentDate.year}-${currentDate.month}-$day'] ?? 0;
        final isCurrentDay = _isToday(day);
        final isSelected = _isSelected(day);

        return GestureDetector(
          onTap: () => _onDateTap(day),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: getColorForHeat(heatLevel),
              border: _buildBorder(isCurrentDay, isSelected),
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                  color: _getTextColor(isCurrentDay, isSelected),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Border _buildBorder(bool isCurrentDay, bool isSelected) {
    if (isCurrentDay) return Border.all(color: currentDateColor, width: 2);
    if (isSelected) return Border.all(color: Colors.blue, width: 2);
    return Border.all(color: Colors.transparent, width: 2);
  }

  Color _getTextColor(bool isCurrentDay, bool isSelected) {
    if (isCurrentDay) return currentDateColor;
    if (isSelected) return Colors.blue;
    return Colors.black;
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

  Widget _buildHeatLegend() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: List.generate(6, (level) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                color: getColorForHeat(level),
              ),
              const SizedBox(width:2),
            ],
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

  String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(0, month));
  }
}

class _DayName extends StatelessWidget {
  final String day;
  const _DayName(this.day);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        day,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}