import 'dart:async';

import 'package:discipline_plus/pages/listpage/core/refresh_reload_notifier.dart';
import 'package:discipline_plus/models/initiative.dart';
import 'package:discipline_plus/pages/listpage/widget/custompageslider.dart';
import 'package:discipline_plus/pages/listpage/widget/quantity_selector.dart';
import 'package:discipline_plus/pages/timerpage/timer_page.dart';
import 'package:discipline_plus/pages/listpage/widget/heatmap_calender.dart';
import 'package:discipline_plus/pages/listpage/widget/heatmap_row.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../models/app_time.dart';
import '../../models/study_break.dart';
import '../drawer/drawer.dart';
import '../logic/taskmanager.dart';
import 'core/current_day_manager.dart';
import 'dialog/custom_pop_up_dialog.dart';

// All your imports remain unchanged

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {

  final ValueNotifier<double> slidingPanelNotifier = ValueNotifier(0.0);
  final ScrollController _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  final TextEditingController initiativeTitleController = TextEditingController();

  late int initiativeCompletionTime = 30;
  late int breakTime = 15;



  @override
  void initState() {
    super.initState();
    // RefreshReloadNotifier.instance.register(loadData);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await RefreshReloadNotifier.instance.notifyAll();
    });
  }

  // Future<void> loadData() async {
  //   await TaskManager.instance.reloadRepository();
  //   setState(() {});
  // }


  void _onRefresh() async {
    await RefreshReloadNotifier.instance.notifyAll();
    _refreshController.refreshCompleted();
  }

  void showDialogAdd() {
    showDialog(
      context: context,
      builder: (BuildContext context) => customPopupDialog(),
    );
  }


  void addInitiative(context) {
    var ini = Initiative(index: TaskManager.instance.getNextIndex(),
        title: initiativeTitleController.text,
        completionTime: AppTime(0, initiativeCompletionTime),
        studyBreak: StudyBreak(title: "$breakTime min break",  completionTime: AppTime(0, breakTime))
    );

    setState(() {
      TaskManager.instance.addInitiative(CurrentDayManager.getCurrentDay(),ini);
    });

    Navigator.of(context).pop();
  }


  Widget customPopupDialog() {
    return AlertDialog(
      title: Text("New Initiative",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38),),
      backgroundColor: Colors.white,
      // White background for dialog
      // contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.all(16),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Square corners
      ),
      content: SizedBox(
        width: 500, // Increase the width of the dialog
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title TextField with colorful border and white background
            TextField(
              controller: initiativeTitleController,
              style: TextStyle(
                  color: Colors.black45,    // Your desired text color
                  fontSize: 22,
                  fontWeight: FontWeight.bold
              ),
              decoration: InputDecoration(
                hintText: 'Enter title here',
                hintStyle: TextStyle(color: Colors.black26, fontSize: 16,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 10, vertical: 10),
              ),
            ),
            SizedBox(height: 10),

            // Number TextField with colorful border and width of 50
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [


                Text("Duration", style: TextStyle(color: Colors.black26, fontSize: 16,)),
                Flexible(
                  child: QuantitySelector(
                    initialValue: initiativeCompletionTime,
                    initialStep: 5,
                    onChanged: (value) {
                      initiativeCompletionTime = value;
                    },
                  ),
                ),
              ],
            ),
            // SizedBox(height: 10,),
            Divider(),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Break", style: TextStyle(color: Colors.black26, fontSize: 16,)),

                Flexible(
                  child: QuantitySelector(
                    initialValue: breakTime,
                    initialStep: 5,
                    onChanged: (value) {
                      breakTime = value;
                    },
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(

                    onTap: () => Navigator.of(context).pop(),
                    child: Center(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Cancel", style: TextStyle(color: Colors.black38, fontSize: 18, fontWeight: FontWeight.bold)),
                    ))

                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Colors.blue,

                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
                child: InkWell(

                    onTap: ()=> addInitiative(context),
                    child: Center(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Add", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ))

                ),
              ),
            ),
          ],
        )
      ],




    );
  }

  @override
  Widget build(BuildContext context) {

    // return DietPage();
    return Scaffold(
      floatingActionButton: _buildFAB(),
      drawer: CustomDrawer(),
      body: SlidingUpPanel(
        minHeight: 100,
        maxHeight: 550,
        onPanelSlide: (val) => slidingPanelNotifier.value = val,
        panel: _buildPanelContent(),
        // body: buildCustomPageSlider(context)
        // body: _pageView()
        // body: _buildMainContent(),
        body: CustomPageSlider()


      ),
    );
  }



  Widget _buildFAB() {
    return Stack(
      children: [
        ValueListenableBuilder(
            valueListenable: slidingPanelNotifier,
            builder: (context,value,child){
              return Positioned(
                bottom: 10 + (1 - value) * 90, // 200 pixels from top
                right: 1, // 16 pixels from right (classic FAB spacing)
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      onPressed: showDialogAdd,
                      child: Icon(Icons.add),
                    ),
                    // SizedBox(height: 10), // space between buttons
                    // FloatingActionButton(
                    //   onPressed: () {},
                    //   child: Icon(Icons.add_home_outlined),
                    // ),
                  ],
                ),
              );
            }
        )

      ],
    );

  }

  Widget _buildPanelContent() {
    return Column(
      children: [
        SizedBox(height: 80, child: HeatmapRow()),
        SizedBox(height: 450, child: HeatmapCalender()),
      ],
    );
  }



  ReorderableDragStartListener _buildLeading(Initiative bi, int index) {
    return ReorderableDragStartListener(
      index: index,
      child: _buildLeadingIcon(
        isComplete: bi.isComplete,
        whiteCircleSize: 20,
        iconSize: 24,
      ),
    );
  }

  Widget _buildLeadingIcon({
    required bool isComplete,
    required double whiteCircleSize,
    required double iconSize,
  }) {
    return SizedBox(
      width: 24,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(top: -8, bottom: -8, left: 11, child: Container(width: 2, color: Colors.indigo[300])),
          Container(
            width: whiteCircleSize,
            height: whiteCircleSize,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          Icon(
            isComplete ? Icons.circle_rounded : Icons.circle_outlined,
            size: iconSize,
            color: Colors.indigo[300],
          ),
        ],
      ),
    );
  }

  Widget _buildRichTitle(Initiative u, {FontWeight? fontWeight}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${u.title} ',
            style: TextStyle(fontSize: 18, color: Colors.indigo[700], fontWeight: fontWeight),
          ),
          TextSpan(
            text: u.completionTime.remainingTime(),
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void navigateToTimerPage({
    required DismissDirection dismissDirection,
    required Initiative initiative,
  }) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) =>
            TimerPage(initiative: initiative),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Offset beginOffset;
          if (dismissDirection == DismissDirection.startToEnd) {
            beginOffset = Offset(-1.0, 0.0);
          } else if (dismissDirection == DismissDirection.endToStart) {
            beginOffset = Offset(1.0, 0.0);
          } else {
            beginOffset = Offset(0.0, 1.0);
          }

          return SlideTransition(
            position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(animation),
            child: child,
          );
        },
      ),
    );
  }
}
