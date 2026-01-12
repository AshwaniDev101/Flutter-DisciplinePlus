import 'package:discipline_plus/drawer/drawer.dart';
import 'package:flutter/material.dart';
import 'habit_model.dart';
import 'habit_tile.dart';
import 'habit_progress_card.dart';
import 'shared_preferences_manager.dart';
import 'create_habit.dart';
import 'edit_habit.dart';

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
  List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    final daysInMonth = DateTime(_now.year, _now.month + 1, 0).day;
    _monthDays = List.generate(daysInMonth, (i) => DateTime(_now.year, _now.month, i + 1));
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    await SharedPreferencesManager.init();
    final habits = await SharedPreferencesManager.getHabits();
    if (mounted) {
      setState(() {
        _habits = habits;
      });
    }
  }

  bool _doneOn(Habit h, DateTime d) => h.completedDates.contains(dateKey(d));

  void _toggle(Habit h, DateTime d) async {
    final k = dateKey(d);
    setState(() {
      if (h.completedDates.contains(k)) {
        h.completedDates.remove(k);
      } else {
        h.completedDates.add(k);
      }
    });
    await SharedPreferencesManager.updateHabit(h);
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final doneToday = _habits.where((h) => _doneOn(h, today)).length;
    
    return Scaffold(
      drawer: const CustomDrawer(),
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
                (context, index) => GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditHabitPage(habit: _habits[index])));
                    _loadHabits();
                  },
                  child: HabitTile(
                    habit: _habits[index],
                    monthDays: _monthDays,
                    now: _now,
                    onToggle: _toggle,
                  ),
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
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Habit Tracker',
              style: TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      pinned: false,
      backgroundColor: Colors.grey[50],
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month_rounded, size: 20)),
        IconButton(
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateHabitPage()));
            _loadHabits();
          },
          icon: const Icon(Icons.add, size: 24),
        ),
      ],
    );
  }
}
