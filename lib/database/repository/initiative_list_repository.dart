import 'package:discipline_plus/models/initiative.dart';

import '../services/firebase_initiative_list.dart';

class InitiativeListRepository {
  final FirebaseInitiativeService _service;

  InitiativeListRepository({FirebaseInitiativeService? service})
      : _service = service ?? FirebaseInitiativeService.instance;

  Stream<List<Initiative>> watchAll() {
    return _service.streamInitiatives();
  }

  Future<void> add(Initiative initiative) {
    return _service.addInitiative(initiative);
  }

  Future<void> update(String id, Initiative initiative) {
    return _service.updateInitiative(id, initiative);
  }

  Future<void> delete(String id) {
    return _service.deleteInitiative(id);
  }

  Future<void> reorder(List<Initiative> initiatives) {
    return _service.reorderInitiatives(initiatives);
  }
}
