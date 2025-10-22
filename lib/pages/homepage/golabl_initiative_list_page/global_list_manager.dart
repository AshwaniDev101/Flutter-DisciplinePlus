
import 'package:discipline_plus/database/repository/global_initiative_list_repository.dart';
import 'package:discipline_plus/database/services/firebase_global_initiative_list_service.dart';
import 'package:rxdart/rxdart.dart';
import '../../../models/initiative.dart';


// This handle a single list in a single page
class GlobalListManager {
  GlobalListManager._internal();
  static final GlobalListManager _instance = GlobalListManager._internal();
  static GlobalListManager get instance => _instance;
  final GlobalInitiativeListRepository _initiativeListRepository = GlobalInitiativeListRepository(FirebaseGlobalInitiativeListService.instance);
  List<Initiative> _latestInitiatives = [];
  final BehaviorSubject<List<Initiative>> _initiativesSubject = BehaviorSubject<List<Initiative>>.seeded(<Initiative>[]);


  Stream<List<Initiative>> watch() => _initiativesSubject.stream;

  void bindToInitiatives() {
    _initiativeListRepository.watchInitiatives().listen((list) {
      _initiativesSubject.add(list);
      _latestInitiatives = list;
    });
  }

  Future<void> addInitiative(Initiative initiative) async {
    await _initiativeListRepository.add(initiative);
  }

  Future<void> deleteInitiative(String id) async {
    await _initiativeListRepository.delete(id);

  }

  Future<void> updateInitiative(Initiative updated) async {
    await _initiativeListRepository.update(updated.id, updated);
  }

  // Initiative? getNextInitiative(int currentIndex) {
  //   final nextIndex = currentIndex + 1;
  //   if (nextIndex >= 0 && nextIndex < _latestInitiatives.length) {
  //     return _latestInitiatives[nextIndex];
  //   }
  //   return null;
  // }
  //
  // int getNextIndex() {
  //   int listSize = _latestInitiatives.length;
  //   if (listSize == 0) {
  //     return 0;
  //   } else {
  //     return listSize;
  //   }
  // }
  //
  // int getLength() {
  //   return _latestInitiatives.length;
  // }







}