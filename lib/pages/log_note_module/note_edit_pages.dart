import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'note.dart';

class NewNotePage extends StatefulWidget {
  const NewNotePage({super.key});

  @override
  State<NewNotePage> createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  Color _selectedColor = const Color(0xFFFFF4E6);
  final List<Color> _palette = [
    const Color(0xFFFFF4E6),
    const Color(0xFFEFF7FF),
    const Color(0xFFEFFFEF),
    const Color(0xFFFFF1F6),
    const Color(0xFFF3F0FF),
    const Color(0xFFFFFBEB),
  ];
  final List<String> _tags = <String>[];
  final _tagCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardColor,
        elevation: 0.8,
        title: const Text('Create Log'),
        iconTheme: IconThemeData(color: theme.iconTheme.color),
        actions: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  final n = Note(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleCtrl.text.trim().isEmpty
                        ? 'Untitled'
                        : _titleCtrl.text.trim(),
                    content: _contentCtrl.text.trim(),
                    color: _selectedColor,
                    createdAt: DateTime.now(),
                    tags: List<String>.from(_tags),
                  );
                  Navigator.pop(context, n);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 8),
                    Text('Save'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  hintText: 'Title...',
                  border: InputBorder.none,
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Write your log here...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _palette
                            .map(
                              (c) => GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColor = c),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: _selectedColor == c
                                    ? Border.all(
                                  width: 2,
                                  color: theme.primaryColor,
                                )
                                    : null,
                              ),
                              width: 36,
                              height: 36,
                            ),
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: InputDecoration(
                      hintText: 'Add tag and press +',
                      filled: true,
                      fillColor: theme.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    color: theme.colorScheme.onPrimary,
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final t = _tagCtrl.text.trim();
                      if (t.isNotEmpty) {
                        setState(() {
                          _tags.add(t);
                          _tagCtrl.clear();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags
                  .map(
                    (t) => ActionChip(
                  label: Text(t),

                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class NoteDetailPage extends StatelessWidget {
  final Note note;

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditNotePage(note: note),
                ),
              );
              if (updated != null && updated is Note) {
                Navigator.pop(context, {
                  'action': 'updated',
                  'note': updated,
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Log?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context, {'action': 'delete', 'id': note.id});
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: note.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: note.tags
                        .map((t) => Chip(label: Text(t)))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: theme.iconTheme.color?.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  'Created: ${note.createdAt.toLocal().toString().split('.')[0]}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.iconTheme.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  note.content,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, {
                        'action': 'archive',
                        'id': note.id,
                      });
                    },
                    icon: const Icon(Icons.archive),
                    label: Text(note.archived ? 'Unarchive' : 'Archive'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(
                          text: '${note.title}\n\n${note.content}',
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Copied to clipboard'),
                          backgroundColor: theme.primaryColor,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditNotePage extends StatefulWidget {
  final Note note;

  const EditNotePage({super.key, required this.note});

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late Color _selectedColor;
  final List<Color> _palette = [
    const Color(0xFFFFF4E6),
    const Color(0xFFEFF7FF),
    const Color(0xFFEFFFEF),
    const Color(0xFFFFF1F6),
    const Color(0xFFF3F0FF),
    const Color(0xFFFFFBEB),
  ];
  late List<String> _tags;
  final _tagCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _selectedColor = widget.note.color;
    _tags = List<String>.from(widget.note.tags);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Log'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              final updated = Note(
                id: widget.note.id,
                title: _titleCtrl.text.trim().isEmpty
                    ? 'Untitled'
                    : _titleCtrl.text.trim(),
                content: _contentCtrl.text.trim(),
                color: _selectedColor,
                createdAt: widget.note.createdAt,
                tags: List<String>.from(_tags),
                pinned: widget.note.pinned,
                archived: widget.note.archived,
              );
              Navigator.pop(context, updated);
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _contentCtrl,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Edit your log...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Wrap(
                      spacing: 8,
                      children: _palette
                          .map(
                            (c) => GestureDetector(
                          onTap: () =>
                              setState(() => _selectedColor = c),
                          child: Container(
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: _selectedColor == c
                                  ? Border.all(
                                width: 2,
                                color: theme.primaryColor,
                              )
                                  : null,
                            ),
                            width: 34,
                            height: 34,
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add tag',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final t = _tagCtrl.text.trim();
                    if (t.isNotEmpty) {
                      setState(() {
                        _tags.add(t);
                        _tagCtrl.clear();
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _tags
                  .map(
                    (t) => ActionChip(
                  label: Text(t),

                ),
              )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
