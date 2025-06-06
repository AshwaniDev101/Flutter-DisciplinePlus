
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../dietpage/dietpage.dart';
import '../drawer/drawer.dart';
import '../listpage/core/refresh_reload_notifier.dart';
import '../listpage/core/current_day_manager.dart';
import 'logic/taskmanager.dart';
import '../timerpage/timer_page.dart';
import 'heatmap_panel.dart';
import 'initiative_listview.dart';
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
  late final RefreshController _refreshControllers;

  @override
  void initState() {
    super.initState();
    // one controller per day tab
    _refreshControllers = RefreshController();
    RefreshReloadNotifier.instance.register(_loadData);

    RefreshReloadNotifier.instance.notifyAll();
  }

  @override
  void dispose() {
    slidingPanelNotifier.dispose();
    _scrollController.dispose();
    _refreshControllers.dispose();

    super.dispose();
  }

  Future<void> _loadData() async {
    // await TaskManager.instance.reloadRepository(CurrentDayManager.getCurrentDay());
    setState(() {});
  }

  void _showInitiativeDialog({initiative}) {
    showDialog(
      context: context,
      builder: (_) => InitiativeDialog(
        existing_initiative: initiative,
        onSubmit: (newInit, isEdit) {
          setState(() {
            if (isEdit) {
              TaskManager.instance.updateInitiative(
                CurrentDayManager.getCurrentDay(),
                newInit,
              );
            } else {
              TaskManager.instance.addInitiative(
                CurrentDayManager.getCurrentDay(),
                newInit,
              );
            }
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // void _goLeft() => setState(() => CurrentDayManager.goLeft());
  // void _goRight() => setState(() => CurrentDayManager.goRight());

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
                    borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
                  ),
                  child: InitiativeListview(
                        // dayIndex: 0,
                        scrollController: _scrollController,
                        refreshController: _refreshControllers,
                        onItemSwipe: (dir, item) =>
                            _navigateToTimer(item, dir),
                        onItemEdit: (item) => _showInitiativeDialog(initiative: item),

                  ),
                  // child: IndexedStack(
                  //   index: CurrentDayManager.getCurrentIndex(),
                  //   children: List.generate(
                  //     CurrentDayManager.length(),
                  //         (i) => DayContent(
                  //       dayIndex: i,
                  //       scrollController: _scrollController,
                  //       refreshController: _refreshControllers[i],
                  //       onItemSwipe: (dir, item) =>
                  //           _navigateToTimer(item, dir),
                  //       onItemEdit: (item) => _showInitiativeDialog(initiative: item),
                  //     ),
                  //   ),
                  // ),
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
                SizedBox(width: 10,),
                FloatingActionButton(
                  onPressed: () => _showInitiativeDialog(),
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
        pageBuilder: (_, __, ___) =>
            TimerPage(initiative: initiative),
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

