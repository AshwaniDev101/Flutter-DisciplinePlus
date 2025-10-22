import 'package:discipline_plus/models/initiative.dart';

import '../services/firebase_global_initiative_list_service.dart';

class GlobalInitiativeListRepository {

  final FirebaseGlobalInitiativeListService _service = FirebaseGlobalInitiativeListService.instance;

  GlobalInitiativeListRepository._internal();

  static final GlobalInitiativeListRepository instance = GlobalInitiativeListRepository._internal();


  Stream<List<Initiative>> watchInitiatives() {
    return _service.watchInitiatives();
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
