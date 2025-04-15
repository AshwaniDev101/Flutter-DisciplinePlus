// hive_initiative_service.dart

import 'package:hive/hive.dart';

import '../../models/data_types.dart';
import 'initiative_service.dart';

class HiveInitiativeService implements InitiativeService {
  static const String _boxName = 'initiatives';

  Future<Box> get _box async => await Hive.openBox(_boxName);

  @override
  Future<List<BaseInitiative>> fetchAll() async {
    final box = await _box;
    return box.values.cast<BaseInitiative>().toList();
  }

  @override
  Future<void> save(BaseInitiative initiative) async {
    final box = await _box;
    await box.put(initiative.id, initiative);
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<void> update(BaseInitiative initiative) async {
    final box = await _box;
    await box.put(initiative.id, initiative);
  }
}
