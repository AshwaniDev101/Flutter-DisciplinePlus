
import 'package:discipline_plus/pages/homepage/schedule_handler/manager/schedule_manager.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../models/initiative.dart';
import '../global_initiative_list_page/global_initiative_list/manager/global_list_manager.dart';




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



/// Combined stream: daily initiatives + their completion state
  Stream<List<Initiative>> get mergedDayInitiatives {
    return Rx.combineLatest2<Map<String, InitiativeCompletion>, List<Initiative>, List<Initiative>>(
      ScheduleManager.instance.schedule$,
      GlobalListManager.instance.watch(),
          (dailyMap, globalInitiativeList) {
        print('Daily Keys: ${dailyMap.keys.toList()}');
        print('Global Initiative List: ${globalInitiativeList.map((e) => e.title).toList()}');

        // Merge only initiatives that exist in dailyMap
        final merged = globalInitiativeList
            .where((i) => dailyMap.containsKey(i.id)) // keep only if id exists in dailyMap
            .map((i) {
          final isComplete = dailyMap[i.id]!.isComplete; // safe now
          return i.copyWith(isComplete: isComplete);
        })
            .toList();

        print('Merged List: ${merged.map((e) => e.isComplete).toList()}');

        return merged;
      },
    );
  }


  /// Returns the latest cached completion percentage synchronously
  double get latestCompletionPercentage {
    if (_latestMerged.isEmpty) return 0.0;
    final completedCount = _latestMerged.where((i) => i.isComplete).length;
    final totalCount = _latestMerged.length;
    return (completedCount / totalCount) * 100;
  }

  void changeDay(String day) => _scheduleManager.changeDay(day);


}
