

import 'dart:async';
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../player.dart';
import 'ground_block.dart';

class PlayerArm extends SpriteAnimationComponent with CollisionCallbacks {

  final Player owner;
  final SpriteSheet animationSheet;

  PlayerArm({required this.owner, required this.animationSheet});

  bool _isInGround = false;

  @override
  FutureOr<void> onLoad() async {
    priority = 1;

    animation = animationSheet.createAnimation(row: 0, stepTime: 0.1, loop: false);
    anchor = const Anchor(0.35, 0.45);
    position = Vector2(18, 22);

    final RectangleHitbox hitbox = RectangleHitbox(
      size: Vector2(3, 20),
      anchor: Anchor.center,
      position: Vector2(size.x / 2 + 11, size.y / 2 - 2.5),
      angle: pi / 2,
    );
    add(hitbox);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is GroundBlock) {
      _isInGround = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is GroundBlock) {
      _isInGround = false;
    }
  }

  bool isInGround() {
    return _isInGround;
  }
}