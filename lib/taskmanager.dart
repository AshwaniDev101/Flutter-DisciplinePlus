// lib/task_manager.dart

import 'models/data_types.dart';

class TaskManager {
  // 1) Singleton boilerplate
  TaskManager._internal();
  static final TaskManager _instance = TaskManager._internal();
  static TaskManager get instance => _instance;


  // 2) Raw data and flattened list
  final List<BaseTask> baseTaskList = [];

  // 3) Pointer to current task
  int currentBaseTaskIndex = 0;

  /// Initialize with your Undertaking list
  void init(List<Undertaking> undertakings) {
    _undertakingList
      ..clear()
      ..addAll(undertakings);
    _rebuildBaseTaskList();
    currentBaseTaskIndex = 0;
  }

  /// Start the sequence from a specific index
  void startFrom(int index) {
    if (index >= 0 && index < baseTaskList.length) {
      currentBaseTaskIndex = index;
    } else {
      currentBaseTaskIndex = 0;
    }
  }

  /// Flatten Undertakings → BaseTasks
  void _rebuildBaseTaskList() {
    baseTaskList
      ..clear()
      ..addAll(
        _undertakingList.expand<BaseTask>((ut) {
          if (ut.basetask.isEmpty) return [ut];
          return ut.basetask;
        }),
      );
  }

  /// Returns the current task, or null if index is out of range
  BaseTask? get currentTask {
    if (currentBaseTaskIndex < 0 ||
        currentBaseTaskIndex >= baseTaskList.length) return null;
    return baseTaskList[currentBaseTaskIndex];
  }

  /// Marks the current task done
  void markCurrentDone() {
    currentTask?.isComplete = true;
  }



  int taskCounter = 0;
  bool expectingBreak = false;

  // BaseTask? nextTask() {
  //   if (expectingBreak) {
  //     // We're due for a break
  //     if (taskCounter == 3) {
  //       taskCounter = 0; // Reset after long break
  //       expectingBreak = false;
  //       return longBreak();
  //     } else {
  //       expectingBreak = false;
  //       return shortBreak();
  //     }
  //   } else {
  //     // Time for actual task
  //     final task = actualTask();
  //     if (task != null) {
  //       taskCounter++;
  //       expectingBreak = true;
  //     }
  //     return task;
  //   }
  // }


  /// Advances to the next *undone* task, returns it or null if none left
  BaseTask? nextTask() {
    while (currentBaseTaskIndex < baseTaskList.length - 1) {
      currentBaseTaskIndex+=1;

      if (!baseTaskList[currentBaseTaskIndex].isComplete) {
        return baseTaskList[currentBaseTaskIndex];
      }
    }

    return null; // No more tasks
  }

  // BaseTask shortBreak(){
  //   return Initiative(dynamicTime: AppTime(7, 7),title: "Short Break",completionTime: AppTime(0, 10));
  // }
  // BaseTask mediumBreak(){
  //   return Initiative(dynamicTime: AppTime(7, 7),title: "Medium Break",completionTime: AppTime(0, 20));
  // }
  // BaseTask longBreak(){
  //   return Initiative(dynamicTime: AppTime(7, 7),title: "Long Break",completionTime: AppTime(0, 30));
  // }

  // helper: look ahead for next undone task
  String peekNextTaskTitle() {
    final tmi = TaskManager.instance;
    for (int i = tmi.currentBaseTaskIndex + 1;
    i < tmi.baseTaskList.length;
    i++) {
      if (!tmi.baseTaskList[i].isComplete) {
        return tmi.baseTaskList[i].title;
      }
    }
    return 'No more tasks';
  }

  /// Reset all tasks to undone and index to 0
  void resetAll() {
    for (final t in baseTaskList) t.isComplete = false;
    currentBaseTaskIndex = 0;
  }
}
