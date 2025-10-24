
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'firebase_options.dart';
import 'managers/audio_manager.dart';
import 'pages/homepage/schedule_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ========================= Database =======================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // initialize Hive for Flutter
  await Hive.initFlutter();
  await Hive.openBox('initiatives');

  // Choose which service to use:
  // final useLocal = false; // toggle this for Hive vs. Firebase
  // final service = useLocal
  //     ? HiveInitiativeService()
  //     : FirebaseInitiativeService();

  // final repo = InitiativeRepository(service);

  await AudioManager().init();
  runApp(const MyApp());


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widgets is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'DisciplinePlus',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(
      //   // colorScheme: ColorScheme.fromSeed(seedColor: Constants.background_color),
      //   useMaterial3: true,
      //   popupMenuTheme: PopupMenuThemeData(
      //     color: Colors.grey[50], // menu background
      //     textStyle: TextStyle(color: Colors.grey[400]), // menu text
      //   ),
      // ),
      home: SchedulePage(),
      // home: CaloriesCounterPage()
      // home: CalorieHistoryPage()
    );





  }
}

