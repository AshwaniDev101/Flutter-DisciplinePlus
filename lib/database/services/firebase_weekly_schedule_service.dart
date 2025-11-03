
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discipline_plus/models/initiative.dart';

class FirebaseWeeklyScheduleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1';
  final String _initiative_list = 'initiative_list';

  // Singleton
  FirebaseWeeklyScheduleService._();
  static final instance = FirebaseWeeklyScheduleService._();


  CollectionReference get _initiativeCollection => _db.collection(_root).doc(_userId).collection('schedule');

  /// Stream all initiatives for [day] (e.g. "Sunday") ordered by index.
  Stream<Map<String, InitiativeCompletion>> watchWeekDay(String day) {
    return _initiativeCollection
        .doc(day)
        .collection(_initiative_list)
        // .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => {
      for (var doc in snapshot.docs)
        doc.id: InitiativeCompletion.fromMap(doc.id, doc.data())
    });
  }
  // Stream<Map<String, InitiativeCompletion>> watchWeekDay(String day) {
  //   return _initiativeCollection
  //       .doc(day)
  //       .collection(_initiative_list)
  //       .snapshots()
  //       .map((snapshot) {
  //     final result = <String, InitiativeCompletion>{};
  //
  //     for (var doc in snapshot.docs) {
  //       final data = doc.data();
  //       // ensure data is Map<String, dynamic>
  //       final mapData = Map<String, dynamic>.from(data);
  //       result[doc.id] = InitiativeCompletion.fromMap(doc.id, mapData);
  //     }
  //
  //     return result;
  //   });
  // }





  /// Add a new [initiative] under [day].
  Future<void> addInitiative(String day, InitiativeCompletion initiativeCompletion) {
    final ref = _initiativeCollection.doc(day)
        .collection(_initiative_list)
        .doc(initiativeCompletion.id);
    // final map = initiative.toMap()..remove('id');

    final map = initiativeCompletion.toMap()..remove('id');


    return ref.set(map);
  }


  /// Update an existing [initiative] under [day] by [id].
  Future<void> completeInitiative(String day, String initiativeID, bool isComplete) {
    final ref = _initiativeCollection.doc(day)
        .collection(_initiative_list)
        .doc(initiativeID);
    // final map = initiative.toMap()..remove('id');

    final map = {
      'isComplete':isComplete,
    };
    return ref.update(map);
  }


  /// Delete initiative by [initiativeID] under [day].
  Future<void> deleteInitiative(String day, String initiativeID) {

    // print("===== Delete is called $initiativeID");
    return _initiativeCollection.doc(day)
        .collection(_initiative_list)
        .doc(initiativeID)
        .delete();
  }




  /// Reorder the list by writing each initiative's index in a batch.
  Future<void> reorderDayList(String day, List<Initiative> list) async {
    final batch = _db.batch();
    final col = _initiativeCollection.doc(day)
        .collection(_initiative_list);
    for (var ini in list) {
      final docRef = col.doc(ini.id);
      batch.update(docRef, {'index': ini.index});
    }
    await batch.commit();
  }
}
