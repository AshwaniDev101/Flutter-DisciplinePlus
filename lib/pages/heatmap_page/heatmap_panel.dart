import 'package:discipline_plus/database/repository/heatmap_repository.dart';
import 'package:flutter/material.dart';
import 'grid/month_heatmap.dart';
import 'calender/heatmap_calender.dart';

class HeatmapPanel extends StatelessWidget {

  final DateTime currentDateTime;
  const HeatmapPanel({required this.currentDateTime, super.key});

  @override
  Widget build(BuildContext c) {

    // heatLevelMap:{'1':10,'2':20,'3':30,'4':40,'5':50,'6':60,'7':70,'8':80,'9':90,'10':100}
    return Column(

      children: [
        SizedBox(height: 80, child: MonthHeatmap(currentDateTime: currentDateTime,heatmapStream: HeatmapRepository.instance.watchHeatmap(date:currentDateTime, heatmapID: HeatmapID.overallInitiative))),
        const SizedBox(height: 450, child: HeatmapCalender()),
      ],
    );
  }
}
