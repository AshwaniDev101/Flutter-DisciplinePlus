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

        return ListView.separated(
          itemBuilder: (context, index) {
            final initiative = initiatives[index];
            return _GlobalInitiativeCard(initiative: initiative);
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: initiatives.length,
        );
      },
    );
  }
}

class _GlobalInitiativeCard extends StatelessWidget {
  final Initiative initiative;

  const _GlobalInitiativeCard({required this.initiative,});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: key,
      width: double.infinity, // forces full width
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: IntrinsicHeight(
          // helps with better vertical alignment
          child: SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                EditDeleteOptionMenuWidget(context,
                onDelete: () {
                  GlobalListManager.instance.deleteInitiative(initiative.id);
                },
                onEdit: () {
                  DialogHelper.showEditInitiativeDialog(context: context, existingInitiative: initiative);
                }
            ),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        initiative.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo[700],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: initiative.completionTime.remainingTime(),
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            if (initiative.studyBreak.completionTime.minute != 0)
                              TextSpan(
                                text: "   ${initiative.studyBreak.completionTime.minute}m brk",
                                style: const TextStyle(fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () {
                      ScheduleManager.instance
                          .addInitiativeIn(SelectedDayManager.currentSelectedWeekDay.value, initiative);
                    },
                    icon: Icon(Icons.add))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
