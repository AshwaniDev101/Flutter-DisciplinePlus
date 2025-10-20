import 'package:discipline_plus/database/services/firebase_global_initiative_list_service.dart';
import 'package:discipline_plus/database/services/firebase_initiative_history_service.dart';
import 'package:discipline_plus/models/initiative.dart';
import 'package:rxdart/rxdart.dart';

import '../../../database/repository/global_initiative_list_repository.dart';
import '../../../database/repository/initiative_history_repository.dart';


/// The [ScheduleCompletionManager] is responsible for tracking and updating
/// the completion state of initiatives in the app.
///
/// It acts as the bridge between the app’s business logic and the underlying
/// [FirebaseInitiativeHistoryService], providing a reactive interface
/// for reading and writing completion data.
///
/// Key responsibilities:
/// - Expose a stream of global initiatives merged with their completion state.
/// - Allow toggling or setting completion for a specific initiative.
/// - Provide a centralized, testable, and reusable way to interact with
///   initiative completion data.
///
/// Unlike [ScheduleManager], which organizes initiatives by day,
/// this manager focuses purely on whether an initiative is complete or not,
/// and can be used for any initiative regardless of the day.
///
/// Example usage:
/// ```dart
/// ScheduleCompletionManager.instance.watchMergedInitiativeList().listen((initiatives) {
///   // Each initiative now contains its current completion state.
/// });
///
/// // Mark an initiative as complete
/// ScheduleCompletionManager.instance.toggleCompletion('initiativeId', true);
/// ```
///
/// Think of this manager as the “source of truth” for initiative completion.


class ScheduleCompletionManager {
  ScheduleCompletionManager._internal();

  static final ScheduleCompletionManager _instance = ScheduleCompletionManager._internal();
  static ScheduleCompletionManager get instance => _instance;


  final InitiativeHistoryRepository _initiativeCompletionRepository = InitiativeHistoryRepository(FirebaseInitiativeHistoryService.instance);


  final GlobalInitiativeListRepository _globalInitiativeListRepository = GlobalInitiativeListRepository(FirebaseGlobalInitiativeListService.instance);


  /// Stream of all available initiatives (e.g., from a global list or repository)
  Stream<List<Initiative>> _watchGlobalInitiativeList() {
    return _globalInitiativeListRepository.watchInitiatives();
  }

  /// Stream of initiative completion states for today
  Stream<Map<String, bool>> _watchTodayCompletionMap() {
    return _initiativeCompletionRepository.watchInitiativeCompletionHistory(DateTime.now());
  }

  /// Merges available initiatives with completion data
  Stream<List<Initiative>> watchMergedInitiativeList() {
    return Rx.combineLatest2<List<Initiative>, Map<String, bool>, List<Initiative>>(
      _watchGlobalInitiativeList(),
      _watchTodayCompletionMap(),
          (globalInitiatives, completionMap) {
        return globalInitiatives.map((initiative) {
          final isComplete = completionMap[initiative.id] ?? false;
          return initiative.copyWith(isComplete: isComplete);
        }).toList();
      },
    );
  }

  Future<void> toggleCompletion(String initiativeId, bool value) async {
    await _initiativeCompletionRepository.setInitiativeCompletion(
      DateTime.now(),
      initiativeId,
      value,
    );
  }

}
