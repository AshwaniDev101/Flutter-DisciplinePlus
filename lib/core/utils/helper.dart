


import 'dart:ui';

Color hexToColor(String hexCode) {
  return Color(int.parse('FF' + hexCode.substring(1, 7), radix: 16));
}