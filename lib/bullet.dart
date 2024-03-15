import 'dart:async';
import 'dart:math';

import 'package:brocode/player.dart';
import 'package:brocode/utils/platform_utils.dart';
import 'package:flame/components.dart';
import 'brocode.dart';

class Bullet extends SpriteComponent with HasGameRef<Brocode>{
  Bullet({required Vector2 position, required this.owner}) : super(position: position);

  final Player owner;
  double moveSpeed = 600;
  late Vector2 direction;

  @override
  FutureOr<void> onLoad(){
    sprite = Sprite(game.images.fromCache('bullet_sprites/Bullet.png'));
    scale = Vector2.all(3);
    anchor = Anchor.center;
    if(onPhone()) {
      direction = owner.shootJoystick!.delta.normalized();
      direction.y = -direction.y;
      angle = direction.angleToSigned(Vector2(1, 0));
      direction.y = -direction.y;
    } else {
      direction = game.cursorPosition - (game.size/2 + game.camera.viewport.position);
      direction.y = -direction.y;
      angle = direction.angleToSigned(Vector2(1, 0));
      direction.y = -direction.y;
    }

    return super.onLoad();
  }

  @override
  void update(double dt) {
    position += direction.normalized() * moveSpeed * dt;
    super.update(dt);
  }
}