
import 'package:flutter/cupertino.dart';

class TabSelector extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  TabSelector(this.currentIndex, this.onTap);
  @override
  Widget build(_) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: ['Available','Consumed'].asMap().entries.map((e) {
      final sel = e.key==currentIndex;
      return GestureDetector(
        onTap: ()=>onTap(e.key),
        child: Container( /* your style for sel vs un-sel */ ),
      );
    }).toList(),
  );
}