import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';


class Player extends SpriteComponent with HasGameReference<Brocode>{
  Player({this.color = "Red"});

  final String color;

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
}