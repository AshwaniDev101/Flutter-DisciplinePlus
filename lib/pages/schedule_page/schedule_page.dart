
import 'package:discipline_plus/pages/schedule_page/viewModel/schedule_view_model.dart';
import 'package:discipline_plus/pages/schedule_page/widgets/schedule_listview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../drawer/drawer.dart';
import '../../models/initiative.dart';
import '../../theme/app_colors.dart';
import '../global_initiative_list_page/global_initiative_list/global_initiative_list_page.dart';
import '../global_initiative_list_page/manager/global_list_manager.dart';
import '../global_initiative_list_page/new_initiatives/new_initiative_dialog.dart';
import '../heatmap_page/heatmap_panel.dart';
import '../timer_page/timer_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with RouteAware {
  final double _panelMinHeight = 80;
  final double _panelMaxHeight = 550;


  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScheduleViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<String>(
            stream: vm.weekDayName$,
            builder: (context, snapshot) {
              final day = snapshot.data ?? '';
              return Text(
                day,
                style: AppTextStyle.appBarTextStyle,
              );
            }),
        iconTheme: IconThemeData(color: AppColors.appbarContent),
        backgroundColor: AppColors.appbar,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
              onPressed: () {
                vm.toPreviousDay();
                // ScheduleManager.instance.changeDay(ScheduleManager.instance.currentDay);
              },
              icon: Icon(Icons.keyboard_arrow_left_rounded)),
          IconButton(
              onPressed: () {
                vm.toNextDay();
                // ScheduleManager.instance.changeDay(ScheduleManager.instance.currentDay);
              },
              icon: Icon(Icons.keyboard_arrow_right_rounded)),
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => GlobalInitiativeListPage(
                          currentWeekDay: vm.currentWeekDay,
                          onAdd: (initiative) {
                            vm.addInitiativeIn(vm.currentWeekDay, initiative.id);
                          },
                        )));
              },
              icon: Icon(Icons.add)),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SlidingUpPanel(
        minHeight: _panelMinHeight,
        maxHeight: _panelMaxHeight,
        boxShadow: const <BoxShadow>[],
        color: AppColors.slideUpPanelColor,

        panel: HeatmapPanel(
          currentDateTime: vm.dateTimeNow,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // const Divider(height: 1, thickness: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ScheduleListview(
                  stream: vm.mergedDayInitiatives,
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
                    vm.deleteInitiativeFrom(
                      vm.currentWeekDay,
                      initiative.id,
                    );
                  },
                  onItemComplete: (initiative, isComplete) {

                    vm.onComplete(initiative, isComplete);
                    // WeeklyScheduleRepository.instance.completeInitiative(vm.currentWeekDay, initiative.id, isComplete);
                    //
                    // var latest = vm.latestCompletionPercentage;
                    // // Updating heatmap
                    // HeatmapRepository.instance
                    //     .updateEntry(heatmapID: HeatmapID.overallInitiative, date: dateTimeNow, value: latest);
                    //

                  },
                  onPlay: (initiative) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerPage(
                            initiative: initiative,
                            initiativeList: vm.latestMergedList,
                            onComplete: (Initiative initiative, bool isManual) {
                              vm.onComplete(initiative, true);
                              // widget.onItemComplete(init, true);
                            }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
