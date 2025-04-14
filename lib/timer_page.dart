
import 'dart:async';
import 'dart:math';
import 'package:discipline_plus/resource_managers/audio_manager.dart';
import 'package:discipline_plus/taskmanager.dart';
import 'package:discipline_plus/widget/pai_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:discipline_plus/constants.dart';
import 'package:discipline_plus/models/data_types.dart';

class TimerPage extends StatefulWidget {
  final BaseInitiative baseInitiative;
  const TimerPage({required this.baseInitiative, Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  // UI Constants
  final double circleRadius = 150.0;
  final double ringThickness = 10.0;
  final double pieGraphGap = 60.0;
  final double tickLength = 10.0;

  // Feature flags and style settings
  final bool showNumbers = true;
  final bool autoNextTask = true;
  final int? clockSpeed = 80; // null = real‐time; >1 = multiplier
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
  bool isChecked = false;

  // Initiatives
  Initiative? currentInitiative;
  Initiative? nextInitiative;
  bool isBreakGiven = false;

  // --- Derived getters ---
  int get remainingSeconds => max(0, totalTimeSeconds - elapsedSeconds);
  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  double get progress => totalTimeSeconds > 0 ? remainingSeconds / totalTimeSeconds : 0;

  @override
  void initState() {
    super.initState();
    // Initialize current initiative from baseInitiative
    if (widget.baseInitiative is InitiativeGroup) {
      var group = widget.baseInitiative as InitiativeGroup;
      if (group.hasNoInitiatives()) {
        _showErrorDialog("Empty Group");
        return;
      }
      currentInitiative = group.initiativeList.first;
    } else {
      currentInitiative = widget.baseInitiative as Initiative;
    }

    if (currentInitiative == null) {
      _showErrorDialog("No Current Initiatives");
      return;
    }
    nextInitiative = TaskManager.instance.nextInitiative(currentInitiative!.id);

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
      isChecked = false;
    });
    _startTimer();
  }

