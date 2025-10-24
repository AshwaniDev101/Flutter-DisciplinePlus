
import 'package:discipline_plus/database/repository/global_initiative_list_repository.dart';

import '../../../../../models/initiative.dart';

class GlobalListManager {
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



//
// import 'package:discipline_plus/database/repository/global_initiative_list_repository.dart';
// import 'package:discipline_plus/database/services/firebase_global_initiative_list_service.dart';
// import 'package:rxdart/rxdart.dart';
// import '../../../models/initiative.dart';
//
//
// // This handle a single list in a single page
// class GlobalListManager {
//   GlobalListManager._internal();
//   static final GlobalListManager _instance = GlobalListManager._internal();
//   static GlobalListManager get instance => _instance;
//   final GlobalInitiativeListRepository _initiativeListRepository = GlobalInitiativeListRepository.instance;
//   List<Initiative> _latestInitiatives = [];
//
//   //It’s like a StreamController but it remembers the last emitted value.
//   //Since it holds the latest value, you can listen to it in multiple places at the same time
//   final BehaviorSubject<List<Initiative>> _initiativesSubject = BehaviorSubject<List<Initiative>>.seeded(<Initiative>[]);
//
//
//   Stream<List<Initiative>> watch() => _initiativesSubject.stream;
//
//   void bindToInitiatives() {
//     _initiativeListRepository.watchInitiatives().listen((list) {
//       _initiativesSubject.add(list);
//       _latestInitiatives = list;
//     });
//   }
//
//   Future<void> addInitiative(Initiative initiative) async {
//     await _initiativeListRepository.add(initiative);
//   }
//
//   Future<void> deleteInitiative(String id) async {
//     await _initiativeListRepository.delete(id);
//
//   }
//
//   Future<void> updateInitiative(Initiative updated) async {
//     await _initiativeListRepository.update(updated.id, updated);
//   }
//
//
//
//
//
//
//
// }