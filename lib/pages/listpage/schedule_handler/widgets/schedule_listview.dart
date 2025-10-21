import 'package:discipline_plus/pages/listpage/schedule_handler/schedule_coordinator.dart';
import 'package:discipline_plus/pages/listpage/schedule_handler/schedule_manager.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../../../managers/selected_day_manager.dart';
import '../../../../models/initiative.dart';
import '../schedule_completion_manager.dart';


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
      return Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Initiative>>(
                // stream:ScheduleManager.instance.watch(),
                // stream:ScheduleManager.instance.schedule$,
                stream:ScheduleCoordinator.instance.mergedDayInitiatives,
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
        ),
      );
    }




    Widget _dismissibleItem(BuildContext context, Initiative init, int index) {
    return Dismissible(
      key: ValueKey(init.id),
      direction: DismissDirection.horizontal,
      background: _swipeBg(Icons.timer, Alignment.centerLeft, const EdgeInsets.only(left: 20)),
      secondaryBackground: _swipeBg(Icons.timer, Alignment.centerRight, const EdgeInsets.only(right: 20)),
      confirmDismiss: (dir) async {
        widget.onItemSwipe(dir, init);
        return false;
      },
      child: GestureDetector(
        onLongPressStart: (details) => _showMenu(context, details.globalPosition, init),
        child: Material(
          color: Colors.transparent, // keep background transparent if needed
          child: InkWell(
            onTap: () {
              // handle normal tap if needed
              print("Tapped on ${init.title}");
            },
            splashColor: Colors.indigo.withOpacity(0.2), // ripple color
            highlightColor: Colors.indigo.withOpacity(0.1),

            child: Card(
              elevation: 0,
              color: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              // margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  // Handle tap if needed
                  print("Tapped on ${init.title}");
                },
                onLongPress: () {
                  _showMenu(context, Offset(0, 0), init); // pass proper position if needed
                },
                child: Column(
                  children: [



                    Row(
                      children: [


                        ReorderableDragStartListener(
                          index: index,
                          child: _buildLeadingIcon(
                            isComplete: init.isComplete,
                            whiteCircleSize: 20,
                            iconSize: 24,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Text('02:05',style: TextStyle(fontSize: 12,color: Colors.grey[600]), ),
                              Text(
                                init.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.indigo[700],
                                  fontWeight: FontWeight.w400,
                                ),
                              ),

                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: init.completionTime.remainingTime(),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    if (init.studyBreak.completionTime.minute != 0)
                                      TextSpan(
                                        text: "   ${init.studyBreak.completionTime.minute}m brk",
                                        style: const TextStyle(fontSize: 12, color: Colors.red),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),


                        Row(
                          mainAxisSize: MainAxisSize.min, // shrink-wrap icons
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.play_arrow_rounded, color: Colors.green[300]),
                              padding: EdgeInsets.zero,

                            ),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.more_vert_rounded, color: Colors.grey),
                              padding: EdgeInsets.zero,

                            ),
                          ],
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            ),


          ),
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


    void _showMenu(BuildContext context, Offset pos, Initiative item) {
      showMenu(
        context: context,
        position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx, pos.dy),
        items: [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
          PopupMenuItem(
            value: 'complete',
            child: StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  children: [
                    Checkbox(
                      value: item.isComplete,
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() {
                          item.isComplete = val;
                        });
                        // Update database immediately
                        ScheduleCompletionManager.instance
                            .toggleCompletion(item.id, val);
                      },
                    ),
                    const Text('Complete'),
                  ],
                );
              },
            ),
          ),
        ],
      ).then((value) {
        if (value == 'delete') {
          ScheduleManager.instance.deleteInitiativeFrom(
            SelectedDayManager.currentSelectedWeekDay.value,
            item.id,
          );
        } else if (value == 'edit') {
          widget.onItemEdit(item);
        }
        // No need to handle 'complete' here because the checkbox already updated it
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
          Positioned(top: -15, bottom: -15, left: 11, child: Container(width: 2, color: Colors.grey)),
          Container(
            width: whiteCircleSize,
            height: whiteCircleSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          Icon(
            isComplete ? Icons.check_circle : Icons.circle_outlined,
            size: iconSize,
            color:  isComplete? Colors.blue:Colors.grey,
          ),
        ],
      ),
    );
  }

}
