import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

class RoundedRectangleComponent extends PositionComponent {
  final double borderRadius;
  final Paint paint;

  RoundedRectangleComponent({
    required Vector2 size,
    this.borderRadius = 10.0,
    Color color = Colors.red,
    Anchor anchor = Anchor.center,
  })  : paint = Paint()..color = color,
        super(size: size, anchor: anchor);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect, paint);
  }
}