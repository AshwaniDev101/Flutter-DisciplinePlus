import 'package:flutter/material.dart';
import 'app_settings.dart';
import 'notes_home_screen.dart';
import 'shared_preferences_manager.dart';

void main() => runApp(LogNoteModule());

class LogNoteModule extends StatefulWidget {
  const LogNoteModule({super.key});

  @override
  _LogNoteModuleState createState() => _LogNoteModuleState();
}

class _LogNoteModuleState extends State<LogNoteModule> {
  late ValueNotifier<AppSettings> _settingsNotifier;

  @override
  void initState() {
    super.initState();
    _settingsNotifier = ValueNotifier(
      AppSettings(darkMode: false, fontSize: 16.0, autoSync: false),
    );
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await LogNotePrefsManager.getSettings();
    if (mounted) {
      _settingsNotifier.value = settings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppSettings>(
      valueListenable: _settingsNotifier,
      builder: (context, settings, child) {
        final baseTextTheme = Typography.englishLike2018.apply(
          fontSizeFactor: settings.fontSize / 16.0,
        );

        final lightTheme = ThemeData(
          primarySwatch: Colors.indigo,
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.grey[100],
          textTheme: baseTextTheme,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        );

        final darkTheme = ThemeData(
          primarySwatch: Colors.indigo,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.grey[900],
          textTheme: baseTextTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardTheme: CardTheme(
            color: Colors.grey[800],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Notes — Home',
          themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: lightTheme,
          darkTheme: darkTheme,
          home: NotesHomeScreen(
            settingsNotifier: _settingsNotifier,
          ),
        );
      },
    );
  }
}
