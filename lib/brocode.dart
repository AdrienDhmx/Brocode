import 'dart:async';
import 'dart:ui';

import 'package:brocode/player.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:brocode/game_map.dart';

class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, PanDetector  {
  late Player player;
  int followingPlayerCounter = 10; // hack to let the camera move to the player before following it

  @override
  FutureOr<void> onLoad() async {
    await images.load('bullet_sprites/Bullet.png');
    final map = GameMap();
    player = Player(color: "Blue");

    //debugMode = true;
    world.addAll([
      map,
      player,
    ]);

    // will place the player at 1/4 of the height from the bottom the screen
    camera.viewport.position.y += camera.visibleWorldRect.height / 4;

    // add(FpsTextComponent(position: Vector2(0, size.y - 24)));
    // uncomment to print all the components in the world
    // await map.loaded;
    // printChildren(world);

    return super.onLoad();
  }

  @override
  void update(dt) {
    super.update(dt);
    if(followingPlayerCounter == 0) {
      // use 0.98 speed of player to make the camera feel not too responsive without lagging behind
      camera.follow(player, maxSpeed: player.moveSpeed * 0.98);
      followingPlayerCounter = -1;
    } else if(followingPlayerCounter > 0) {
      camera.moveTo(player.position, speed: double.infinity);
    } else {
      followingPlayerCounter--;
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.isShooting = true;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.isShooting = false;
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}