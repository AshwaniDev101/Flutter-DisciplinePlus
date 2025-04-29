// firebase_week_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discipline_plus/models/initiative.dart';

class FirebaseWeekService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'WeekList';

  // Singleton
  FirebaseWeekService._();
  static final instance = FirebaseWeekService._();

  /// Stream all initiatives for [day] (e.g. "Sunday") ordered by index.
  Stream<List<Initiative>> streamForDay(String day) {
    return _db
        .collection(_root)
        .doc(day)
        .collection('InitiativeList')
        .orderBy('index')
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Initiative.fromMap(data);
    })
        .toList());
  }

  /// Add a new [initiative] under [day].
  Future<void> addInitiative(String day, Initiative initiative) {
    final ref = _db
        .collection(_root)
        .doc(day)
        .collection('InitiativeList')
        .doc(initiative.id);
    final map = initiative.toMap()..remove('id');
    return ref.set(map);
  }

  /// Update an existing [initiative] under [day].
  Future<void> updateInitiative(String day, Initiative initiative) {
    final ref = _db
        .collection(_root)
        .doc(day)
        .collection('InitiativeList')
        .doc(initiative.id);
    final map = initiative.toMap()..remove('id');
    return ref.update(map);
  }

  /// Delete initiative by [id] under [day].
  Future<void> deleteInitiative(String day, String id) {
    return _db
        .collection(_root)
        .doc(day)
        .collection('InitiativeList')
        .doc(id)
        .delete();
  }

  /// Reorder the list by writing each initiative's index in a batch.
  Future<void> reorderDayList(String day, List<Initiative> list) async {
    final batch = _db.batch();
    final col = _db
        .collection(_root)
        .doc(day)
        .collection('InitiativeList');
    for (var ini in list) {
      final docRef = col.doc(ini.id);
      batch.update(docRef, {'index': ini.index});
    }
    await batch.commit();
  }
}
