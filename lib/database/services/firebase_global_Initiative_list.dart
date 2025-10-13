import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:discipline_plus/models/initiative.dart';

class FirebaseGlobalInitiativeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _root = 'users';
  final String _userId = 'user1'; // user 1 can be dynamic

  // Singleton
  FirebaseGlobalInitiativeService._();
  static final instance = FirebaseGlobalInitiativeService._();

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

  // Future<void> updateInitiative(String id, Initiative initiative) async {
  //   final ref = _initiativeCollection.doc(id);
  //   final updateData = initiative.toMap()..remove('id');
  //
  //   try {
  //     await ref.update(updateData);
  //   } on FirebaseException catch (e) {
  //     if (e.code == 'not-found') {
  //       // Log or handle specific case gracefully
  //       debugPrint('Update failed: Document with ID $id not found.');
  //     } else {
  //       debugPrint('Firestore error (${e.code}): ${e.message}');
  //       rethrow; // Optional: let it bubble up
  //     }
  //   } catch (e, stackTrace) {
  //     debugPrint('Unexpected error during initiative update: $e');
  //     debugPrint('$stackTrace');
  //     // Optional: send to logging service like Sentry or Firebase Crashlytics
  //   }
  // }

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
