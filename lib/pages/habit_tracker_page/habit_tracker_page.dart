import 'package:flutter/material.dart';

void main() => runApp(const HabitApp());

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Habit Tracker (Soft + Compact)',
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

class Habit {
  final String id;
  final String title;
  final Color color;
  final IconData icon;
  final Set<String> completedDates; // stored as 'yyyy-M-d' for simplicity

  Habit({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    Set<String>? completedDates,
  }) : completedDates = completedDates ?? <String>{};
}

String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
const _weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

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

    // softer / pastel colors (lighter shades)
    _habits.addAll([
      Habit(
        id: 'a',
        title: 'Morning Run',
        color: Colors.orange.shade300,
        icon: Icons.directions_run,
        completedDates: {_dateKey(_now), _dateKey(_now.subtract(const Duration(days: 1)))},
      ),
      Habit(
        id: 'b',
        title: 'Read 30m',
        color: Colors.blue.shade300,
        icon: Icons.menu_book,
        completedDates: {_dateKey(_now.subtract(const Duration(days: 2)))},
      ),
      Habit(id: 'c', title: 'Meditation', color: Colors.green.shade300, icon: Icons.self_improvement),
      Habit(id: 'd', title: 'Drink Water', color: Colors.teal.shade300, icon: Icons.water),
      Habit(id: 'e', title: 'Learn Coding', color: Colors.purple.shade300, icon: Icons.code),
    ]);
  }

  bool _doneOn(Habit h, DateTime d) => h.completedDates.contains(_dateKey(d));
  void _toggle(Habit h, DateTime d) {
    final k = _dateKey(d);
    setState(() {
      if (h.completedDates.contains(k)) h.completedDates.remove(k);
      else h.completedDates.add(k);
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime(_now.year, _now.month, _now.day);
    final doneToday = _habits.where((h) => _doneOn(h, today)).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // title: const Text('Habits'),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.notes, color: Colors.indigo),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Habit Tracker', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),

                  ],
                )
              ],
            ),
            // centerTitle: true, // removed
            floating: true,
            pinned: false,
            backgroundColor: Colors.grey[50],
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            // leading: IconButton(
            //   icon: const Icon(Icons.menu),
            //   onPressed: () {},
            // ),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_month_rounded, size: 20)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 24),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _buildTopCard(doneToday),
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

  Widget _buildTopCard(int doneToday) {
    final total = _habits.length;
    final percent = total == 0 ? 0.0 : doneToday / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 9,
                    valueColor: AlwaysStoppedAnimation(Colors.grey.shade100),
                  ),
                ),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: percent),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, v, child) {
                      final color = v < 0.4 ? Colors.orange.shade300 : (v < 0.9 ? Colors.blue.shade300 : Colors.green.shade300);
                      return CircularProgressIndicator(value: v, strokeWidth: 9, strokeCap: StrokeCap.round, valueColor: AlwaysStoppedAnimation(color));
                    },
                  ),
                ),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${(percent * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('$doneToday / $total', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  Text('${_now.day}/${_now.month}/${_now.year}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _roundedStat('Habits', '$total', Icons.list_alt, Colors.indigo.shade300)),
                  const SizedBox(width: 8),
                  Expanded(child: _roundedStat('Done', '$doneToday', Icons.check_circle, Colors.green.shade300)),
                  const SizedBox(width: 8),
                  Expanded(child: _roundedStat('Month', '${_monthDays.length}', Icons.calendar_month, Colors.teal.shade300)),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _roundedStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class HabitTile extends StatefulWidget {
  final Habit habit;
  final List<DateTime> monthDays;
  final DateTime now;
  final Function(Habit, DateTime) onToggle;

  const HabitTile({
    super.key,
    required this.habit,
    required this.monthDays,
    required this.now,
    required this.onToggle,
  });

  @override
  State<HabitTile> createState() => _HabitTileState();
}

class _HabitTileState extends State<HabitTile> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final dayIndex = widget.now.day - 1;
        final itemWidth = 42.0;
        final viewportWidth = _scrollController.position.viewportDimension;
        final offset = (dayIndex * itemWidth) - (viewportWidth / 2) + (itemWidth / 2);
        _scrollController.jumpTo(offset.clamp(0.0, _scrollController.position.maxScrollExtent));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _doneOn(DateTime d) => widget.habit.completedDates.contains(_dateKey(d));

  int _streak() {
    int s = 0;
    DateTime cursor = DateTime(widget.now.year, widget.now.month, widget.now.day);
    while (_doneOn(cursor)) {
      s++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return s;
  }

  double _weeklyProgress() {
    final last7 = List.generate(7, (i) => DateTime(widget.now.year, widget.now.month, widget.now.day).subtract(Duration(days: i)));
    final done = last7.where((d) => _doneOn(d)).length;
    return done / last7.length;
  }

  @override
  Widget build(BuildContext context) {
    final weekly = _weeklyProgress();
    final streak = _streak();
    final h = widget.habit;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 18, backgroundColor: h.color.withOpacity(0.18), child: Icon(h.icon, color: h.color, size: 16)),
          const SizedBox(width: 10),
          Expanded(child: Text(h.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          const SizedBox(width: 6),
          Column(children: [
            Text('${(weekly * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text('Streak: $streak', style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ]),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.monthDays.length,
            itemBuilder: (c, i) {
              final d = widget.monthDays[i];
              final done = _doneOn(d);
              final isToday = d.year == widget.now.year && d.month == widget.now.month && d.day == widget.now.day;

              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => widget.onToggle(h, d),
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: done ? h.color.withOpacity(0.34) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: done ? [BoxShadow(color: h.color.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))] : null,
                        border: isToday
                            ? Border.all(color: Colors.amber, width: 2)
                            : Border.all(color: done ? h.color.withOpacity(0.7) : Colors.grey.shade300),
                      ),
                      child: Center(child: done ? const Icon(Icons.check, color: Colors.white, size: 14) : Text('${d.day}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(width: 36, child: Text(_weekDays[d.weekday - 1], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black54))),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
