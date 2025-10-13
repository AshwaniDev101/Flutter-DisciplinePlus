import 'package:discipline_plus/models/initiative.dart';

import '../services/firebase_global_Initiative_list.dart';

class GlobalInitiativeListRepository {
  final FirebaseGlobalInitiativeService _service;

  GlobalInitiativeListRepository(this._service);

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
