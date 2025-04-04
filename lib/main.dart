import 'package:discipline_plus/system_settings.dart';
import 'package:flutter/material.dart';


import 'expandable_list_screen.dart';
import 'timer_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'DisciplinePlus',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Constants.background_color),
          useMaterial3: true,
        ),
        home: ExpandableListScreen()
      // home: TimerPage()
    );
  }
}

