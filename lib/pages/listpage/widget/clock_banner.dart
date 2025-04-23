import 'package:flutter/material.dart';
import 'dart:async';

class ClockBanner extends StatefulWidget {
  const ClockBanner({super.key});

  @override
  State<ClockBanner> createState() => _ClockBannerState();
}

class _ClockBannerState extends State<ClockBanner> {
  late Stream<DateTime> _clockStream;

  Stream<DateTime> _buildAlignedClockStream() async* {
    yield DateTime.now(); // Emit immediately

    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;
    await Future.delayed(Duration(seconds: secondsUntilNextMinute));

    yield DateTime.now(); // Align with system clock

    yield* Stream.periodic(Duration(minutes: 1), (_) => DateTime.now());
  }

  @override
  void initState() {
    super.initState();
    _clockStream = _buildAlignedClockStream();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _clockStream,
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();

        const weekdays = [
          'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
        ];
        final weekday = weekdays[now.weekday - 1];
        final hour = now.hour.toString().padLeft(2, '0');
        final minute = now.minute.toString().padLeft(2, '0');
        final timeString = '$hour:$minute';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
          decoration: BoxDecoration(
            color: Colors.indigo[100],
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                weekday,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.indigo[900],
                ),
              ),
              Text(
                timeString,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
