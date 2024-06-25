import 'dart:async';
import 'dart:convert';
import 'package:brocode/game/brocode.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';


class ImageMagazine extends SpriteComponent with HasGameReference<Brocode> {
  late TextComponent textComponent;
  @override
  FutureOr<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: game.images.fromCache('character_sprites/Green/Gunner_Green_Shoot.png'),
      srcSize: Vector2.all(48.0),
    );
    scale = Vector2.all(2);
    sprite = spriteSheet.getSprite(0, 0);
    anchor = Anchor.topLeft;
    position = Vector2(20, 20);

    textComponent = TextComponent(
      text: "30/30",
      position: Vector2(50, 15),
      scale: Vector2.all(0.45),
    );
    add(textComponent);

    return super.onLoad();
  }
  @override
  FutureOr<void> update(double dt) {
    super.update(dt);
    textComponent.text = "${game.player.magCapacity-game.player.shotCounter}/${game.player.magCapacity}";
  }
}