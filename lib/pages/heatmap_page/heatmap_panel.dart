import 'package:flutter/material.dart';
import 'grid/month_heatmap.dart';
import 'calender/heatmap_calender.dart';

class HeatmapPanel extends StatelessWidget {
  const HeatmapPanel({super.key});

  @override
  Widget build(BuildContext c) {
    return const Column(
      children: [
        SizedBox(height: 80, child: MonthHeatmap(heatLevelMap:{'1':10,'2':20,'3':30,'4':40,'5':50,'6':60,'7':70,'8':80,'9':90,'10':100})),
        SizedBox(height: 450, child: HeatmapCalender()),
      ],
    );
  }
}
