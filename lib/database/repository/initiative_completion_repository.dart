import 'package:discipline_plus/database/services/firebase_initiative_completion_service.dart';

/// Repository layer for initiative completion logic.
/// This class abstracts away all Firebase logic,
/// allowing your app to be tested and maintained more easily.
class InitiativeCompletionRepository {
  final FirebaseInitiativeCompletionService _service;

  InitiativeCompletionRepository(this._service);

  /// Watch completion history for a specific date
  Stream<Map<String, bool>> watchInitiativeCompletionHistory(DateTime date) {
    return _service.watchInitiativeCompletionHistory(date);
  }

  /// Set or update completion state for a specific initiative
  Future<void> setInitiativeCompletion(
    DateTime date,
    String initiativeId,
    bool isComplete,
  ) {
    return _service.setInitiativeCompletion(date, initiativeId, isComplete);
  }


}
