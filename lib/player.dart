import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:brocode/objects/ground_block.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

import 'bullet.dart';


class Player extends SpriteComponent with HasGameReference<Brocode>, KeyboardHandler, CollisionCallbacks{
  Player({this.color = "Red"});


  final String color;

  final Vector2 velocity = Vector2.zero();
  final double gravity = 20;
  final double jumpSpeed = 450;
  final double moveSpeed = 200;
  final double maxVelocity = 300;
  int horizontalDirection = 0;

  late RectangleHitbox hitbox;
  bool hasJumped = false;
  bool isOnGround = false;

  final double weaponsRate = 0.5;
  bool isShooting = false;
  double lastShoot = 0;

  Map<PositionComponent, Set<Vector2>> collisions = {};

  @override
  FutureOr<void> onLoad() async {
    priority = 1;
    final spriteSheet = SpriteSheet(
        image: await game.images.load('character_sprites/$color/Gunner_${color}_Idle.png'),
        srcSize: Vector2(48, 48),
    );

    sprite = spriteSheet.getSprite(0, 0);
    anchor = Anchor.center;
    scale = Vector2.all(2);
    position = Vector2(game.size.x / 2, 1400);
    hitbox = RectangleHitbox(
        size: Vector2(19, 33),
        anchor: Anchor.center,
        position: Vector2(size.x/2-3, size.y/2-1),
    );
    add(hitbox);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }

    _updatePlayerPosition(dt);
    _shoot(dt);

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    // left Q or <-
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyQ) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) ? -1 : 0;
    // right D or ->
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) ? 1 : 0;
    // jump space
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock) {
      collisions[other] = intersectionPoints;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is GroundBlock) {
      collisions.remove(other);
    }
    super.onCollisionEnd(other);
  }

  void _shoot(double dt){
    lastShoot += dt;
    if(isShooting && lastShoot >= weaponsRate) {
      lastShoot = 0;
      game.world.add(Bullet(position: position + Vector2(size.x/2-6, -6)));
    }
  }

  void _handleCollision() {
    collisions.forEach((component, intersectionPoints) {

      final Vector2 fromAbove = Vector2(0, -1);
      final Vector2 fromUnder = Vector2(0, 1);
      final Vector2 fromRight = Vector2(1, 0);
      final Vector2 fromLeft = Vector2(-1, 0);

      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;
        final collisionNormal = hitbox.absoluteCenter - mid;
        //final separationDistance = (hitbox.size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // 0.5 to also include collisions on corners
        if (fromRight.dot(collisionNormal) > 0.5 && velocity.x < 0) { // hit wall on the left
          velocity.x = 0;
        } else if (fromLeft.dot(collisionNormal) > 0.5 && velocity.x > 0) { // hit wall on the right
          velocity.x = 0;
        }

        if (fromAbove.dot(collisionNormal) > 0.9 && velocity.y > 0) { // hit ground
          velocity.y = 0; // cancel gravity
          isOnGround = true; // can jump
        } else if (fromUnder.dot(collisionNormal) > 0.9 && velocity.y < 0) { // hit ceiling
          velocity.y = 0;
        }
      }
    });
  }

  void _updatePlayerPosition(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    velocity.y += gravity * dt * 100;

    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
      hasJumped = false;
    }

    velocity.y = velocity.y.clamp(-jumpSpeed, maxVelocity);
    _handleCollision();
    position += velocity * dt;

    if(velocity.y > 0) { // falling
      isOnGround = false;
    }
  }
}