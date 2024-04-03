import 'dart:async';
import 'package:brocode/brocode.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';


class Crosshair extends SpriteComponent with HasGameReference<Brocode> {
  Crosshair({this.maxDistance = 100});

  final double maxDistance;

  @override
  FutureOr<void> onLoad() async {
    sprite = Sprite(game.images.fromCache('others/crosshair010.png'));
    size = Vector2.all(10);
    anchor = Anchor.center;
    return super.onLoad();
  }
  void updateCrosshairPosition(Vector2 shotDirection, isFlipped, Vector2 basePosition) {
    shotDirection.x = isFlipped ? -shotDirection.x : shotDirection.x;
    position = shotDirection.normalized()*maxDistance+basePosition;


  }
}