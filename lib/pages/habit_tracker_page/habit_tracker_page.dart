import 'package:flutter/material.dart';
import 'habit_model.dart';
import 'habit_tile.dart';
import 'habit_progress_card.dart';
import 'shared_preferences_manager.dart';

void main() => runApp(const HabitApp());

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey[50],
        visualDensity: VisualDensity.compact,
      ),
      home: const HabitHomePage(),
    );
  }
}

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage> {
  final DateTime _now = DateTime.now();
  late final List<DateTime> _monthDays;
  final List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    final daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    _monthDays = List.generate(daysInMonth, (i) => DateTime(_now.year, _now.month, i + 1));

    _habits.addAll([
      Habit(
        id: 'a',
        title: 'Morning Run',
        color: Colors.orange.shade300,
        icon: Icons.directions_run,
        completedDates: {dateKey(_now), dateKey(_now.subtract(const Duration(days: 1)))},
      ),
      Habit(
        id: 'b',
        title: 'Read 30m',
        color: Colors.blue.shade300,
        icon: Icons.menu_book,
        completedDates: {dateKey(_now.subtract(const Duration(days: 2)))},
      ),
      Habit(id: 'c', title: 'Meditation', color: Colors.green.shade300, icon: Icons.self_improvement),
      Habit(id: 'd', title: 'Drink Water', color: Colors.teal.shade300, icon: Icons.water),
      Habit(id: 'e', title: 'Learn Coding', color: Colors.purple.shade300, icon: Icons.code),
    ]);

    _initializeData();
  }

  Future<void> _initializeData() async {
    await SharedPreferencesManager.init();
    await SharedPreferencesManager.loadHabits(_habits);
    if (mounted) {
      setState(() {});
    }
  }

  bool _doneOn(Habit h, DateTime d) => h.completedDates.contains(dateKey(d));

  void _toggle(Habit h, DateTime d) {
    final k = dateKey(d);
    setState(() {
      if (h.completedDates.contains(k)) {
        h.completedDates.remove(k);
      } else {
        h.completedDates.add(k);
      }
    });
    SharedPreferencesManager.saveHabit(h);
  }

  Future<void> _migrateToDrift() async {
    // Stub function for future implementation of Drift database.
    print('Drift migration stub called. Implement full integration as needed.');
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final doneToday = _habits.where((h) => _doneOn(h, today)).length;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: HabitProgressCard(
                doneToday: doneToday,
                totalHabits: _habits.length,
                now: _now,
                daysInMonth: _monthDays.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => HabitTile(
                  habit: _habits[index],
                  monthDays: _monthDays,
                  now: _now,
                  onToggle: _toggle,
                ),
                childCount: _habits.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notes, color: Colors.indigo),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Habit Tracker',
                  style: TextStyle(
                      color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          )
        ],
      ),
      pinned: false,
      backgroundColor: Colors.grey[50],
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
            onPressed: () {}, icon: const Icon(Icons.calendar_month_rounded, size: 20)),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 24),
        ),
      ],
    );
  }
}
