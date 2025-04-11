// lib/task_manager.dart

import 'models/data_types.dart';

class TaskManager {
  TaskManager._internal();
  static final TaskManager _instance = TaskManager._internal();
  static TaskManager get instance => _instance;



  // Flat list of all real initiatives
  final List<Initiative> _flatInitiatives = [];
  final Map<String,int> _flatInitiativesMap = {};



  // Flatten the list and create a map title and index key value pair
  void updateList(List<BaseInitiative> baseInitiativeList) {
    _flatInitiatives.clear();
    _flatInitiativesMap.clear();

    int index = 0;

    for (final baseInitiative in baseInitiativeList) {
      final initiatives = baseInitiative is InitiativeGroup
          ? baseInitiative.initiativeList
          : [baseInitiative as Initiative];

      for (final init in initiatives) {
        _flatInitiatives.add(init);
        _flatInitiativesMap[init.title] = index++;
      }
    }

    printList();
  }


  void printList() {
    print("------------------- TaskManager title index Map-----------------------------");
    _flatInitiativesMap.forEach((key, value) {
      print("${key.toString()}:${value.toString()}");
    });
    print("=================== TaskManager Initiatives List ============================");
    for(var i=0;i<_flatInitiatives.length;i++)
      {
        print("$i = ${_flatInitiatives[i].title.toString()}");
      }
  }

  Initiative? nextInitiative(String title)
  {

    if (!_flatInitiativesMap.containsKey(title)) {
      print('Error: Title "$title" not found in the map.');
      return null;
    }

    int? index = _flatInitiativesMap[title];

    if (index == null) {
      print('Error: Index is null for title "$title".');
      return null;
    }
    index+=1;

    if (index < 0 || index >= _flatInitiatives.length) {
      print('Error: Index $index is out of bounds for _flatInitiatives.');
      return null;
    }

    return _flatInitiatives[index];

  }




}




// /// The current real task, or null if none.
// Initiative? get current =>
//     _flatInitiatives.isEmpty ? null : _flatInitiatives[_currentIndex];
//
// /// Mark the current real task done.
// void markCurrentDone() {
//   current?.isComplete = true;
// }


//
// /// Peek the title of the next undone real task.
// String peekNextTitle() {
//   for (int i = _currentIndex + 1; i < _flatInitiatives.length; i++) {
//     if (!_flatInitiatives[i].isComplete) {
//       return _flatInitiatives[i].title;
//     }
//   }
//   return 'No more tasks';
// }
//
// /// Advance to the next undone real task.
// /// Returns that Initiative, or null if none left.
// Initiative? next() {
//   for (int i = _currentIndex + 1; i < _flatInitiatives.length; i++) {
//     if (!_flatInitiatives[i].isComplete) {
//       _currentIndex = i;
//       return _flatInitiatives[i];
//     }
//   }
//   return null;
// }
//
// /// Jump directly to a specific real-task index.
// void startFrom(int idx) {
//   if (idx >= 0 && idx < _flatInitiatives.length) {
//     _currentIndex = idx;
//   }
// }
//
// /// Reset all tasks to undone and pointer to start.
// void resetAll() {
//   for (final ini in _flatInitiatives) {
//     ini.isComplete = false;
//   }
//   _currentIndex = 0;
// }



// // lib/task_manager.dart
//
// import 'models/data_types.dart';
//
// class TaskManager {
//   // 1) Singleton boilerplate
//   TaskManager._internal();
//   static final TaskManager _instance = TaskManager._internal();
//   static TaskManager get instance => _instance;
//
//
//   // 2) Raw data and flattened list
//   final List<Initiative> listOfEveryInitiative = [];
//
//
//   // 3) Pointer to current task
//   int currentBaseTaskIndex = 0;
//
//   /// Initialize with your Undertaking list
//   void updateList(List<BaseInitiative> list) {
//     listOfEveryInitiative.clear();
//     for (BaseInitiative listItem in list){
//       if(listItem is InitiativeGroup){
//         for(Initiative init in listItem.initiativeList){
//           listOfEveryInitiative.add(init);
//         }
//
//       } else if(listItem is Initiative)
//         {
//           listOfEveryInitiative.add(listItem);
//         }
//
//     }
//     print("===========================My own script============================");
//
//     for(Initiative init in listOfEveryInitiative)
//       {
//         print(init.title);
//       }
//
//   }
//
//   /// Start the sequence from a specific index
//   void startFrom(int index) {
//     if (index >= 0 && index < listOfEveryInitiative.length) {
//       currentBaseTaskIndex = index;
//     } else {
//       currentBaseTaskIndex = 0;
//     }
//   }
//
//
//
//   /// Returns the current task, or null if index is out of range
//   BaseInitiative? get currentTask {
//     if (currentBaseTaskIndex < 0 ||
//         currentBaseTaskIndex >= listOfEveryInitiative.length) return null;
//     return listOfEveryInitiative[currentBaseTaskIndex];
//   }
//
//   /// Marks the current task done
//   void markCurrentDone() {
//     currentTask?.isComplete = true;
//   }
//
//
//
//   int taskCounter = 0;
//   bool expectingBreak = false;
//
//   // BaseTask? nextTask() {
//   //   if (expectingBreak) {
//   //     // We're due for a break
//   //     if (taskCounter == 3) {
//   //       taskCounter = 0; // Reset after long break
//   //       expectingBreak = false;
//   //       return longBreak();
//   //     } else {
//   //       expectingBreak = false;
//   //       return shortBreak();
//   //     }
//   //   } else {
//   //     // Time for actual task
//   //     final task = actualTask();
//   //     if (task != null) {
//   //       taskCounter++;
//   //       expectingBreak = true;
//   //     }
//   //     return task;
//   //   }
//   // }
//
//
//   /// Advances to the next *undone* task, returns it or null if none left
//   BaseInitiative? nextTask() {
//     while (currentBaseTaskIndex < listOfEveryInitiative.length - 1) {
//       currentBaseTaskIndex+=1;
//
//       if (!listOfEveryInitiative[currentBaseTaskIndex].isComplete) {
//         return listOfEveryInitiative[currentBaseTaskIndex];
//       }
//     }
//
//     return null; // No more tasks
//   }
//
//   // BaseTask shortBreak(){
//   //   return Initiative(dynamicTime: AppTime(7, 7),title: "Short Break",completionTime: AppTime(0, 10));
//   // }
//   // BaseTask mediumBreak(){
//   //   return Initiative(dynamicTime: AppTime(7, 7),title: "Medium Break",completionTime: AppTime(0, 20));
//   // }
//   // BaseTask longBreak(){
//   //   return Initiative(dynamicTime: AppTime(7, 7),title: "Long Break",completionTime: AppTime(0, 30));
//   // }
//
//   // helper: look ahead for next undone task
//   String peekNextTaskTitle() {
//     final tmi = TaskManager.instance;
//     for (int i = tmi.currentBaseTaskIndex + 1;
//     i < tmi.listOfEveryInitiative.length;
//     i++) {
//       if (!tmi.listOfEveryInitiative[i].isComplete) {
//         return tmi.listOfEveryInitiative[i].title;
//       }
//     }
//     return 'No more tasks';
//   }
//
//   /// Reset all tasks to undone and index to 0
//   void resetAll() {
//     for (final t in listOfEveryInitiative) t.isComplete = false;
//     currentBaseTaskIndex = 0;
//   }
// }
