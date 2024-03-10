import 'dart:async';
import 'dart:ui';

import 'package:brocode/player.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:brocode/game_map.dart';

class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, TapCallbacks{
  late Player player;
  @override
  FutureOr<void> onLoad() async {
    await images.load('bullet_sprites/Bullet.png');
    final map = GameMap();
    player = Player(color: "Blue");

    world.addAll([
      map,
      player,
    ]);

    camera.follow(player);

    // uncomment to print all the components in the world
    // await map.loaded;
    // printChildren(world);

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    player.isShooting = true;
    super.onLongTapDown(event);
  }
  @override
  void onTapUp(TapUpEvent event) {
    player.isShooting = false;
    super.onTapUp(event);
  }
  @override
  void onTapCancel(TapCancelEvent event) {
    player.isShooting = false;
    super.onTapCancel(event);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}