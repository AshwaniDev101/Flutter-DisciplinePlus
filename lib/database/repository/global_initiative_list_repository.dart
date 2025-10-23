import 'package:discipline_plus/models/initiative.dart';
import '../services/firebase_global_initiative_list_service.dart';

/// A repository for managing the global list of initiatives.
/// This class provides a singleton instance to interact with the Firebase service.
class GlobalInitiativeListRepository {
  final _service = FirebaseGlobalInitiativeListService.instance;

  GlobalInitiativeListRepository._internal();

  static final instance = GlobalInitiativeListRepository._internal();

  /// Watches for changes in the list of initiatives.
  /// Returns a stream of [Initiative] lists.
  Stream<List<Initiative>> watchInitiatives() {
    return _service.watchInitiatives();
  }

  /// Adds a new initiative to the list.
  Future<void> add(Initiative initiative) {
    return _service.addInitiative(initiative);
  }

  /// Reorders the list of initiatives.
  Future<void> reorder(List<Initiative> initiatives) {
    return _service.reorderInitiatives(initiatives);
  }

  /// Updates an existing initiative.
  Future<void> update(String id, Initiative initiative) {
    return _service.updateInitiative(id, initiative);
  }

  /// Deletes an initiative from the list.
  Future<void> delete(String id) {
    return _service.deleteInitiative(id);
  }
}
