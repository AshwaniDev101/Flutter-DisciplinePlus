import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../models/app_time.dart';
import '../../../../models/initiative.dart';
import '../../../../models/study_break.dart';
import 'widget/quantity_selector.dart';

class DialogHelper {
  static void showAddInitiativeDialog(
      {required BuildContext context, required Function(Initiative newInitiative) onNew}) {
    showDialog(
        context: context,
        builder: (_) => _NewInitiativeDialogWidget.save(onNewSave: (newInitiative) {
              onNew(newInitiative);

              Navigator.of(context).pop();
            }));
  }

  static void showEditInitiativeDialog(
      {required BuildContext context,
      Initiative? existingInitiative,
      required Function(Initiative newInitiative) onEdit}) {
    showDialog(
      context: context,
      builder: (_) => _NewInitiativeDialogWidget.edit(
          existingInitiative: existingInitiative,
          onEditSave: (editedInitiative) {
            onEdit(editedInitiative);

            Navigator.of(context).pop();
          }),
    );
  }
}

class _NewInitiativeDialogWidget extends StatefulWidget {
  final Initiative? existingInitiative;
  final void Function(Initiative newInitiative)? onNewSave;
  final void Function(Initiative newInitiative)? onEditSave;

  const _NewInitiativeDialogWidget.save({
    required this.onNewSave,
  })  : existingInitiative = null,
        onEditSave = null,
        assert(onNewSave != null, "onNewSave is required");

  const _NewInitiativeDialogWidget.edit({
    required this.existingInitiative,
    required this.onEditSave,
  })  : onNewSave = null,
        assert(onEditSave != null, "onEditSave is required");

  @override
  _NewInitiativeDialogWidgetState createState() => _NewInitiativeDialogWidgetState();
}

class _NewInitiativeDialogWidgetState extends State<_NewInitiativeDialogWidget> {
  final TextEditingController _titleCtrl = TextEditingController();
  int _duration = 30;
  int _break = 15;

  @override
  void initState() {
    super.initState();
    if (widget.existingInitiative != null) {
      _titleCtrl.text = widget.existingInitiative!.title;
      _duration = widget.existingInitiative!.completionTime.minute;
      _break = widget.existingInitiative!.studyBreak.completionTime.minute;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final init = Initiative(
      id: widget.existingInitiative?.id,
      index: widget.existingInitiative?.index ?? 0,
      title: _titleCtrl.text,
      completionTime: AppTime(0, _duration),
      studyBreak: StudyBreak(
        title: '$_break min break',
        completionTime: AppTime(0, _break),
      ),
      timestamp: Timestamp.now(),
    );

    if (widget.onEditSave != null) {
      widget.onEditSave!(init);
    } else {
      widget.onNewSave!(init);
    }
  }

  @override
  Widget build(BuildContext c) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            widget.onEditSave != null ? Icons.edit_note_rounded : Icons.add_card,
            color: Colors.grey[500],
          ),
          SizedBox(
            width: 5,
          ),
          Text(widget.onEditSave != null ? 'Edit Initiative' : 'New Initiative',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black38)),
        ],
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              style: TextStyle(color: Colors.grey[500], fontSize: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  hintText: 'Enter title here',
                  hintStyle: const TextStyle(color: Colors.black26, fontSize: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  )),
            ),
            const SizedBox(height: 10),
            _selectorRow('Duration', _duration, (v) => setState(() => _duration = v)),
            const Divider(),
            _selectorRow('Break', _break, (v) => setState(() => _break = v)),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Cancel',style: TextStyle(color: Colors.blue),)),
        ElevatedButton(onPressed: _save, child: Text(widget.onEditSave != null ? 'Save' : 'Add', style: TextStyle(color: Colors.blue),)),
      ],
    );
  }

  Widget _selectorRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        QuantitySelector(initialValue: value, initialStep: 5, onChanged: onChanged),
      ],
    );
  }
}