  /// Called when the timer finishes its cycle.
  void _onComplete() {
    _playStopSound();
    currentInitiative!.isComplete = true;
    if (!isBreakGiven) {
      // Switch to study break if it exists
      StudyBreak studyBreak = currentInitiative!.studyBreak;
      currentInitiative = Initiative(
        title: studyBreak.title,
        completionTime: studyBreak.completionTime,
      );
      isBreakGiven = true;
    } else {
      // Proceed to the next initiative
      currentInitiative = nextInitiative;
      nextInitiative = TaskManager.instance.nextInitiative(currentInitiative!.id);
      isBreakGiven = false;
    }

    // Reset timer based on new initiative
    totalTimeSeconds =
    ((currentInitiative!.completionTime.hour * 60 + currentInitiative!.completionTime.minute) * 60);
    elapsedSeconds = 0;

    // Restart timer if not paused (with a short delay)
    if (!isPaused) {
      _delayedRestart = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) _startTimer();
      });
    }
  }

  void _onManualComplete(bool? value) {
    setState(() {
      isChecked = value ?? false;
      currentInitiative!.isComplete = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background_color,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Constants.background_color,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display current or break title based on state
            Text(
              !isBreakGiven ? currentInitiative!.title : currentInitiative!.studyBreak.title,
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
                              totalNumberOfTicks: currentInitiative!.completionTime.hour * 60 +
                                  currentInitiative!.completionTime.minute,
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
                onPressed: _restartTimer,
                child: const Text('+5'),
              ),
              ElevatedButton(
                onPressed: _restartTimer,
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
                "next: ${isBreakGiven ? (nextInitiative != null ? nextInitiative!.title : "There is no Initiative left") : currentInitiative!.studyBreak.title} ",
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


//
// import 'dart:async';
// import 'dart:math';
//
// import 'package:discipline_plus/resource_managers/audio_manager.dart';
// import 'package:discipline_plus/taskmanager.dart';
// import 'package:discipline_plus/widget/pai_chart_painter.dart';
// import 'package:flutter/material.dart';
// import 'package:discipline_plus/constants.dart';
// import 'package:discipline_plus/models/data_types.dart';
// import 'package:just_audio/just_audio.dart';
//
// class TimerPage extends StatefulWidget {
//   final BaseInitiative baseInitiative;
//   const TimerPage({required this.baseInitiative, super.key});
//
//   @override
//   State<TimerPage> createState() => _TimerPageState();
// }
//
// class _TimerPageState extends State<TimerPage> {
//   // --- UI constants ---
//   final double circleRadius = 150.0;
//   final double ringThickness = 10.0;
//   final double pieGraphGap = 60.0;
//   final double tickLength = 10.0;
//
//   // --- Feature flags ---
//   final bool showNumbers = true;
//   final bool autoNextTask = true;
//   // final Duration nextTaskDelay = const Duration(seconds: 1);
//   final int? clockSpeed = 30  ; // null = real‐time; >1 = multiplier
//
//   // --- Style placeholders ---
//   final Color tickColor = Colors.white;
//   final double numberFontSize = 12.0;
//   final Color numberColor = Colors.white;
//   final double numberDistanceOffset = 30;
//
//   // --- Timer state ---
//   late int totalTimeSeconds;
//   int elapsedSeconds = 0;
//   Timer? _timer;
//   Timer? _delayedRestart;
//   bool isPaused = true;
//   bool isChecked = false;
//
//   Initiative? currentInitiative;
//   Initiative? nextInitiative;
//   bool isBreakGiven = false;
//
//
//
//
//
//
//   // --- Derived getters ---
//   int get remainingSeconds => max(0, totalTimeSeconds - elapsedSeconds);
//   String get formattedTime {
//     final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
//     final s = (remainingSeconds % 60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }
//   double get progress => remainingSeconds / totalTimeSeconds;
//
//
//   // --- Cached next‐task title ---
//
//   @override
//   void initState() {
//     super.initState();
//     // load current and next initiatives
//     if (widget.baseInitiative is InitiativeGroup) {
//       var group = (widget.baseInitiative as InitiativeGroup);
//       if(group.hasNoInitiatives()) {
//           showErrorDialog(context, "Empty Group");
//           return;
//         }
//
//       currentInitiative = group.initiativeList[0];
//     }else{
//       currentInitiative = (widget.baseInitiative as Initiative);
//       // nextInitiative = Initiative(title: 'IDK', completionTime: AppTime(0, 0));
//     }
//
//
//     // currentBreak =  currentInitiative.studyBreak!;
//     // hasBreak=true;
//     if(currentInitiative==null) {
//       showErrorDialog(context, "No Current Initiatives");
//       return;
//     }
//
//
//     nextInitiative = TaskManager.instance.nextInitiative(currentInitiative!.id);
//
//     // Compute total seconds for this task
//     totalTimeSeconds = (currentInitiative!.completionTime.hour * 60 + currentInitiative!.completionTime.minute) * 60;
//     // Future.delayed(const Duration(milliseconds: 2000), _startTimer);
//     // initial delayed start
//
//     _delayedRestart = Timer(const Duration(milliseconds: 2000), () {
//       if (mounted) _startTimer();
//     });
//
//
//
//
//   }
//
//
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _delayedRestart?.cancel();
//     // player.dispose();
//     super.dispose();
//   }
//
//
//   Future<void> _startTimer() async {
//
//
//
//     print("------------------------------- current=>${currentInitiative!.title}: next=>${nextInitiative?.title.toString()} ");
//
//     _timer?.cancel();  // <- Cancel old one anyway
//     _timer = null;
//
//     // if (_timer != null) return;
//     setState(() => isPaused = false);
//
//     final intervalMs = clockSpeed != null
//         ? (1000 / clockSpeed!).floor().clamp(1, 1000)
//         : 1000;
//
//     _timer = Timer.periodic(Duration(milliseconds: intervalMs), (t) {
//       if (!mounted) return;
//       setState(() {
//         if (elapsedSeconds < totalTimeSeconds) {
//           elapsedSeconds++;
//         } else {
//           t.cancel();
//
//           _onComplete();
//         }
//       });
//     });
//   }
//
//   void _pauseTimer() {
//     _timer?.cancel();
//     _timer = null;
//     _delayedRestart?.cancel();
//     setState(() => isPaused = true);
//   }
//
//   void _restartTimer() {
//     _timer?.cancel();
//     _timer = null;
//     _delayedRestart?.cancel();
//     setState(() {
//       elapsedSeconds = 0;
//       isPaused = true;
//       isChecked = false;
//     });
//     _startTimer();
//   }
//
//   /// Called when the work‐timer finishes.
//
//   void _onComplete() {
//
//     playStopSound();
//     // playSound();
//     if(!isBreakGiven) {
//         StudyBreak studyBreak = currentInitiative!.studyBreak;
//         currentInitiative= Initiative(title: studyBreak.title, completionTime: studyBreak.completionTime);
//         isBreakGiven = true;
//
//       }
//     else
//       {
//         currentInitiative = nextInitiative;
//         nextInitiative = TaskManager.instance.nextInitiative(currentInitiative!.id);
//         isBreakGiven = false;
//       }
//
//
//     totalTimeSeconds = (currentInitiative!.completionTime.hour * 60 + currentInitiative!.completionTime.minute) * 60;
//     elapsedSeconds = 0;
//
//
//
//
//     if (!isPaused) {
//
//       _delayedRestart = Timer(const Duration(milliseconds: 2000), () {
//         if (mounted) _startTimer();
//       });
//     }
//
//
//     // _delayedRestart = Timer(const Duration(milliseconds: 2000), _startTimer);
//
//
//
//   }
//
//
//   void _onManualComplete(bool? v) {
//     setState(() {
//       isChecked = v ?? false;
//
//       currentInitiative!.isComplete = true;
//       // if (isChecked && !currentInitiative!.isComplete);
//       // if (isChecked && !currentInitiative!.isComplete) _onComplete();
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Constants.background_color,
//       appBar: AppBar(
//         title: Text(''),
//         backgroundColor: Constants.background_color,
//         iconTheme: const IconThemeData(color: Colors.white),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Text(!isBreakGiven? currentInitiative!.title: currentInitiative!.studyBreak.title, style: const TextStyle(color: Colors.white,fontSize: 32)),
//             Expanded(
//               child: Center(
//                 child: GestureDetector(
//                   onTap: isPaused ? _startTimer : _pauseTimer,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       CircleAvatar(
//                         radius: circleRadius,
//                         backgroundColor: Colors.white,
//                         child: CircleAvatar(
//                           radius: circleRadius - ringThickness,
//                           backgroundColor: Constants.background_color,
//
//                           // Animated painter
//                           child: CustomPaint(
//                             size: Size(
//                               circleRadius * 2 - pieGraphGap,
//                               circleRadius * 2 - pieGraphGap,
//                             ),
//                             painter: PieChartPainter(
//                               color: isPaused
//                                   ? const Color.fromRGBO(255, 255, 255, 0.5)
//                                   : Colors.white,
//                               tickLength: tickLength,
//                               tickDistanceFromCenter:
//                               circleRadius - ringThickness - 15,
//                               numberDistanceFromCenter:
//                               circleRadius - ringThickness + numberDistanceOffset,
//                               progress: progress,
//                               totalNumberOfTicks:
//                               currentInitiative!.completionTime.hour * 60 +
//                                   currentInitiative!.completionTime.minute,
//                               showNumbers: showNumbers,
//                               tickColor: tickColor,
//                               numberColor: numberColor,
//                               numberFontSize: numberFontSize,
//                             ),
//                           ),
//                         ),
//                       ),
//                       if (isPaused)
//                         const Icon(Icons.pause, size: 100, color: Colors.white),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//
//
//             // Time 15:20 min
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               child: Text(
//                 formattedTime,
//                 style: const TextStyle(color: Colors.white, fontSize: 32),
//               ),
//             ),
//
//             if (isPaused) ...[
//
//               // Restart Button
//               ElevatedButton(onPressed: _restartTimer, child: const Text('Restart')),
//
//               // 'Complete?' Checkbox
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text('Complete?', style: TextStyle(color: Colors.white)),
//                   Checkbox(
//                     value: isChecked,
//                     onChanged: _onManualComplete,
//                     activeColor: Colors.white,
//                     checkColor: Colors.black,
//                   ),
//                 ],
//               ),
//             ],
//               // "Next task title"
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Text("next: ${isBreakGiven? nextInitiative!=null? nextInitiative!.title:"There is no Initiative left": currentInitiative!.studyBreak.title} ",
//                 style: const TextStyle(color: Colors.white70, fontSize: 16),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//
//   void showErrorDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Error'),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: const Text('OK'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void playStopSound()
//   {
//     AudioManager().play(SoundEffect.success);
//   }
//
// }
//

