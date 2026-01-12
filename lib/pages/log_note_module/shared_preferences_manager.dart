import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'note.dart';
import 'app_settings.dart';

class LogNotePrefsManager {
  static const String _kSettingsKey = 'app_settings_v1';
  static const String _kNotesKey = 'notes_v1';

  static Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettingsKey);
    if (raw != null) {
      try {
        return AppSettings.fromMap(json.decode(raw));
      } catch (e) {
        return _defaultSettings();
      }
    }
    return _defaultSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettingsKey, json.encode(settings.toMap()));
  }

  static Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kNotesKey);
    if (raw != null) {
      try {
        final List dec = json.decode(raw) as List;
        return dec
            .map((e) => Note.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final enc = json.encode(notes.map((n) => n.toMap()).toList());
    await prefs.setString(_kNotesKey, enc);
  }

  static AppSettings _defaultSettings() {
    return AppSettings(darkMode: false, fontSize: 16.0, autoSync: false);
  }
}
