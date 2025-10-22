
import 'package:discipline_plus/pages/homepage/golabl_initiative_list_page/new_initiatives/new_initiative_dialog.dart';
import 'package:discipline_plus/pages/homepage/schedule_handler/schedule_completion_manager.dart';
import 'package:discipline_plus/pages/homepage/schedule_handler/schedule_coordinator.dart';
import 'package:discipline_plus/pages/homepage/schedule_handler/schedule_manager.dart';
import 'package:discipline_plus/pages/homepage/schedule_handler/widgets/schedule_listview.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../database/repository/heatmap_repository.dart';
import '../../drawer/drawer.dart';
import '../../managers/selected_day_manager.dart';
import 'dialog_helper.dart';
import 'golabl_initiative_list_page/global_initiative_list_page.dart';
import 'golabl_initiative_list_page/global_list_manager.dart';
import '../heatmap_page/heatmap_panel.dart';
import '../timerpage/timer_page.dart';

const double _panelMinHeight = 80;
const double _panelMaxHeight = 550;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {

  final DateTime dateTime_now = DateTime.now();

  @override
  void initState() {
    super.initState();

    GlobalListManager.instance.bindToInitiatives();
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
                ScheduleManager.instance.changeDay(SelectedDayManager.currentSelectedWeekDay.value);
              },
              icon: Icon(Icons.keyboard_arrow_left_rounded)),
          IconButton(
              onPressed: () {
                SelectedDayManager.toNextDay();
                ScheduleManager.instance.changeDay(SelectedDayManager.currentSelectedWeekDay.value);
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

                  
                  onItemEdit: (existingInitiative) {

                    DialogHelper.showEditInitiativeDialog(context: context, existingInitiative: existingInitiative);


                  }),
            ),
          ],
        ),
      ),
    );
  }
  
  
}

