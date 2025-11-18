
import 'package:discipline_plus/database/repository/global_initiative_list_repository.dart';


import '../../../../../models/initiative.dart';

class GlobalListManager{
  GlobalListManager._internal();
  static final GlobalListManager instance = GlobalListManager._internal();

  final GlobalInitiativeListRepository _repo = GlobalInitiativeListRepository.instance;

  // Directly watch initiatives from repository
  Stream<List<Initiative>> watch() => _repo.watchInitiatives();

  // Add a new initiative
  Future<void> addInitiative(Initiative initiative) async {
    await _repo.add(initiative);
  }

  // Delete an initiative by ID
  Future<void> deleteInitiative(String id) async {
    await _repo.delete(id);
  }

  // Update an existing initiative
  Future<void> updateInitiative(Initiative updated) async {
    await _repo.update(updated.id, updated);
  }
}
