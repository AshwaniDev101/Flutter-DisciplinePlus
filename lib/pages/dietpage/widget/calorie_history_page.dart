import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../database/repository/calories_repository.dart';
import '../../../database/services/firebase_calories_service.dart';
// import '../repositories/calories_repository.dart';
// import '../services/firebase_calories_service.dart';

class CalorieHistoryPage extends StatefulWidget {
  const CalorieHistoryPage({super.key});

  @override
  _CalorieHistoryPageState createState() => _CalorieHistoryPageState();
}

class _CalorieHistoryPageState extends State<CalorieHistoryPage> {
  int selectedYear = DateTime.now().year;
  final List<int> availableYears = [
    DateTime.now().year - 2,
    DateTime.now().year - 1,
    DateTime.now().year,
  ];

  /// Dummy in‐memory map: month → (day → calories)
  Map<int, Map<int, int>> yearData = {};

  @override
  void initState() {
    super.initState();
    _loadYearData(selectedYear);
  }

  Future<void> pushDummyYearDataBatch({
    required String userId,
    required int year,
  }) async {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();
    final root = db.collection('users').doc(userId).collection('history');

    for (var month = 1; month <= 12; month++) {
      // build the month doc ref
      final y = year.toString();
      final m = month.toString();
      final docRef = root.doc(y).collection(m).doc('calories_list');

      // prepare one map for the whole month
      final Map<String, int> monthData = {
        for (var day = 1; day <= 28; day++)
          day.toString().padLeft(2, '0'): (month * 100) + day,
      };

      // batch set (merge: true in case some days already exist)
      batch.set(docRef, monthData, SetOptions(merge: true));
    }

    // commit all 12 writes in one go
    await batch.commit();
  }
  Future<void> pushSingleDayCalories({
    required String userId,
    required int year,
    required int month,
    required int day,
    required int calories,
  }) async {
    final db = FirebaseFirestore.instance;
    final y = year.toString();
    final m = month.toString();
    final d = day.toString();

    final docRef = db
        .collection('users')
        .doc(userId)
        .collection('history')
        .doc(y)
        .collection(m)
        .doc('calories_list');

    // Merge so existing days aren’t overwritten
    await docRef.set({ d: calories }, SetOptions(merge: true));
  }










  void _loadYearData(int year) async {
    // ——— Dummy data for now ———
    // final Map<int, Map<int, int>> dummy = {};
    // for (var m = 1; m <= 12; m++) {
    //   final monthMap = <int, int>{};
    //   for (var d = 1; d <= 28; d++) {
    //     // just fill 28 days for simplicity
    //     monthMap[d] = (m * 100) + d; // e.g. Jan 1 → 101, Feb 2 → 202
    //   }
    //   dummy[m] = monthMap;
    // }

    // setState(() {
    //   yearData = dummy;
    // });

    // ——— When ready, uncomment and use your repo: ———
    //
    final repo = CaloriesRepository(FirebaseCaloriesService.instance);
    final fetched = await repo.fetchYear(year);
    setState(() {
      yearData = fetched;

      debugPrintYearData(2026,yearData);
    });
  }

  // ================================ Debug functions =================================




  void debugPrintYearData(int year, Map<int, Map<int, int>> data) {
    if (data.isEmpty) {
      print('⚠️ No calorie data for year $year.');
      return;
    }

    print('📅 Calorie Data for Year $year\n');

    data.forEach((month, daysMap) {
      if (daysMap.isEmpty) return;

      print('📂 Month $month:');

      daysMap.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key))
        ..forEach((entry) {
          final day = entry.key;
          final cal = entry.value;
          print('   → $day/$month/$year: $cal kcal');
        });

      print('');
    });
  }



  // ================================ Debug functions =================================














  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie History'),
        actions: [
          DropdownButton<int>(
            value: selectedYear,
            items: availableYears
                .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                .toList(),
            onChanged: (y) {
              if (y == null) return;
              setState(() => selectedYear = y);
              _loadYearData(y);
            },
            underline: SizedBox(),
            icon: Icon(Icons.calendar_today, color: Colors.white),
          ),
          SizedBox(width: 16),
          ElevatedButton(onPressed: (){pushSingleDayCalories(userId: 'user1',year: 2025,month: 6,day: 23,calories: 1000);}, child: Text("Push"))
        ],
      ),

      body:ListView(
    children: yearData.entries.expand((monthEntry) {
      final month = monthEntry.key;
      final daysMap = monthEntry.value;

      return daysMap.entries.map((dayEntry) {
        final day = dayEntry.key;
        final calories = dayEntry.value;

        return ListTile(
          title: Text('$day/$month/$selectedYear: $calories kcal'),
        );
      }).toList();
    }).toList(),
    ),


    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month - 1];
  }
}

