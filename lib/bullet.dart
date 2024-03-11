import 'dart:async';

import 'package:flame/components.dart';
import 'brocode.dart';

class Bullet extends SpriteComponent with HasGameRef<Brocode>{
  Bullet({required Vector2 position}) : super(position: position);

  double moveSpeed = 600;
  late Vector2 direction;

  @override
  FutureOr<void> onLoad(){
    sprite = Sprite(game.images.fromCache('bullet_sprites/Bullet.png'));
    scale = Vector2.all(3);
    anchor = Anchor.center;
    direction = game.cursorPosition - (game.size/2 + game.camera.viewport.position);
    direction.y = -direction.y;
    angle = direction.angleToSigned(Vector2(1, 0));
    direction.y = -direction.y;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += direction.normalized() * moveSpeed * dt;
    super.update(dt);
  }
}