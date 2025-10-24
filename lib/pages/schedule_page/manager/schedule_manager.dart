import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import '../../../../database/repository/weekly_schedule_repository.dart';
import '../../../../models/initiative.dart';
import '../../global_initiative_list_page/manager/global_list_manager.dart';

/// Singleton class to manage weekly initiatives, active day,
/// and merging with global initiatives.
class ScheduleManager {

  ScheduleManager._internal() {
    // Keep the latest merged initiatives cached
    // mergedDayInitiatives.listen((list) => _latestMerged = list);
  }
  static final ScheduleManager instance = ScheduleManager._internal();

  final _repository = WeeklyScheduleRepository.instance;

  // ---------------- Day Management ----------------
  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  // Stores currently selected day reactively
  final BehaviorSubject<String> _daySubject =
  BehaviorSubject.seeded(DateFormat('EEEE').format(DateTime.now()));

  /// Stream of current active day (for reactive widgets)
  Stream<String> get day$ => _daySubject.stream;

  /// Current active day (synchronous)
  String get currentDay => _daySubject.value;

  /// Set active day if valid
  void changeDay(String day) {
    if (_daySubject.value != day && _days.contains(day)) {
      _daySubject.add(day);
    }
  }

  /// Move to next day of the week (wraps around)
  void toNextDay() {
    final index = _days.indexOf(_daySubject.value);
    _daySubject.add(_days[(index + 1) % _days.length]);
  }

  /// Move to previous day of the week (wraps around)
  void toPreviousDay() {
    final index = _days.indexOf(_daySubject.value);
    _daySubject.add(_days[(index - 1 + _days.length) % _days.length]);
  }

  // ---------------- Schedule Management ----------------
  /// Cache of initiatives for the currently selected day
  // Map<String, InitiativeCompletion> _cache = {};

  /// Stream of initiatives for the current day, updates automatically
  late final Stream<Map<String, InitiativeCompletion>> schedule$ =
  _daySubject.stream
      .distinct()
      .switchMap((day) => _repository.watchDay(day))
      .map((list) {
    // _cache = list; // Update cache
    return list;
  })
      .shareReplay(maxSize: 1);

  /// Add an initiative to a given weekday
  Future<void> addInitiativeIn(String weekDayName, String initiativeID) =>
      _repository.add(weekDayName, initiativeID);

  /// Delete an initiative from a given weekday
  Future<void> deleteInitiativeFrom(String weekDayName, String id) =>
      _repository.delete(weekDayName, id);

  /// Number of initiatives currently loaded in cache
  // int get length => _cache.length;

  // ---------------- Merged Initiatives ----------------
  /// Latest merged initiatives (daily + global)
  // List<Initiative> _latestMerged = [];

  /// Stream combining daily initiatives with global initiative list
  Stream<List<Initiative>> get mergedDayInitiatives {
    return Rx.combineLatest2<Map<String, InitiativeCompletion>, List<Initiative>, List<Initiative>>(
      schedule$,
      GlobalListManager.instance.watch(),
          (dailyMap, globalList) => globalList
          .where((i) => dailyMap.containsKey(i.id)) // Only include scheduled initiatives
          .map((i) => i.copyWith(isComplete: dailyMap[i.id]!.isComplete)) // Update completion status
          .toList(),
    );
  }

  /// Completion percentage of currently cached merged initiatives
  // double get latestCompletionPercentage {
  //   if (_latestMerged.isEmpty) return 0.0;
  //   final completed = _latestMerged.where((i) => i.isComplete).length;
  //   return (completed / _latestMerged.length) * 100;
  // }
}
