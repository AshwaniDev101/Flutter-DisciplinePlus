import 'package:flutter/material.dart';
import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/models/app_time.dart';
import 'package:discipline_plus/pages/timer_page/viewModel/timer_view_model.dart';
import 'package:discipline_plus/pages/timer_page/widgets/pai_chart_painter.dart';
import 'package:provider/provider.dart';

class TimerPage extends StatelessWidget {
  final Initiative initiative;
  final List<Initiative> initiativeList;
  final Function(Initiative init, bool isManual) onComplete;

  const TimerPage({
    super.key,
    required this.initiative,
    required this.initiativeList,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TimerViewModel(
        initialInitiative: initiative,
        initiativeList: initiativeList,
        onComplete: onComplete,
      ),
      child: const _TimerPageBody(),
    );
  }
}

class _TimerPageBody extends StatelessWidget {
  const _TimerPageBody();

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TimerViewModel>();
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
              vm.isAllDone
                  ? "All tasks completed!"
                  : vm.currentInitiative.title,
              style: const TextStyle(color: Colors.white, fontSize: 32),
              textAlign: TextAlign.center,
            ),

            // Timer circle
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: vm.isPaused ? vm.startTimer : vm.pauseTimer,
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
                              color: vm.isPaused
                                  ? const Color.fromRGBO(255, 255, 255, 0.5)
                                  : Colors.white,
                              tickLength: tickLength,
                              tickDistanceFromCenter:
                                  circleRadius - ringThickness - 15,
                              numberDistanceFromCenter:
                                  circleRadius - ringThickness + numberDistanceOffset,
                              progress: vm.progress,
                              totalNumberOfTicks: vm.totalTicks,
                              showNumbers: showNumbers,
                              tickColor: tickColor,
                              numberColor: numberColor,
                              numberFontSize: numberFontSize,
                            ),
                          ),
                        ),
                      ),
                      if (vm.isPaused && !vm.isAllDone)
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
                vm.isAllDone ? "" : vm.formattedTime,
                style: const TextStyle(color: Colors.white, fontSize: 32),
              ),
            ),

            // Controls (only when paused and tasks remain)
            if (!vm.isAllDone && vm.isPaused) ...[
              ElevatedButton(
                onPressed: () => vm.increaseTime(AppTime(0, 5)),
                child: const Text('+5'),
              ),
              ElevatedButton(
                onPressed: vm.moveToNextInitiative,
                child: const Text('Next'),
              ),
              ElevatedButton(
                onPressed: vm.restartTimer,
                child: const Text('Restart'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Complete?', style: TextStyle(color: Colors.white)),
                  Checkbox(
                    value: vm.currentInitiative.isComplete,
                    onChanged: vm.handleManualComplete,
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
                "next: ${vm.onBreak
                    ? (vm.nextInitiative != null ? vm.nextInitiative!.title : "No Initiative left")
                    : vm.currentInitiative.studyBreak.title}",
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
