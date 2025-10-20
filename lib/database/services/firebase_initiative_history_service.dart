import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseInitiativeHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton pattern
  FirebaseInitiativeHistoryService._();
  static final instance = FirebaseInitiativeHistoryService._();

  final String userId = 'user1'; // TODO: make dynamic later

  /// Watch initiative completion history for a specific date
  Stream<Map<String, bool>> watchInitiativeCompletionHistory(DateTime date) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}')
        .collection('initiative_completion_list')
        .snapshots()
        .map((snapshot) {
      final Map<String, bool> completionMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final bool isComplete = data['isComplete'] ?? false;
        completionMap[doc.id] = isComplete;
      }

      return completionMap;
    });
  }

  /// Set initiative completion state
  Future<void> setInitiativeCompletion(
      DateTime date, String initiativeId, bool isComplete) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc('${date.year}')
        .collection('${date.month}')
        .doc('${date.day}')
        .collection('initiative_completion_list')
        .doc(initiativeId);

    await ref.set({
      'isComplete': isComplete,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
