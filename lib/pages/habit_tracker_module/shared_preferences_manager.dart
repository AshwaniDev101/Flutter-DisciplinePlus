import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit_model.dart';

class SharedPreferencesManager {
  static late SharedPreferences _prefs;
  static const String _habitsKey = 'habits';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<List<Habit>> getHabits() async {
    final habitsString = _prefs.getString(_habitsKey);
    if (habitsString == null) {
      return [];
    }
    final List<dynamic> habitList = jsonDecode(habitsString);
    return habitList.map((json) => Habit.fromJson(json)).toList();
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    final habitList = habits.map((habit) => habit.toJson()).toList();
    await _prefs.setString(_habitsKey, jsonEncode(habitList));
  }

  static Future<void> addHabit(Habit habit) async {
    final habits = await getHabits();
    habits.add(habit);
    await saveHabits(habits);
  }

  static Future<void> updateHabit(Habit habit) async {
    final habits = await getHabits();
    final index = habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      habits[index] = habit;
      await saveHabits(habits);
    }
  }
}
