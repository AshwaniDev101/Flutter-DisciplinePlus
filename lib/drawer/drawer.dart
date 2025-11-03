
import 'package:flutter/material.dart';

import '../pages/calories_counter/calorie_counter_page/calories_counter_page.dart';
import '../pages/habit_tracker_page/habit_tracker_page.dart';
import '../pages/home_page/home_page.dart';
import '../theme/app_colors.dart';


class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});


  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(

      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.appbarContent,
            ),
            child: Text(
              'Ashwani Yadav',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),



          ListTile(
            leading: Icon(Icons.monitor_weight_outlined),
            title: Text('Calories Counter'),
            onTap: () {
              Navigator.push(
                context,
                // MaterialPageRoute(builder: (context) => DietPage()),
                MaterialPageRoute(builder: (context) => CalorieCounterPage(pageDateTime: DateTime.now(),)),
              );

            },
          ),


          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Homepage'),
            onTap: () {
              // Handle Settings tap
              MaterialPageRoute(builder: (context) =>   HomePage());

            },
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('HabitTracker'),
            onTap: () {
              // Handle Settings tap
              MaterialPageRoute(builder: (context) =>   HabitTrackerDemo());

            },
          ),

          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Handle Settings tap
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

