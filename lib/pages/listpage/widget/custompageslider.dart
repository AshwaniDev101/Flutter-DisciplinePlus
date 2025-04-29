import 'package:discipline_plus/database/repository/week_repository.dart';
import 'package:discipline_plus/database/services/week_service/firebase_week_service.dart';
import 'package:discipline_plus/models/app_time.dart';

import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../logic/taskmanager.dart';

import '../core/current_day_manager.dart';
import '../core/refresh_reload_notifier.dart';
import '../../../core/utils/constants.dart';
import '../../../models/initiative.dart';
import '../../timerpage/timer_page.dart';

class CustomPageSlider extends StatefulWidget {
  @override
  _CustomPageSliderState createState() => _CustomPageSliderState();
}

class _CustomPageSliderState extends State<CustomPageSlider> {

  late final List<RefreshController> _refreshControllers;
  final ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    super.initState();

    RefreshReloadNotifier.instance.register(loadData);// reloading data

    _refreshControllers = List.generate(
      CurrentDayManager.length(),
          (_) => RefreshController(initialRefresh: false),
    );
  }

  @override
  void dispose() {
    for (var ctrl in _refreshControllers) {
      ctrl.dispose();
    }
    _scrollController.dispose();
    super.dispose();
  }


  void _goLeft() {
    setState(() {

      CurrentDayManager.goLeft();


    });
  }

  void _goRight() {
    setState(() {
      CurrentDayManager.goRight();
    });
  }



  Future<void> loadData() async {
    await TaskManager.instance.reloadRepository(CurrentDayManager.getCurrentDay());
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {


    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        SizedBox(height: 35),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: Icon(Icons.arrow_left), onPressed: _goLeft),
              Text(
                CurrentDayManager.getCurrentDay().toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(icon: Icon(Icons.arrow_right), onPressed: _goRight),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: IndexedStack(
              // index: _currentIndex,
              index: CurrentDayManager.getCurrentIndex(),
              children: List.generate(
                CurrentDayManager.length(),
                    (i) => _buildDayContent(i),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayContent(int index) {
    return Column(
      children: [
        Expanded(
          child: SmartRefresher(
            controller: _refreshControllers[index],
            onRefresh: () async {
              await RefreshReloadNotifier.instance.notifyAll();
              _refreshControllers[index].refreshCompleted();
            },
            child: ReorderableListView(
              scrollController: _scrollController,
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

        setState(() {
          TaskManager.instance.removeInitiative(CurrentDayManager.getCurrentDay(),item.id);
        });

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
