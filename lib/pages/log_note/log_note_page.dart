import 'package:flutter/material.dart';

void main() => runApp(LogNoteModule());

class LogNoteModule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notes — Home',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: NotesHomeScreen(),
    );
  }
}

class Note {
  final String title;
  final String content;
  final Color color;
  final DateTime createdAt;
  final List<String> tags;
  final bool pinned;

  Note({
    required this.title,
    required this.content,
    required this.color,
    required this.createdAt,
    this.tags = const [],
    this.pinned = false,
  });
}

class NotesHomeScreen extends StatefulWidget {
  @override
  _NotesHomeScreenState createState() => _NotesHomeScreenState();
}

class _NotesHomeScreenState extends State<NotesHomeScreen> {
  int _selectedIndex = 0;

  final List<Note> sampleNotes = [
    Note(
      title: 'Grocery',
      content:
          'Milk, eggs, paneer, tomatoes. Try to buy low-fat milk and fresh spinach. Also check for discounts on oats and peanut butter.',
      color: Color(0xFFFFF4E6),
      createdAt: DateTime.now().subtract(Duration(hours: 3)),
      tags: ['shopping', 'today'],
      pinned: true,
    ),
    Note(
      title: 'RestFul API',
      content:
          'Discuss API design. Keep endpoints RESTful. Auth with JWT and refresh tokens. Database schema v2 should include version field.',
      color: Color(0xFFEFFFEF),
      createdAt: DateTime.now().subtract(Duration(days: 2, hours: 4)),
      tags: ['meeting'],
    ),
    Note(
      title: 'Time Table',
      content:
          'Day 1: Arrive and explore local market. Day 2: Heritage walk and museum. Reserve train tickets before 10 AM.',
      color: Color(0xFFFFF1F6),
      createdAt: DateTime.now().subtract(Duration(days: 5)),
      tags: ['personal', 'travel'],
    ),
    Note(
      title: 'App Ideas',
      content: 'Idea — Dark mode toggle with dynamic palette.',
      color: Color(0xFFF3F0FF),
      createdAt: DateTime.now().subtract(Duration(minutes: 50)),
    ),
    Note(
      title: 'Dinner',
      content: 'Marinate paneer with hung curd, turmeric, chili powder, garam masala. Grill at high heat for char.',
      color: Color(0xFFFFFBEB),
      createdAt: DateTime.now().subtract(Duration(days: 10)),
      tags: ['food'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: SizedBox(
        height: 64,
        width: 64,
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NewNotePage())),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Icon(Icons.add, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: buildBottomBar(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return buildNotesGrid();
      case 1:
        return ArchivePage(notes: sampleNotes);
      case 2:
        return TagsPage(notes: sampleNotes);
      case 3:
        return SettingsPage();
      default:
        return buildNotesGrid();
    }
  }

  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 80,
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.notes, color: Colors.indigo),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Notes', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700)),
              SizedBox(height: 4),
              Text('${sampleNotes.length} logs', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          )
        ],
      ),
      actions: [
        IconButton(onPressed: () {}, icon: Icon(Icons.search, color: Colors.black87)),
        IconButton(onPressed: () {}, icon: Icon(Icons.more_vert, color: Colors.black54)),
      ],
    );
  }

  Widget buildTopSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: Offset(0, 4)),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search logs, tags, text...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(width: 4),
                ChoiceChip(label: Text('All'), selected: true, onSelected: (_) {}),
                SizedBox(width: 8),
                ChoiceChip(label: Text('Pinned'), selected: false, onSelected: (_) {}),
                SizedBox(width: 8),
                ChoiceChip(label: Text('Work'), selected: false, onSelected: (_) {}),
                SizedBox(width: 8),
                ChoiceChip(label: Text('Personal'), selected: false, onSelected: (_) {}),
                SizedBox(width: 8),
                ChoiceChip(label: Text('Ideas'), selected: false, onSelected: (_) {}),
                SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotesGrid() {
    // Separate pinned notes to show first
    final pinned = sampleNotes.where((n) => n.pinned).toList();
    final others = sampleNotes.where((n) => !n.pinned).toList();
    final all = [...pinned, ...others];

    return Column(
      children: [
        buildTopSection(context),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            int crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;
            double crossAxisSpacing = 12;
            double mainAxisSpacing = 12;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8),
              child: GridView.builder(
                itemCount: all.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final note = all[index];
                  return noteCard(note);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget noteCard(Note note) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoteDetailPage(note: note)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: note.color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: Offset(0, 6)),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.02)),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(note.pinned ? Icons.push_pin : Icons.circle_outlined, size: 18, color: Colors.black54),
                ],
              ),
              SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content,
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (var tag in note.tags)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(tag, style: TextStyle(fontSize: 11)),
                        ),
                    ],
                  ),
                  Text(
                    timeAgo(note.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                ],
              )
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
      color: Colors.white,
      shape: CircularNotchedRectangle(),
      notchMargin: 10,
      elevation: 8,
      child: Container(
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side icons
            Row(
              children: [
                _buildBarItem(Icons.home, 0, label: 'Home'),
                SizedBox(width: 6),
                _buildBarItem(Icons.archive, 1, label: 'Archive'),
              ],
            ),
            // Right side icons
            Row(
              children: [
                _buildBarItem(Icons.label_outline, 2, label: 'Tags'),
                SizedBox(width: 6),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: isSelected
              ? BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 48, maxWidth: 84),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: isSelected ? Colors.indigo : Colors.black54),
                if (label != null) SizedBox(height: 4),
                if (label != null)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: TextStyle(fontSize: 11, color: isSelected ? Colors.indigo : Colors.black54),
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

// --- Pages: NewNote, NoteDetail, EditNote, Archive, Tags, Settings ---

class NewNotePage extends StatefulWidget {
  @override
  _NewNotePageState createState() => _NewNotePageState();
}

class _NewNotePageState extends State<NewNotePage> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  Color _selectedColor = Color(0xFFFFF4E6);
  final List<Color> _palette = [
    Color(0xFFFFF4E6),
    Color(0xFFEFF7FF),
    Color(0xFFEFFFEF),
    Color(0xFFFFF1F6),
    Color(0xFFF3F0FF),
    Color(0xFFFFFBEB),
    Color(0xFFEFFFEF),
    Color(0xFFFFF1F6),
    Color(0xFFF3F0FF),
    Color(0xFFFFFBEB)
  ];
  final _tags = <String>[];
  final _tagCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.8,
        title: Text('Create Log', style: TextStyle(color: Colors.black)),
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Row(children: [Icon(Icons.check), SizedBox(width: 8), Text('Save')]),
              ),
              SizedBox(width: 20,)
            ],
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Title...',
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: TextField(
                  controller: _contentCtrl,
                  decoration: InputDecoration(
                    hintText: 'Write your log here...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                ),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Row(children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _palette
                          .map((c) => GestureDetector(
                                onTap: () => setState(() => _selectedColor = c),
                                child: Container(
                                  margin: EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: _selectedColor == c ? Border.all(width: 2, color: Colors.indigo) : null,
                                  ),
                                  width: 36,
                                  height: 36,
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                // SizedBox(width: 12),
                // ElevatedButton(
                //   onPressed: () {
                //     Navigator.pop(context);
                //   },
                //   style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                //   child: Row(children: [Icon(Icons.check), SizedBox(width: 8), Text('Save')]),
                // )
              ]),
            ),
            SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _tagCtrl,
                  decoration: InputDecoration(
                      hintText: 'Add tag and press +',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(color: Colors.indigo, borderRadius: BorderRadius.circular(8)),
                child: IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.add),
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
              )
            ]),
            SizedBox(height: 8),
            Wrap(spacing: 8, children: _tags.map((t) => Chip(label: Text(t))).toList())
          ],
        ),
      ),
    );
  }
}

