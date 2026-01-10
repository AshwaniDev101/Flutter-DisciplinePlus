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
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: Colors.blueGrey[800],
          scaffoldBackgroundColor: Colors.grey[100],
          cardColor: Colors.white,
          textTheme: baseTextTheme.apply(bodyColor: Colors.grey[800], displayColor: Colors.black),
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.blueGrey[800],
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blueGrey[600],
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.lightBlueAccent),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardTheme: const CardThemeData(elevation: 0, shadowColor: Colors.transparent),
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: Colors.blueGrey[900],
          scaffoldBackgroundColor: const Color(0xFF121212),
          cardColor: Colors.grey[900],
          textTheme: baseTextTheme.apply(bodyColor: Colors.grey[300], displayColor: Colors.white),
          appBarTheme: AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.grey[900],
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.tealAccent[400],
            foregroundColor: Colors.black,
          ),
          colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark, primarySwatch: Colors.blueGrey).copyWith(secondary: Colors.tealAccent[400]),
          visualDensity: VisualDensity.adaptivePlatformDensity,
          cardTheme: CardThemeData(
            elevation: 0,
            shadowColor: Colors.transparent,
            color: Colors.grey[850],
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
