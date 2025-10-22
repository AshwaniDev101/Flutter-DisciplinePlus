import 'package:discipline_plus/pages/timerpage/timer_page.dart';
import 'package:flutter/material.dart';
import '../../../../managers/selected_day_manager.dart';
import '../../../../models/initiative.dart';
import '../schedule_coordinator.dart';
import '../schedule_manager.dart';

/// Displays a list of daily schedules using real-time stream updates
class ScheduleListview extends StatefulWidget {


  final void Function(Initiative) onItemEdit;

  const ScheduleListview({
    super.key,
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
              stream: ScheduleCoordinator.instance.mergedDayInitiatives,
              builder: (context, snapshot) {
                // --- Handle errors and loading states ---
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final initiatives = snapshot.data ?? [];

                if (initiatives.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                // --- Build the initiative list ---
                return Column(
                  children: [
                    for (int i = 0; i < initiatives.length; i++)
                      _buildCard(context, initiatives[i], i),
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

  /// Builds a single schedule card
  Widget _buildCard(BuildContext context, Initiative init, int index) {

    final key = GlobalKey();
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildLeadingIcon(
            isComplete: init.isComplete,
            whiteCircleSize: 20,
            iconSize: 24,
          ),
          const SizedBox(width: 4),

          // --- Title and details ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('02:05',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                          text:
                          "   ${init.studyBreak.completionTime.minute}m brk",
                          style:
                          const TextStyle(fontSize: 12, color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- Actions ---
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TimerPage(
                        initiative: init,
                        onComplete: ({bool isComplete = false, bool isManual = false}) {
                          // handle completion here
                          print("Completed: $isComplete, Manual: $isManual");

                          // example: update ScheduleCompletionManager
                          // ScheduleCompletionManager.instance.toggleCompletion(
                          //   init.id,
                          //   isComplete: isComplete,
                          // );
                        },
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.play_arrow_rounded, color: Colors.green[300]),
                padding: EdgeInsets.zero,
              ),


              IconButton(
                key: key,
                onPressed: () => _showMenu(context, key, init),
                icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the vertical timeline + completion icon
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
          // Vertical timeline line
          Positioned(
            top: -15,
            bottom: -15,
            left: 11,
            child: Container(width: 2, color: Colors.grey),
          ),
          // White background circle
          Container(
            width: whiteCircleSize,
            height: whiteCircleSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          // Icon
          Icon(
            isComplete ? Icons.check_circle : Icons.circle_outlined,
            size: iconSize,
            color: isComplete ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }

  /// Menu options for edit/delete/complete
  void _showMenu(BuildContext context, GlobalKey key, Initiative item) {
    final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
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
                      setState(() => item.isComplete = val);
                      // ScheduleCompletionManager.instance
                      //     .toggleCompletion(item.id, val);
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
    });
  }



}
