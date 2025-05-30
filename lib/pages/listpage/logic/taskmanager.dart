
import 'package:discipline_plus/pages/listpage/core/current_day_manager.dart';
import '../../../database/repository/week_repository.dart';
import '../../../database/services/firebase_week_service.dart';
import '../../../models/initiative.dart';

class TaskManager {
  TaskManager._internal();
  static final TaskManager _instance = TaskManager._internal();
  static TaskManager get instance => _instance;


  final WeekRepository _weekRepository = WeekRepository(FirebaseWeekService.instance);

  final List<Initiative> _initiativesListTaskManager = [];



  Stream<List<Initiative>> watchInitiatives(String day) {
    return _weekRepository.watchInitiatives(day);
  }


  Future<void> addInitiative(String day, Initiative initiative) async {
    _initiativesListTaskManager.add(initiative);
    await _weekRepository.addInitiative(day,initiative);
  }

  Future<void> removeInitiative(String day, String id) async {
    _initiativesListTaskManager.removeWhere((element) => element.id == id);
    await _weekRepository.removeInitiative(day, id);

  }



  Future<void> updateInitiative(String day, Initiative updated) async {

    // 2️⃣ Persist to Firestore
    await _weekRepository.updateInitiative(day, updated.id, updated);
  }


  Future<void> updateAllOrders() async {
    final batchUpdates = _initiativesListTaskManager.asMap().entries.map((e) {
      e.value.index = e.key;
      return _weekRepository.updateInitiative(CurrentDayManager.getCurrentDay(),e.value.id,e.value);
    }).toList();

    await Future.wait(batchUpdates);
  }

// ====================== Local management functions ==================================

  void insertInitiativeAt(int index, Initiative ini) {
    _initiativesListTaskManager.insert(index, ini);
  }

  Initiative removeInitiativeAt(int index) {
    final removed = _initiativesListTaskManager[index];
    _initiativesListTaskManager.removeAt(index);
    return removed;
  }

  Initiative getInitiativeAt(int index) {
    return _initiativesListTaskManager[index];
  }


  Initiative? getNextInitiative(int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= 0 && nextIndex < _initiativesListTaskManager.length) {
      return _initiativesListTaskManager[nextIndex];
    }
    return null;
  }

  int getNextIndex() {
    int listSize = _initiativesListTaskManager.length;
    if (listSize == 0) {
      return 0;
    } else {
      return listSize;
    }
  }

  int getLength() {
    return _initiativesListTaskManager.length;
  }







}