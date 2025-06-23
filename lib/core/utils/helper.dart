import 'dart:ui';

Color hexToColor(String hexCode) {
  return Color(int.parse('FF${hexCode.substring(1, 7)}', radix: 16));
}

Color hexToColorWithOpacity(String hexCode, [double opacityPercent=100]) {
  assert(hexCode.length == 7 && hexCode.startsWith('#'));
  assert(opacityPercent >= 0 && opacityPercent <= 100);

  int alpha = ((opacityPercent / 100) * 255).round();
  final alphaHex = alpha.toRadixString(16).padLeft(2, '0').toUpperCase();

  return Color(int.parse('$alphaHex${hexCode.substring(1)}', radix: 16));
}

String generateReadableTimestamp() {
  final now = DateTime.now();
  return "${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)}_${_twoDigits(now.hour)}:${_twoDigits(now.minute)}.${now.millisecond}_${now.microsecond}";
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');
