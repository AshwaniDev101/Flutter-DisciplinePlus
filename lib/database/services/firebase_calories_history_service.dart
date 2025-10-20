
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../models/food_stats.dart';

/// A dedicated Firebase service responsible for managing the user's
/// calorie history data.
///
/// This class provides a structured interface to access, update,
/// and remove calorie-related data stored in Firestore. The data
/// is stored in the following hierarchy:
///
/// users/{userId}/history/{year}/{month}/{day}/foodStats
///
/// The service follows a singleton pattern to ensure only one instance
/// interacts with Firestore throughout the app lifecycle, improving
/// consistency and performance.
class FirebaseCaloriesHistoryService {
  /// Private constructor — enforces the singleton pattern
  FirebaseCaloriesHistoryService._();

  /// Global singleton instance
  static final instance = FirebaseCaloriesHistoryService._();

  /// Firestore instance used for all database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Root-level Firestore collection for user data
  final String _root = 'users';

  /// Static user ID placeholder — replace with dynamically fetched user ID later
  final String _userId = 'user1';


  /// Retrieves all stored [FoodStats] documents for a specific [year] and [month].
  ///
  /// Each document within the month represents a single day, identified
  /// by its numeric day value (1–31). The resulting map uses the day as
  /// the key and the corresponding [FoodStats] object as the value.
  ///
  /// This method also sorts the result in reverse order (latest day first),
  /// making it convenient for displaying recent data in a UI such as a
  /// calendar or history timeline.
  Future<Map<int, FoodStats>> getFoodStatsForMonth({
    required int year,
    required int month,
  }) async {
    final monthRef = _firestore
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(year.toString())
        .collection(month.toString());

    final snapshot = await monthRef.get();
    final Map<int, FoodStats> statsMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final day = int.tryParse(doc.id);

      if (day != null && data['foodStats'] != null) {
        try {
          statsMap[day] = FoodStats.fromMap(data['foodStats']);
        } catch (e) {
          debugPrint('Invalid foodStats data for day $day: $e');
        }
      }
    }

    // Sort entries in descending order (most recent first)
    final reversedMap = Map.fromEntries(
      statsMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );

    return reversedMap;
  }

  /// Retrieves the complete set of [FoodStats] for an entire [year].
  ///
  /// This method loads all 12 months asynchronously, processing each month
  /// in parallel to reduce total load time. It returns a nested map:
  ///
  /// `{ monthNumber: { dayNumber: FoodStats } }`
  ///
  /// Only months that contain at least one valid entry are included in the
  /// final map. This design helps to minimize unnecessary data overhead.
  Future<Map<int, Map<int, FoodStats>>> getFoodStatsForYear({
    required int year,
  }) async {
    final yearRef = _firestore
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(year.toString());

    final Map<int, Map<int, FoodStats>> yearlyStats = {};

    // Run all monthly fetches in parallel for faster total execution
    final monthFutures = List.generate(12, (index) async {
      final month = index + 1;
      final monthRef = yearRef.collection(month.toString());
      final snapshot = await monthRef.get();

      final Map<int, FoodStats> monthMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final day = int.tryParse(doc.id);

        if (day != null && data['foodStats'] != null) {
          try {
            monthMap[day] = FoodStats.fromMap(data['foodStats']);
          } catch (_) {}
        }
      }

      // Only store non-empty months to reduce memory footprint
      if (monthMap.isNotEmpty) yearlyStats[month] = monthMap;
    });

    await Future.wait(monthFutures);
    return yearlyStats;
  }

  /// Updates or creates the [FoodStats] record for a specific day.
  ///
  /// If the document for that date does not exist, it will be created.
  /// The method uses Firestore's `SetOptions(merge: true)` to preserve
  /// existing data and prevent accidental overwrites of unrelated fields.
  ///
  /// This makes the method safe to call repeatedly when incrementally
  /// updating food or calorie entries throughout the day.
  Future<void> updateFoodStats({
    required DateTime cardDateTime,
    required FoodStats foodStats,
  }) async {

    var ref = _firestore
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(cardDateTime.year.toString())
        .collection(cardDateTime.month.toString())
        .doc(cardDateTime.day.toString());



    await ref.set(
      {'foodStats': foodStats.toMap()},
      SetOptions(merge: true),
    );
  }

  /// Permanently deletes the [FoodStats] document for the specified day.
  ///
  /// This method is useful when the user removes a day's entry entirely,
  /// such as deleting a mistakenly added food record. It ensures complete
  /// removal of that day’s document without affecting other data in the
  /// month or year collections.
  Future<void> deleteFoodStats({
    required DateTime cardDateTime,
  }) async {

    var ref = _firestore
        .collection(_root)
        .doc(_userId)
        .collection('history')
        .doc(cardDateTime.year.toString())
        .collection(cardDateTime.month.toString())
        .doc(cardDateTime.day.toString());

    print("============ Deleting ${ref.path.toString()}");
    await ref.delete();
  }
}










// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/cupertino.dart';
// import '../../models/food_stats.dart';
//
// /// A Firebase service for fetching user's calorie history.
// ///
// /// This service is designed for structured Firestore data:
// /// users/{userId}/history/{year}/{month}/{day}/foodStats
// class FirebaseCaloriesHistoryService {
//   // Singleton instance
//   FirebaseCaloriesHistoryService._();
//   static final instance = FirebaseCaloriesHistoryService._();
//
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   final String _root = 'users';
//   final String _userId = 'user1'; // TODO: Replace with dynamic user ID later.
//
//   /// Fetches [FoodStats] for all days in a specific [year] and [month].
//   ///
//   /// Returns a map where the key is the day of the month and the value is [FoodStats].
//
//
//   Future<Map<int, FoodStats>> getFoodStatsForMonth({
//     required int year,
//     required int month,
//   }) async {
//     final monthRef = _firestore
//         .collection(_root)
//         .doc(_userId)
//         .collection('history')
//         .doc(year.toString())
//         .collection(month.toString());
//
//     final snapshot = await monthRef.get();
//
//     final Map<int, FoodStats> statsMap = {};
//
//     for (final doc in snapshot.docs) {
//       final data = doc.data();
//       final day = int.tryParse(doc.id);
//
//       if (day != null && data['foodStats'] != null) {
//         try {
//           statsMap[day] = FoodStats.fromMap(data['foodStats']);
//         } catch (e) {
//
//           debugPrint('Invalid foodStats data for day $day: $e');
//         }
//       }
//     }
//
//     final reversedMap = Map.fromEntries(
//       statsMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
//     );
//
//     return reversedMap;
//   }
//
//   /// Fetches all [FoodStats] for a given [year].
//   ///
//   /// Returns a nested map: `{ month: { day: FoodStats } }`.
//   /// Only includes months that contain at least one valid entry.
//   Future<Map<int, Map<int, FoodStats>>> getFoodStatsForYear({
//     required int year,
//   }) async {
//     final yearRef = _firestore
//         .collection(_root)
//         .doc(_userId)
//         .collection('history')
//         .doc(year.toString());
//
//     final Map<int, Map<int, FoodStats>> yearlyStats = {};
//
//     // Run month fetches in parallel for efficiency
//     final monthFutures = List.generate(12, (index) async {
//       final month = index + 1;
//       final monthRef = yearRef.collection(month.toString());
//       final snapshot = await monthRef.get();
//
//       final Map<int, FoodStats> monthMap = {};
//
//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final day = int.tryParse(doc.id);
//
//         if (day != null && data['foodStats'] != null) {
//           try {
//             monthMap[day] = FoodStats.fromMap(data['foodStats']);
//           } catch (_) {}
//         }
//       }
//
//       if (monthMap.isNotEmpty) yearlyStats[month] = monthMap;
//     });
//
//     await Future.wait(monthFutures);
//     return yearlyStats;
//   }
// }
