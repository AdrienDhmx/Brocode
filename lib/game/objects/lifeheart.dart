import 'dart:async';
import 'package:brocode/game/brocode.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'dart:ui';
import 'package:flame/palette.dart';
class ImageLifeheart extends SpriteComponent with HasGameReference<Brocode> {
  late TextComponent textComponent;
  @override
  FutureOr<void> onLoad() async {
    final spriteSheet = SpriteSheet(
      image: game.images.fromCache('others/heart.png'),
      srcSize: Vector2.all(32.0),
    );
    scale = Vector2.all(2);
    sprite = spriteSheet.getSprite(0, 0);
    anchor = Anchor.topLeft;
    position = Vector2(40, 90);

    // final regular = TextPaint(style: style);
    textComponent = TextComponent(
      text: "3",
      position: Vector2(-5, 8),
      scale: Vector2.all(0.45),
    );
    add(textComponent);

    return super.onLoad();
  }
  @override
  FutureOr<void> update(double dt) {
    super.update(dt);
  }
}