import 'dart:async';

import 'package:discipline_plus/models/data_types.dart';
import 'package:discipline_plus/taskmanager.dart';
import 'package:discipline_plus/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with RouteAware {
  // Data source for the schedule
  final List<BaseTask> _items_list = [
    Undertaking(
      title: 'DSA',
      completionTime: const AppTime(3, 0), // Last initiative ends at 10:30
      isComplete: false,
      basetask: [
        Initiative(
            title: 'Self-Attempt',
            completionTime: AppTime(0, 1),
            isComplete: false),
        ShortBreak(),
        Initiative(
            title: 'Implementation',
            completionTime: AppTime(0, 2),
            isComplete: false),
        ShortBreak(),
        Initiative(
          title: 'Real-Solution',
          completionTime: AppTime(0, 1),
        ),
        ShortBreak(),

        Initiative(
            title: 'Deployment',
            completionTime: AppTime(0, 3),
            isComplete: false),
      ],
    ),
    LongBreak(),
    Undertaking(
      title: 'JavaScript',
      completionTime: const AppTime(2, 0), // Last initiative ends at 12:00
      basetask: [
        Initiative(
          title: 'Video-1',
          completionTime: AppTime(0, 1),
        ),
        Initiative(
          title: 'Video-2',
          completionTime: AppTime(0, 30),
        ),
        Initiative(
          title: 'Video-1',
          completionTime: AppTime(0, 30),
        ),
        Initiative(
          title: 'Video-2',
          completionTime: AppTime(0, 30),
        ),
      ],
    ),
    Initiative(
        title: 'GYM',
        completionTime: AppTime(0, 30),

        isComplete: false),
    Initiative(
        title: 'Meditation',
        completionTime: AppTime(0, 15),

        isComplete: false),
    Initiative(
      title: 'English',
      completionTime: AppTime(0, 20),

    ),
    Initiative(
      title: 'Drawing',
      completionTime: AppTime(0, 10),

    ),
    Initiative(
        title: 'Assignment',
        completionTime: AppTime(0, 5),
        isComplete: false),
    Initiative(
      title: 'Personal Project',
      completionTime: AppTime(0, 30),

    ),
  ];

  late Timer _timer;
  late String currentTime;
  late String currentWeekday;
  late TaskManager taskManager;

  @override
  void initState() {
    super.initState();

    _updateTime(); // Initial time
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());

    // 1) Initialize the manager once
    TaskManager.instance.init(_items_list);
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour24 = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final weekday = _getWeekdayName(now.weekday);

    // Convert to 12-hour format
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final period = hour24 >= 12 ? 'PM' : 'AM';

    setState(() {
      currentTime = '$hour12:$minute $period';
      currentWeekday = weekday;
    });
  }

  String _getWeekdayName(int weekdayNumber) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekdayNumber - 1];
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning from TimerPage
    setState(() {}); // Rebuilds ListPage with updated tasks

    print("return back==============================================");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlidingUpPanel(
        panel: HeatMapCalendar(
          defaultColor: Colors.white,
          flexible: true,
          colorMode: ColorMode.color,
          // textColor: Theme.of(context).primaryColor,
          textColor: Colors.black45,
          // fontSize: 12,
          datasets: {
            DateTime(2025, 4, 6): 0,
            DateTime(2025, 4, 7): 1,
            DateTime(2025, 4, 8): 2,
            DateTime(2025, 4, 9): 3,
            DateTime(2025, 4, 13): 4,
          },
          colorsets: {
            0: Colors.red[400]!,
            1: Colors.green[100]!,
            2: Colors.green[300]!,
            3: Colors.green[400]!,
            4: Colors.green[500]!,
            5: Colors.green[600]!,
          },
          onClick: (value) {
            // Do something
          },
        ),
        body: Column(
          children: [
            // Header with weekday and current time

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.indigo[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Monday",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[900],
                        ),
                      ),
                      Text(
                        currentTime,
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // const Divider(height: 1),

            Expanded(
              child: ReorderableListView(
                padding: const EdgeInsets.all(8),
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final item = _items_list.removeAt(oldIndex);
                    _items_list.insert(newIndex, item);

                    // taskManager.updateBaseTaskList(); // can't update base task list
                  });
                },
                children: [
                  for (int index = 0; index < _items_list.length; index++)
                    Dismissible(
                      key: ValueKey(_items_list[index].title),
                      direction: DismissDirection.horizontal,
                      // Left swipe background (archive)
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.archive,
                            color: Colors.white, size: 28),
                      ),
                      // Right swipe background (timer)
                      secondaryBackground: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.timer,
                            color: Colors.white, size: 28),
                      ),
                      confirmDismiss: (direction) async {
                        // 1) tell TaskManager where to start
                        TaskManager.instance.startFrom(index);

                        // 2) navigate to TimerPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => TimerPage()),
                        );

                        return false;
                      },
                      // adding bot main list index plus initiative list
                      child: _buildUndertakingItem(_items_list[index],
                          index + _items_list[index].basetask.length),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a widget for an individual undertaking.
  Widget _buildUndertakingItem(Undertaking undertaking, int index) {
    // Build a RichText widget to display the dynamicTime, title, and completionTime with different styles.

    // If there are no basetask, show a simple ListTile.
    if (undertaking.basetask.isEmpty) {
      return ListTile(
        key: ValueKey(undertaking.title),
        leading: buildUndertakingLeading(undertaking, index),
        title: buildRichTitle(undertaking),
        onTap: () {
          // handle tap
        },
      );
    } else {
      // Use an ExpansionTile for undertakings with basetask.
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor:
              Colors.indigo[300], // 👈 Set your custom divider color here
        ),
        child: ExpansionTile(
          // backgroundColor: Colors.indigo[100],
          key: ValueKey(undertaking.title),
          leading: buildUndertakingLeading(undertaking, index),

          title: buildRichTitle(undertaking, fontWeight: FontWeight.bold),
          children: undertaking.basetask.asMap().entries.map((entry) {
            int initiativeIndex = entry.key;
            BaseTask initiative = entry.value;

            // Build a RichText for the initiative with different styles.
            Widget buildInitiativeTitle() {
              return RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "    ${initiative.title} ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo[400],
                      ),
                    ),
                    TextSpan(
                      text: " ${initiative.completionTime.remainingTime()}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.indigo[100],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Wrap each initiative ListTile in a Dismissible widget.
            return Dismissible(
              key: ValueKey(
                  "${undertaking.title}-${initiative.title}-$initiativeIndex"),
              direction: DismissDirection.horizontal,
              background: Container(
                color: Colors.blue,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.info, color: Colors.white, size: 26),
              ),
              secondaryBackground: Container(
                color: Colors.orange,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child:
                    const Icon(Icons.play_arrow, color: Colors.white, size: 26),
              ),
              confirmDismiss: (direction) async {
                // Developer: Handle any dismiss action for the initiative.
                return false;
              },
              child: ListTile(
                leading: buildInitiativeLeading(initiative),
                //=====================================
                title: buildInitiativeTitle(),
                onTap: () {},
              ),
            );
          }).toList(),
        ),
      );
    }
  }

  ListTile getListTile(Undertaking undertaking, index) {
    return ListTile(
      key: ValueKey(undertaking.title),
      leading: ReorderableDragStartListener(
        index: index,
        child: SizedBox(
          width: 24,
          height: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Vertical Line
              Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 2,
                    color: Colors.indigo[300],
                  ),
                ),
              ),

              // White background circle to hide line behind transparent icons
              if (!undertaking.isComplete)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // or background color of ListTile
                  ),
                ),
            ],
          ),
        ),
      ),
      title: buildRichTitle(undertaking),
      onTap: () {
        // handle tap
      },
    );
  }

  Widget buildRichTitle(Undertaking undertaking, {FontWeight? fontWeight}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "${undertaking.title} ",
            style: TextStyle(
              fontSize: 18,
              color: Colors.indigo[700],
              fontWeight:
                  fontWeight != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          TextSpan(
            text: undertaking.completionTime.remainingTime(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.indigo[100],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVerticalLine({
    double width = 2,
    double topOffset = -4,
    double bottomOffset = -6,
    double containerWidth = 24,
    Color color = Colors.indigo,
  }) {
    return Positioned(
      top: topOffset,
      bottom: bottomOffset,
      left: (containerWidth - width) / 2,
      child: Container(
        width: width,
        color: color,
      ),
    );
  }

  ReorderableDragStartListener buildUndertakingLeading(
      Undertaking undertaking, int index) {
    return ReorderableDragStartListener(
      index: index,
      child: SizedBox(
        width: 24,
        height: 48, // Fixed height for consistency.
        child: Stack(
          clipBehavior: Clip.none, // Allow the vertical line to extend outside.
          alignment: Alignment.center,
          children: [
            // Common vertical line.
            buildVerticalLine(
              containerWidth: 24,
              color: Colors.indigo[300]!,
              topOffset: -8,
              bottomOffset: -8,
            ),
            // White background circle to mask the line (only if not done).
            if (!undertaking.isComplete)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            // Actual icon for the undertaking.
            Icon(
              undertaking.isComplete ? Icons.circle : Icons.circle_outlined,
              color: Colors.indigo[300],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInitiativeLeading(BaseTask initiative) {
    return SizedBox(
      width: 24,
      height: 48, // Fixed height for consistency.
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Draw the common vertical line.
          buildVerticalLine(
            containerWidth: 24,
            color: Colors.indigo[300]!,
            topOffset: -8,
            bottomOffset: -8,
          ),
          // White background circle to mask the line if the initiative is not done.
          if (!initiative.isComplete)
            Container(
              width: 15,
              height: 15,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          // Actual icon for the initiative (checks its own state).
          Icon(
            initiative.isComplete ? Icons.circle : Icons.circle_outlined,
            color: Colors.indigo[300],
            size: 18,
          ),
        ],
      ),
    );
  }
}
