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

// All your imports remain unchanged

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {

  final ValueNotifier<double> slidingPanelNotifier = ValueNotifier(0.0);
  // final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    RefreshReloadNotifier.instance.register(loadData);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await RefreshReloadNotifier.instance.notifyAll();
    });
  }

  Future<void> loadData() async {
    await TaskManager.instance.reloadRepository();
    setState(() {});
  }


  void _onRefresh() async {
    await RefreshReloadNotifier.instance.notifyAll();
    _refreshController.refreshCompleted();
  }

  void showDialogAdd() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomPopupDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildFAB(),
      body: SlidingUpPanel(
        minHeight: 100,
        maxHeight: 550,
        onPanelSlide: (val) => slidingPanelNotifier.value = val,
        panel: _buildPanelContent(),
        body: _buildMainContent(),
      ),
    );
  }

  Widget _buildFAB() {
    return Stack(
      children: [
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
    );

  }

  Widget _buildPanelContent() {
    return Column(
      children: [
        SizedBox(height: 80, child: HeatmapRow()),
        SizedBox(height: 450, child: HeatmapCalender()),
      ],
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        ClockBanner(),
        Expanded(
          child: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ReorderableListView(
              // scrollController: _scrollController,
              padding: const EdgeInsets.all(8),
              onReorder: _onReorder,
              children: List.generate(
                TaskManager.instance.getLength(),
                    (i) => _buildDismissibleItem(i),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final item = TaskManager.instance.getInitiativeAt(oldIndex);
      TaskManager.instance.removeInitiativeAt(oldIndex);
      TaskManager.instance.insertInitiativeAt(newIndex, item);
    });
    TaskManager.instance.updateAllOrders();
  }

  Widget _buildDismissibleItem(int index) {
    final initiative = TaskManager.instance.getInitiativeAt(index);
    return Dismissible(
      key: ValueKey(initiative.id),
      direction: DismissDirection.horizontal,
      background: _buildDismissBackground(Icons.timer, Alignment.centerLeft, EdgeInsets.only(left: 20)),
      secondaryBackground: _buildDismissBackground(Icons.timer, Alignment.centerRight, EdgeInsets.only(right: 20)),
      child: _buildInitiativeItem(initiative, index),
      confirmDismiss: (direction) async {
        navigateToTimerPage(dismissDirection: direction, initiative: initiative);
        return false;
      },
    );
  }

  Widget _buildDismissBackground(IconData icon, Alignment alignment, EdgeInsets padding) {
    return Container(
      color: Constants.background_color,
      alignment: alignment,
      padding: padding,
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildInitiativeItem(Initiative item, int index) {
    return GestureDetector(
      onLongPressStart: (details) => _showItemMenu(details.globalPosition, item),
      child: ListTile(
        leading: _buildLeading(item, index),
        title: _buildRichTitle(item),
        onTap: () {},
      ),
    );
  }

  void _showItemMenu(Offset position, Initiative item) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'delete') {
        TaskManager.instance.removeInitiative(item.id);
      }
    });
  }

  ReorderableDragStartListener _buildLeading(Initiative bi, int index) {
    return ReorderableDragStartListener(
      index: index,
      child: _buildLeadingIcon(
        isComplete: bi.isComplete,
        whiteCircleSize: 20,
        iconSize: 24,
      ),
    );
  }

  Widget _buildLeadingIcon({
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
          Positioned(top: -8, bottom: -8, left: 11, child: Container(width: 2, color: Colors.indigo[300])),
          Container(
            width: whiteCircleSize,
            height: whiteCircleSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
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

  Widget _buildRichTitle(Initiative u, {FontWeight? fontWeight}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${u.title} ',
            style: TextStyle(fontSize: 18, color: Colors.indigo[700], fontWeight: fontWeight),
          ),
          TextSpan(
            text: u.completionTime.remainingTime(),
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
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
          Offset beginOffset;
          if (dismissDirection == DismissDirection.startToEnd) {
            beginOffset = Offset(-1.0, 0.0);
          } else if (dismissDirection == DismissDirection.endToStart) {
            beginOffset = Offset(1.0, 0.0);
          } else {
            beginOffset = Offset(0.0, 1.0);
          }

          return SlideTransition(
            position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
