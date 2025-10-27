import 'package:flutter/material.dart';

class AppColors {
  // App bar
  static Color appbar       = Colors.pink.shade300;
  static Color appbarTitle  = Colors.white;
  static Color appbarIcon   = Colors.white;

  // Option Menu
  static Color optionMenuBackground = Colors.grey.shade50;
  static Color optionMenuContent    = Colors.blueGrey.shade600;

  // Schedule
  static Color scheduleTitle  = Colors.blue;
  static Color scheduleTime   = Colors.grey;
  static Color scheduleBrake  = Colors.red;
}

class AppStyle {
  // Option Menu
  static TextStyle optionMenuTextStyle = TextStyle(fontSize: 14, color: AppColors.optionMenuContent);

  // Schedule
  static TextStyle scheduleTitle = TextStyle(fontSize: 14, color: AppColors. scheduleTitle );
  static TextStyle scheduleTime  = TextStyle(fontSize: 14, color: AppColors. scheduleTime  );
  static TextStyle scheduleBrake = TextStyle(fontSize: 14, color: AppColors. scheduleBrake );
}
