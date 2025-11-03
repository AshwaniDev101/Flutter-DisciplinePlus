

part of '../home_page.dart';
/// Single dashboard summary card (self-contained sample data).
class _DashboardSummaryCard extends StatelessWidget {
  const _DashboardSummaryCard({super.key});

  // --- SAMPLE VALUES (replace with your live values) ---
  static const int caloriesConsumed = 520;
  static const int caloriesTarget = 1800;
  static const int tasksCompleted = 3;
  static const int tasksTotal = 6;
  static const int habitsDone = 2;
  static const int habitsTotal = 4;
  // -----------------------------------------------------

  double get _calorieProgress => caloriesTarget == 0 ? 0.0 : caloriesConsumed / caloriesTarget;
  double get _taskProgress => tasksTotal == 0 ? 0.0 : tasksCompleted / tasksTotal;
  double get _habitProgress => habitsTotal == 0 ? 0.0 : habitsDone / habitsTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = '${DateTime.now().day} ${_monthName(DateTime.now().month)} ${DateTime.now().year}';

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: title + date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(dateText, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Hook: open dashboard/details
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Main Row: Calories | Separator | Habits | Tasks
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Calories (big circular)
                _MetricCircle(
                  label: 'Calories',
                  primaryText: '$caloriesConsumed / $caloriesTarget',
                  percent: _calorieProgress.clamp(0.0, 1.0),
                  color: Colors.deepOrange,
                ),

                const SizedBox(width: 12),

                // Vertical divider
                Container(width: 1, height: 86, color: Colors.grey[200]),

                const SizedBox(width: 12),

                // Two small stacked metrics: Habits & Tasks
                Expanded(
                  child: Column(
                    children: [
                      _MiniMetricRow(
                        icon: Icons.check_circle,
                        title: 'Habits',
                        subtitle: '$habitsDone / $habitsTotal',
                        percent: _habitProgress.clamp(0.0, 1.0),
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _MiniMetricRow(
                        icon: Icons.task_alt,
                        title: 'Tasks',
                        subtitle: '$tasksCompleted / $tasksTotal',
                        percent: _taskProgress.clamp(0.0, 1.0),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Summary text + progress bars (calories shown more detail)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calories short summary
                Text(
                  _calorieSummaryText(),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),

                // Linear progress row for tasks + habits (compact)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tasks', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _taskProgress,
                              backgroundColor: Colors.grey[200],
                              minHeight: 8,
                              valueColor: AlwaysStoppedAnimation(Colors.blue),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Habits', style: theme.textTheme.bodySmall),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _habitProgress,
                              backgroundColor: Colors.grey[200],
                              minHeight: 8,
                              valueColor: AlwaysStoppedAnimation(Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // CTA row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Hook: open detailed screen
                        },
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('View Details'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Hook: quick action (e.g., mark today's tasks)
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Quick Done'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _calorieSummaryText() {
    final left = (caloriesTarget - caloriesConsumed).clamp(0, caloriesTarget);
    if (caloriesConsumed >= caloriesTarget) return 'Target reached — great job!';
    return '$left kcal left • ${( _calorieProgress * 100 ).toInt()}%';
  }

  String _monthName(int m) {
    const names = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return names[m];
  }
}

/// Large circular metric widget
class _MetricCircle extends StatelessWidget {
  final String label;
  final String primaryText;
  final double percent;
  final Color color;
  const _MetricCircle({
    required this.label,
    required this.primaryText,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Column(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation(Colors.grey[200]!),
                  ),
                ),
                SizedBox(
                  width: 86,
                  height: 86,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: percent),
                    duration: const Duration(milliseconds: 500),
                    builder: (_, value, __) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      valueColor: AlwaysStoppedAnimation(color),
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${(percent * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(primaryText, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// Compact metric row used for Tasks/Habits
class _MiniMetricRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double percent;
  final Color color;

  const _MiniMetricRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.14),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
