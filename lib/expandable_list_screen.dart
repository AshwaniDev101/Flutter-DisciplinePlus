import 'package:discipline_plus/timer_page.dart';
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
    ParentItem(
      title: 'GYM',
      children: [],
    ),
    ParentItem(
      title: 'Meditation',
      children: [],
    ),
    ParentItem(
      title: 'English',
      children: [],
    ),
    ParentItem(
      title: 'Drawing',
      children: [],
    ),
    ParentItem(
      title: 'Assignment',
      children: [],
    ),
  ];

  void _navigateToTimer(BuildContext context, String title) {
    Navigator.pushNamed(context, '/timer', arguments: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: Size(200, 50),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Timer Page'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimerPage()),
                );
              },
            ),
          ),

          SizedBox(height: 40,)
        ],
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

