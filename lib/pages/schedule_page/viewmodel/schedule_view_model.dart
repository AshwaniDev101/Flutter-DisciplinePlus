import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import '../../../../database/repository/weekly_schedule_repository.dart';
import '../../../../models/initiative.dart';
import '../../../database/repository/heatmap_repository.dart';
import '../../global_initiative_list/global_initiative_list_page/manager/global_list_manager.dart';

/// Singleton class to manage weekly initiatives, active day,
/// and merging with global initiatives.
class ScheduleViewModel extends ChangeNotifier {

  ScheduleViewModel() {
    // Keep the latest merged initiatives cached
    // mergedDayInitiatives.listen((list) => _latestMerged = list);
    mergedDayInitiatives.listen((list) {
      _latestMerged = list;

      print("'================= List Merged ===================");
      print(_latestMerged);
    } );
  }
  // static final ScheduleViewModel instance = ScheduleViewModel._internal();

  final DateTime dateTimeNow = DateTime.now();

  final _repository = WeeklyScheduleRepository.instance;

  // ---------------- Day Management ----------------
  static const List<String> _weekDayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  // Stores currently selected day reactively
  final BehaviorSubject<String> _daySubject =
  BehaviorSubject.seeded(DateFormat('EEEE').format(DateTime.now()));

  /// Stream of current active day (for reactive widgets)
  Stream<String> get weekDayName$ => _daySubject.stream;

  /// Current active day (synchronous)
  /// ? used by two widget
  String get currentWeekDay => _daySubject.value;

  /// Set active day if valid
  void changeDay(String day) {
    if (_daySubject.value != day && _weekDayNames.contains(day)) {
      _daySubject.add(day);
    }
  }

  /// Move to next day of the week (wraps around)
  void toNextDay() {
    final index = _weekDayNames.indexOf(_daySubject.value);
    _daySubject.add(_weekDayNames[(index + 1) % _weekDayNames.length]);
  }

  /// Move to previous day of the week (wraps around)
  void toPreviousDay() {
    final index = _weekDayNames.indexOf(_daySubject.value);
    _daySubject.add(_weekDayNames[(index - 1 + _weekDayNames.length) % _weekDayNames.length]);
  }

  // ---------------- Schedule Management ----------------
  /// Cache of initiatives for the currently selected day
  // Map<String, InitiativeCompletion> _cache = {};

  /// Stream of initiatives for the current day, updates automatically
  late final Stream<Map<String, InitiativeCompletion>> schedule$ =
  _daySubject.stream
      .distinct()
      .switchMap((weekDayName) => _repository.watchWeekDay(weekDayName))
      .map((list) {
    // _cache = list; // Update cache
    return list;
  })
      .shareReplay(maxSize: 1);

  /// Add an initiative to a given weekday
  Future<void> addInitiativeIn(String weekDayName, InitiativeCompletion initiativeCompletion) =>
      _repository.add(weekDayName, initiativeCompletion);

  /// Delete an initiative from a given weekday
  Future<void> deleteInitiativeFrom(String weekDayName, String id) =>
      _repository.delete(weekDayName, id);

  /// Number of initiatives currently loaded in cache
  // int get length => _cache.length;

  // ---------------- Merged Initiatives ----------------
  /// Latest merged initiatives (daily + global)
  List<Initiative> _latestMerged = [];

  /// Stream combining daily initiatives with schedule initiative

  /// Merges the global initiatives with their daily completion states,
  /// and sorts them by the completion timestamp.
  Stream<List<Initiative>> get mergedDayInitiatives {
    return Rx.combineLatest2<
        Map<String, InitiativeCompletion>,
        List<Initiative>,
        List<Initiative>>(
      schedule$, // Stream of completion data for a given day
      GlobalListManager.instance.watch(), // Stream of all global initiatives
          (dailyMap, globalList) {
        // keep only initiatives that exist in the daily map (completed ones)
        final merged = globalList
            .where((i) => dailyMap.containsKey(i.id))
            .map((i) {
          final completion = dailyMap[i.id]!;
          // merge initiative data with its completion state
          return i.copyWith(
            isComplete: completion.isComplete,
            timestamp: completion.timestamp,
          );
        })
            .toList();

        // sort by completion timestamp (oldest → newest)
        merged.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return merged;
      },
    );
  }


  List<Initiative> get latestMergedList => _latestMerged;//? un-used for now



  // Initiative? getNextByCurrent(Initiative current) {
  //   final pos = _latestMerged.indexWhere((i) => i.id == current.id);
  //   if (pos == -1 || pos + 1 >= _latestMerged.length) return null;
  //   return _latestMerged[pos + 1];
  // }


  /// Completion percentage of currently cached merged initiatives
  double get latestCompletionPercentage {
    if (_latestMerged.isEmpty) return 0.0;
    final completed = _latestMerged.where((i) => i.isComplete).length;
    return (completed / _latestMerged.length) * 100;
  }



  void onComplete(Initiative initiative, bool isComplete)
  {
    WeeklyScheduleRepository.instance.completeInitiative(currentWeekDay, initiative.id, isComplete);

    var latest = latestCompletionPercentage;
    // Updating heatmap
    HeatmapRepository.instance.updateEntry(heatmapID: HeatmapID.overallInitiative, date: dateTimeNow, value: latest);


  }
}
