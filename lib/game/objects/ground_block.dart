import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

import '../brocode.dart';

class GroundBlock extends PositionComponent with HasGameRef<Brocode>  {
  GroundBlock(this.object, this.scaleFactor);

  final double scaleFactor;
  final TiledObject object;
  late RectangleHitbox hitbox;

  @override
  FutureOr<void> onLoad() {
    hitbox = RectangleHitbox(
      size: object.size * scaleFactor,
      position: object.position * scaleFactor,
      anchor: Anchor.topLeft,
    );
    add(hitbox);
    return super.onLoad();
  }

}