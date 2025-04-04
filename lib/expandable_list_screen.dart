import 'package:flutter/material.dart';

class ExpandableListScreen extends StatefulWidget {
  @override
  _ExpandableListScreenState createState() => _ExpandableListScreenState();
}

class _ExpandableListScreenState extends State<ExpandableListScreen> {
  final List<ParentItem> _items = [
    ParentItem(
      title: 'DSA',
      children: [
        ChildItem(title: 'Self-Attempt'),
        ChildItem(title: 'Implementation'),
        ChildItem(title: 'Real-Solution'),
        ChildItem(title: 'Deployment'),
      ],
    ),
    ParentItem(
      title: 'JavaScript',
      children: [
        ChildItem(title: 'Video-1'),
        ChildItem(title: 'Video-2'),
      ],
    ),
    // ... other items
  ];

  void _navigateToTimer(BuildContext context, String title) {
    Navigator.pushNamed(context, '/timer', arguments: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          final parent = _items[index];

          if (parent.children.isEmpty) {
            return ListTile(
              leading: Checkbox(
                value: parent.checked,
                onChanged: (bool? value) {
                  setState(() => _items[index] = parent.copyWith(checked: value));
                },
              ),
              title: Text(parent.title),
              onTap: () => _navigateToTimer(context, parent.title),
            );
          }

          return ExpansionTile(
            leading: Checkbox(
              value: parent.checked,
              onChanged: (bool? value) {
                setState(() => _items[index] = parent.copyWith(checked: value));
              },
            ),
            title: Text(parent.title),
            children: parent.children.map((child) {
              return Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: ListTile(
                  leading: Checkbox(
                    value: child.checked,
                    onChanged: (bool? value) {
                      setState(() {
                        parent.children[parent.children.indexOf(child)] =
                            child.copyWith(checked: value);
                      });
                    },
                  ),
                  title: Text(child.title),
                  onTap: () => _navigateToTimer(context, child.title),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ParentItem {
  final String title;
  final List<ChildItem> children;
  final bool checked;

  const ParentItem({
    required this.title,
    required this.children,
    this.checked = false,
  });

  ParentItem copyWith({bool? checked}) {
    return ParentItem(
      title: title,
      children: children,
      checked: checked ?? this.checked,
    );
  }
}

class ChildItem {
  final String title;
  final bool checked;

  const ChildItem({
    required this.title,
    this.checked = false,
  });

  ChildItem copyWith({bool? checked}) {
    return ChildItem(
      title: title,
      checked: checked ?? this.checked,
    );
  }
}

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final title = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: Text('Timer for $title')),
      body: Center(
        child: Text('Timer Page for: $title'),
      ),
    );
  }
}