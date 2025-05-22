
import 'package:discipline_plus/resource/audio_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'core/utils/constants.dart';
import 'firebase_options.dart';
import 'pages/listpage/home_page.dart';

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
      home: HomePage(),
    );





  }
}

