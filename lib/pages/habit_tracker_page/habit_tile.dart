import 'package:flutter/material.dart';
import 'habit_model.dart';

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
        const itemWidth = 42.0;
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

  bool _doneOn(DateTime d) => widget.habit.completedDates.contains(dateKey(d));

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
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 6))
        ],
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
                        boxShadow: done
                            ? [BoxShadow(color: h.color.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))]
                            : null,
                        border: isToday
                            ? Border.all(color: Colors.amber, width: 2)
                            : Border.all(color: done ? h.color.withOpacity(0.7) : Colors.grey.shade300),
                      ),
                      child: Center(child: done ? const Icon(Icons.check, color: Colors.white, size: 14) : Text('${d.day}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(width: 36, child: Text(weekDays[d.weekday - 1], textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black54))),
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
