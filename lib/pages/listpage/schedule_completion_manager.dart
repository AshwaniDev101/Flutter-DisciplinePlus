import 'package:discipline_plus/database/services/firebase_global_initiative_list_service.dart';
import 'package:discipline_plus/database/services/firebase_initiative_completion_service.dart';
import 'package:discipline_plus/models/initiative.dart';
import 'package:rxdart/rxdart.dart';

import '../../database/repository/global_initiative_list_repository.dart';
import '../../database/repository/initiative_completion_repository.dart';

class ScheduleCompletionManager {
  ScheduleCompletionManager._internal();

  static final ScheduleCompletionManager _instance = ScheduleCompletionManager._internal();
  static ScheduleCompletionManager get instance => _instance;


  final InitiativeCompletionRepository _initiativeCompletionRepository = InitiativeCompletionRepository(FirebaseInitiativeCompletionService.instance);


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
