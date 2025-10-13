import 'package:flutter/material.dart';
import '../../../models/initiative.dart';
import '../../../models/app_time.dart';
import '../../../models/study_break.dart';
import 'widget/quantity_selector.dart';

class InitiativeDialog extends StatefulWidget {
  final Initiative? existing_initiative;
  final void Function(Initiative newInitiative) onNewSave;
  final void Function(Initiative newInitiative) onEditSave;

  const InitiativeDialog({
    super.key,
    this.existing_initiative,
    required this.onNewSave,
    required this.onEditSave,
  });

  @override
  _InitiativeDialogState createState() => _InitiativeDialogState();
}

class _InitiativeDialogState extends State<InitiativeDialog> {
  final TextEditingController _titleCtrl = TextEditingController();
  int _duration = 30;
  int _break = 15;

  @override
  void initState() {
    super.initState();
    if (widget.existing_initiative != null) {
      _titleCtrl.text = widget.existing_initiative!.title;
      _duration = widget.existing_initiative!.completionTime.minute;
      _break = widget.existing_initiative!.studyBreak.completionTime.minute;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _save() {



    final init = Initiative(

      id: widget.existing_initiative?.id,
      index: widget.existing_initiative!.index,
      title: _titleCtrl.text,
      completionTime: AppTime(0, _duration),
      studyBreak: StudyBreak(
        title: '$_break min break',
        completionTime: AppTime(0, _break),
      ),
    );

    final isEdit = widget.existing_initiative != null;
    if (isEdit)
      {

        widget.onEditSave(init);
      }else
        {
          widget.onNewSave(init);
        }

  }

  @override
  Widget build(BuildContext c) {
    final isEdit = widget.existing_initiative != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Initiative' : 'New Initiative',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black38)),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'Enter title here',
                hintStyle:
                const TextStyle(color: Colors.black26, fontSize: 16),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4)),
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
        ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Edit' : 'Add')),
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
