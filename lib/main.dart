import 'package:discipline_plus/constants.dart';
import 'package:discipline_plus/resource_managers/audio_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


import 'list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AudioManager().init();
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
        home: ListPage()
      // home: TimerPage()
    );
  }
}

