import 'dart:async';
import 'package:brocode/game/objects/rounded_rectangle_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class HealthBar extends PositionComponent{
  late RoundedRectangleComponent innerRectangle;
  late RoundedRectangleComponent outerRectangle;
  late double borderRadius;
  final Color color = Colors.red;
  final int maxHealthPoints;
  int healthPoints;

  HealthBar(Vector2 position, Vector2 size, {this.maxHealthPoints = 100}): healthPoints=maxHealthPoints, super(size: size, position: position, anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() {
    borderRadius = size.y/3;
    double borderSize = size.y;
    innerRectangle = RoundedRectangleComponent(size: size, borderRadius: borderRadius, color: color, anchor: Anchor.centerLeft);
    innerRectangle.position.y = size.y/2;
    outerRectangle = RoundedRectangleComponent(size: Vector2(size.x+borderSize, size.y+borderSize), borderRadius: borderRadius, color: color.withOpacity(0.5));
    outerRectangle.position = size/2;


    addAll([
      innerRectangle,
      outerRectangle,
    ]);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updateInnerLength();
    super.update(dt);
  }

  void _updateInnerLength() {
    innerRectangle.size.x = size.x*(healthPoints/100);
  }

  void resetHealthPoints(){
    healthPoints = maxHealthPoints;
  }
}