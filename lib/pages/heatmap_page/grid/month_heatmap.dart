import 'package:flutter/material.dart';
import '../../../core/utils/helper.dart';

class MonthHeatmap extends StatelessWidget {
  final DateTime currentDateTime;
  final Stream<Map<String, dynamic>> heatmapStream;

  final double height = 70;
  final double hSpacing = 6;
  final double vSpacing = 6;
  final double horizontalPadding = 4;
  final double verticalPadding = 8.0;
  final bool useHorizontalScroll = false; // allow scrolling when many columns

  const MonthHeatmap({
    super.key,
    required this.currentDateTime,
    required this.heatmapStream,
  });

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
    final now = currentDateTime;
    final daysInMonth = _daysInMonth(now);

    // first day of month (1=Mon .. 7=Sun)
    final firstWeekday = DateTime(now.year, now.month, 1).weekday;

    const rows = 2;
    final offset = (firstWeekday - 1) % rows;
    final columns = ((offset + daysInMonth) / rows).ceil();

    final deviceWidth = MediaQuery.of(context).size.width;
    final totalHSpacing = (columns - 1) * hSpacing;
    final availableWidth = deviceWidth - horizontalPadding * 2 - totalHSpacing;
    final rawBoxSize = (availableWidth / columns);

    final totalVSpacing = (rows - 1) * vSpacing;
    final availableHeight = height - verticalPadding * 2 - totalVSpacing;
    final rawRowHeight = (availableHeight / rows);

    final boxSize = rawBoxSize.isFinite
        ? rawBoxSize.clamp(6.0, 48.0).clamp(0.0, rawRowHeight)
        : rawRowHeight.clamp(6.0, 48.0);

    final placeholderColor = hexToColorWithOpacity("#FFFFFF", 0);


    return StreamBuilder<Map<String, dynamic>>(
      stream: heatmapStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
          );
        }

        if (snapshot.hasError) {
          return SizedBox(
            height: 70,
            child: Center(child: Text('Error loading heatmap')),
          );
        }

        final heatmapData = snapshot.data ?? {};

        print("=== === ${heatmapData}");

        // generate all the cells
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

          final value = (heatmapData[dayNumber.toString()] ?? 0).toDouble();
          final color = getColorForHeat(value);

          final isToday = (now.day == dayNumber &&
              DateTime.now().month == now.month &&
              DateTime.now().year == now.year);

          return Container(
            width: boxSize,
            height: boxSize,
            margin: EdgeInsets.only(bottom: vSpacing),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: isToday ? Border.all(width: 2, color: Colors.black12) : null,
            ),
            child: Center(
              child: Text(
                "$dayNumber",
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ),
          );
        });

        // build columns
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

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0, top: 2),
                child: Text(
                  '${getMonthName(now)} ${now.year}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: useHorizontalScroll
                    ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal, child: rowContent)
                    : rowContent,
              ),
            ],
          ),
        );
      },
    );
  }
}
