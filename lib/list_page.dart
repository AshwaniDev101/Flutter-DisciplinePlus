import 'dart:async';

import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/taskmanager.dart';
import 'package:discipline_plus/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dilog/custom_pop_up_dialog.dart';
import 'models/app_time.dart';
import 'utils/constants.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with RouteAware {
  late Timer _timer;
  late AppTime currentTime;
  late String currentWeekday;

  final ScrollController _scrollController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    TaskManager.instance.reloadRepository();
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    _updateWeekTime();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateWeekTime());

    // loadInitiatives();
    //
    // // Initialize TaskManager
    // TaskManager.instance.updateList(_items_list);
  }

  @override // call when return to the this route from some other route
  void didPopNext() {
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void showDialogAdd() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomPopupDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Stack(
        children: [
          // Your main content here
          Positioned(
            bottom: 150, // 200 pixels from top
            right: 1, // 16 pixels from right (classic FAB spacing)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: showDialogAdd,
                  child: Icon(Icons.add),
                ),
                // SizedBox(height: 10), // space between buttons
                // FloatingActionButton(
                //   onPressed: () {},
                //   child: Icon(Icons.add_home_outlined),
                // ),
              ],
            ),
          ),
        ],
      ),

      // body: SlidingUpPanel(
      //
      //   // HeatMap
      //   panel: HeatMapCalendar(
      //     defaultColor: Colors.white,
      //     flexible: true,
      //     colorMode: ColorMode.color,
      //     textColor: Colors.black45,
      //     datasets: {
      //       DateTime(2025,4,6):0,
      //       DateTime(2025,4,7):1,
      //       DateTime(2025,4,8):2,
      //       DateTime(2025,4,9):3,
      //       DateTime(2025,4,13):4,
      //     },
      //     colorsets: {
      //       0: Colors.red[400]!,
      //       1: Colors.green[100]!,
      //       2: Colors.green[300]!,
      //       3: Colors.green[400]!,
      //       4: Colors.green[500]!,
      //       5: Colors.green[600]!,
      //     },
      //     onClick: (value) {
      //       // Do something
      //     },
      //   ),
      //
      //
      //
      //   body:

      body: Column(
        children: [
          // Wednesday   09:15
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
            decoration: BoxDecoration(
              color: Colors.indigo[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(currentWeekday,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo[900])),
                Text(currentTime.toString(),
                    style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[900])),
              ],
            ),
          ),

          // ElevatedButton(
          //   onPressed: (){addData();},
          //   child: const Text('next'),
          // ),
          // AnimatedSkyHeader(
          //   currentWeekday: 'Wednesday',
          //   currentTime: currentTime,
          //   isFastForward: true, // Pass true for fast-forward mode
          // ),

          // Listview

          Expanded(
            child: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: ReorderableListView(
                scrollController: _scrollController,
                padding: const EdgeInsets.all(8),
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;

                  setState(() {
                    final item = TaskManager.instance.getInitiativeAt(oldIndex);
                    TaskManager.instance.removeInitiativeAt(oldIndex);
                    TaskManager.instance.insertInitiativeAt(newIndex, item);
                  });

                  TaskManager.instance.updateAllOrders();

                },
                children: [
                  // Every list Item
                  for (var i = 0; i < TaskManager.instance.getLength(); i++)

                    Dismissible(
                      key: ValueKey(TaskManager
                          .instance.getInitiativeAt(i).id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Constants.background_color,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.timer, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Constants.background_color,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.timer, color: Colors.white),
                      ),
                      child: _buildinitiativeItem(
                          TaskManager.instance.getInitiativeAt(i),
                          i),
                      confirmDismiss: (direction) async {
                        navigateToTimerPage(
                            dismissDirection: direction,
                            initiative: TaskManager
                                .instance.getInitiativeAt(i));
                        return false; // Item won't get removed
                      },
                    ),
                ],
              ),
            ),
          ),

          //     Heatmap
          SizedBox(
            height: 100, // enough for 7 rows
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              // Horizontal grid for 31 columns
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 rows
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 7 * 31,
              // total cells = 217
              itemBuilder: (context, index) {
                final heatLevel = index % 5; // mock data for now

                final colors = [
                  Color(0xFFEBEDF0), // empty
                  Color(0xFF9BE9A8), // light
                  Color(0xFF40C463), // medium
                  Color(0xFF30A14E), // strong
                  Color(0xFF216E39), // very strong
                ];

                return Container(
                  decoration: BoxDecoration(
                    color: colors[heatLevel],
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
              padding: EdgeInsets.all(2),
            ),
          )
        ],
      ),
      // ),
    );
  }

  Widget _buildinitiativeItem(Initiative item, int index) {
    return Builder(
      builder: (context) {
        return GestureDetector(
          // Option Menu
          onLongPressStart: (details) {
            final position = details.globalPosition;
            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                  position.dx, position.dy, position.dx, position.dy),
              items: [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ).then((value) {
              if (value == 'edit') {
                // handle edit
              } else if (value == 'delete') {
                TaskManager.instance.removeInitiative(item.id);
              }
            });
          },
          // Item
          child: ListTile(
            leading: buildLeading(item, index),
            title: buildRichTitle(item),
            onTap: () {
              // handle tap
            },
          ),
        );
      },
    );
  }

  //================  build and updating Leading Icon ===========================
  ReorderableDragStartListener buildLeading(Initiative bi, int index) {
    return ReorderableDragStartListener(
      index: index,
      child: buildLeadingIcon(
        isComplete: bi.isComplete,
        whiteCircleSize: 20,
        iconSize: 24,
      ),
    );
  }

  Widget buildChildLeading(Initiative ini) {
    return buildLeadingIcon(
      isComplete: ini.isComplete,
      whiteCircleSize: 14,
      // small then the icon size to make sure it remain behind the circle
      iconSize: 18,
    );
  }

  Widget buildLeadingIcon({
    required bool isComplete,
    required double whiteCircleSize,
    required double iconSize,
  }) {
    return SizedBox(
      width: 24,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -8,
            bottom: -8,
            left: 11,
            child: Container(width: 2, color: Colors.indigo[300]),
          ),
          // if (!isComplete)
          Container(
            width: whiteCircleSize,
            height: whiteCircleSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          Icon(
            isComplete ? Icons.circle_rounded : Icons.circle_outlined,
            size: iconSize,
            color: Colors.indigo[300],
          ),
        ],
      ),
    );
  }

