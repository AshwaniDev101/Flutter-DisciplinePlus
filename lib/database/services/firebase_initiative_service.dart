// firebase_initiative_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/data_types.dart';
import 'initiative_service.dart';

class FirebaseInitiativeService implements InitiativeService {
  final CollectionReference _col =
  FirebaseFirestore.instance.collection('initiatives');

  BaseInitiative _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // you’ll need some discriminator to know if it’s a group or single
    if (data['type'] == 'group') {
      final children = (data['children'] as List)
          .map((e) => Initiative.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      return InitiativeGroup(
        id: doc.id,
        title: data['title'],
        initiativeList: children,
        isComplete: data['isComplete'] ?? false,
      );
    } else {
      return Initiative(
        id: doc.id,
        title: data['title'],
        completionTime:
        AppTime(data['completionHour'], data['completionMinute']),
        dynamicTime:
        AppTime(data['dynamicHour'], data['dynamicMinute']),
        isComplete: data['isComplete'] ?? false,
      );
    }
  }

  Map<String, dynamic> _toMap(BaseInitiative ini) {
    final base = {
      'title': ini.title,
      'isComplete': ini.isComplete,
      'completionHour': ini.completionTime.hour,
      'completionMinute': ini.completionTime.minute,
      'dynamicHour': ini.dynamicTime.hour,
      'dynamicMinute': ini.dynamicTime.minute,
    };
    if (ini is InitiativeGroup) {
      return {
        ...base,
        'type': 'group',
        'children': ini.initiativeList
            .map((e) => _toMap(e)..['type'] = 'single')
            .toList(),
      };
    } else {
      return {
        ...base,
        'type': 'single',
      };
    }
  }

  @override
  Future<List<BaseInitiative>> fetchAll() async {
    final snap = await _col.get();
    return snap.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> save(BaseInitiative initiative) {
    return _col.doc(initiative.id).set(_toMap(initiative));
  }

  @override
  Future<void> delete(String id) {
    return _col.doc(id).delete();
  }

  @override
  Future<void> update(BaseInitiative initiative) {
    return _col.doc(initiative.id).update(_toMap(initiative));
  }
}
