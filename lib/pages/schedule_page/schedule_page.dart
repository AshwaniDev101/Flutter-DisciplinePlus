import 'package:discipline_plus/pages/schedule_page/widgets/schedule_listview.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../database/repository/weekly_schedule_repository.dart';
import '../../drawer/drawer.dart';
import '../global_initiative_list_page/global_initiative_list/global_initiative_list_page.dart';

import '../global_initiative_list_page/manager/global_list_manager.dart';
import '../global_initiative_list_page/new_initiatives/new_initiative_dialog.dart';
import '../heatmap_page/heatmap_panel.dart';
import 'manager/schedule_manager.dart';

const double _panelMinHeight = 80;
const double _panelMaxHeight = 550;

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with RouteAware {
  final DateTime dateTimeNow = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<String>(
            stream: ScheduleManager.instance.day$,
            builder: (context, snapshot) {
              final day = snapshot.data ?? '';
              return Text(
                day,
                style: TextStyle(color: Colors.white),
              );
            }),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.pink.shade200,
        actions: [
          IconButton(
              onPressed: () {
                ScheduleManager.instance.toPreviousDay();
                // ScheduleManager.instance.changeDay(ScheduleManager.instance.currentDay);
              },
              icon: Icon(Icons.keyboard_arrow_left_rounded)),
          IconButton(
              onPressed: () {
                ScheduleManager.instance.toNextDay();
                // ScheduleManager.instance.changeDay(ScheduleManager.instance.currentDay);
              },
              icon: Icon(Icons.keyboard_arrow_right_rounded)),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => GlobalInitiativeListPage()));
              },
              icon: Icon(Icons.add)),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SlidingUpPanel(
        minHeight: _panelMinHeight,
        maxHeight: _panelMaxHeight,
        panel: const HeatmapPanel(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Divider(height: 1, thickness: 1),
            Expanded(
              child: ScheduleListview(
                stream: ScheduleManager.instance.mergedDayInitiatives,
                onItemEdit: (existingInitiative) {
                  DialogHelper.showEditInitiativeDialog(
                      context: context,
                      existingInitiative: existingInitiative,
                      onEdit: (editedInitiative) {
                        GlobalListManager.instance.updateInitiative(
                          editedInitiative,
                        );
                      });
                },
                onItemDelete: (initiative) {
                  ScheduleManager.instance.deleteInitiativeFrom(
                    ScheduleManager.instance.currentDay,
                    initiative.id,
                  );
                },
                onItemComplete: (initiative, isComplete) {

                  WeeklyScheduleRepository.instance
                      .completeInitiative(ScheduleManager.instance.currentDay, initiative.id, isComplete);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
