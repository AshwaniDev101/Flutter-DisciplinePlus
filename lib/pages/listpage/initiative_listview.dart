import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/initiative.dart';
import '../listpage/core/refresh_reload_notifier.dart';
import 'logic/taskmanager.dart';
import '../../core/utils/constants.dart';
import 'core/current_day_manager.dart';

class InitiativeListview extends StatefulWidget {
  // final int dayIndex;
  final ScrollController scrollController;
  final RefreshController refreshController;
  final void Function(DismissDirection, Initiative) onItemSwipe;
  final void Function(Initiative) onItemEdit;

  const InitiativeListview({
    super.key,
    // required this.dayIndex,
    required this.scrollController,
    required this.refreshController,
    required this.onItemSwipe,
    required this.onItemEdit,
  });

  @override
  State<InitiativeListview> createState() => _InitiativeListviewState();
}

class _InitiativeListviewState extends State<InitiativeListview> {


    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Expanded(
            child: SmartRefresher(
              controller: widget.refreshController,
              onRefresh: () async {
                await RefreshReloadNotifier.instance.notifyAll();
                widget.refreshController.refreshCompleted();
              },
              child: StreamBuilder<List<Initiative>>(
                stream: TaskManager.instance.watchInitiatives(CurrentDayManager.getCurrentDay()),
                builder: (context, snapshot) {

                  //
                  // if (snapshot.connectionState == ConnectionState.waiting) {
                  //   return const Center(child: CircularProgressIndicator());
                  // }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  final initiatives = snapshot.data ?? [];

                  return Stack(
                    children : [
                      ReorderableListView(
                      scrollController: widget.scrollController,
                      padding: const EdgeInsets.all(8),
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = initiatives[oldIndex];
                          TaskManager.instance.removeInitiativeAt(oldIndex);
                          TaskManager.instance.insertInitiativeAt(newIndex, item);
                          TaskManager.instance.updateAllOrders();
                        });
                      },
                      children: [
                        for (int i = 0; i < initiatives.length; i++)
                          _dismissibleItem(context, initiatives[i], i),
                      ],
                    ),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Positioned.fill(
                          child: IgnorePointer(
                            ignoring: true,
                            child: Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(strokeWidth: 3),
                              ),
                            ),
                          ),
                        ),
                    ]
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    }


  Widget _dismissibleItem(BuildContext context, Initiative init, int index) {
    return Dismissible(
      key: ValueKey(init.id),
      direction: DismissDirection.horizontal,
      background: _swipeBg(Icons.timer, Alignment.centerLeft, const EdgeInsets.only(left: 20)),
      secondaryBackground:
      _swipeBg(Icons.timer, Alignment.centerRight, const EdgeInsets.only(right: 20)),
      confirmDismiss: (dir) async {
        widget.onItemSwipe(dir, init);
        return false;
      },
      child: GestureDetector(
        onLongPressStart: (details) =>
            _showMenu(context, details.globalPosition, init),
        child: ListTile(
          dense: true,
          leading: ReorderableDragStartListener(
            index: index,
            // child: _buildIcon(init.isComplete),
            child: _buildLeadingIcon(
              isComplete: init.isComplete,
              whiteCircleSize: 20,
              iconSize: 24,),
          ),
          title: _buildTitle(init),
        ),
      ),
    );
  }

  Container _swipeBg(IconData icon, Alignment align, EdgeInsets pad) => Container(
    color: Constants.background_color,
    alignment: align,
    padding: pad,
    child: Icon(icon, color: Colors.white),
  );

  // Widget _buildIcon(bool done) => Icon(
  //   done ? Icons.circle_rounded : Icons.circle_outlined,
  //   color: Colors.indigo[300],
  //   size: 24,
  // );

  Widget _buildTitle(Initiative init) {

    return RichText(
      text: TextSpan(children: [

        TextSpan(
          text: '${init.title} ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.indigo[700],
            fontWeight: FontWeight.w400,
            // fontWeight: init.isComplete ? FontWeight.w300 : FontWeight.bold,
          ),
        ),
        TextSpan(
          text: init.completionTime.remainingTime(),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        if (init.studyBreak.completionTime.minute != 0)
          TextSpan(
            text: "   ${init.studyBreak.completionTime.minute}m brk",
            style: const TextStyle(fontSize: 12, color: Colors.red),
          ),
      ]),
    );


  }

  void _showMenu(BuildContext context, Offset pos, Initiative item) {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx, pos.dy),
      items: [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    ).then((value) {
      if (value == 'delete') {
        TaskManager.instance.removeInitiative(
            CurrentDayManager.getCurrentDay(), item.id);
      } else if (value == 'edit') {
        widget.onItemEdit(item);
      }
    });
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
          Positioned(top: -8, bottom: -8, left: 11, child: Container(width: 2, color: Colors.grey)),
          Container(
            width: whiteCircleSize,
            height: whiteCircleSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          Icon(
            isComplete ? Icons.circle_rounded : Icons.circle_outlined,
            size: iconSize,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

}
