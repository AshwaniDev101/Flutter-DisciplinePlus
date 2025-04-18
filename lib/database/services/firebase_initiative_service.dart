// firebase_initiative_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/initiative.dart';
import 'initiative_service.dart';

class FireInitiativeService implements InitiativeService {
  final CollectionReference _col =
  FirebaseFirestore.instance.collection('initiatives');

  Initiative _fromDoc(DocumentSnapshot doc) {
    // Get the raw map and inject the Firestore doc ID as the Initiative.id
    final data = Map<String, dynamic>.from(doc.data() as Map);
    data['id'] = doc.id;
    return Initiative.fromMap(data);
  }

  Map<String, dynamic> _toMap(Initiative ini) {
    // Use your model's toMap, but strip out 'id' since we rely on doc.id
    final map = Map<String, dynamic>.from(ini.toMap());
    map.remove('id');
    return map;
  }

/*  @override
  Future<List<Initiative>> fetchAll() async {
    final snap = await _col.get();
    return snap.docs.map(_fromDoc).toList();
  }*/

  @override
  Future<List<Initiative>> fetchAll() async {
    final snap = await _col.orderBy('index').get();  // <-- sorted by index!
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> save(Initiative initiative) {
    return _col.doc(initiative.id).set(_toMap(initiative));
  }

  @override
  Future<void> delete(String id) {
    return _col.doc(id).delete();
  }

  @override
  Future<void> update(Initiative initiative) {
    return _col.doc(initiative.id).update(_toMap(initiative));
  }
}
