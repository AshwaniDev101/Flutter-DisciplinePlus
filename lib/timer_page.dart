
import 'dart:math';

import 'package:discipline_plus/system_settings.dart';
import 'package:flutter/material.dart';



class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {

  var circle_radius = 150.0;
  var ring_thinkness = 10.0;
  var piegraph_gap = 60.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Constants.background_color,
        body: Center(
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Expanded(child: Center(child: CircleAvatar(
                  radius: circle_radius ,
                  backgroundColor: Colors.white,  // Transparent inside
                  child: CircleAvatar(
                    radius: circle_radius-ring_thinkness,
                    backgroundColor: Constants.background_color,  // Inner circle color
                    child: CustomPaint(
                      size: Size(circle_radius*2-piegraph_gap, circle_radius*2-piegraph_gap), // Define the size of the pie chart
                      painter: PieChartPainter(
                          totalNumberOfTicks: 10,
                          ticksFilled: 9,
                          color: Colors.white,
                          tickDistanceFromCenter: circle_radius-ring_thinkness-10-5
                      ),
                    ),
                  ),
                ),)),
                Divider(),
                Expanded(child: Center(child: Container(
                  width: 100,  // Set width and height equal for a square
                  height: 100,
                  color: Colors.white,  // Background color
                ))),


              ],
            ),
          ),
        )
    );
  }
}

class PieChartPainter extends CustomPainter {
  final int totalNumberOfTicks;
  final int ticksFilled;
  final Color color;
  final double tickLength;           // Fixed tick length
  final double tickDistanceFromCenter; // Distance from center where tick starts

  PieChartPainter({
    required this.totalNumberOfTicks,
    required this.ticksFilled,
    required this.color,
    this.tickLength = 10.0,
    required this.tickDistanceFromCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final piePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Ensure ticksFilled doesn't exceed totalNumberOfTicks
    int filledTicks = ticksFilled > totalNumberOfTicks ? totalNumberOfTicks : ticksFilled;
    // Calculate the sweep angle based on the fraction of ticks filled
    double sweepAngle = (filledTicks / totalNumberOfTicks) * 2 * pi;

    // Draw the partial pie arc starting at 0 radians (90° right)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0, // starting at 0 radians (right side)
      sweepAngle,
      true,
      piePaint,
    );

    // Draw tick marks around the circle
    final tickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    for (int i = 0; i < totalNumberOfTicks; i++) {
      // Calculate the angle for each tick (dividing the circle evenly)
      double tickAngle = (2 * pi * i) / totalNumberOfTicks;

      // Inner point is at tickDistanceFromCenter from the center
      final innerPoint = Offset(
        center.dx + tickDistanceFromCenter * cos(tickAngle),
        center.dy + tickDistanceFromCenter * sin(tickAngle),
      );

      // Outer point adds the fixed tickLength to the inner distance
      final outerPoint = Offset(
        center.dx + (tickDistanceFromCenter + tickLength) * cos(tickAngle),
        center.dy + (tickDistanceFromCenter + tickLength) * sin(tickAngle),
      );

      canvas.drawLine(innerPoint, outerPoint, tickPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
