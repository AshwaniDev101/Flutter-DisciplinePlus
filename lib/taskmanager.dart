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

  final List<Initiative> _initiativesListTaskManager = [];


// ====================== Repository management functions ==================================
  Future<void> reloadRepository() async {
    var list = await repo.getAllInitiatives();
    _initiativesListTaskManager.clear();
    _initiativesListTaskManager.addAll(list);
  }

  Future<void> addInitiative(Initiative initiative) async {
    _initiativesListTaskManager.add(initiative);
    await repo.addInitiative(initiative);
  }

  Future<void> removeInitiative(String id) async {
    await repo.removeInitiative(id);
    _initiativesListTaskManager.removeWhere((element) => element.id == id);
  }


  // void updateAllOrders() {
  //   // loop through the list, set each .index, and push an update to Firebase
  //   for (int i = 0; i < _initiativesListTaskManager.length; i++) {
  //     final ini = _initiativesListTaskManager[i];
  //     ini.index = i;
  //    repo.updateInitiative(ini);
  //   }
  // }

  Future<void> updateAllOrders() async {
    final batchUpdates = _initiativesListTaskManager.asMap().entries.map((e) {
      e.value.index = e.key;
      return repo.updateInitiative(e.value);
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