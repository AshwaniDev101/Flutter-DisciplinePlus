
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../managers/selected_day_manager.dart';
import '../../../../models/initiative.dart';
import '../schedule_handler/schedule_manager.dart';
import 'global_list_manager.dart';
import 'new_initiatives/new_initiative_dialog.dart';


class GlobalInitiativeListPage extends StatefulWidget {
  const GlobalInitiativeListPage({
    super.key,
  });

  @override
  State<GlobalInitiativeListPage> createState() => _GlobalInitiativeListPageState();
}

class _GlobalInitiativeListPageState extends State<GlobalInitiativeListPage> {
  final TextEditingController searchController = TextEditingController();

  final String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add tasks to '${SelectedDayManager.currentSelectedWeekDay.value}'"),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUpdateInitiativeDialog(context: context),
        child: Text("new"),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Initiative>>(
              stream: GlobalListManager.instance.watch(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                final initiatives = snapshot.data ?? [];

                if (snapshot.connectionState == ConnectionState.waiting && initiatives.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (initiatives.isEmpty) {
                  return const Center(child: Text('No data available'));
                }

                return ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    final item = initiatives[oldIndex];
                  },
                  children: [
                    for (int i = 0; i < initiatives.length; i++)
                      _cardItem(
                        context,
                        initiatives[i],
                        i,
                        Key('$i-${initiatives[i].id}'),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {},
            ),
          )
        ],
      ),
    );
  }

  Widget _cardItem(BuildContext context, Initiative init, int index, Key key) {
    return SizedBox(
      key: key,
      width: double.infinity, // forces full width
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: IntrinsicHeight(
          // helps with better vertical alignment
          child: SizedBox(
            height: 60,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IconButton(
                  onPressed: () {
                    GlobalListManager.instance.deleteInitiative(init.id);
                  },
                  icon: Icon(Icons.delete),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        init.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.indigo[700],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: init.completionTime.remainingTime(),
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            if (init.studyBreak.completionTime.minute != 0)
                              TextSpan(
                                text: "   ${init.studyBreak.completionTime.minute}m brk",
                                style: const TextStyle(fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScheduleManager.instance.addInitiativeIn(SelectedDayManager.currentSelectedWeekDay.value, init);
                  },
                  child: Text("Add"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddUpdateInitiativeDialog({Initiative? initiative, required BuildContext context}) {
    showDialog(
        context: context,
        builder: (_) => NewInitiativeDialog(
            existing_initiative: initiative,
            onNewSave: (newInitiative) {
              GlobalListManager.instance.addInitiative(
                newInitiative,
              );
              print("data saved ===============");
              Navigator.of(context).pop();
            },
            onEditSave: (editedInitiative) {
              GlobalListManager.instance.updateInitiative(
                editedInitiative,
              );
              Navigator.of(context).pop();
            }));
  }
}
