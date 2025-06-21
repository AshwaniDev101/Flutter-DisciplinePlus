
import 'package:discipline_plus/database/repository/initiative_list_repository.dart';
import 'package:discipline_plus/database/services/firebase_initiative_list.dart';
import 'package:rxdart/rxdart.dart';
import '../../../models/initiative.dart';

class InitiativeListManager {
  InitiativeListManager._internal();
  static final InitiativeListManager _instance = InitiativeListManager._internal();
  static InitiativeListManager get instance => _instance;
  final InitiativeListRepository _initiativeListRepository = InitiativeListRepository(FirebaseInitiativeService.instance);
  List<Initiative> _latestInitiatives = [];
  final BehaviorSubject<List<Initiative>> _initiativesSubject = BehaviorSubject<List<Initiative>>.seeded(<Initiative>[]);


  Stream<List<Initiative>> watch() => _initiativesSubject.stream;

  void bindToInitiatives() {
    _initiativeListRepository.watchAll().listen((list) {
      _initiativesSubject.add(list);
      _latestInitiatives = list;
    });
  }

  Future<void> addInitiative(Initiative initiative) async {
    await _initiativeListRepository.add(initiative);
  }

  Future<void> removeInitiative(String id) async {
    await _initiativeListRepository.delete(id);

  }

  Future<void> updateInitiative(Initiative updated) async {
    await _initiativeListRepository.update(updated.id, updated);
  }

  Initiative? getNextInitiative(int currentIndex) {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= 0 && nextIndex < _latestInitiatives.length) {
      return _latestInitiatives[nextIndex];
    }
    return null;
  }

  int getNextIndex() {
    int listSize = _latestInitiatives.length;
    if (listSize == 0) {
      return 0;
    } else {
      return listSize;
    }
  }

  int getLength() {
    return _latestInitiatives.length;
  }





  // Future<void> updateAllOrders() async {
  //   final batchUpdates = _initiativesListTaskManager.asMap().entries.map((e) {
  //     e.value.index = e.key;
  //     return _weekRepository.updateInitiative(CurrentDayManager.getCurrentDay(),e.value.id,e.value);
  //   }).toList();
  //
  //   await Future.wait(batchUpdates);
  // }

// ====================== Local management functions ==================================

  // void insertInitiativeAt(int index, Initiative ini) {
  //   _initiativesListTaskManager.insert(index, ini);
  // }
  //
  // Initiative removeInitiativeAt(int index) {
  //   final removed = _initiativesListTaskManager[index];
  //   _initiativesListTaskManager.removeAt(index);
  //   return removed;
  // }
  //
  // Initiative getInitiativeAt(int index) {
  //   return _initiativesListTaskManager[index];
  // }
  //
  //
  // Initiative? getNextInitiative(int currentIndex) {
  //   final nextIndex = currentIndex + 1;
  //   if (nextIndex >= 0 && nextIndex < _initiativesListTaskManager.length) {
  //     return _initiativesListTaskManager[nextIndex];
  //   }
  //   return null;
  // }
  //








}