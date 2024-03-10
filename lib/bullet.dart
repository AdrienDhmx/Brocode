import 'dart:async';

import 'package:flame/components.dart';

import 'brocode.dart';

class Bullet extends SpriteComponent with HasGameRef<Brocode>{
  Bullet({required Vector2 position}) : super(position: position);
  double moveSpeed = 600;
  @override
  FutureOr<void> onLoad(){
    sprite = Sprite(game.images.fromCache('bullet_sprites/Bullet.png'));
    scale = Vector2.all(3);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    position.x += moveSpeed * dt;
    super.update(dt);
  }
}