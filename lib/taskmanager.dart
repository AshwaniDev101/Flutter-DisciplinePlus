// lib/task_manager.dart

import 'package:flutter/cupertino.dart';
import 'database/repository/initiative_repository.dart';
import 'database/services/firebase_initiative_service.dart';
import 'models/initiative.dart';

class TaskManager {
  TaskManager._internal();
  static final TaskManager _instance = TaskManager._internal();
  static TaskManager get instance => _instance;


  InitiativeRepository repo = InitiativeRepository(FireInitiativeService());

  final List<Initiative> initiativesListTaskManager = [];

  Future<void> reloadRepository() async {

    var list = await repo.getAllInitiatives();
    initiativesListTaskManager.clear();
    initiativesListTaskManager.addAll(list);

    printList();
  }

  void addInitiative(Initiative initiative) {
    initiativesListTaskManager.add(initiative);
    repo.addInitiative(initiative);
    printList();
  }

  void removeInitiativeByID(String id) {
    initiativesListTaskManager.removeWhere((element) => element.id == id);
    printList();
  }

  void removeInitiativeByIndex(int index) {
    initiativesListTaskManager.removeAt(index);
    printList();
  }

  int getNextIndex() {
    int listSize = initiativesListTaskManager.length;
    if (listSize == 0) {
      return 0;
    } else {
      return listSize;
    }
  }


  void updateInitiative(String id, Initiative updated) {
    final index = initiativesListTaskManager.indexWhere((e) => e.id == id);
    if (index != -1) {
      initiativesListTaskManager[index] = updated;
      printList();
    } else {
      debugPrint("Initiative with ID $id not found.");
    }
  }

  Initiative? nextInitiative(int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= 0 && nextIndex < initiativesListTaskManager.length) {
      return initiativesListTaskManager[nextIndex];
    }
    return null;
  }

  void printList() {
    debugPrint("------------------- TaskManager title index Map -----------------------------");
    debugPrint("=================== TaskManager Initiatives List ============================");
    for (var i = 0; i < initiativesListTaskManager.length; i++) {
      debugPrint("$i. ID ${initiativesListTaskManager[i].id}, ${initiativesListTaskManager[i].title}");
    }
  }
}
