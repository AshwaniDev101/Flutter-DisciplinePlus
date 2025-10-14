import 'package:discipline_plus/database/services/firebase_initiative_completion_service.dart';
import 'package:discipline_plus/pages/listpage/schedule_completion_manager.dart';
import 'package:discipline_plus/pages/listpage/schedule_coordinator.dart';
import 'package:discipline_plus/pages/listpage/schedule_handler/schedule_manager.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../database/repository/heatmap_repository.dart';
import '../../database/services/firebase_heatmap_service.dart';
import '../../drawer/drawer.dart';
import '../../managers/selected_day_manager.dart';
import '../../models/initiative.dart';
import '../global_initiative_page/global_list_manager.dart';
import '../global_initiative_page/new_initiatives/add_initiative_dialog.dart';
import '../heatmap_page/heatmap_panel.dart';
import '../timerpage/timer_page.dart';

import 'widgets/schedule_listview.dart';

const double _panelMinHeight = 60;
const double _panelMaxHeight = 550;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  final ValueNotifier<double> slidingPanelNotifier = ValueNotifier(0.0);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    GlobalListManager.instance.bindToInitiatives();
  }

  @override
  void dispose() {
    slidingPanelNotifier.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _showAddUpdateInitiativeDialog({Initiative? initiative}) {
    showDialog(
        context: context,
        builder: (_) => InitiativeDialog(
            existing_initiative: initiative,
            onNewSave: (newInitiative) {
              GlobalListManager.instance.addInitiative(
                newInitiative,
              );
              Navigator.of(context).pop();
            },
            onEditSave: (editedInitiative) {
              GlobalListManager.instance.updateInitiative(
                editedInitiative,
              );
              Navigator.of(context).pop();
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<String>(
          valueListenable: SelectedDayManager.currentSelectedWeekDay,
          builder: (context, value, _) => Text(
            value,
            style: TextStyle(color: Colors.white),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.pink.shade200,
        actions: [
          IconButton(
              onPressed: () {
                SelectedDayManager.toPreviousDay();
                ScheduleManager.instance
                    .changeDay(SelectedDayManager.currentSelectedWeekDay.value);
              },
              icon: Icon(Icons.keyboard_arrow_left_rounded)),
          IconButton(
              onPressed: () {
                SelectedDayManager.toNextDay();
                ScheduleManager.instance
                    .changeDay(SelectedDayManager.currentSelectedWeekDay.value);
              },
              icon: Icon(Icons.keyboard_arrow_right_rounded)),
          IconButton(
              onPressed: () {
                SelectedDayManager.toNextDay();
                ScheduleManager.instance
                    .changeDay(SelectedDayManager.currentSelectedWeekDay.value);
              },
              icon: Icon(Icons.add)),
          // PopupMenuButton<String>(
          //   icon: const Icon(Icons.more_vert, color: Colors.white),
          //   onSelected: (String value) {
          //     // Handle menu item selection
          //     if (value == 'test1') {
          //       FirebaseInitiativeCompletionService.instance
          //           .setInitiativeCompletion(
          //               DateTime.now(), "some initiative id", true);
          //     }
          //   },
          //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          //     PopupMenuItem<String>(
          //       value: 'test1',
          //       child: Row(
          //         children: [
          //           Icon(Icons.settings, color: Colors.pink[200]),
          //           const SizedBox(width: 8),
          //           const Text('Settings'),
          //           const SizedBox(width: 8),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: Stack(children: [
        SafeArea(
          child: SlidingUpPanel(
            minHeight: _panelMinHeight,
            maxHeight: _panelMaxHeight,
            onPanelSlide: (v) => slidingPanelNotifier.value = v,
            panel: const HeatmapPanel(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: 1, thickness: 1),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12)),
                    ),
                    child: ScheduleListview(
                      // dayIndex: 0,
                      scrollController: _scrollController,
                      // refreshController: _refreshControllers,
                      onItemSwipe: (swipeDirection, initiative) =>
                          _navigateToTimer(initiative, swipeDirection),
                      onItemEdit: (existingInitiative) =>
                          _showAddUpdateInitiativeDialog(
                              initiative: existingInitiative),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Floating action buttons
        ValueListenableBuilder<double>(
          valueListenable: slidingPanelNotifier,
          builder: (_, v, __) => Positioned(
            bottom: 10 + (1 - v) * 90,
            right: 16,
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () =>
                      showFullScreenGlobalInitiativeDialog(context),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  void _navigateToTimer(initiative, DismissDirection dir) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => TimerPage(
          initiative: initiative,
          onComplete: ({isManual = false, isComplete = false}) {

            ScheduleCompletionManager.instance
                .toggleCompletion(initiative.id, isComplete);


            // Updating heatmap

            HeatmapRepository heatmapRepository = HeatmapRepository(FirebaseHeatmapService.instance);

            var percentage = ScheduleCoordinator.instance.latestCompletionPercentage;
            heatmapRepository.updateEntry(activityId: initiative.id, date: DateTime.now(), value: percentage);


          },
        ),

        // transitionsBuilder: (c, anim, __, child) {
        //   final begin = dir == DismissDirection.startToEnd
        //       ? const Offset(-1, 0)
        //       : const Offset(1, 0);
        //   return SlideTransition(
        //     position: Tween(begin: begin, end: Offset.zero).animate(anim),
        //     child: child,
        //   );
        // },
      ),
    );
  }

  void showFullScreenGlobalInitiativeDialog(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    String searchText = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(
                      "Add tasks to '${SelectedDayManager.currentSelectedWeekDay.value}'"),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _showAddUpdateInitiativeDialog(),
                  child: Text("new"),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<Initiative>>(
                        stream: GlobalListManager.instance.watch(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Something went wrong'));
                          }

                          final initiatives = snapshot.data ?? [];

                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              initiatives.isEmpty) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (initiatives.isEmpty) {
                            return const Center(
                                child: Text('No data available'));
                          }

                          return ReorderableListView(
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex--;
                                final item = initiatives[oldIndex];
                                // Implement reorder logic
                              });
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
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() => searchText = value);
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
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
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                            if (init.studyBreak.completionTime.minute != 0)
                              TextSpan(
                                text:
                                    "   ${init.studyBreak.completionTime.minute}m brk",
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScheduleManager.instance.addInitiativeIn(
                        SelectedDayManager.currentSelectedWeekDay.value, init);
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
}

