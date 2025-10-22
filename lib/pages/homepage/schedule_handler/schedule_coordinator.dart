
import 'package:discipline_plus/pages/homepage/schedule_handler/schedule_manager.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../models/initiative.dart';

import '../golabl_initiative_list_page/global_list_manager.dart';




class ScheduleCoordinator {
  static final ScheduleCoordinator instance = ScheduleCoordinator._internal();


  ScheduleCoordinator._internal() {
    // Subscribe once and keep latest merged initiatives cached
    mergedDayInitiatives.listen((list) {
      _latestMerged = list;
    });
  }

  final _scheduleManager = ScheduleManager.instance;


  List<Initiative> _latestMerged = [];


  // Cached latest merged initiatives
  // Subscribe once and keep latest merged initiatives cached




/// Combined stream: daily initiatives + their completion state
//   Stream<List<Initiative>> get mergedDayInitiatives {
//     return Rx.combineLatest2<List<Initiative>, List<Initiative>, List<Initiative>>(
//       ScheduleManager.instance.schedule$,
//         GlobalListManager.instance.watch(),
//           (dailyList, globalCompletionList) {
//         final completionMap = {
//           for (final i in globalCompletionList) i.id: i.isComplete,
//         };
//
//         return dailyList.map((i) {
//           final isComplete = completionMap[i.id] ?? false;
//           return i.copyWith(isComplete: isComplete);
//         }).toList();
//       },
//     );
//   }
  Stream<List<Initiative>> get mergedDayInitiatives {
    return Rx.combineLatest2<Map<String, InitiativeCompletion>, List<Initiative>, List<Initiative>>(
      ScheduleManager.instance.schedule$,
      GlobalListManager.instance.watch(),
          (dailyMap, globalInitiativeList) {
        print('Daily Keys: ${dailyMap.keys.toList()}');
        print('Global Initiative List: ${globalInitiativeList.map((e) => e.title).toList()}');

        // Convert dailyMap to a map of id -> isComplete
        final completionMap = {
          for (final entry in dailyMap.entries) entry.key: entry.value.isComplete,
        };

        // Merge global initiatives with completion info from dailyMap
        final merged = globalInitiativeList.map((i) {
          final isComplete = completionMap[i.id] ?? false;
          return i.copyWith(isComplete: isComplete);
        }).toList();

        print('Merged List: ${merged.map((e) => e.isComplete).toList()}');

        return merged;
      },
    );
  }

  // Stream<List<Initiative>> get mergedDayInitiatives {
  //   return Rx.combineLatest2<List<Initiative>, List<Initiative>, List<Initiative>>(
  //     ScheduleManager.instance.schedule$,
  //     GlobalListManager.instance.watch(),
  //         (dailyList, globalInitiativeList) {
  //       print('Daily List: ${dailyList.map((e) => e.title).toList()}');
  //       print('Global InitiativeList List: ${globalInitiativeList.map((e) => e.title).toList()}');
  //
  //       final completionMap = {
  //         for (final i in globalInitiativeList) i.id: i.isComplete,
  //       };
  //
  //       final merged = dailyList.map((i) {
  //         final isComplete = completionMap[i.id] ?? false;
  //         return i.copyWith(isComplete: isComplete);
  //       }).toList();
  //
  //       print('Merged List: ${merged.map((e) => e.title).toList()}');
  //
  //       return merged;
  //     },
  //   );
  // }


  /// Returns the latest cached completion percentage synchronously
  double get latestCompletionPercentage {
    if (_latestMerged.isEmpty) return 0.0;
    final completedCount = _latestMerged.where((i) => i.isComplete).length;
    final totalCount = _latestMerged.length;
    return (completedCount / totalCount) * 100;
  }

  void changeDay(String day) => _scheduleManager.changeDay(day);

  // Future<void> toggleCompletion(String initiativeId, bool value) async {
  //   await _initiativeCompletionRepository.setInitiativeCompletion(
  //     DateTime.now(),
  //     initiativeId,
  //     value,
  //   );
  // }
}