class NoteDetailPage extends StatelessWidget {
  final Note note;

  NoteDetailPage({required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditNotePage(note: note))),
          ),
          IconButton(icon: Icon(Icons.delete_outline), onPressed: () => Navigator.pop(context)),
        ],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: note.color, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(note.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 6, children: note.tags.map((t) => Chip(label: Text(t))).toList()),
            ]),
          ),
          SizedBox(height: 12),
          Row(children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey[700]),
            SizedBox(width: 8),
            Text('Created: ${note.createdAt.toLocal().toString().split('.').first}',
                style: TextStyle(color: Colors.grey[700])),
          ]),
          SizedBox(height: 16),
          Expanded(child: SingleChildScrollView(child: Text(note.content, style: TextStyle(fontSize: 16)))),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.archive),
                  label: Text('Archive'),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.share),
                  label: Text('Share'),
                ),
              ),
            ],
          )
        ]),
      ),
    );
  }
}

class EditNotePage extends StatefulWidget {
  final Note note;

  EditNotePage({required this.note});

  @override
  _EditNotePageState createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late Color _selectedColor;
  final List<Color> _palette = [
    Color(0xFFFFF4E6),
    Color(0xFFEFF7FF),
    Color(0xFFEFFFEF),
    Color(0xFFFFF1F6),
    Color(0xFFF3F0FF),
    Color(0xFFFFFBEB)
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note.title);
    _contentCtrl = TextEditingController(text: widget.note.content);
    _selectedColor = widget.note.color;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Log'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: InputDecoration(hintText: 'Title')),
            SizedBox(height: 12),
            Expanded(
                child: TextField(
                    controller: _contentCtrl,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(hintText: 'Edit your log...'))),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    children: _palette
                        .map((c) => GestureDetector(
                              onTap: () => setState(() => _selectedColor = c),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: _selectedColor == c ? Border.all(width: 2, color: Colors.indigo) : null,
                                ),
                                width: 34,
                                height: 34,
                              ),
                            ))
                        .toList(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text('Save'),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ArchivePage extends StatelessWidget {
  final List<Note> notes;

  ArchivePage({required this.notes});

  @override
  Widget build(BuildContext context) {
    final archived = notes.length >= 2 ? notes.sublist(notes.length - 2) : <Note>[];
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: archived.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.archive, size: 72, color: Colors.grey[400]),
                    SizedBox(height: 12),
                    Text('No archived logs', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                    SizedBox(height: 8),
                    Text(
                        'Archive logs you no longer need in the main list. They will remain here until restored or deleted.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: archived.length,
                separatorBuilder: (_, __) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final n = archived[index];
                  return ListTile(
                    tileColor: n.color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    title: Text(n.title, style: TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(icon: Icon(Icons.unarchive), onPressed: () {}),
                  );
                },
              ),
      ),
    );
  }
}

