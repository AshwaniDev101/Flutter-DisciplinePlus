import 'package:flutter/material.dart';

class HabitProgressCard extends StatelessWidget {
  final int doneToday;
  final int totalHabits;
  final DateTime now;
  final int daysInMonth;

  const HabitProgressCard({
    super.key,
    required this.doneToday,
    required this.totalHabits,
    required this.now,
    required this.daysInMonth,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalHabits == 0 ? 0.0 : doneToday / totalHabits;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          _buildProgressCircle(percent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildStatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(double percent) {
    return SizedBox(
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
                final color = v < 0.4
                    ? Colors.orange.shade300
                    : (v < 0.9 ? Colors.blue.shade300 : Colors.green.shade300);
                return CircularProgressIndicator(
                  value: v,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.round,
                  valueColor: AlwaysStoppedAnimation(color),
                );
              },
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${(percent * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('$doneToday / $totalHabits',
                style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ]),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Today',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        Text('${now.day}/${now.month}/${now.year}',
            style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: _roundedStat(
                'Habits', '$totalHabits', Icons.list_alt, Colors.indigo.shade300)),
        const SizedBox(width: 8),
        Expanded(
            child: _roundedStat(
                'Done', '$doneToday', Icons.check_circle, Colors.green.shade300)),
        const SizedBox(width: 8),
        Expanded(
            child: _roundedStat(
                'Month', '$daysInMonth', Icons.calendar_month, Colors.teal.shade300)),
      ],
    );
  }

  Widget _roundedStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.black54),
            overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}
