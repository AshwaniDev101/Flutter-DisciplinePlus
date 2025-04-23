
import 'dart:math';

import 'package:flutter/material.dart';

/// painter for arc, ticks, and optional numbers
class PieChartPainter extends CustomPainter {
  final Color color;
  final double tickLength;
  final double tickDistanceFromCenter;
  final double numberDistanceFromCenter;
  final double progress;
  final int totalNumberOfTicks;
  final bool showNumbers;
  final Color tickColor;
  final Color numberColor;
  final double numberFontSize;

  PieChartPainter({
    required this.color,
    required this.tickLength,
    required this.tickDistanceFromCenter,
    required this.numberDistanceFromCenter,
    required this.progress,
    required this.totalNumberOfTicks,
    this.showNumbers = false,
    this.tickColor = Colors.white,
    this.numberColor = Colors.white,
    this.numberFontSize = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final startAngle = -pi / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fillPaint = Paint()..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progress * 2 * pi,
      true,
      fillPaint,
    );

    final tickPaint = Paint()
      ..color = tickColor
      ..strokeWidth = 2;
    for (int i = 0; i < totalNumberOfTicks; i++) {
      final angle = startAngle + (2 * pi * i) / totalNumberOfTicks;
      final inner = center + Offset(cos(angle), sin(angle)) * tickDistanceFromCenter;
      final outer = center + Offset(cos(angle), sin(angle)) * (tickDistanceFromCenter + tickLength);
      canvas.drawLine(inner, outer, tickPaint);

      if (showNumbers) {
        final pos = center + Offset(cos(angle), sin(angle)) * numberDistanceFromCenter;
        final tp = TextPainter(
          text: TextSpan(
            text: '$i',
            style: TextStyle(color: numberColor, fontSize: numberFontSize),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

