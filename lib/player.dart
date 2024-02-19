import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';


class Player extends SpriteComponent with HasGameReference<Brocode>, KeyboardHandler{
  Player({this.color = "Red"});

  final String color;
  int horizontalDirection = 0;
  double moveSpeed = 200;

  @override
  FutureOr<void> onLoad() async {

    final spriteSheet = SpriteSheet(
        image: await game.images.load('character_sprites/$color/Gunner_${color}_Idle.png'),
        srcSize: Vector2(48, 48),
    );

    sprite = spriteSheet.getSprite(0, 0);
    anchor = Anchor.center;
    scale = Vector2.all(2);
    position = game.size/2;
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

  void _updatePlayerPosition(double dt) {
    Vector2 velocity = Vector2.all(0);
    if(isFlippedHorizontally && horizontalDirection > 0){
      flipHorizontally();
    } else if(!isFlippedHorizontally && horizontalDirection < 0){
      flipHorizontally();
    }
    velocity.x = horizontalDirection*moveSpeed;
    position += velocity*dt;
  }
}