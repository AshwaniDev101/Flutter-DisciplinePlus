import 'package:discipline_plus/database/repository/heatmap_repository.dart';
import 'package:discipline_plus/database/services/firebase_heatmap_service.dart';
import 'package:discipline_plus/pages/listpage/logic/schedule_manager.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../models/initiative.dart';
import '../dietpage/dietpage.dart';
import '../drawer/drawer.dart';
import '../listpage/core/current_day_manager.dart';
import 'core/refresh_reload_notifier.dart';
import 'logic/initiative_list_manager.dart';
import '../timerpage/timer_page.dart';
import 'heatmap_panel.dart';
import 'schedule_listview.dart';
import 'add_initiative_dialog.dart';

const double _panelMinHeight = 90;
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

    InitiativeListManager.instance.bindToInitiatives();
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
              InitiativeListManager.instance.addInitiative(
                newInitiative,
              );
              Navigator.of(context).pop();
            },
            onEditSave: (editedInitiative) {
              InitiativeListManager.instance.updateInitiative(
                editedInitiative,
              );
              Navigator.of(context).pop();
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      body: Stack(children: [
        SlidingUpPanel(
          minHeight: _panelMinHeight,
          maxHeight: _panelMaxHeight,
          onPanelSlide: (v) => slidingPanelNotifier.value = v,
          panel: const HeatmapPanel(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 35),
              // _DayHeader(onLeft: _goLeft, onRight: _goRight),
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
                    onItemSwipe: (swipeDirection, initiative) => _navigateToTimer(initiative, swipeDirection),
                    onItemEdit: (existingInitiative) =>
                        _showAddUpdateInitiativeDialog(initiative: existingInitiative),
                  ),
                ),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<double>(
          valueListenable: slidingPanelNotifier,
          builder: (_, v, __) => Positioned(
            bottom: 10 + (1 - v) * 90,
            right: 16,
            child: Row(
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DietPage()),
                    );
                  },
                  child: const Icon(Icons.monitor_weight_outlined),
                ),
                SizedBox(
                  width: 10,
                ),
                SizedBox(
                  width: 10,
                ),
                FloatingActionButton(
                  onPressed: () => showFullScreenDialog(context),
                  child: const Icon(Icons.list_alt),
                ),
                FloatingActionButton(
                  onPressed: () {
                    HeatmapRepository _heatmapRepository = HeatmapRepository(
                        FirebaseHeatmapService.instance('user1'));

                    // _heatmapRepository.updateEntries(activityId: 'diet_heatmap', year: 2025, month: 6, dayHeatLevel: {23:1,24:2,25:3,26:4,27:5,28:6,29:7,});
                    _heatmapRepository.overwriteHeatmap(
                        activityId: 'diet_heatmap',
                        year: 2025,
                        month: 6,
                        dayHeatLevel: {
                          17: 1,
                          18: 2,
                          19: 3,
                          20: 4,
                          21: 5,
                          22: 6,
                          23: 7,
                        });
                  },
                  child: const Icon(Icons.star),
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
        pageBuilder: (_, __, ___) => TimerPage(initiative: initiative),
        transitionsBuilder: (c, anim, __, child) {
          final begin = dir == DismissDirection.startToEnd
              ? const Offset(-1, 0)
              : const Offset(1, 0);
          return SlideTransition(
            position: Tween(begin: begin, end: Offset.zero).animate(anim),
            child: child,
          );
        },
      ),
    );
  }

  void showFullScreenDialog(BuildContext context) {
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
                  title: Text("Add to ${CurrentDayManager.currentWeekDay}"),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _showAddUpdateInitiativeDialog(),
                  child: const Icon(Icons.add),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<Initiative>>(
                        stream: InitiativeListManager.instance.watch(),
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
                    InitiativeListManager.instance.deleteInitiative(init.id);
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
                IconButton(
                  onPressed: () {
                    ScheduleManager.instance.addInitiativeIn(
                        CurrentDayManager.currentWeekDay, init);
                  },
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// class _DayHeader extends StatelessWidget {
//   final VoidCallback onLeft, onRight;
//   const _DayHeader({required this.onLeft, required this.onRight});
//
//   @override
//   Widget build(BuildContext c) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Theme.of(c).colorScheme.surfaceVariant,
//         borderRadius:
//         const BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(icon: const Icon(Icons.arrow_left), onPressed: onLeft),
//           Text(
//             CurrentDayManager.getCurrentDay().toUpperCase(),
//             style: Theme.of(c)
//                 .textTheme
//                 .titleMedium
//                 ?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.5),
//           ),
//           IconButton(icon: const Icon(Icons.arrow_right), onPressed: onRight),
//         ],
//       ),
//     );
//   }
// }
