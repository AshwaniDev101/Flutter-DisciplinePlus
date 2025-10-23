
import 'package:flutter/material.dart';

class EditDeleteOptionMenu extends StatelessWidget {
  final Function() onEdit;
  final Function() onDelete;

  const EditDeleteOptionMenu({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();

    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        final RenderBox button = key.currentContext!.findRenderObject() as RenderBox;
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

        final position = RelativeRect.fromRect(
          Rect.fromPoints(
            button.localToGlobal(Offset.zero, ancestor: overlay),
            button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
          ),
          Offset.zero & overlay.size,
        );

        final selected = await showMenu<String>(
          context: context,
          position: position,
          items: const [
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.blue),
                  SizedBox(width: 6),
                  Text('Edit', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 16, color: Colors.red),
                  SizedBox(width: 6),
                  Text('Delete', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        );

        if (selected == 'edit') onEdit();
        if (selected == 'delete') onDelete();
      },
      child: const SizedBox(
        width: 20,
        height: 20,
        child: Icon(Icons.more_vert_rounded, color: Colors.grey, size: 20),
      ),
    );
  }
}
