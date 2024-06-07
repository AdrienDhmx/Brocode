import 'dart:async';
import 'dart:ui';

import 'package:brocode/game/objects/rounded_rectangle_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent{
  late RoundedRectangleComponent innerRectangle;
  late RoundedRectangleComponent outerRectangle;
  final double borderRadius = 1;
  final Color color = Colors.red;

  HealthBar(Vector2 position, Vector2 size): super(size: size, position: position, anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() {
    innerRectangle = RoundedRectangleComponent(size: size, borderRadius: borderRadius, color: color);
    innerRectangle.priority = 0;
    innerRectangle.position = size/2;
    outerRectangle = RoundedRectangleComponent(size: Vector2(size.x+3, size.y+3), borderRadius: borderRadius, color: color.withOpacity(0.5));
    outerRectangle.position = size/2;
    outerRectangle.priority = 1;

    addAll([
      innerRectangle,
      outerRectangle,
    ]);
    return super.onLoad();
  }

  void updateInnerLength(double healthPercentage) {
    innerRectangle.size = size*healthPercentage;
  }
}