
import 'dart:async';
import 'dart:math';
import 'package:discipline_plus/pages/timerpage/widgets/pai_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:discipline_plus/models/initiative.dart';
import '../../core/utils/constants.dart';
import '../../managers/audio_manager.dart';
import '../../models/app_time.dart';
import '../homepage/schedule_handler/schedule_manager.dart';

class TimerPage extends StatefulWidget {
  final Initiative initiative;
  final Function({bool isManual,bool isComplete}) onComplete;

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

  // Testing
  final int? clockSpeed = 80; // null = real‐time; >1 = multiplier

  // Feature flags and style settings
  final bool showNumbers = true;
  final bool autoNextTask = true;
  final Color tickColor = Colors.white;
  final double numberFontSize = 12.0;
  final Color numberColor = Colors.white;
  final double numberDistanceOffset = 30;

  // Timer state
  late int totalTimeSeconds;
  int elapsedSeconds = 0;
  Timer? _timer;
  Timer? _delayedRestart;
  bool isPaused = true;


  // Initiatives
  Initiative? currentInitiative;
  Initiative? nextInitiative;
  bool onBreak = false;

  // --- Derived getters ---
  int get remainingSeconds => max(0, totalTimeSeconds - elapsedSeconds);
  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int get totalTicks => (totalTimeSeconds / 60).ceil();

  double get progress => totalTimeSeconds > 0 ? remainingSeconds / totalTimeSeconds : 0;

  @override
  void initState() {
    super.initState();
    // Initialize current initiative from baseInitiative
    currentInitiative = widget.initiative;
    if (currentInitiative == null) {
      _showErrorDialog("No Current Initiatives");
      return;
    }
    nextInitiative = ScheduleManager.instance.getNext(currentInitiative!.index);

    // Calculate total time in seconds
    totalTimeSeconds =
    ((currentInitiative!.completionTime.hour * 60 + currentInitiative!.completionTime.minute) * 60);

    // Delay initial timer start
    _delayedRestart = Timer(const Duration(milliseconds: 2000), () {
      if (mounted) _startTimer();
    });
  }

  @override
  void dispose() {
    _cancelTimers();
    super.dispose();
  }

  // Helper method to cancel active timers
  void _cancelTimers() {
    _timer?.cancel();
    _delayedRestart?.cancel();
  }

  Future<void> _startTimer() async {
    // Print current initiative details for debugging
    debugPrint("------------------------------- current=>${currentInitiative!.title}: next=>${nextInitiative?.title.toString()} ");

    // Ensure previous timers are cancelled
    _cancelTimers();

    setState(() => isPaused = false);

    // Calculate timer interval in milliseconds. (Using floor for safety.)
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

  void _pauseTimer() {
    _cancelTimers();
    setState(() => isPaused = true);
  }

  void _restartTimer() {
    _cancelTimers();
    setState(() {
      elapsedSeconds = 0;
      isPaused = true;
    });
    _startTimer();
  }


  void moveToNextInitiative() {


    if (!onBreak) {

      currentInitiative = Initiative(
        index: -1,
        title: currentInitiative!.studyBreak.title,
        completionTime: currentInitiative!.studyBreak.completionTime,
      );
      onBreak = true;
    } else {

      currentInitiative = nextInitiative;
      nextInitiative = ScheduleManager.instance.getNext(currentInitiative!.index);
      onBreak = false;
    }

    setState(() {
      totalTimeSeconds =
          (currentInitiative!.completionTime.hour * 60
              + currentInitiative!.completionTime.minute) * 60;
      elapsedSeconds = 0;
    });

  }

  void _onComplete() {
    _playStopSound();

    widget.onComplete(isManual: false,isComplete: widget.initiative.isComplete);
    moveToNextInitiative();

    if (!isPaused) {
      _delayedRestart = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) _startTimer();
      });
    }
  }


  // void _onManualComplete(bool? value) {
  //   setState(() {
  //
  //     widget.initiative.isComplete = value??false;
  //
  //   });
  //   widget.onComplete(isManual: true,isComplete: widget.initiative.isComplete);
  // }

  void _onManualComplete(bool? value) {
    final newValue = value ?? false;

    // Notify parent / managers first
    widget.onComplete(isManual: true, isComplete: newValue);

    // Then update local state to rebuild UI
    setState(() {
      widget.initiative.isComplete = newValue;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _playStopSound() {
    AudioManager().play(SoundEffect.success);
  }


  void increaseTime(AppTime appTime) {
    final addedSeconds = (appTime.hour * 60 + appTime.minute) * 60;
    setState(() {
      // bump up total time
      totalTimeSeconds += addedSeconds;

    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background_color,
      appBar: AppBar(
        // title: const Text(''),
        backgroundColor: Constants.background_color,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display current or break title based on state
            Text(
              !onBreak ? currentInitiative!.title : currentInitiative!.studyBreak.title,
              style: const TextStyle(color: Colors.white, fontSize: 32),
            ),
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
                              tickDistanceFromCenter: circleRadius - ringThickness - 15,
                              numberDistanceFromCenter: circleRadius - ringThickness + numberDistanceOffset,
                              progress: progress,
                              // totalNumberOfTicks: currentInitiative!.completionTime.hour * 60 + currentInitiative!.completionTime.minute,
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
            // Timer display
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                formattedTime,
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),
            if (isPaused) ...[
              ElevatedButton(
                onPressed: ()=>increaseTime(AppTime(0, 5)),
                child: const Text('+5'),
              ),
              ElevatedButton(
                onPressed: moveToNextInitiative,
                child: const Text('next'),
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
                    value: widget.initiative.isComplete,
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
                "next: ${onBreak ? (nextInitiative != null ? nextInitiative!.title : "There is no Initiative left") : currentInitiative!.studyBreak.title} ",
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
