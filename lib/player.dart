import 'dart:async';

import 'package:brocode/brocode.dart';
import 'package:brocode/objects/ground_block.dart';
import 'package:brocode/utils/platform_utils.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';

import 'bullet.dart';


class Player extends SpriteComponent with HasGameReference<Brocode>, KeyboardHandler, CollisionCallbacks{
  Player({this.color = "Red"});

  final String color;

  final Vector2 velocity = Vector2.zero();
  final double gravity = 20;
  final double jumpSpeed = 450;
  final double moveSpeed = 200;
  final double maxVelocity = 300;
  int horizontalDirection = 0;


  JoystickComponent? movementJoystick;
  JoystickComponent? shootJoystick;

  static const int magCapacity = 30; // susceptible de changer en fonction des armes
  final double effectiveReloadTime = 1.5; // susceptible de changer en fonction des armes
  int countDownShot = magCapacity;
  bool isReloading = false;
  double dtReload = 0;
  late RectangleHitbox hitbox;
  bool hasJumped = false;
  bool isOnGround = false;

  final double rateOfFire = 0.3; // 
  bool isShooting = false;
  double dtlastShot = 0;

  Map<PositionComponent, Set<Vector2>> collisions = {};

  @override
  FutureOr<void> onLoad() async {
    priority = 1;
    final spriteSheet = SpriteSheet(
        image: await game.images.load('character_sprites/$color/Gunner_${color}_Idle.png'),
        srcSize: Vector2(48, 48),
    );

    sprite = spriteSheet.getSprite(0, 0);
    anchor = Anchor.center;
    scale = Vector2.all(2);
    position = Vector2(game.size.x / 2, 1400);
    hitbox = RectangleHitbox(
        size: Vector2(19, 33),
        anchor: Anchor.center,
        position: Vector2(size.x/2-3, size.y/2-1),
    );
    add(hitbox);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(onPhone()) {
      horizontalDirection = 0;
      if (movementJoystick!.direction != JoystickDirection.idle) {
        horizontalDirection = movementJoystick!.delta.x > 0 ? 1 : -1;
        hasJumped = movementJoystick!.delta.y <= -25;
      } else {
        hasJumped = false;
      }

      isShooting = shootJoystick!.direction != JoystickDirection.idle;
    }

    if (horizontalDirection < 0 && scale.x > 0) {
      flipHorizontally();
    } else if (horizontalDirection > 0 && scale.x < 0) {
      flipHorizontally();
    }

    _updatePlayerPosition(dt);
    _shoot(dt);

    super.update(dt);
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    // left Q or <-
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyQ) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) ? -1 : 0;
    // right D or ->
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) ? 1 : 0;
    // jump space
    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    if(!isReloading) {
      // reload
      isReloading = keysPressed.contains(LogicalKeyboardKey.keyR);
    }
    return true;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock) {
      collisions[other] = intersectionPoints;
    }
    super.onCollision(intersectionPoints, other);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is GroundBlock) {
      collisions.remove(other);
    }
    super.onCollisionEnd(other);
  }

  void _shoot(double dt){
    dtlastShot += dt; // met a jour le temps passé entre le dernier dir
    if(countDownShot == 0 || isReloading){
      _reload(dt);
    }
    if(isShooting && dtlastShot >= rateOfFire && !isReloading) { // il faut que le tir precedent se soit passé il y a plus lgt (ou égale) que la cadence de tir minimum
      dtlastShot = 0;
      countDownShot--;
      game.world.add(Bullet(position: position + Vector2(0, -5), owner: this));
    }
  }
  void _reload(double dt) {
    isReloading = true;
    if(dtReload >= effectiveReloadTime) { // verifie si le temps passé a recharger est bien égale au temps de référence (variable globale) à recharger
      isReloading = false;
      countDownShot = magCapacity;
      dtReload = 0;
    }
    if(isReloading) {
      dtReload += dt;
    }
  }
  void _handleCollision() {
    collisions.forEach((component, intersectionPoints) {

      final Vector2 fromAbove = Vector2(0, -1);
      final Vector2 fromUnder = Vector2(0, 1);
      final Vector2 fromRight = Vector2(1, 0);
      final Vector2 fromLeft = Vector2(-1, 0);

      if (intersectionPoints.length == 2) {
        final mid = (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) / 2;
        final collisionNormal = hitbox.absoluteCenter - mid;
        //final separationDistance = (hitbox.size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // 0.5 to also include collisions on corners
        if (fromRight.dot(collisionNormal) > 0.5 && velocity.x < 0) { // hit wall on the left
          velocity.x = 0;
        } else if (fromLeft.dot(collisionNormal) > 0.5 && velocity.x > 0) { // hit wall on the right
          velocity.x = 0;
        }

        if (fromAbove.dot(collisionNormal) > 0.9 && velocity.y > 0) { // hit ground
          velocity.y = 0; // cancel gravity
          if(fromLeft.dot(collisionNormal) < 0.2 && fromRight.dot(collisionNormal) < 0.2) {
            isOnGround = true; // can jump
          }
        } else if (fromUnder.dot(collisionNormal) > 0.9 && velocity.y < 0) { // hit ceiling
          velocity.y = 0;
        }
      }
    });
  }

  void _updatePlayerPosition(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    // the gravity needs to take into account the time passed between the updates
    // it's multiplied by 100 because dt is mainly between 0.02 and 0.002 seconds which would decrease the effect of the gravity too much
    velocity.y += gravity * dt * 100;

    if (hasJumped) {
      if (isOnGround) {
        velocity.y = -jumpSpeed;
        isOnGround = false;
      }
    }

    velocity.y = velocity.y.clamp(-jumpSpeed, maxVelocity);
    _handleCollision();
    position += velocity * dt;

    if(velocity.y > 0) { // falling
      isOnGround = false;
    }
  }

}