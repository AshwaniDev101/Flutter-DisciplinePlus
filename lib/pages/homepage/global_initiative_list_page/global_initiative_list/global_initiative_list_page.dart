import 'package:discipline_plus/pages/homepage/global_initiative_list_page/global_initiative_list/widgets/global_initiative_listview.dart';
import 'package:flutter/material.dart';
import '../../../../../managers/selected_day_manager.dart';
import '../../../../models/initiative.dart';
import '../../schedule_handler/schedule_manager.dart';
import '../new_initiatives/new_initiative_dialog.dart';
import 'global_list_manager.dart';

class GlobalInitiativeListPage extends StatefulWidget {
  const GlobalInitiativeListPage({
    super.key,
  });

  @override
  State<GlobalInitiativeListPage> createState() => _GlobalInitiativeListPageState();
}

class _GlobalInitiativeListPageState extends State<GlobalInitiativeListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Add to '${SelectedDayManager.currentSelectedWeekDay.value}'"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: TextButton(
                onPressed: () {
                  DialogHelper.showAddInitiativeDialog(
                      context: context,
                      onNew: (newInitiative) {
                        GlobalListManager.instance.addInitiative(
                          newInitiative,
                        );
                      });
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  // bright background
                  foregroundColor: Colors.white,
                  // text color
                  // padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // rounded corners
                  ),
                  shadowColor: Colors.blueAccent,
                  elevation: 1, // gives subtle shadow
                ),
                child: const Text(
                  'New',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: GlobalInitiativeListview(
              onAdd: (initiative) {
                ScheduleManager.instance
                    .addInitiativeIn(SelectedDayManager.currentSelectedWeekDay.value, initiative.id);
              },
              onEdit: (initiative) {
                DialogHelper.showEditInitiativeDialog(
                    context: context,
                    existingInitiative: initiative,
                    onEdit: (Initiative editedInitiative) {
                      GlobalListManager.instance.updateInitiative(
                        editedInitiative,
                      );
                    });
              },
              onDelete: (initiative) {
                GlobalListManager.instance.deleteInitiative(initiative.id);
              },
            ))
          ],
        )));
  }
}
