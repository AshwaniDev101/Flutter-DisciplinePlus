// initiative_service.dart

import '../../models/data_types.dart';

abstract class InitiativeService {
  Future<List<BaseInitiative>> fetchAll();
  Future<void> save(BaseInitiative initiative);
  Future<void> delete(String id);
  Future<void> update(BaseInitiative initiative);
}