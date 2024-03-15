import 'dart:async';
import 'package:brocode/player.dart';
import 'package:brocode/utils/platform_utils.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:brocode/game_map.dart';
import 'package:flutter/material.dart';

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

    final cameraVerticalOffset = camera.viewport.size.y / 4;
    if(onPhone()) {
      await Flame.device.setLandscape();

      // add the joysticks
      final knobColor = Colors.white.withAlpha(220);
      Paint paint = Paint();
      paint.color = knobColor;

      final backgroundColor = Colors.white.withAlpha(100);
      Paint backgroundPaint = Paint();
      backgroundPaint.color = backgroundColor;

      final movementJoystick = JoystickComponent(
        knob: CircleComponent(radius: 20, paint: paint),
        background: CircleComponent(radius: 50, paint: backgroundPaint),
        margin: EdgeInsets.only(left: 50, bottom: cameraVerticalOffset + 40),
      );

      final shootJoystick = JoystickComponent(
        knob: CircleComponent(radius: 20, paint: paint),
        background: CircleComponent(radius: 50, paint: backgroundPaint),
        margin: EdgeInsets.only(right: 50, bottom: cameraVerticalOffset + 40),
      );

      camera.viewport.add(movementJoystick);
      camera.viewport.add(shootJoystick);

      player.movementJoystick = movementJoystick;
      player.shootJoystick = shootJoystick;
    }
    // will place the player at 1/4 of the height of the screen from the bottom
    camera.viewport.position.y += cameraVerticalOffset;

    camera.follow(player, snap: true);

    // add(FpsTextComponent(position: Vector2(0, size.y - 24)));
    // uncomment to print all the components in the world
    // await map.loaded;
    // printChildren(world);

    return super.onLoad();
  }

  @override
  void onPanStart(DragStartInfo info) {
    if(onPhone()) {
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
    if(onPhone()) {
      return;
    }
    player.isShooting = false;
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }
}