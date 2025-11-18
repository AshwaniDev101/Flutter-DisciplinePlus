import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/models/app_time.dart';
import '../../../managers/audio_manager.dart';

class TimerViewModel extends ChangeNotifier {
  // Constructor
  TimerViewModel({
    required Initiative initialInitiative,
    required this.initiativeList,
    required this.onComplete,
  }) {
    // Initialize current initiative
    currentInitiative = initialInitiative;
    // Set total time for the initiative
    totalTimeSeconds = toSeconds(currentInitiative.completionTime);
    // Start timer after small delay
    _restartDelayTimer = Timer(const Duration(milliseconds: 2000), () {
      startTimer();
    });
  }

  // Passed in dependencies
  final List<Initiative> initiativeList;
  final Function(Initiative init, bool isManual) onComplete;

  // Timer & Test Settings
  // final int? clockSpeed = 80; // null = real-time, >1 = faster for testing
  final int? clockSpeed = null; // null = real-time, >1 = faster for testing
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

  // Lifecycle
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

  // Public methods for the View
  void startTimer() {
    if (!isPaused) return;
    debugPrint("current=>${currentInitiative.title}, next=>${nextInitiative?.title}");

    _cancelTimers();
    isPaused = false;
    notifyListeners();

    final intervalMs = clockSpeed != null
        ? (1000 / clockSpeed!).floor().clamp(1, 1000)
        : 1000;

    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (elapsedSeconds < totalTimeSeconds) {
        elapsedSeconds++;
      } else {
        timer.cancel();
        _handleCompletion();
      }
      notifyListeners();
    });
  }

  void pauseTimer() {
    if (isPaused) return;
    _cancelTimers();
    isPaused = true;
    notifyListeners();
  }

  void restartTimer() {
    _cancelTimers();
    elapsedSeconds = 0;
    isPaused = true;
    notifyListeners();
    startTimer();
  }

  void moveToNextInitiative() {
    if (isAllDone) return;

    if (!onBreak) {
      // Find the original work initiative to access its studyBreak property
      final originalInitiative = initiativeList.firstWhere(
        (i) => i.id == currentInitiative.id,
        orElse: () => currentInitiative, // Fallback
      );

      // Switch to break
      currentInitiative = Initiative(
        index: -1,
        title: originalInitiative.studyBreak.title,
        completionTime: originalInitiative.studyBreak.completionTime,
        id: originalInitiative.id, // link break to work initiative
        timestamp: Timestamp.now()
      );
      onBreak = true;

      // Precompute next work initiative for UI
      nextInitiative = _getNextWorkInitiative(originalInitiative);

    } else {
      // Move to next work initiative after break
      if (nextInitiative != null) {
        currentInitiative = nextInitiative!;
        onBreak = false;
        nextInitiative = null; // Clear it after moving
      } else {
        isAllDone = true;
        _cancelTimers();
      }
    }

    if (!isAllDone) {
      totalTimeSeconds = toSeconds(currentInitiative.completionTime);
      elapsedSeconds = 0;
    }
    notifyListeners();
  }

  Initiative? _getNextWorkInitiative(Initiative current) {
    final pos = initiativeList.indexWhere((i) => i.id == current.id);
    if (pos == -1 || pos + 1 >= initiativeList.length) return null;
    return initiativeList[pos + 1];
  }

  void _handleCompletion() {
    _playStopSound();
    onComplete(currentInitiative, false);
    moveToNextInitiative();

    if (!isPaused && !isAllDone) {
      _restartDelayTimer = Timer(const Duration(milliseconds: 2000), () {
        startTimer();
      });
    }
    notifyListeners();
  }

  void handleManualComplete(bool? value) {
    final newValue = value ?? false;
    onComplete(currentInitiative, true);
    currentInitiative.isComplete = newValue;
    notifyListeners();
  }

  void increaseTime(AppTime appTime) {
    final addedSeconds = (appTime.hour * 60 + appTime.minute) * 60;
    totalTimeSeconds += addedSeconds;
    notifyListeners();
  }

  // Private helpers
  void _playStopSound() {
    if (_timer?.isActive != true) {
      AudioManager().play(SoundEffect.success);
    }
  }
}
