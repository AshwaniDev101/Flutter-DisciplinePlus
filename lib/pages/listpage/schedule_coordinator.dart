import 'package:discipline_plus/pages/listpage/schedule_handler/schedule_manager.dart';
import 'package:rxdart/rxdart.dart';
import '../../../models/initiative.dart';

import 'schedule_completion_manager.dart';

class ScheduleCoordinator {
  static final ScheduleCoordinator instance = ScheduleCoordinator._internal();
  ScheduleCoordinator._internal();

  final _scheduleManager = ScheduleManager.instance;
  final _completionManager = ScheduleCompletionManager.instance;

  /// Combined stream: daily initiatives + their completion state
  Stream<List<Initiative>> get mergedDayInitiatives {
    return Rx.combineLatest2<List<Initiative>, List<Initiative>, List<Initiative>>(
      _scheduleManager.schedule$,
      _completionManager.watchMergedInitiativeList(),
          (dailyList, globalCompletionList) {
        final completionMap = {
          for (final i in globalCompletionList) i.id: i.isComplete,
        };

        return dailyList.map((i) {
          final isComplete = completionMap[i.id] ?? false;
          return i.copyWith(isComplete: isComplete);
        }).toList();
      },
    );
  }

  double get completionRate => _scheduleManager.completionRate;
  void changeDay(String day) => _scheduleManager.changeDay(day);
}
