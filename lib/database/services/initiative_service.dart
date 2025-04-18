// initiative_service.dart

import '../../models/initiative.dart';

abstract class InitiativeService {
  Future<List<Initiative>> fetchAll();
  Future<void> save(Initiative initiative);
  Future<void> delete(String id);
  Future<void> update(Initiative initiative);
}