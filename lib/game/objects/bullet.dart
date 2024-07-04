import 'dart:async';

import 'package:brocode/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import '../brocode.dart';
import 'ground_block.dart';

class Bullet extends SpriteComponent with HasGameReference<Brocode>, CollisionCallbacks {
  Bullet({required Vector2 position, required this.direction, required this.owner, this.maxDistance = 100}) : super(position: position);

  final Player owner;
  double moveSpeed = 600;
  Vector2 direction;
  late RectangleHitbox hitbox;
  double traveledDistance = 0;
  double maxDistance;

  @override
  FutureOr<void> onLoad(){
    sprite = Sprite(game.images.fromCache('bullet_sprites/Bullet.png'));
    scale = Vector2.all(3);
    anchor = Anchor.center;
    maxDistance *= owner.scale.y;
    priority = -1;

    direction.y = -direction.y;
    angle = direction.angleToSigned(Vector2(1, 0));
    direction.y = -direction.y;

    hitbox = RectangleHitbox(size: size, anchor: Anchor.topLeft);
    add(hitbox);

    return super.onLoad();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock) {
      parent?.remove(this);
    } else if(other is MyPlayer){
      other.takeDamage(10, owner as OtherPlayer);
      parent?.remove(this);
    } else if(other is OtherPlayer){
      parent?.remove(this);
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void update(double dt) {
    final dtPosition = direction.normalized() * moveSpeed * dt;
    position += dtPosition;

    traveledDistance += dtPosition.length;
    if(traveledDistance > maxDistance) {
      parent?.remove(this);
    }

    super.update(dt);
  }
}