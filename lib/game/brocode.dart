import 'dart:async';
import 'package:brocode/game/player.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:brocode/game/game_map.dart';
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/widgets.dart' as widgets;

import '../core/utils/platform_utils.dart';


class Brocode extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection, PanDetector, PointerMoveCallbacks  {
  late Player player;
  Vector2 cursorPosition = Vector2.zero();

  @override
  FutureOr<void> onLoad() async {
    await images.load('bullet_sprites/Bullet.png');
    await images.load('others/crosshair010.png');
    final map = GameMap();
    player = Player(color: "Green");

    //debugMode = true;
    world.addAll([
      map,
      player,
    ]);

    if(isOnPhone()) {
      await Flame.device.setLandscape();
      const cameraVerticalOffset = 50;
      camera.viewport.position.y += cameraVerticalOffset;
      camera.viewfinder.zoom = 0.75;

      // add the joysticks
      final movementJoystick = createVirtualJoystick(flutter_material.Colors.white,
          margin: const flutter_material.EdgeInsets.only(left: 50, bottom: cameraVerticalOffset + 40));
      final shootJoystick = createVirtualJoystick(flutter_material.Colors.white,
          margin: const flutter_material.EdgeInsets.only(right: 50, bottom: cameraVerticalOffset + 40));

      camera.viewport.add(movementJoystick);
      camera.viewport.add(shootJoystick);

      player.movementJoystick = movementJoystick;
      player.shootJoystick = shootJoystick;
    } else {
      // will place the player at 1/4 of the height of the screen from the bottom
      final cameraVerticalOffset = camera.viewport.size.y / 4;
      camera.viewport.position.y += cameraVerticalOffset;
      cursorPosition = size; //player starts the game looking to the right.
    }

    camera.follow(player, snap: true);

    // add(FpsTextComponent(position: Vector2(0, size.y - 24)));
    // uncomment to print all the components in the world
    // await map.loaded;
    // printChildren(world);

    return super.onLoad();
  }

  @override
  void onPanStart(DragStartInfo info) {
    if(isOnPhone()) {
      return;
    }
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
    if(isOnPhone()) {
      return;
    }
    player.isShooting = false;
  }
  @override
  void onPointerMove(PointerMoveEvent event) {
    cursorPosition = event.localPosition;
    super.onPointerMove(event);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}