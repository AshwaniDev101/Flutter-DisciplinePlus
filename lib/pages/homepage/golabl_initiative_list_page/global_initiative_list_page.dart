
import 'package:discipline_plus/pages/homepage/golabl_initiative_list_page/widget/global_initiative_listview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../managers/selected_day_manager.dart';
import '../../../../models/initiative.dart';
import '../dialog_helper.dart';
import '../schedule_handler/schedule_manager.dart';
import 'global_list_manager.dart';
import 'new_initiatives/new_initiative_dialog.dart';


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
          title: Text("Add tasks to '${SelectedDayManager.currentSelectedWeekDay.value}'"),
          actions: [
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => DialogHelper.showAddInitiativeDialog(context: context),
          child: Text("new"),
        ),
        body: SafeArea(child: Column(
          children: [
            Expanded(child: GlobalInitiativeListview())
          ],
        ))
    );
  }

}
