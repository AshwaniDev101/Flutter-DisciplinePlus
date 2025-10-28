import 'package:flutter/material.dart';

import '../core/utils/helper.dart';

class AppColors {

  // Color Palette
  // static Color primary       = Color(0xFF016B61);
  // static Color secondary     = Color(0xFF70B2B2);
  // static Color third        = Color(0xFF9ECFD4);
  // static Color fourth        = Color(0xFFE5E9C5);

  static Color primary       = Color(0xFFFFA4A4);
  static Color secondary     = Color(0xFF70B2B2);
  static Color third        = Color(0xFF9ECFD4);
  static Color fourth        = Color(0xFFE5E9C5);



  // App bar
  static Color appbar       = primary;
  static Color appbarTitle  = Colors.white;
  static Color appbarIcon   = Colors.white;

  // Option Menu
  static Color optionMenuBackground = Colors.grey.shade50;
  static Color optionMenuContent    = Colors.blueGrey.shade600;




  static final List<Color> colorPalette = const [
    Color(0xFFF8BBD0),
    Color(0xFFBBDEFB),
    Color(0xFFC8E6C9),
    Color(0xFFE1BEE7),
    Color(0xFFB2DFDB),
    Color(0xFFFFECB3),
    Color(0xFFFFE0B2),
    Color(0xFFC5CAE9),
    Color(0xFFB2EBF2),
    Color(0xFFFFCDD2),
    Color(0xFFDCEDC8),
    Color(0xFFFFF9C4),
    Color(0xFFD1C4E9),
    Color(0xFFB3E5FC),
    Color(0xFFFFCCBC),
    Color(0xFFE6EE9C),
    Color(0xFFCFD8DC),
    Color(0xFFF3E5F5),
    Color(0xFFEF9A9A),
    Color(0xFFBCAAA4),
    Color(0xFFFFF3E0),
    Color(0xFFA1887F),
    Color(0xFF8D6E63),
    Color(0xFF6D4C41),
    Color(0xFFFFE082),
    Color(0xFFFFCC80),
    Color(0xFFD7CCC8),
    Color(0xFFFF5252),
    Color(0xFFFFA726),
    Color(0xFFFFEB3B),
    Color(0xFF26C6DA),
    Color(0xFF66BB6A),
    Color(0xFF7E57C2),
    Color(0xFF29B6F6),
    Color(0xFFEC407A),
    Color(0xFFAB47BC),
  ];


}

class AppStyle {
  // Option Menu
  static TextStyle optionMenuTextStyle = TextStyle(fontSize: 14, color: AppColors.optionMenuContent);
  static TextStyle appBarTextStyle = TextStyle(color: AppColors.appbarTitle);


}
