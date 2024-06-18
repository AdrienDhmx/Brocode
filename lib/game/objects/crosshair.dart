import 'dart:async';
import 'package:brocode/game/brocode.dart';
import 'package:flame/components.dart';

class Crosshair extends SpriteComponent with HasGameReference<Brocode> {
  Crosshair({this.maxDistance = 100});

  final double maxDistance;
  late Sprite crossHair;
  late Sprite redCrossHair;

  @override
  FutureOr<void> onLoad() async {
    crossHair = Sprite(game.images.fromCache('others/crosshair010.png'));
    redCrossHair = Sprite(game.images.fromCache('others/red_crosshair.png'));
    sprite = crossHair;
    size = Vector2.all(10);
    scale = Vector2.all(2);
    anchor = Anchor.center;
    return super.onLoad();
  }
  void updateCrosshairPosition(Vector2 shotDirection, isFlipped, Vector2 cursorPosition) {
    if(isFlipped){
      shotDirection.x = -shotDirection.x;
    }
    position = cursorPosition;
    if(shotDirection.length > maxDistance*scale.y){
      sprite = redCrossHair;
    } else{
      sprite = crossHair;
    }
  }
}