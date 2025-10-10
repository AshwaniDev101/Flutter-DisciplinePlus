
import 'package:flutter/material.dart';

import '../pages/calories_counter_page/calories_counter.dart';
import '../pages/dietpage/dietpage.dart';

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
              color: Colors.pink[200],
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
            title: Text('Diet Page'),
            onTap: () {
              Navigator.push(
                context,
                // MaterialPageRoute(builder: (context) => DietPage()),
                MaterialPageRoute(builder: (context) => CaloriesCounterPage()),
              );

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

