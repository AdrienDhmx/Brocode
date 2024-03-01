import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:brocode/map.dart';


class Player extends SpriteComponent with HasGameReference<Brocode>, KeyboardHandler, CollisionCallbacks{
  Player({this.color = "Red"});

  final String color;
  int horizontalDirection = 0;
  double moveSpeed = 200;
  bool isOnGround = false;
  double gravity = 100;

  @override
  FutureOr<void> onLoad() async {

    final spriteSheet = SpriteSheet(
        image: await game.images.load('character_sprites/$color/Gunner_${color}_Idle.png'),
        srcSize: Vector2(48, 48),
    );

    sprite = spriteSheet.getSprite(0, 0);
    anchor = Anchor.center;
    scale = Vector2.all(2);
    position = Vector2(game.size.x / 2, 1400);

    add(
        RectangleHitbox(
          size: Vector2(19, 33),
          anchor: Anchor.center,
          position: Vector2(size.x/2-3, size.y/2-1)
        ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerPosition(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {

    horizontalDirection = 0;
    horizontalDirection += keysPressed.contains(LogicalKeyboardKey.keyQ) || keysPressed.contains(LogicalKeyboardKey.arrowLeft) ? -1 : 0;
    horizontalDirection += keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight) ? 1 : 0;

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if(!isOnGround) {
      print("Collision at ${intersectionPoints.elementAt(0)}, with player position: ${position}");
    }
    if(other is RectangleHitbox || other is Map){
      isOnGround = true;
    }
    super.onCollision(intersectionPoints, other);
  }


  void _updatePlayerPosition(double dt) {
    Vector2 velocity = Vector2.all(0);
    if(isFlippedHorizontally && horizontalDirection > 0){
      flipHorizontally();
    } else if(!isFlippedHorizontally && horizontalDirection < 0){
      flipHorizontally();
    }
    velocity.x = horizontalDirection*moveSpeed;
    if(!isOnGround){
      velocity.y = gravity;
    }
    position += velocity*dt;
  }
}