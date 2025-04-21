import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

class SnappingScrollPhysics extends ScrollPhysics {
  final double itemWidth;

  const SnappingScrollPhysics({
    super.parent,
    required this.itemWidth,
  });

  @override
  SnappingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SnappingScrollPhysics(
      parent: buildParent(ancestor),
      itemWidth: itemWidth,
    );
  }

  double _getNearestScrollOffset(ScrollMetrics position) {
    return (position.pixels / itemWidth).roundToDouble() * itemWidth;
  }

  @override
  Simulation? createBallisticSimulation(ScrollMetrics position, double velocity) {
    final double target = _getNearestScrollOffset(position);

    if (target == position.pixels) return null;

    return SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 0.1,
        stiffness: 150.0,
        ratio: 1,
      ),
      position.pixels,
      target,
      velocity,
    );
  }
}
