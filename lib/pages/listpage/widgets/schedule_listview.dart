import 'package:discipline_plus/pages/listpage/schedule_handler/schedule_manager.dart';
import 'package:flutter/material.dart';
import '../../../managers/current_day_manager.dart';
import '../../../models/initiative.dart';
import '../../../core/utils/constants.dart';

class ScheduleListview extends StatefulWidget {
  // final int dayIndex;
  final ScrollController scrollController;
  // final RefreshController refreshController;
  final void Function(DismissDirection, Initiative) onItemSwipe;
  final void Function(Initiative) onItemEdit;

  const ScheduleListview({
    super.key,
    // required this.dayIndex,
    required this.scrollController,
    // required this.refreshController,
    required this.onItemSwipe,
    required this.onItemEdit,
  });

  @override
  State<ScheduleListview> createState() => _ScheduleListviewState();
}

class _ScheduleListviewState extends State<ScheduleListview> {


    @override
    Widget build(BuildContext context) {
      return Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Initiative>>(
              // stream:ScheduleManager.instance.watch(),
              stream:ScheduleManager.instance.schedule$,
              // initialData: const [],
              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                // if (snapshot.connectionState == ConnectionState.waiting && initiatives.isEmpty) {
                //   return const Center(child: CircularProgressIndicator());
                // }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final initiatives = snapshot.data ?? [];

                if (initiatives.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                return ReorderableListView(
                scrollController: widget.scrollController,
                padding: const EdgeInsets.all(8),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    // final item = initiatives[oldIndex];
                    // TaskManager.instance.removeInitiativeAt(oldIndex);
                    // TaskManager.instance.insertInitiativeAt(newIndex, item);
                    // TaskManager.instance.updateAllOrders();
                  });
                },
                children: [
                  for (int i = 0; i < initiatives.length; i++)
                    _dismissibleItem(context, initiatives[i], i),
                ],
                                  );
              },
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
          title: Text(init.title,style: TextStyle(
            fontSize: 16,
            color: Colors.indigo[700],
            fontWeight: FontWeight.w400,
            // fontWeight: init.isComplete ? FontWeight.w300 : FontWeight.bold,
          )),
          subtitle: RichText(
            text: TextSpan(children: [

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
          ),
          // trailing: Icon(Icons.square_outlined),
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
        ScheduleManager.instance.deleteInitiativeFrom(CurrentDayManager.getCurrentDay(), item.id);
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
