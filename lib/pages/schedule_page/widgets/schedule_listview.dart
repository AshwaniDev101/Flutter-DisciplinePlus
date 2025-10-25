import 'package:discipline_plus/pages/timer_page/timer_page.dart';
import 'package:flutter/material.dart';
import '../../../../models/initiative.dart';


/// Displays a list of daily schedules using real-time stream updates
class ScheduleListview extends StatefulWidget {

  final Stream<List<Initiative>> stream;
  final void Function(Initiative) onItemEdit;
  final void Function(Initiative) onItemDelete;
  final void Function(Initiative, bool) onItemComplete;

  const ScheduleListview({
    super.key,
    required this.stream,
    required this.onItemEdit,
    required this.onItemDelete,
    required this.onItemComplete,
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
              stream: widget.stream,
              // stream: ScheduleCoordinator.instance.mergedDayInitiatives,
              builder: (context, snapshot) {

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


                return ListView.builder(
                  itemCount: initiatives.length,
                  itemBuilder: (context, i) => _buildCard(context, initiatives[i], i),
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: false,
                );

                // return Column(
                //   children: [
                //     for (int i = 0; i < initiatives.length; i++)
                //       _buildCard(context, initiatives[i], i),
                //   ],
                // );
              },
            ),
          ),
          const SizedBox(height: 180),
        ],
      ),
    );
  }

  /// Builds a single schedule card
  Widget _buildCard(BuildContext context, Initiative initiative, int index) {

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
            isComplete: initiative.isComplete,
            whiteCircleSize: 20,
            iconSize: 24,
          ),
          const SizedBox(width: 4),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('02:05',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                Text(
                  initiative.title,
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
                        text: initiative.completionTime.remainingTime(),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      if (initiative.studyBreak.completionTime.minute != 0)
                        TextSpan(
                          text:
                          "   ${initiative.studyBreak.completionTime.minute}m brk",
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
                        initiative: initiative,
                        onComplete: (bool isManual) {
                          widget.onItemComplete(initiative, true);
                        }),
                        // onComplete: ({bool isComplete = false}) {
                        //   // handle completion here
                        //   print(" ==== Completed: , Manual: $isManual");
                        //
                        //   widget.onItemComplete(initiative, isComplete);
                        //
                        //
                        //
                        //   // widget.onItemComplete(initiative, initiative.isComplete=isComplete);
                        //   // example: update ScheduleCompletionManager
                        //   // ScheduleCompletionManager.instance.toggleCompletion(
                        //   //   init.id,
                        //   //   isComplete: isComplete,
                        //   // );
                        // },


                    ),
                  );
                },
                icon: Icon(Icons.play_arrow_rounded, color: Colors.green[300]),
                padding: EdgeInsets.zero,
              ),


              IconButton(
                key: key,
                onPressed: () => _showMenu(context, key, initiative),
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
  /// Compact menu options for edit/delete/complete
  void _showMenu(BuildContext context, GlobalKey key, Initiative initiative) {

    // bool isComplete = false;
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
        PopupMenuItem(
          value: 'edit',
          child: const Text('Edit', style: TextStyle(fontSize: 14)),
        ),
        PopupMenuItem(
          value: 'delete',
          child: const Text('Delete', style: TextStyle(fontSize: 14)),
        ),
        PopupMenuItem(
          value: 'complete',
          child: StatefulBuilder(
            builder: (context, setState) {

              return InkWell(
                onTap: () {
                  setState(() {
                    initiative.isComplete = !initiative.isComplete;
                    widget.onItemComplete(initiative, initiative.isComplete);
                  });
                },

                child: Padding(
                  padding: const EdgeInsets.only(top:2,bottom: 2,right: 2),
                  child: Row(
                    children: [
                      Icon(initiative.isComplete?Icons.check_box:Icons.check_box_outline_blank_rounded, color: initiative.isComplete?Colors.blue:Colors.grey),
                      SizedBox(width: 4,),
                      Text(initiative.isComplete?'Completed!':'Complete?', style: TextStyle(fontSize: 14)),
                    ]
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ).then((value) {
      if (value == 'delete') {
        widget.onItemDelete(initiative);
      } else if (value == 'edit') {
        widget.onItemEdit(initiative);
      }
    });
  }


}
