import 'package:flutter/material.dart';
import 'note.dart';
import 'app_settings.dart';
import 'shared_preferences_manager.dart';

class ArchivePage extends StatelessWidget {
  final List<Note> notes;
  final void Function(String id) onRestore;

  const ArchivePage({
    super.key,
    required this.notes,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final archived = notes.where((n) => n.archived).toList();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: archived.isEmpty
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.archive,
                size: 72,
                color: theme.iconTheme.color?.withOpacity(0.4),
              ),
              const SizedBox(height: 12),
              Text(
                'No archived logs',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.iconTheme.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Archive logs you no longer need in the main list. They will remain here until restored or deleted.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.iconTheme.color?.withOpacity(0.6),
                ),
              ),
            ],
          ),
        )
            : ListView.separated(
          itemCount: archived.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final n = archived[index];
            return Container(
              decoration: BoxDecoration(
                color: n.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  n.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  n.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.unarchive),
                  onPressed: () => onRestore(n.id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TagsPage extends StatefulWidget {
  final List<Note> notes;

  const TagsPage({super.key, required this.notes});

  @override
  State<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  final _newTagCtrl = TextEditingController();
  late Map<String, int> counts;

  @override
  void initState() {
    super.initState();
    _updateCounts();
  }

  void _updateCounts() {
    counts = <String, int>{};
    for (final n in widget.notes) {
      for (final t in n.tags) {
        counts[t] = (counts[t] ?? 0) + 1;
      }
    }
  }

  @override
  void didUpdateWidget(TagsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.notes != widget.notes) {
      _updateCounts();
    }
  }

  @override
  void dispose() {
    _newTagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tags = counts.keys.toList();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tags',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.label_outline,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text('${tags.length}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagCtrl,
                    decoration: InputDecoration(
                      hintText: 'Create a new tag',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final t = _newTagCtrl.text.trim();
                    if (t.isNotEmpty && !counts.containsKey(t)) {
                      setState(() {
                        counts[t] = 0;
                        _newTagCtrl.clear();
                      });
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tags.isEmpty
                  ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 72,
                      color: theme.iconTheme.color?.withOpacity(0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No tags created yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.iconTheme.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add tags when creating or editing notes. They will appear here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.iconTheme.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              )
                  : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                  MediaQuery.of(context).size.width > 600 ? 4 : 2,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final t = tags[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: theme.primaryColor.withOpacity(0.1),
                              child: Text(
                                t[0].toUpperCase(),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${counts[t]}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.iconTheme.color?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  final ValueNotifier<AppSettings> settingsNotifier;

  const SettingsPage({super.key, required this.settingsNotifier});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _darkMode;
  late double _fontSize;
  late bool _sync;

  @override
  void initState() {
    super.initState();
    final settings = widget.settingsNotifier.value;
    _darkMode = settings.darkMode;
    _fontSize = settings.fontSize;
    _sync = settings.autoSync;
  }

  Future<void> _updateSettings() async {
    final newSettings = AppSettings(
      darkMode: _darkMode,
      fontSize: _fontSize,
      autoSync: _sync,
    );
    await LogNotePrefsManager.saveSettings(newSettings);
    widget.settingsNotifier.value = newSettings;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColorLight,
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ashwani yadav',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'ashwani10101@gmail.com',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Dark mode'),
                    subtitle: const Text('Toggle app appearance'),
                    value: _darkMode,
                    onChanged: (v) async {
                      setState(() => _darkMode = v);
                      await _updateSettings();
                    },
                  ),
                  ListTile(
                    title: const Text('Font size'),
                    subtitle: Slider(
                      value: _fontSize,
                      min: 12,
                      max: 22,
                      divisions: 5,
                      label: '${_fontSize.round()}',
                      onChanged: (v) async {
                        setState(() => _fontSize = v);
                        await _updateSettings();
                      },
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Auto-sync'),
                    subtitle: const Text('Backup notes to cloud'),
                    value: _sync,
                    onChanged: (v) async {
                      setState(() => _sync = v);
                      await _updateSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  subtitle: Text('Version 1.0.0'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text('Privacy & security'),
                  subtitle: Text('Manage data and permissions'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign out'),
                  onTap: () {
                    // TODO: Implement sign out
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
