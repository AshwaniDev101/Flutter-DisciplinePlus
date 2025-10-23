import 'package:flutter/material.dart';

import '../../models/initiative.dart';
import 'golabl_initiative_list_page/global_initiative_list/global_list_manager.dart';

import 'golabl_initiative_list_page/new_initiatives/new_initiative_dialog.dart';

class DialogHelper {

  /// Todo you might wanna use a call back function here to get the edited initiative
  static void showAddInitiativeDialog({required BuildContext context}) {
    showDialog(
        context: context,
        builder: (_) => NewInitiativeDialog.save(onNewSave: (newInitiative) {
              // print("==== On Save called");
              GlobalListManager.instance.addInitiative(
                newInitiative,
              );
              // print("data saved ===============");
              Navigator.of(context).pop();
            }));
  }

  /// Todo you might wanna use a call back function here to get the edited initiative
  static void showEditInitiativeDialog({required BuildContext context, Initiative? existingInitiative}) {
    showDialog(
      context: context,
      builder: (_) => NewInitiativeDialog.edit(
          existingInitiative: existingInitiative,
          onEditSave: (editedInitiative) {
            // print("==== On Edit called");
            GlobalListManager.instance.updateInitiative(
              editedInitiative,
            );
            Navigator.of(context).pop();
          }),
    );
  }
}
