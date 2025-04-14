
// lib/list_page.dart

import 'dart:async';

import 'package:discipline_plus/models/data_types.dart';
import 'package:discipline_plus/taskmanager.dart';
import 'package:discipline_plus/timer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'constants.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> with RouteAware {


  late Timer _timer;
  late String currentTime;
  late String currentWeekday;

  final ScrollController _scrollController = ScrollController();

  final List<BaseInitiative> _items_list = [
    InitiativeGroup(
      title: 'DSA',
      initiativeList: [
        Initiative(title: 'Self-Attempt', completionTime: AppTime(0, 2)),
        Initiative(title: 'Implementation', completionTime: AppTime(0, 2)),
        Initiative(title: 'Efficient-Solution', completionTime: AppTime(0, 2)),
        Initiative(
          title: 'Deployment',
          completionTime: AppTime(0, 15),
          studyBreak: LongBreak(),
        ),
      ],
    ),
    // Initiative(title: 'Meditation', completionTime: AppTime(0, 20)),
    InitiativeGroup(
      title: 'JavaScript',
      initiativeList: [
        Initiative(title: 'Video-1', completionTime: AppTime(0, 1)),
        Initiative(title: 'Apply-1', completionTime: AppTime(0, 1)),
        Initiative(title: 'Video-2', completionTime: AppTime(0, 1)),
        Initiative(title: 'Apply-2', completionTime: AppTime(0, 1), studyBreak: LongBreak(),),
      ],
    ),

    Initiative(title: 'Meditation', completionTime: AppTime(0, 2)),

    Initiative(title: 'English', completionTime: AppTime(0, 5)),
    Initiative(title: 'Drawing', completionTime: AppTime(0, 1)),
    Initiative(title: 'Assignment', completionTime: AppTime(0, 2)),
    Initiative(title: 'Maker Project', completionTime: AppTime(0, 15)),
    Initiative(title: 'GYM', completionTime: AppTime(0, 15)),
  ];


  @override
  void initState() {
    super.initState();
    _updateWeekTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateWeekTime());
    // Initialize TaskManager
    TaskManager.instance.updateList(_items_list);
  }

  @override // call when return to the this route from some other route
  void didPopNext() {
    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: SlidingUpPanel(

        // HeatMap
        panel: HeatMapCalendar(
          defaultColor: Colors.white,
          flexible: true,
          colorMode: ColorMode.color,
          textColor: Colors.black45,
          datasets: {
            DateTime(2025,4,6):0,
            DateTime(2025,4,7):1,
            DateTime(2025,4,8):2,
            DateTime(2025,4,9):3,
            DateTime(2025,4,13):4,
          },
          colorsets: {
            0: Colors.red[400]!,
            1: Colors.green[100]!,
            2: Colors.green[300]!,
            3: Colors.green[400]!,
            4: Colors.green[500]!,
            5: Colors.green[600]!,
          },
          onClick: (value) {
            // Do something
          },
        ),



        body: Column(
          children: [

            // Wednesday   09:15
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
              decoration: BoxDecoration(
                color: Colors.indigo[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),



              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(currentWeekday, style: TextStyle(fontSize:22, fontWeight: FontWeight.w600, color:Colors.indigo[900])),
                  Text(currentTime,   style: TextStyle(fontSize:34, fontWeight: FontWeight.bold, color:Colors.indigo[900])),
                ],
              ),


            ),


            // Listview
            Expanded(
              child: ReorderableListView(
                scrollController: _scrollController,
                padding: const EdgeInsets.all(8),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _items_list.removeAt(oldIndex);
                    _items_list.insert(newIndex, item);
                    // Keep TaskManager in sync
                    TaskManager.instance.updateList(_items_list);
                  });
                },
                children: [


                  // Every list Item
                  for (int i = 0; i < _items_list.length; i++)
                    Dismissible(
                      key: ValueKey(_items_list[i].id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        color: Constants.background_color,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left:20),
                        child: const Icon(Icons.timer, color:Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Constants.background_color,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right:20),
                        child: const Icon(Icons.timer, color:Colors.white),
                      ),
                      child: _buildBaseInitiativeItem(_items_list[i], i),
                      confirmDismiss: (direction) async {
                        // Navigate to TimerPage but don't remove
                        Navigator.push(context, MaterialPageRoute(builder: (_) => TimerPage( baseInitiative: _items_list[i])));
                        return false;
                      },
                    ),




                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaseInitiativeItem(BaseInitiative item, int topIndex) {

    // InitiativeGroup
    if (item is InitiativeGroup) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.indigo[300]),
        child: ExpansionTile(
          key: ValueKey(item.id),
          leading: buildLeading(item, topIndex),
          title: buildRichTitle(item, fontWeight: FontWeight.bold),
          children: item.initiativeList.asMap().entries.map((e) {
            // final childIndex = e.key;
            final ini = e.value;

            // Initiative Group Children
            return Dismissible(
              key: ValueKey(ini.id),
              direction: DismissDirection.horizontal,
              background: Container(
                color: Constants.background_color,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                child: const Icon(Icons.timer, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Constants.background_color,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.timer, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                Navigator.push(context, MaterialPageRoute(builder: (_) => TimerPage( baseInitiative: ini)));

                return false; // don't actually dismiss
              },
              child: ListTile(
                leading: buildChildLeading(ini),
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '   ${ini.title} ',
                        style: const TextStyle(fontSize: 16, color: Colors.indigo),
                      ),
                      TextSpan(
                        text: ini.completionTime.remainingTime(),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  // existing onTap logic...
                },
              ),
            );


          }).toList(),
        ),
      );


      // Normal Initiative
    } else {
      item as Initiative;
      return ListTile(
        leading: buildLeading(item, topIndex),
        title: buildRichTitle(item),
        onTap: () {
          // existing onTap logic...
        },
      );
    }
  }



  //================  build and updating Leading Icon ===========================
  ReorderableDragStartListener buildLeading(BaseInitiative bi, int index) {
    return ReorderableDragStartListener(
      index: index,
      child: buildLeadingIcon(
        isComplete: bi.isComplete,
        whiteCircleSize: 20,
        iconSize: 24,
      ),
    );
  }

  Widget buildChildLeading(Initiative ini) {
    return buildLeadingIcon(
      isComplete: ini.isComplete,
      whiteCircleSize: 14,// small then the icon size to make sure it remain behind the circle
      iconSize: 18,
    );
  }

  Widget buildLeadingIcon({required bool isComplete, required double whiteCircleSize, required double iconSize,}) {
    return SizedBox(
      width: 24,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -8,
            bottom: -8,
            left: 11,
            child: Container(width: 2, color: Colors.indigo[300]),
          ),
          // if (!isComplete)
            Container(
              width: whiteCircleSize,
              height: whiteCircleSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          Icon(
            isComplete ? Icons.circle_rounded: Icons.circle_outlined,
            size: iconSize,
            color: Colors.indigo[300],
          ),
        ],
      ),
    );
  }


//================  build and updating Title ===========================
  Widget buildRichTitle(BaseInitiative u, {FontWeight? fontWeight}) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(text: '${u.title} ', style: TextStyle(fontSize:18, color:Colors.indigo[700], fontWeight:fontWeight)),
        TextSpan(text: u.completionTime.remainingTime(), style: const TextStyle(fontSize:16, color:Colors.grey)),
      ]),
    );
  }



  void _updateWeekTime() {
    final now = DateTime.now();
    final hour12 = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    setState(() {
      currentTime = '$hour12:$minute $period';
      currentWeekday = _weekdayName(now.weekday);
    });
  }

  String _weekdayName(int weekdayNumber) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekdayNumber - 1];
  }


}
