import 'package:flutter/material.dart';
import 'note.dart';
import 'app_settings.dart';
import 'note_edit_pages.dart';
import 'log_note_sub_pages.dart';
import 'shared_preferences_manager.dart';

class NotesHomeScreen extends StatefulWidget {
  final ValueNotifier<AppSettings> settingsNotifier;

  const NotesHomeScreen({super.key, required this.settingsNotifier});

  @override
  _NotesHomeScreenState createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  int _selectedIndex = 0;
  List<Note> notes = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> get _filteredNotes {
    final visibleNotes = notes.where((n) => !n.archived).toList();
    if (_searchQuery.isEmpty) {
      final pinned = visibleNotes.where((n) => n.pinned).toList();
      final others = visibleNotes.where((n) => !n.pinned).toList();
      return [...pinned, ...others];
    } else {
      final query = _searchQuery.toLowerCase();
      return visibleNotes
          .where((n) =>
      n.title.toLowerCase().contains(query) ||
          n.content.toLowerCase().contains(query) ||
          n.tags.any((tag) => tag.toLowerCase().contains(query)))
          .toList();
    }
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await LogNotePrefsManager.getNotes();
    if (loadedNotes.isEmpty) {
      // Seed with sample notes if none exist
      notes = [
        Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Grocery',
          content: 'Milk, eggs, paneer, tomatoes. Try to buy low-fat milk and fresh spinach.',
          color: const Color(0xFFFFF4E6),
          createdAt: DateTime.now().subtract(const Duration(hours: 3)),
          tags: const ['shopping', 'today'],
          pinned: true,
        ),
        Note(
          id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          title: 'RestFul API',
          content: 'Discuss API design. Keep endpoints RESTful.',
          color: const Color(0xFFEFFFEF),
          createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
          tags: const ['meeting'],
        ),
      ];
      await _saveNotes();
    } else {
      notes = loadedNotes;
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveNotes() async {
    await LogNotePrefsManager.saveNotes(notes);
  }

  void _addNote(Note n) {
    setState(() {
      notes.insert(0, n);
    });
    _saveNotes();
  }

  void _updateNote(Note updated) {
    final i = notes.indexWhere((n) => n.id == updated.id);
    if (i != -1) {
      setState(() => notes[i] = updated);
      _saveNotes();
    }
  }

  void _deleteNoteById(String id) {
    setState(() => notes.removeWhere((n) => n.id == id));
    _saveNotes();
  }

  void _toggleArchive(String id) {
    final i = notes.indexWhere((n) => n.id == id);
    if (i != -1) {
      final n = notes[i];
      setState(() {
        notes[i] = Note(
          id: n.id,
          title: n.title,
          content: n.content,
          color: n.color,
          createdAt: n.createdAt,
          tags: n.tags,
          pinned: n.pinned,
          archived: !n.archived,
        );
      });
      _saveNotes();
    }
  }

  void _togglePin(String id) {
    final i = notes.indexWhere((n) => n.id == id);
    if (i != -1) {
      final n = notes[i];
      setState(() {
        notes[i] = Note(
          id: n.id,
          title: n.title,
          content: n.content,
          color: n.color,
          createdAt: n.createdAt,
          tags: n.tags,
          pinned: !n.pinned,
          archived: n.archived,
        );
      });
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: () async {
            final newNote = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewNotePage(),
                fullscreenDialog: true,
              ),
            );
            if (newNote != null && newNote is Note) _addNote(newNote);
          },
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _loading
            ? const Center(child: CircularProgressIndicator())
            : buildNotesGrid();
      case 1:
        return ArchivePage(
          notes: notes,
          onRestore: _toggleArchive,
        );
      case 2:
        return TagsPage(notes: notes);
      case 3:
        return SettingsPage(
          settingsNotifier: widget.settingsNotifier,
        );
      default:
        return buildNotesGrid();
    }
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 80,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notes,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Log Notes',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${notes.length} logs',
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.54),
          ),
        ),
      ],
    );
  }

  Widget buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.54),
                ),
                hintText: 'Search logs, tags, text...',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const SizedBox(width: 4),
                ChoiceChip(
                  label: const Text('All'),
                  selected: true,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Pinned'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Work'),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotesGrid() {
    return Column(
      children: [
        buildTopSection(context),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
                child: GridView.builder(
                  itemCount: _filteredNotes.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (context, index) {
                    final note = _filteredNotes[index];
                    return noteCard(note);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget noteCard(Note note) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailPage(note: note),
            ),
          );
          if (res != null && res is Map<String, dynamic>) {
            final action = res['action'] as String?;
            final id = res['id'] as String?;
            final Note? updated = res['note'] as Note?;
            switch (action) {
              case 'delete':
                if (id != null) _deleteNoteById(id);
                break;
              case 'archive':
                if (id != null) _toggleArchive(id);
                break;
              case 'toggle_pin':
                if (id != null) _togglePin(id);
                break;
              case 'updated':
                if (updated != null) _updateNote(updated);
                break;
            }
          }
          setState(() {});
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: note.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor,
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 0.5,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _togglePin(note.id),
                    child: Icon(
                      note.pinned ? Icons.push_pin : Icons.circle_outlined,
                      size: 18,
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: textTheme.bodyMedium,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final tag in note.tags)
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tag,
                            style: textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    timeAgo(note.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  Widget buildBottomBar() {
    return BottomAppBar(
      color: Theme.of(context).cardColor,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 8,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildBarItem(Icons.home, 0, label: 'Home'),
                const SizedBox(width: 6),
                _buildBarItem(Icons.archive, 1, label: 'Archive'),
              ],
            ),
            Row(
              children: [
                _buildBarItem(Icons.label_outline, 2, label: 'Tags'),
                const SizedBox(width: 6),
                _buildBarItem(Icons.settings, 3, label: 'Settings'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarItem(IconData icon, int index, {String? label}) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: isSelected
              ? BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          )
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 48, maxWidth: 84),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? theme.primaryColor
                      : theme.iconTheme.color?.withOpacity(0.54),
                ),
                if (label != null) const SizedBox(height: 4),
                if (label != null)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.iconTheme.color?.withOpacity(0.54),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
