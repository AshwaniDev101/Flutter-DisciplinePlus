

import 'package:discipline_plus/pages/calories_counter_page/widgets/calories_states.dart';
import 'package:discipline_plus/pages/calories_counter_page/widgets/global_food_list.dart';
import 'package:flutter/material.dart';

class CaloriesCounterPage extends StatefulWidget {
  const CaloriesCounterPage({super.key});

  @override
  State<CaloriesCounterPage> createState() => _CaloriesCounterPageState();
}

class _CaloriesCounterPageState extends State<CaloriesCounterPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20,),
            CaloriesStates(),
            SizedBox(height: 20,),
            GlobalFoodList()

          ],
        ),
      ),
    );

  }
}
