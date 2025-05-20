import 'package:flutter/material.dart';
import '../listpage/widget/heatmap_row.dart';
import '../listpage/widget/heatmap_calender.dart';

class HeatmapPanel extends StatelessWidget {
  const HeatmapPanel({super.key});

  @override
  Widget build(BuildContext c) {
    return const Column(
      children: [
        SizedBox(height: 80, child: HeatmapRow()),
        SizedBox(height: 450, child: HeatmapCalender()),
      ],
    );
  }
}
