// Flutter core and UI libraries
import 'dart:ui';
import 'package:flutter/material.dart';

// Importing data model for food statistics
import '../../models/food_stats.dart';

/// Converts a HEX color code (e.g. "#FF5733") into a [Color] object.
///
/// This method assumes the HEX code is in the format "#RRGGBB"
/// and automatically adds a full opacity prefix ("FF").
Color hexToColor(String hexCode) {
  return Color(int.parse('FF${hexCode.substring(1, 7)}', radix: 16));
}

/// Converts a HEX color code into a [Color] object with adjustable opacity.
///
/// [hexCode] must be in "#RRGGBB" format.
/// [opacityPercent] specifies transparency from 0 (fully transparent)
/// to 100 (fully opaque). Defaults to 100.
///
/// Example: `hexToColorWithOpacity("#FF0000", 50)` → semi-transparent red.
Color hexToColorWithOpacity(String hexCode, [double opacityPercent = 100]) {
  assert(hexCode.length == 7 && hexCode.startsWith('#'));
  assert(opacityPercent >= 0 && opacityPercent <= 100);

  // Convert opacity percentage into a hex alpha value (00–FF)
  int alpha = ((opacityPercent / 100) * 255).round();
  final alphaHex = alpha.toRadixString(16).padLeft(2, '0').toUpperCase();

  // Combine alpha + RGB into a complete ARGB color code
  return Color(int.parse('$alphaHex${hexCode.substring(1)}', radix: 16));
}

/// Determines the progress color based on the user's calorie intake.
///
/// Uses traffic-light style colors:
/// - **Red** if calories > 2000
/// - **Orange** if calories between 1600 and 2000
/// - **GreenAccent** if calories ≤ 1600
///
/// Returns grey if [latestStats] is `null` (data not yet available).
Color getProgressColor(FoodStats? latestStats) {
  if (latestStats == null) {
    return Colors.grey; // Default color when no data is available
  }

  final kcal = latestStats.calories;

  if (kcal > 2000) {
    // return Colors.red[500]!;
    return Colors.redAccent;
  } else if (kcal > 1600) {
    return Colors.orange[500]!;
  } else {
    return Colors.green[400]!;
  }
}

/// Returns the current date formatted as "DD/MM/YYYY".
///
/// Pads day and month values to ensure two digits each.
String getCurrentDateFormatted() {
  final now = DateTime.now();
  final day = now.day.toString().padLeft(2, '0');
  final month = now.month.toString().padLeft(2, '0');
  final year = now.year.toString();

  return '$day/$month/$year';
}

/// Generates a detailed timestamp string for unique identifiers or logs.
///
/// Example output: `"2025-10-18_09:42.123_456"`
///
/// Format: `YYYY-MM-DD_HH:MM.millisecond_microsecond`
String generateReadableTimestamp() {
  final now = DateTime.now();
  return "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_"
      "${_twoDigits(now.hour)}:${_twoDigits(now.minute)}."
      "${now.millisecond}_${now.microsecond}";
}

/// Pads a number with a leading zero if it’s a single digit.
///
/// Example: `7 → "07"`
String _twoDigits(int n) => n.toString().padLeft(2, '0');
