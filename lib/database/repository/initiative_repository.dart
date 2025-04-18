
import '../../models/initiative.dart';
import '../services/initiative_service.dart';


class InitiativeRepository {
  final InitiativeService _service;

  InitiativeRepository(this._service);

  Future<List<Initiative>> getAllInitiatives() {
    return _service.fetchAll();
  }

  Future<void> addInitiative(Initiative ini) {
    return _service.save(ini);
  }

  Future<void> removeInitiative(String id) {
    return _service.delete(id);
  }

  Future<void> markComplete(Initiative ini, bool isComplete) {
    ini.isComplete = isComplete;
    return _service.update(ini);
  }
}
