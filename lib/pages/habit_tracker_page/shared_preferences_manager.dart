import 'package:shared_preferences/shared_preferences.dart';
import 'habit_model.dart';

class SharedPreferencesManager {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> loadHabits(List<Habit> habits) async {
    for (final habit in habits) {
      final savedKey = 'habit_${habit.id}_completed';
      final saved = _prefs.getString(savedKey);
      if (saved != null && saved.isNotEmpty) {
        habit.completedDates.addAll(saved.split(','));
      }
    }
  }

  static Future<void> saveHabit(Habit habit) async {
    final savedKey = 'habit_${habit.id}_completed';
    await _prefs.setString(savedKey, habit.completedDates.join(','));
  }
}
