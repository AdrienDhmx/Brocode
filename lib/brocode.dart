import 'dart:async';
import 'package:brocode/player.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:brocode/game_map.dart';

class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, PanDetector, PointerMoveCallbacks  {
  late Player player;
  Vector2 cursorPosition = Vector2.zero();

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

    // will place the player at 1/4 of the height of the screen from the bottom
    camera.viewport.position.y += camera.visibleWorldRect.height / 4;
    camera.follow(player, snap: true);

    // add(FpsTextComponent(position: Vector2(0, size.y - 24)));
    // uncomment to print all the components in the world
    // await map.loaded;
    // printChildren(world);

    return super.onLoad();
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.isShooting = true;
    cursorPosition = info.raw.globalPosition.toVector2();
  }
  @override
  void onPanUpdate(DragUpdateInfo info) {
    cursorPosition = info.raw.globalPosition.toVector2();
    super.onPanUpdate(info);
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