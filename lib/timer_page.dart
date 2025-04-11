

// lib/pages/timer_page.dart
// lib/pages/timer_page.dart

import 'dart:async';
import 'dart:math';
import 'package:discipline_plus/taskmanager.dart';
import 'package:discipline_plus/widget/pai_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:discipline_plus/constants.dart';
import 'package:discipline_plus/models/data_types.dart';

class TimerPage extends StatefulWidget {

  final BaseInitiative baseInitiative;
  const TimerPage({required this.baseInitiative, super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  // --- UI constants ---
  final double circleRadius = 150.0;
  final double ringThickness = 10.0;
  final double pieGraphGap = 60.0;
  final double tickLength = 10.0;

  // --- Feature flags ---
  final bool showNumbers = true;
  final bool autoNextTask = true;
  final Duration nextTaskDelay = const Duration(seconds: 1);
  final int? clockSpeed = 8; // null = real‐time; >1 = multiplier

  // --- Style placeholders ---
  final Color tickColor = Colors.white;
  final double numberFontSize = 12.0;
  final Color numberColor = Colors.white;
  final double numberDistanceOffset = 30;

  // --- Timer state ---
  // late final Initiative task;
  late int totalTimeSeconds;
  int elapsedSeconds = 0;
  Timer? _timer;
  bool isPaused = true;
  bool isChecked = false;



  // --- Derived getters ---
  int get remainingSeconds => max(0, totalTimeSeconds - elapsedSeconds);
  String get formattedTime {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
  double get progress => remainingSeconds / totalTimeSeconds;


  // --- Cached next‐task title ---
  Initiative? currentInitiative;

  bool isBreakGiven = false;

  Initiative? nextInitiative;





  @override
  void initState()
  {
    super.initState();

    if (widget.baseInitiative is InitiativeGroup) {
      var group = (widget.baseInitiative as InitiativeGroup);

      if(group.hasNoInitiatives())
        {
          showErrorDialog(context, "Empty Group");
          return;
        }

      currentInitiative = group.initiativeList[0];

      // Find the next incomplete task in sub list
      // for (Initiative initiative in group.initiativeList) {
      //   if (initiative.isNotComplete) {
      //     currentInitiative = initiative;
      //     break;
      //   }
      // }

    }else{
      var init = (widget.baseInitiative as Initiative);
      currentInitiative = init;
      // nextInitiative = Initiative(title: 'IDK', completionTime: AppTime(0, 0));
    }


    // currentBreak =  currentInitiative.studyBreak!;
    // hasBreak=true;
    if(currentInitiative==null) {
      showErrorDialog(context, "No Current Initiatives");
      return;
    }


    nextInitiative = TaskManager.instance.nextInitiative(currentInitiative!.title);

    // Compute total seconds for this task
    totalTimeSeconds = (currentInitiative!.completionTime.hour * 60 + currentInitiative!.completionTime.minute) * 60;
    Future.delayed(const Duration(milliseconds: 2000), _startTimer);




    // nextInitiative = TaskManager.instance.nextInitiative(currentInitiative.title);
    // if(nextInitiative==null)
    //   {
    //     showErrorDialog(context, "There are No Initiative");
    //
    //   }

  }



  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  void _startTimer() {


    print("------------------------------- current=>${currentInitiative!.title}: next=>${nextInitiative?.title.toString()} ");

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

  /// Called when the work‐timer finishes.

  void _onComplete() {




    if(!isBreakGiven)
      {

        StudyBreak studyBreak = currentInitiative!.studyBreak;

        currentInitiative= Initiative(title: studyBreak.title, completionTime: studyBreak.completionTime);
        isBreakGiven = true;

      }
    else
      {
        currentInitiative = nextInitiative;
        nextInitiative = TaskManager.instance.nextInitiative(currentInitiative!.title);
        isBreakGiven = false;
      }


    totalTimeSeconds = (currentInitiative!.completionTime.hour * 60 + currentInitiative!.completionTime.minute) * 60;

    Future.delayed(const Duration(milliseconds: 2000),(){
      setState(() {

        _restartTimer();
      });
    });



  }


  void _onManualComplete(bool? v) {
    setState(() {
      isChecked = v ?? false;
      // if (isChecked && !currentInitiative.isComplete) _onComplete();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background_color,
      appBar: AppBar(
        title: Text(!isBreakGiven? currentInitiative!.title.toString(): currentInitiative!.studyBreak.title, style: const TextStyle(color: Colors.white)),
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

                          // Animated painter
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
                              currentInitiative!.completionTime.hour * 60 +
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


            // Time 15:20 min
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                formattedTime,
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),

            if (isPaused) ...[

              // Restart Button
              ElevatedButton(onPressed: _restartTimer, child: const Text('Restart')),

              // 'Complete?' Checkbox
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
              // "Next task title"
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(isBreakGiven? nextInitiative!=null? nextInitiative!.title:"There is no Initiative left": currentInitiative!.studyBreak.title,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }




  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }


}