//================  build and updating Title ===========================
  Widget buildRichTitle(Initiative u, {FontWeight? fontWeight}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(
            text: '${u.title} ',
            style: TextStyle(
                fontSize: 18,
                color: Colors.indigo[700],
                fontWeight: fontWeight)),
        TextSpan(
            text: u.completionTime.remainingTime(),
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ]),
    );
  }

  void _updateWeekTime() {
    final now = DateTime.now();

    // Create an instance of AppTime with the current hour and minute
    final appTime = AppTime(now.hour, now.minute);

    setState(() {
      currentTime = appTime; // This will return time in HH:MM AM/PM format
      currentWeekday = _weekdayName(now.weekday);
    });
  }

  String _weekdayName(int weekdayNumber) {
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

  void navigateToTimerPage({
    required DismissDirection dismissDirection,
    required Initiative initiative,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TimerPage(initiative: initiative),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Determine the start and end offset based on the dismiss direction
          Offset beginOffset;
          if (dismissDirection == DismissDirection.startToEnd) {
            beginOffset = const Offset(-1.0, 0.0); // Slide from left to right
          } else if (dismissDirection == DismissDirection.endToStart) {
            beginOffset = const Offset(1.0, 0.0); // Slide from right to left
          } else {
            beginOffset = const Offset(
                0.0, 1.0); // Slide from top to bottom (fallback case)
          }

          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
