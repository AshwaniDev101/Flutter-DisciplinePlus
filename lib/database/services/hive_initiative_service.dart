
import 'package:hive/hive.dart';
import '../../models/initiative.dart';
import 'initiative_service.dart';

class HiveInitiativeService implements InitiativeService {
  static const String _boxName = 'initiatives';

  Future<Box> get _box async => await Hive.openBox(_boxName);

  @override
  Future<List<Initiative>> fetchAll() async {
    final box = await _box;
    return box.values.map((value) {
      // Each value is stored as a Map<String, dynamic>
      final map = Map<String, dynamic>.from(value as Map);
      return Initiative.fromMap(map);
    }).toList();
  }

  @override
  Future<void> save(Initiative initiative) async {
    final box = await _box;
    // Store the Initiative as a Map
    await box.put(initiative.id, initiative.toMap());
  }

  @override
  Future<void> delete(String id) async {
    final box = await _box;
    await box.delete(id);
  }

  @override
  Future<void> update(Initiative initiative) async {
    final box = await _box;
    // Overwrite the existing entry
    await box.put(initiative.id, initiative.toMap());
  }
}
