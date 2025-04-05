import 'package:discipline_plus/timer_page.dart';
import 'package:flutter/material.dart';

class ExpandableListScreen extends StatefulWidget {
  @override
  _ExpandableListScreenState createState() => _ExpandableListScreenState();
}

class _ExpandableListScreenState extends State<ExpandableListScreen> {
  final List<ParentItem> _items = [
    ParentItem(
      title: '09:00 DSA',
      children: [
        ChildItem(title: '09:00 Self-Attempt'),
        ChildItem(title: '09:30 Implementation'),
        ChildItem(title: '10:00 Real-Solution'),
        ChildItem(title: '10:30 Deployment'),
      ],
    ),
    ParentItem(
      title: '11:30 JavaScript',
      children: [
        ChildItem(title: '11:30 Video-1'),
        ChildItem(title: '12:00 Video-2'),
      ],
    ),
    ParentItem(
      title: '12:30 GYM',
      children: [],
    ),
    ParentItem(
      title: '01:00 Meditation',
      children: [],
    ),
    ParentItem(
      title: '01:30 English',
      children: [],
    ),
    ParentItem(
      title: '02:00 Drawing',
      children: [],
    ),
    ParentItem(
      title: '03:00 Assignment',
      children: [],
    ),
    ParentItem(
      title: '04:00 Personal Project',
      children: [],
    ),
  ];

  void _navigateToTimer(BuildContext context, String title) {
    Navigator.pushNamed(context, '/timer', arguments: title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 40),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Text(
                    "Monday",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "09:04 am",
                        style: TextStyle(
                          fontSize: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final parent = _items[index];

                // Create the list item (ListTile or ExpansionTile) for parent.
                Widget listItem;
                if (parent.children.isEmpty) {
                  listItem = ListTile(
                    leading: Checkbox(
                      value: parent.checked,
                      onChanged: (bool? value) {
                        setState(() =>
                        _items[index] = parent.copyWith(checked: value));
                      },
                    ),
                    title: Text(parent.title),
                    onTap: () => _navigateToTimer(context, parent.title),
                  );
                } else {
                  listItem = ExpansionTile(
                    leading: Checkbox(
                      value: parent.checked,
                      onChanged: (bool? value) {
                        setState(() =>
                        _items[index] = parent.copyWith(checked: value));
                      },
                    ),
                    title: Text(parent.title),
                    children: parent.children.map((child) {
                      // Wrap the child item with Dismissible.
                      return Dismissible(
                        key: Key("${parent.title}-${child.title}"),
                        direction: DismissDirection.horizontal,
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(Icons.archive, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // Action performed on swipe right.
                            print("Swiped right on child: ${child.title}");
                          } else if (direction ==
                              DismissDirection.endToStart) {
                            // Action performed on swipe left.
                            print("Swiped left on child: ${child.title}");
                          }
                          return false;
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 24.0),
                          child: ListTile(
                            leading: Checkbox(
                              value: child.checked,
                              onChanged: (bool? value) {
                                setState(() {
                                  parent.children[
                                  parent.children.indexOf(child)] =
                                      child.copyWith(checked: value);
                                });
                              },
                            ),
                            title: Text(child.title),
                            onTap: () =>
                                _navigateToTimer(context, child.title),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }

                // Wrap the parent item with a Dismissible.
                return Dismissible(
                  key: Key(parent.title), // Ensure a unique key.
                  direction: DismissDirection.horizontal,
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(Icons.archive, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      print("Swiped right on: ${parent.title}");
                    } else if (direction == DismissDirection.endToStart) {
                      print("Swiped left on: ${parent.title}");
                    }
                    return false;
                  },
                  child: listItem,
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
          SizedBox(height: 40),
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
