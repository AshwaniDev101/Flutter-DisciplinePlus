// lib/pages/timer_page.dart

import 'dart:async';
import 'dart:math';
import 'package:discipline_plus/taskmanager.dart';
import 'package:discipline_plus/widget/pai_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:discipline_plus/constants.dart';
import 'package:discipline_plus/models/data_types.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  // --- UI constants ---
  final double circleRadius = 150.0;
  final double ringThickness = 10.0;
  final double pieGraphGap = 60.0;
  final double tickLength = 10.0;

  // --- Debug & feature flags ---
  final bool showNumbers = true;
  final bool autoNextTask = true;
  final Duration nextTaskDelay = Duration(seconds: 4);
  final int? clockSpeed = 8; // null = real‐time; >1 = multiplier

  // --- tweak placeholders ---
  final Color tickColor = Colors.white;
  final double numberFontSize = 12.0;
  final Color numberColor = Colors.white;
  final double numberDistanceOffset = 30;

  // --- Timer state ---
  late final BaseTask task;
  late final int totalTimeSeconds;
  int elapsedSeconds = 0;
  Timer? _timer;
  bool isPaused = true;
  bool isChecked = false;

  // --- Cached next‐task title ---
  late String nextTaskTitle;

  // --- Derived getters ---
  int get remainingSeconds => max(0, totalTimeSeconds - elapsedSeconds);
  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  double get progress => remainingSeconds / totalTimeSeconds;

  @override
  void initState() {
    super.initState();
    // grab current
    task = TaskManager.instance.currentTask!;
    totalTimeSeconds =
        (task.completionTime.hour * 60 + task.completionTime.minute) * 60;

    // compute next‐task title without advancing index
    nextTaskTitle = TaskManager.instance.peekNextTaskTitle();

    if (task.isComplete) {
      isChecked = true;
      isPaused = true;
    } else {
      Future.delayed(const Duration(milliseconds: 500), _startTimer);
    }
  }



  void _startTimer() {
    if (_timer != null) return;
    setState(() => isPaused = false);

    final intervalMs = clockSpeed != null
        ? (1000 / clockSpeed!).floor()
        : 1000;
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (t) {
      if (!mounted) return;
      setState(() {
        if (elapsedSeconds < totalTimeSeconds) {
          elapsedSeconds++;
        } else {
          t.cancel();
          _onComplete();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() => isPaused = true);
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      elapsedSeconds = 0;
      isPaused = true;
      isChecked = false;
    });
    _startTimer();
  }

  void _onComplete() {
    setState(() => isPaused = true);
    TaskManager.instance.markCurrentDone();
    onTaskCompleteTrigger();

    if (autoNextTask) {
      Future.delayed(nextTaskDelay, () {

        final next = TaskManager.instance.nextTask();
        if (next != null) {

          // This rebuild the page, resting everything better then writing a reset function
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TimerPage()),
          );
        } else {
          Navigator.popUntil(context, ModalRoute.withName('/ListPage'));
        }

      });
    }
  }

  // dev hook
  void onTaskCompleteTrigger() {
    debugPrint('Task "${task.title}" completed at ${DateTime.now()}');
  }

  void _onManualComplete(bool? v) {
    setState(() {
      isChecked = v ?? false;
      if (isChecked && !task.isComplete) _onComplete();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background_color,
      appBar: AppBar(
        title: Text(task.title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Constants.background_color,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: isPaused ? _startTimer : _pauseTimer,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: circleRadius,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: circleRadius - ringThickness,
                          backgroundColor: Constants.background_color,
                          child: CustomPaint(
                            size: Size(
                              circleRadius * 2 - pieGraphGap,
                              circleRadius * 2 - pieGraphGap,
                            ),
                            painter: PieChartPainter(
                              color: isPaused
                                  ? const Color.fromRGBO(255, 255, 255, 0.5)
                                  : Colors.white,
                              tickLength: tickLength,
                              tickDistanceFromCenter:
                              circleRadius - ringThickness - 15,
                              numberDistanceFromCenter:
                              circleRadius - ringThickness + numberDistanceOffset,
                              progress: progress,
                              totalNumberOfTicks:
                              task.completionTime.hour * 60 +
                                  task.completionTime.minute,
                              showNumbers: showNumbers,
                              tickColor: tickColor,
                              numberColor: numberColor,
                              numberFontSize: numberFontSize,
                            ),
                          ),
                        ),
                      ),
                      if (isPaused)
                        const Icon(Icons.pause, size: 100, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                formattedTime,
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),

            if (isPaused) ...[
              ElevatedButton(onPressed: _restartTimer, child: const Text('Restart')),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Complete?', style: TextStyle(color: Colors.white)),
                  Checkbox(
                    value: isChecked,
                    onChanged: _onManualComplete,
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                  ),
                ],
              ),
            ],

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Next: $nextTaskTitle',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}