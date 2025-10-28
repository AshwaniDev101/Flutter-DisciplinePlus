import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/models/app_time.dart';
import 'package:discipline_plus/pages/timer_page/widgets/pai_chart_painter.dart';
import '../../core/utils/constants.dart';
import '../../managers/audio_manager.dart';
import '../schedule_page/manager/schedule_manager.dart';

class TimerPage extends StatefulWidget {
  final Initiative initiative;
  final Function(Initiative  init, bool isManual) onComplete;

  const TimerPage({super.key, required this.initiative, required this.onComplete});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  
  // UI Constants
  final double circleRadius = 150.0;
  final double ringThickness = 10.0;
  final double pieGraphGap = 60.0;
  final double tickLength = 10.0;
  final bool showNumbers = true;
  final Color tickColor = Colors.white;
  final double numberFontSize = 12.0;
  final Color numberColor = Colors.white;
  final double numberDistanceOffset = 30;

  
  // Timer & Test Settings
  final int? clockSpeed = 80; // null = real-time, >1 = faster for testing
  late int totalTimeSeconds;
  int elapsedSeconds = 0;
  Timer? _timer;
  Timer? _restartDelayTimer;
  bool isPaused = true;

  
  // Initiative State
  late Initiative currentInitiative;
  Initiative? nextInitiative;
  bool onBreak = false;

  // Flags
  bool isNextAvailable = false;
  bool isAllDone = false;

  
  // Derived getters
  int get remainingSeconds => max(0, totalTimeSeconds - elapsedSeconds);

  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get totalTicks => (totalTimeSeconds / 60).ceil();

  double get progress => totalTimeSeconds > 0 ? remainingSeconds / totalTimeSeconds : 0;

  
  // Lifecycle Methods
  @override
  void initState() {
    super.initState();

    // Initialize current initiative
    currentInitiative = widget.initiative;

    // Set total time for the initiative
    totalTimeSeconds = toSeconds(currentInitiative.completionTime);

    // Start timer after small delay
    _restartDelayTimer = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) _startTimer();
    });
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  
  // Helper Methods
  int toSeconds(AppTime time) => Duration(hours: time.hour, minutes: time.minute).inSeconds;

  void _cancelTimers() {
    _timer?.cancel();
    _restartDelayTimer?.cancel();
  }

  // Start the timer
  Future<void> _startTimer() async {
    debugPrint("current=>${currentInitiative.title}, next=>${nextInitiative?.title}");

    _cancelTimers();
    setState(() => isPaused = false);

    final intervalMs = clockSpeed != null
        ? (1000 / clockSpeed!).floor().clamp(1, 1000)
        : 1000;

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (!mounted) return;

      setState(() {
        if (elapsedSeconds < totalTimeSeconds) {
          elapsedSeconds++;
        } else {
          timer.cancel();
          _onComplete();
        }
      });
    });
  }

  // Pause the timer
  void _pauseTimer() {
    _cancelTimers();
    setState(() => isPaused = true);
  }

  // Restart timer from zero
  void _restartTimer() {
    _cancelTimers();
    setState(() {
      elapsedSeconds = 0;
      isPaused = true;
    });
    _startTimer();
  }

  // Move to next initiative or break
  void moveToNextInitiative() {
    if (isAllDone) return;

    if (!onBreak) {
      // Switch to break
      currentInitiative = Initiative(
        index: -1,
        title: currentInitiative.studyBreak.title,
        completionTime: currentInitiative.studyBreak.completionTime,
        id: currentInitiative.id, // link break to work initiative
      );
      onBreak = true;

      // Precompute next initiative for UI
      nextInitiative = ScheduleManager.instance.getNextByCurrent(
        // Use the previous work initiative to find the next
          ScheduleManager.instance.latestMergedList.firstWhere(
                (i) => i.id == currentInitiative.id,
            orElse: () => currentInitiative,
          )
      );

    } else {
      // Move to next initiative after break
      if (nextInitiative != null) {
        currentInitiative = nextInitiative!;
        onBreak = false;
      } else {
        isAllDone = true;
        _cancelTimers();
      }
    }

    setState(() {
      if (!isAllDone) {
        totalTimeSeconds = toSeconds(currentInitiative.completionTime);
        elapsedSeconds = 0;
      }
    });
  }



  // Called when timer completes
  void _onComplete() {
    _playStopSound();
    widget.onComplete(currentInitiative,false);

    moveToNextInitiative();

    if (!isPaused && !isAllDone) {
      _restartDelayTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) _startTimer();
      });
    }
  }

  // Manual completion toggle
  void _onManualComplete(bool? value) {
    final newValue = value ?? false;
    widget.onComplete(currentInitiative, true);
    setState(() => currentInitiative.isComplete = newValue);
  }

  // Play completion sound
  void _playStopSound() {
    if (_timer?.isActive != true)
    {
      AudioManager().play(SoundEffect.success);
    }
  }

  // Add time manually
  void increaseTime(AppTime appTime) {
    final addedSeconds = (appTime.hour * 60 + appTime.minute) * 60;
    setState(() => totalTimeSeconds += addedSeconds);
  }

  
  // UI
  @override
  Widget build(BuildContext context) {

    final backgroundColor = Colors.blueGrey;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Initiative or break title
            Text(
              isAllDone
                  ? "All tasks completed!"
                  : (!onBreak ? currentInitiative.title : currentInitiative.studyBreak.title),
              style: const TextStyle(color: Colors.white, fontSize: 32),
            ),

            // Timer circle
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
                          backgroundColor: backgroundColor,
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
                              tickDistanceFromCenter: circleRadius - ringThickness - 15,
                              numberDistanceFromCenter: circleRadius - ringThickness + numberDistanceOffset,
                              progress: progress,
                              totalNumberOfTicks: totalTicks,
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

            // Timer text
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                isAllDone ? "" : formattedTime,
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),

            // Controls (only when paused and tasks remain)
            if (!isAllDone && isPaused) ...[
              ElevatedButton(
                onPressed: () => increaseTime(AppTime(0, 5)),
                child: const Text('+5'),
              ),
              ElevatedButton(
                onPressed: moveToNextInitiative,
                child: const Text('Next'),
              ),
              ElevatedButton(
                onPressed: _restartTimer,
                child: const Text('Restart'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Complete?', style: TextStyle(color: Colors.white)),
                  Checkbox(
                    value: currentInitiative.isComplete,
                    onChanged: _onManualComplete,
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                  ),
                ],
              ),
            ],

            // Next initiative info
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "next: ${onBreak ? (nextInitiative != null ? nextInitiative!.title : "No Initiative left") : currentInitiative.studyBreak.title}",
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
