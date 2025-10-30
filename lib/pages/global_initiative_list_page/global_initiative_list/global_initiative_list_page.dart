import 'package:discipline_plus/pages/global_initiative_list_page/global_initiative_list/widgets/global_initiative_listview.dart';
import 'package:flutter/material.dart';
import '../../../../models/initiative.dart';
import '../../../theme/app_colors.dart';
import '../../../widget/new_button.dart';
import '../manager/global_list_manager.dart';
import '../new_initiatives/new_initiative_dialog.dart';


class GlobalInitiativeListPage extends StatefulWidget {

  final String currentWeekDay;

  final Function(Initiative) onAdd;

  const GlobalInitiativeListPage({
    super.key,
    required this.currentWeekDay,
    required this.onAdd
  });

  @override
  State<GlobalInitiativeListPage> createState() => _GlobalInitiativeListPageState();
}

class _GlobalInitiativeListPageState extends State<GlobalInitiativeListPage> {
  @override
  Widget build(BuildContext context) {


    // final vm = context.watch<ScheduleViewModel>();

    return Scaffold(
        appBar: AppBar(
          title: Text("Add to '${widget.currentWeekDay}'",style: AppTextStyle.appBarTextStyle,),
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.appbarContent),
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


            )
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top:0,bottom: 0,left: 4,right: 4),
                  child: GlobalInitiativeListview(
                                onAdd: widget.onAdd,
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
                              ),
                ))
          ],
        )));
  }
}
