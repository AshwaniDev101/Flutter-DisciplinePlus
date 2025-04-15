
import 'dart:math';
import 'package:discipline_plus/models/data_types.dart';
import 'package:flutter/material.dart';

// Represents a simple time structure with hour and minute.
// class AppTime {
//   final int hour;
//   final int minute;
//
//   const AppTime(this.hour, this.minute);
//
//   // Helper method for formatting time as HH:MM
//   String remainingTime() {
//     if (hour == 0) return "${minute}m";
//     if (minute == 0) return "${hour}h";
//     return "${hour}h ${minute}m";
//   }
//
//   @override
//   String toString() {
//     // Convert hour to 12-hour format and determine AM/PM
//     final displayHour = hour % 12 == 0 ? 12 : hour % 12;
//     final period = hour >= 12 ? 'PM' : 'AM';
//     return "${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
//   }
//
//   bool get isZero => hour == 0 && minute == 0;
// }

class AnimatedSkyHeader extends StatefulWidget {
  final String currentWeekday;
  final AppTime currentTime;
  final bool isFastForward;

  const AnimatedSkyHeader({
    Key? key,
    required this.currentWeekday,
    required this.currentTime,
    required this.isFastForward,
  }) : super(key: key);

  @override
  _AnimatedSkyHeaderState createState() => _AnimatedSkyHeaderState();
}

class _AnimatedSkyHeaderState extends State<AnimatedSkyHeader> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  // Configuration variables
  static const double baseArchHeight = 70;  // The base height of the sun and moon arc
  static const double baseYPosition = -30; // The starting Y position of the sun and moon (low to the horizon)
  static const double fastForwardDurationMillis = 20000; // Duration for fast-forward mode (in milliseconds)
  static const double normalDurationMillis = 86400000; // Duration for normal mode (1 day in milliseconds)
  static const int numStars = 30; // Number of stars to show at night
  static const double starSizeMin = 1.0; // Minimum size of stars
  static const double starSizeMax = 2.5; // Maximum size of stars

  @override
  void initState() {
    super.initState();

    final int durationMillis = widget.isFastForward ? fastForwardDurationMillis.toInt() : normalDurationMillis.toInt();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMillis),
    )..repeat();

    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );


  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      builder: (context, child) {
        double t = _progress.value;

        // Determine the background color based on time of day (Smooth transition)
        Color backgroundColor = _getBackgroundColor(t);

        // Smart text color based on the background brightness (for visibility)
        Color textColor = backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

        final screenWidth = MediaQuery.of(context).size.width;

        double iconX, iconY;
        Widget? celestialBody;

        // Adjust the arc height based on the progress (this will change for Sun and Moon)
        double archHeight = baseArchHeight;
        double baseY = baseYPosition;

        // Determine the movement of the Sun or Moon based on time
        if (t < 0.5) {
          // Sun Movement (Daytime)
          double sunProgress = t / 0.5;
          iconX = sunProgress * (screenWidth + 100) - 50;
          double curveT = (iconX + 50) / (screenWidth + 100);
          iconY = sin(curveT * pi) * archHeight + baseY;

          celestialBody = const Icon(Icons.wb_sunny, size: 40, color: Colors.yellow);
        } else {
          // Moon Movement (Nighttime)
          double moonProgress = (t - 0.5) / 0.5;
          iconX = (1 - moonProgress) * (screenWidth + 100) - 50;
          double curveT = (iconX + 50) / (screenWidth + 100);
          iconY = sin(curveT * pi) * archHeight + baseY;

          celestialBody = const Icon(Icons.nightlight_round, size: 40, color: Colors.white);
        }

        return Container(
          width: double.infinity,
          height: 80,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              // Generate stars if it's nighttime (after the sun sets)
              if (t >= 0.5) ..._generateStars(t),

              // Place the Sun or Moon based on time of day
              Positioned(
                left: iconX.clamp(-50.0, screenWidth + 50.0),
                bottom: iconY,
                child: celestialBody,
              ),

              // Weekday Text (Bottom left)
              Positioned(
                left: 12,
                bottom: 12,
                child: Text(
                  widget.currentWeekday,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColor),
                ),
              ),

              // Current Time Text (Bottom right)
              Positioned(
                right: 12,
                bottom: 12,
                child: Text(
                  widget.currentTime.toString(),
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Background color changes dynamically from black to blue, orange, and then dark indigo at night
  Color _getBackgroundColor(double t) {
    if (t < 0.25) {
      return Color.lerp(Colors.black, Colors.lightBlue.shade300, t * 4)!;
    } else if (t < 0.5) {
      return Color.lerp(Colors.lightBlue.shade300, Colors.orange.shade400, (t - 0.25) * 4)!;
    } else if (t < 0.75) {
      return Color.lerp(Colors.orange.shade400, Colors.indigo.shade900, (t - 0.5) * 4)!;
    } else {
      return Color.lerp(Colors.indigo.shade900, Colors.black, (t - 0.75) * 4)!;
    }
  }

  // Star generator for nighttime
  List<Widget> _generateStars(double t) {
    final random = Random(t.toString().hashCode);
    return List.generate(numStars, (index) {
      double x = random.nextDouble() * MediaQuery.of(context).size.width;
      double y = random.nextDouble() * 80;
      double size = random.nextDouble() * (starSizeMax - starSizeMin) + starSizeMin;

      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, 0.8), // white with 80% opacity
            shape: BoxShape.circle,
          ),
        ),
      );

    });
  }
}
