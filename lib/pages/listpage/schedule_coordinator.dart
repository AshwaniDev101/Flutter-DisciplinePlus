import 'package:discipline_plus/pages/listpage/schedule_handler/schedule_manager.dart';
import 'package:rxdart/rxdart.dart';
import '../../../models/initiative.dart';

import 'schedule_completion_manager.dart';



/// The [ScheduleCoordinator] acts as a high-level controller that synchronizes
/// daily schedules with their real-time completion status.
///
/// It bridges the [ScheduleManager] (which handles daily initiatives by weekday)
/// and the [ScheduleCompletionManager] (which tracks initiative completion in Firestore),
/// combining their data streams into one unified list.
///
/// This allows the UI to easily listen to a single stream of initiatives
/// where each item already reflects its up-to-date completion state.
///
/// In short, [ScheduleCoordinator] ensures that what the user sees for the day
/// always matches both the schedule and the actual completion data.
///
/// Responsibilities:
/// - Merge daily initiatives with global completion data.
/// - Expose a combined stream of ready-to-render initiatives.
/// - Provide access to day switching and completion statistics.
///
/// Example usage:
/// ```dart
/// ScheduleCoordinator.instance.mergedDayInitiatives.listen((initiatives) {
///   // Each initiative now contains its live completion state.
/// });
/// ```
///
/// Think of this as the “brain” that keeps your schedule and completion
/// systems in perfect sync.

class ScheduleCoordinator {
  static final ScheduleCoordinator instance = ScheduleCoordinator._internal();


  ScheduleCoordinator._internal() {
    // Subscribe once and keep latest merged initiatives cached
    mergedDayInitiatives.listen((list) {
      _latestMerged = list;
    });
  }

  final _scheduleManager = ScheduleManager.instance;
  final _completionManager = ScheduleCompletionManager.instance;

  List<Initiative> _latestMerged = [];


  // Cached latest merged initiatives
  // Subscribe once and keep latest merged initiatives cached




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


  /// Returns the latest cached completion percentage synchronously
  double get latestCompletionPercentage {
    if (_latestMerged.isEmpty) return 0.0;
    final completedCount = _latestMerged.where((i) => i.isComplete).length;
    final totalCount = _latestMerged.length;
    return (completedCount / totalCount) * 100;
  }

  void changeDay(String day) => _scheduleManager.changeDay(day);
}
