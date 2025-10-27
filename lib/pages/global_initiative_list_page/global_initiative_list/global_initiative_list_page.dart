import 'package:discipline_plus/pages/global_initiative_list_page/global_initiative_list/widgets/global_initiative_listview.dart';
import 'package:flutter/material.dart';
import '../../../../models/initiative.dart';

import '../../../theme/app_colors.dart';
import '../../../widget/new_button.dart';
import '../../schedule_page/manager/schedule_manager.dart';
import '../manager/global_list_manager.dart';
import '../new_initiatives/new_initiative_dialog.dart';


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
          title: Text("Add to '${ScheduleManager.instance.currentWeekDay}'",style: AppStyle.appBarTextStyle,),
          iconTheme: IconThemeData(color: AppColors.appbarIcon),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: NewButton(
                label: 'New',
                onPressed: () {
                  DialogHelper.showAddInitiativeDialog(
                    context: context,
                    onNew: (newInitiative) {
                      GlobalListManager.instance.addInitiative(newInitiative);
                    },
                  );
                },
              ),

              // child: TextButton(
              //   onPressed: () {
              //     DialogHelper.showAddInitiativeDialog(
              //       context: context,
              //       onNew: (newInitiative) {
              //         GlobalListManager.instance.addInitiative(newInitiative);
              //       },
              //     );
              //   },
              //   style: TextButton.styleFrom(
              //     backgroundColor: Colors.tealAccent.shade400,
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(20),
              //     ),
              //     shadowColor: Colors.tealAccent.shade100,
              //     elevation: 3,
              //   ),
              //   child: const Text(
              //     'New',
              //     style: TextStyle(
              //       fontWeight: FontWeight.w600,
              //       fontSize: 14,
              //       letterSpacing: 0.5,
              //     ),
              //   ),
              // ),


            )
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: GlobalInitiativeListview(
              onAdd: (initiative) {
                ScheduleManager.instance.addInitiativeIn(ScheduleManager.instance.currentWeekDay, initiative.id);
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
