// firebase_schedule_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discipline_plus/models/initiative.dart';

class FirebaseScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1'; // user 1 can be dynamic

  // Singleton
  FirebaseScheduleService._();
  static final instance = FirebaseScheduleService._();


  CollectionReference get _initiativeCollection =>
      _db.collection(_root).doc(_userId).collection('schedule');

  /// Stream all initiatives for [day] (e.g. "Sunday") ordered by index.
  Stream<List<Initiative>> streamForDay(String day) {

    return _initiativeCollection.doc(day).collection('initiative_list').orderBy('index').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Initiative.fromMap(data);
      }).toList(),
    );

  }

  /// Add a new [initiative] under [day].
  Future<void> addInitiative(String day, Initiative initiative) {
    final ref = _db
        .collection(_root)
        .doc(day)
        .collection('InitiativeList')
        .doc(initiative.id);
    final map = initiative.toMap()..remove('id');

    print(ref.toString());
    return ref.set(map);
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


  /// Update an existing [initiative] under [day] by [id].
  Future<void> updateInitiative(String day, String id, Initiative initiative) {
    final ref = _db
        .collection(_root)
        .doc(day)
        .collection('InitiativeList')
        .doc(id);
    final map = initiative.toMap()..remove('id');

    return ref.update(map);
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
