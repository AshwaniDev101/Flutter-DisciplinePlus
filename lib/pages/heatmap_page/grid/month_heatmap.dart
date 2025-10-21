import 'package:flutter/material.dart';

import '../../../core/utils/helper.dart';

class MonthHeatmap extends StatelessWidget {
  final double height = 70;
  final double hSpacing = 6;
  final double vSpacing = 6;
  final double horizontalPadding = 4;
  final double verticalPadding = 8.0;
  final bool   useHorizontalScroll = false; // if true, allow scrolling when many columns
  final Map<String, dynamic> heatLevelMap;

  const MonthHeatmap({
    Key? key,
    required this.heatLevelMap,
  }) : super(key: key);


  Color getColorForHeat(double percentage) {
    percentage = percentage.clamp(0, 100);
    if (percentage == 0) {
      return hexToColorWithOpacity("#EBEDF0", 100);
    } else {
      return hexToColorWithOpacity("#38d9a9", percentage);
    }
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = _daysInMonth(now);

    // original weekday (1=Mon .. 7=Sun)
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;

    const rows = 2;
    // map the weekday to one of the 3 rows using modulo so start alignment is consistent
    final offset = (firstWeekday - 1) % rows; // 0..2

    final columns = ((offset + daysInMonth) / rows).ceil();

    final deviceWidth = MediaQuery.of(context).size.width;

    // compute dimensions
    final totalHSpacing = (columns - 1) * hSpacing;
    final availableWidth = deviceWidth - horizontalPadding * 2 - totalHSpacing;
    final rawBoxSize = (availableWidth / columns);

    // final verticalPadding = 8.0;
    final totalVSpacing = (rows - 1) * vSpacing;
    final availableHeight = height - verticalPadding * 2 - totalVSpacing;
    final rawRowHeight = (availableHeight / rows);

    // make boxes square-ish, clamp to reasonable min/max
    final boxSize = rawBoxSize.isFinite
        ? rawBoxSize.clamp(6.0, 48.0).clamp(0.0, rawRowHeight)
        : rawRowHeight.clamp(6.0, 48.0);

    // placeholder color (transparent or faint)
    final placeholderColor = hexToColorWithOpacity("#FFFFFF", 0);



    // generate column-major cells (columns * rows)
    final totalCells = columns * rows;
    final cells = List<Widget>.generate(totalCells, (cellIndex) {
      final dayNumber = (cellIndex - offset + 1);
      final isValidDay = dayNumber >= 1 && dayNumber <= daysInMonth;



      if (!isValidDay) {
        return Container(
          width: boxSize,
          height: boxSize,
          margin: EdgeInsets.only(bottom: vSpacing),
          decoration: BoxDecoration(
            color: placeholderColor,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }

      final color = getColorForHeat((heatLevelMap[dayNumber.toString()] ?? 0).toDouble());

      // optional: highlight today
      final isToday = (now.day == dayNumber && DateTime.now().month == now.month && DateTime.now().year == now.year);

      return Container(
        width: boxSize,
        height: boxSize,
        margin: EdgeInsets.only(bottom: vSpacing),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: isToday ? Border.all(width: 2, color: Colors.black12) : null,
        ),
        child: Center(child: Text("${dayNumber}",style: TextStyle(fontSize: 10,color: Colors.grey[600]),)),
      );
    });

    // break into columns (each column is rows long)
    final weekColumns = List<Widget>.generate(columns, (colIndex) {
      final start = colIndex * rows;
      final end = start + rows;
      final columnCells = cells.sublist(start, end);

      return Container(
        margin: EdgeInsets.only(right: colIndex == columns - 1 ? 0 : hSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: columnCells,
        ),
      );
    });

    final rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: weekColumns,
    );

    return Container(
      height: height,
      width: double.infinity,
      // padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              // color: Colors.redAccent,
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0,top: 2),
                child: Text(('${getMonthName(DateTime.now())} ${DateTime.now().year}'),style: TextStyle(fontSize: 12,color: Colors.grey[600])),
              )),
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: useHorizontalScroll
                ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: rowContent)
                : rowContent,
          ),
        ],
      ),
    );
  }
}
