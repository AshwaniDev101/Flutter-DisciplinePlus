
import 'package:discipline_plus/pages/import_exporter/import_exporter_page.dart';
import 'package:discipline_plus/pages/schedule_page/viewModel/schedule_view_model.dart';
import 'package:discipline_plus/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'managers/audio_manager.dart';
import 'pages/schedule_page/schedule_page.dart';

import 'package:flutter/rendering.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Pre-set a base UI overlay before anything paints
  // SystemChrome.setSystemUIOverlayStyle(
  //   SystemUiOverlayStyle(
  //     statusBarColor: AppColors.appbar,
  //     statusBarIconBrightness: Brightness.light,
  //   ),
  // );

  await AudioManager().init();

  // debugRepaintRainbowEnabled = true;
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

        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // themeMode: ThemeMode.system,

        // home: ChangeNotifierProvider(
        //   create: (_) => ScheduleViewModel(),
        //   child: SchedulePage(),
        // )

        // home: SchedulePage(),
        // home: CaloriesCounterPage()
        // home: CalorieHistoryPage()
        // home: HomePage()
        // home: HabitTrackerDemo()
        home: ImportExporterPage()
        );
  }
}
