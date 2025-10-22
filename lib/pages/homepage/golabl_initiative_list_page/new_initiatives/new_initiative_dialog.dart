import 'package:flutter/material.dart';

import '../../../../models/app_time.dart';
import '../../../../models/initiative.dart';
import '../../../../models/study_break.dart';
import 'widget/quantity_selector.dart';

class NewInitiativeDialog extends StatefulWidget {
  final Initiative? existingInitiative;
  final void Function(Initiative newInitiative)? onNewSave;
  final void Function(Initiative newInitiative)? onEditSave;

  // const NewInitiativeDialog({
//   super.key,
//   this.existing_initiative,
//   required this.onNewSave,
//   required this.onEditSave,
// });

  const NewInitiativeDialog.save({
    super.key,
    required this.onNewSave,
  })  : existingInitiative = null,
        onEditSave = null,
        assert(onNewSave != null, "onNewSave is required");

  const NewInitiativeDialog.edit({
    super.key,
    required this.existingInitiative,
    required this.onEditSave,
  })  : onNewSave = null,
        assert(onEditSave != null, "onEditSave is required");

  @override
  _NewInitiativeDialogState createState() => _NewInitiativeDialogState();
}

class _NewInitiativeDialogState extends State<NewInitiativeDialog> {
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
    );


    if (widget.onEditSave!=null) {
      widget.onEditSave!(init);
    } else {
      widget.onNewSave!(init);
    }
  }


  @override
  Widget build(BuildContext c) {

    return AlertDialog(
      title: Text(widget.onEditSave!=null ? 'Edit Initiative' : 'New Initiative',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black38)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: Colors.black45, fontSize: 22, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Enter title here',
                hintStyle: const TextStyle(color: Colors.black26, fontSize: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
              ),
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
        TextButton(onPressed: () => Navigator.of(c).pop(), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: Text(widget.onEditSave!=null ? 'Edit' : 'Add')),
      ],
    );
  }

  Widget _selectorRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black26, fontSize: 16)),
        QuantitySelector(initialValue: value, initialStep: 5, onChanged: onChanged),
      ],
    );
  }
}
