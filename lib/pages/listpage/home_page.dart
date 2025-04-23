import 'dart:async';

import 'package:discipline_plus/core/refresh_reload_notifier.dart';
import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/controller/taskmanager.dart';
import 'package:discipline_plus/pages/timerpage/timer_page.dart';
import 'package:discipline_plus/pages/listpage/widget/clock_banner.dart';
import 'package:discipline_plus/pages/listpage/widget/heatmap_calender.dart';
import 'package:discipline_plus/pages/listpage/widget/heatmap_row.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../core/utils/constants.dart';
import 'dialog/custom_pop_up_dialog.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  late Timer _timer;
  // late AppTime currentTime;
  // late String currentWeekday;
  final ValueNotifier<double> slidingPanelNotifier = ValueNotifier(0.0);
  final ValueNotifier<double> timeNotifier = ValueNotifier(0.0);

  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    // await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()

    // await loadData(); // ----------------- work

    await RefreshReloadNotifier.instance.notifyAll();
    _refreshController.refreshCompleted();
  }




  @override
  void initState() {
    super.initState();

    // Adding function to list of function to refresh them all at once
    RefreshReloadNotifier.instance.register(loadData);
    // To make sure widget is fully loaded before call load data


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await loadData(); // Safe now: UI is rendered, context is ready
      await RefreshReloadNotifier.instance.notifyAll();
    });

  }

  Future <void> loadData() async
  {
    await TaskManager.instance.reloadRepository();
    setState(() {});
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

          // if (panelValue<0.5)

          ValueListenableBuilder(
              valueListenable: slidingPanelNotifier,
              builder: (context,value,child){
                return Positioned(
                    bottom: 10 + (1 - value) * 90, // 200 pixels from top
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
                );
              }
          )

        ],
      ),


      body: SlidingUpPanel(

        minHeight: 100, // collapsed size
        maxHeight: 550, // expanded size

        onPanelSlide: (val) => slidingPanelNotifier.value = val,

        panel: Column(

          children: [



            SizedBox(
              // height: 300,
              height: 80,
              child: HeatmapRow(),
            ),

          SizedBox(
            height: 450,  // or any height that fits your design
            child: HeatmapCalender(),
          ),
        ],),

        body: Column(
          children: [
            // Wednesday   09:15
            ClockBanner(),

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
          ],
        ),
      )





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



  //
  // void _updateWeekTime() {
  //   final now = DateTime.now();
  //
  //   // Create an instance of AppTime with the current hour and minute
  //   final appTime = AppTime(now.hour, now.minute);
  //
  //   setState(() {
  //     currentTime = appTime; // This will return time in HH:MM AM/PM format
  //     currentWeekday = _weekdayName(now.weekday);
  //   });
  // }
  //
  // String _weekdayName(int weekdayNumber) {
  //   const weekdays = [
  //     'Monday',
  //     'Tuesday',
  //     'Wednesday',
  //     'Thursday',
  //     'Friday',
  //     'Saturday',
  //     'Sunday',
  //   ];
  //   return weekdays[weekdayNumber - 1];
  // }

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
