import 'dart:ui';

Color hexToColor(String hexCode) {
  return Color(int.parse('FF${hexCode.substring(1, 7)}', radix: 16));
}

String generateReadableTimestamp() {
  final now = DateTime.now();
  return "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_${_twoDigits(now.hour)}:${_twoDigits(now.minute)}.${now.millisecond}_${now.microsecond}";
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');