class TagsPage extends StatefulWidget {
  final List<Note> notes;

  TagsPage({required this.notes});

  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  final _newTagCtrl = TextEditingController();
  late Map<String, int> counts;

  @override
  void initState() {
    super.initState();
    counts = {};
    for (var n in widget.notes) {
      for (var t in n.tags) counts[t] = (counts[t] ?? 0) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = counts.keys.toList();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Tags', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.label_outline, size: 16, color: Colors.indigo),
                SizedBox(width: 6),
                Text('${tags.length}')
              ]),
            )
          ]),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _newTagCtrl, decoration: InputDecoration(hintText: 'Create a tag'))),
            SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final t = _newTagCtrl.text.trim();
                if (t.isNotEmpty)
                  setState(() {
                    counts[t] = (counts[t] ?? 0) + 0;
                    _newTagCtrl.clear();
                  });
              },
              child: Text('Add'),
            )
          ]),
          SizedBox(height: 16),
          Expanded(
            child: tags.isEmpty
                ? Center(child: Text('No tags created yet', style: TextStyle(color: Colors.grey[700])))
                : GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                        childAspectRatio: 3.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12),
                    itemCount: tags.length,
                    itemBuilder: (context, index) {
                      final t = tags[index];
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)]),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Row(children: [
                            CircleAvatar(radius: 18, child: Text(t[0].toUpperCase())),
                            SizedBox(width: 12),
                            Text(t, style: TextStyle(fontWeight: FontWeight.w600)),
                          ]),
                          Text('${counts[t]}', style: TextStyle(color: Colors.grey[700]))
                        ]),
                      );
                    },
                  ),
          )
        ]),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  double _fontSize = 16;
  bool _sync = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.indigo.shade500, Colors.indigo.shade300]),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 32)),
              SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Ashwani yadav', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('ashwani10101@gmail.come', style: TextStyle(color: Colors.white70)),
              ])
            ]),
          ),
          SizedBox(height: 18),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(children: [
                SwitchListTile(
                  title: Text('Dark mode'),
                  subtitle: Text('Toggle app appearance'),
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                ListTile(
                  title: Text('Font size'),
                  subtitle: Slider(
                      value: _fontSize,
                      min: 12,
                      max: 22,
                      divisions: 5,
                      label: '${_fontSize.round()}',
                      onChanged: (v) => setState(() => _fontSize = v)),
                ),
                SwitchListTile(
                  title: Text('Auto-sync'),
                  subtitle: Text('Backup notes to cloud'),
                  value: _sync,
                  onChanged: (v) => setState(() => _sync = v),
                ),
              ]),
            ),
          ),
          SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(children: [
              ListTile(leading: Icon(Icons.info_outline), title: Text('About'), subtitle: Text('Version 1.0.0')),
              Divider(height: 1),
              ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('Privacy & security'),
                  subtitle: Text('Manage data and permissions')),
              Divider(height: 1),
              ListTile(leading: Icon(Icons.logout), title: Text('Sign out'), onTap: () {}),
            ]),
          ),
        ],
      ),
    );
  }
}
