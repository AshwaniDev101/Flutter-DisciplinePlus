import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../managers/selected_day_manager.dart';
import '../../../../models/initiative.dart';
import '../../../../widget/global_helper_widget_functions.dart';
import '../../dialog_helper.dart';
import '../../schedule_handler/schedule_manager.dart';
import '../global_list_manager.dart';

class GlobalInitiativeListview extends StatefulWidget {
  const GlobalInitiativeListview({super.key});

  @override
  State<GlobalInitiativeListview> createState() => _GlobalInitiativeListviewState();
}

class _GlobalInitiativeListviewState extends State<GlobalInitiativeListview> {
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Initiative>>(
      stream: GlobalListManager.instance.watch(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        final initiatives = snapshot.data ?? [];

        if (snapshot.connectionState == ConnectionState.waiting && initiatives.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (initiatives.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return ListView.builder(
          itemBuilder: (context, index) {
            final initiative = initiatives[index];
            return _GlobalInitiativeCard(initiative: initiative);
          },
          itemCount: initiatives.length,
        );
      },
    );
  }
}

class _GlobalInitiativeCard extends StatelessWidget {
  final Initiative initiative;

  const _GlobalInitiativeCard({
    required this.initiative,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: key,
      width: double.infinity, // forces full width
      child: Card(
        // margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: IntrinsicHeight(
          // helps with better vertical alignment
          child: SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditDeleteOptionMenuWidget(context, onDelete: () {
                  GlobalListManager.instance.deleteInitiative(initiative.id);
                }, onEdit: () {
                  DialogHelper.showEditInitiativeDialog(context: context, existingInitiative: initiative);
                }),

                SizedBox(width: 10,),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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

                // _getAddButton(onClick:(){


                AddButtonWithProgress(onClick:()
                {
                  ScheduleManager.instance
                      .addInitiativeIn(SelectedDayManager.currentSelectedWeekDay.value, initiative);

                  showMySnackBar(context, "Initiative Added");
                }),

                SizedBox(width: 10,)

              ],
            ),
          ),
        ),
      ),
    );



  }

  void showMySnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2), // how long it shows
      behavior: SnackBarBehavior.floating,   // makes it float above content
      margin: const EdgeInsets.all(16),     // adds spacing from edges
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: Colors.blue,         // change color if you want
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}



class AddButtonWithProgress extends StatefulWidget {
  final void Function() onClick;

  const AddButtonWithProgress({required this.onClick, super.key});

  @override
  State<AddButtonWithProgress> createState() => _AddButtonWithProgressState();
}

class _AddButtonWithProgressState extends State<AddButtonWithProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset(); // reset after animation
      }
    });
  }

  void _handleTap() {
    widget.onClick();
    _controller.forward(); // start circular animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _controller.value,
                  strokeWidth: 3,
                  color: Colors.blue,
                );
              },
            ),
            // Plus button
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.blue, size: 16,),
            ),
          ],
        ),
      ),
    );
  }
}
