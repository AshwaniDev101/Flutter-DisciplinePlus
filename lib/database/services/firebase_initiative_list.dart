import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discipline_plus/models/initiative.dart';

class FirebaseInitiativeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1'; // you can make this dynamic

  // Singleton
  FirebaseInitiativeService._();
  static final instance = FirebaseInitiativeService._();

  CollectionReference get _initiativeCollection =>
      _db.collection(_root).doc(_userId).collection('initiative_list');

  Stream<List<Initiative>> streamInitiatives() {
    return _initiativeCollection.orderBy('index').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Initiative.fromMap(data);
      }).toList(),
    );
  }

  Future<void> addInitiative(Initiative initiative) {
    final ref = _initiativeCollection.doc(initiative.id);
    final map = initiative.toMap()..remove('id');
    return ref.set(map);
  }

  Future<void> updateInitiative(String id, Initiative initiative) {
    final ref = _initiativeCollection.doc(id);
    final map = initiative.toMap()..remove('id');
    return ref.update(map);
  }

  Future<void> deleteInitiative(String id) {
    return _initiativeCollection.doc(id).delete();
  }

  Future<void> reorderInitiatives(List<Initiative> list) async {
    final batch = _db.batch();
    for (var initiative in list) {
      final docRef = _initiativeCollection.doc(initiative.id);
      batch.update(docRef, {'index': initiative.index});
    }
    await batch.commit();
  }
}
