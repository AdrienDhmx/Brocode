import 'dart:async';

import 'package:brocode/app/screens/game.dart';
import 'package:brocode/core/lobbies/lobby_player.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:brocode/game/brocode.dart';
import 'package:brocode/game/game_map.dart';
import 'package:brocode/game/objects/health_bar.dart';
import 'package:brocode/game/overlays/respawn_timer.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/services.dart';

import '../core/utils/platform_utils.dart';
import 'objects/bullet.dart';
import 'objects/crosshair.dart';
import 'objects/ground_block.dart';
import 'objects/player_arm.dart';

enum PlayerColors {
  green,
  red,
  blue,
  yellow;

  const PlayerColors();

  String getLabel() {
    return name[0].toUpperCase() + name.substring(1);
  }
}

enum PlayerStates {
  idle(name: "Idle"),
  running(name: "Run"),
  jumping(name: "Jump"),
  shooting(name: "Shoot"),
  crouching(name: "Crouch"),
  dead(name: "Death");

  const PlayerStates({required this.name});

  final String name;

  Future<SpriteSheet> loadSpriteSheet(Brocode game, String color) async {
    return SpriteSheet(
        image: await game.images.load('character_sprites/$color/Gunner_${color}_$name.png'),
        srcSize: Vector2(48, 48),
    );
  }
}

abstract class Player extends SpriteAnimationComponent with HasGameReference<Brocode>, CollisionCallbacks, HasVisibility {
  Player({required this.id, this.color = PlayerColors.red, required this.pseudo, required this.spawnPos});

  final int id;
  final String pseudo;
  final PlayerColors color;
  late RectangleHitbox hitbox;
  late PlayerArm arm;
  late HealthBar healthBar;
  int lifeNumber = 3;
  final double maxHearDistance = 900;
  late Vector2 spawnPos;

  late SpriteAnimation runningAnimation;
  late SpriteAnimation idleAnimation;
  late SpriteAnimation jumpingAnimation;
  bool isAnimationReversed = false;

  //Movement Variables
  final Vector2 velocity = Vector2.zero();
  final double gravity = 20;
  final double jumpSpeed = 585;
  final double moveSpeed = 200;
  final double maxVelocity = 300;
  int horizontalDirection = 0;
  bool hasJumped = false;
  bool isOnGround = false;

  //Shoot Variables
  bool isShooting = false;
  final double weaponRange = 200; // susceptible de changer en fonction des armes
  final int magCapacity = 30; // susceptible de changer en fonction des armes
  final double effectiveReloadTime = 1.5; // susceptible de changer en fonction des armes
  final double rateOfFire = 0.3; // susceptible de changer en fonction des armes
  int shotCounter = 0;
  bool isReloading = false;
  double dtReload = 0;
  double dtlastShot = 0;

  //Death Variables
  double dtDeath = 0;
  static const double respawnDuration = 3;
  bool isDead = false;

  Map<PositionComponent, Set<Vector2>> collisions = {};

  Vector2 get shotDirection;

  FutureOr<void> _onLoad() async {
    priority = 1;
    String colorName = color.getLabel();
    SpriteSheet idleSpriteSheet = await PlayerStates.idle.loadSpriteSheet(game, colorName);
    SpriteSheet runningSpriteSheet = await PlayerStates.running.loadSpriteSheet(game, colorName);
    SpriteSheet jumpingSpriteSheet = await PlayerStates.jumping.loadSpriteSheet(game, colorName);
    SpriteSheet shootingSpriteSheet = await PlayerStates.shooting.loadSpriteSheet(game, colorName);

    idleAnimation = idleSpriteSheet.createAnimation(row: 0, stepTime: 0.1);
    runningAnimation = runningSpriteSheet.createAnimation(row: 0, stepTime: 0.1);
    jumpingAnimation = jumpingSpriteSheet.createAnimation(row: 0, stepTime: 0.4, loop: false);

    animation = idleAnimation;
    anchor = Anchor.center;
    scale = Vector2.all(2);
    position = spawnPos;
    hitbox = RectangleHitbox(
      size: Vector2(15, 30),
      anchor: Anchor.center,
      position: Vector2(size.x/2, size.y/2),
    );
    add(hitbox);

    arm = PlayerArm(
      owner: this,
      animationSheet: shootingSpriteSheet,
    );
    add(arm);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(isDead){
      death(dt);
    } else if(dtDeath != 0){ //reset death state
      dtDeath = 0;
      isVisible = true;
    }
    super.update(dt);
  }

  void _updatePosition(dt) {
    _updatePlayerPosition(dt);
    _updatePlayerSprite(dt);
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

  Future<void> _shoot(double dt) async {
    dtlastShot += dt; // met a jour le temps passé entre le dernier dir
    if(shotCounter == magCapacity || isReloading){
      _reload(dt);
    }
    if(isShooting && dtlastShot >= rateOfFire && !isReloading) { // il faut que le tir precedent se soit passé il y a plus lgt (ou égale) que la cadence de tir minimum
      Vector2 direction = shotDirection;
      double offset = arm.size.x / 2;
      dtlastShot = 0;
      shotCounter++;

      // when the arm in in the ground the bullet can't be added to the world
      // otherwise it will show above the map (inside the ground)
      if(!arm.isInGround()) {
        game.world.add(Bullet(
            position: arm.absolutePosition + direction.normalized() * offset * scale.y,
            direction: direction,
            owner: this,
            maxDistance: weaponRange - offset
        ));
      }

      arm.animation = arm.animation?.clone();
      if(this is MyPlayer){
        game.shootingAudioPool.start();
      } else if(this is OtherPlayer){
        double distance = (game.player.position - position).length;
        distance = distance > maxHearDistance? maxHearDistance : distance;
        game.shootingAudioPool.start(volume: (maxHearDistance-distance)/maxHearDistance);
      }
    }
  }

  void _reload(double dt) {
    isReloading = true;
    if(dtReload >= effectiveReloadTime) { // verifie si le temps passé a recharger est bien égale au temps de référence (variable globale) à recharger
      isReloading = false;
      shotCounter = 0;
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
        collisionNormal.normalize();

        // 0.44 to also include collisions on corners
        if ((fromRight.dot(collisionNormal) >= 0.44 && velocity.x < 0) // hit wall on the left
            || (fromLeft.dot(collisionNormal) >= 0.44 && velocity.x > 0)) { // hit wall on the right
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
        animation = jumpingAnimation;
      }
    }

    velocity.y = velocity.y.clamp(-jumpSpeed, maxVelocity);
    _handleCollision();
    position += velocity * dt;

    if(velocity.y > 0) { // falling
      isOnGround = false;
    }
  }

  void _updatePlayerSprite(double dt) {
    _updatePlayerSpriteOrientation();

    if(isOnGround) {
      if(horizontalDirection != 0) {
        animation = runningAnimation;
      } else {
        animation = idleAnimation;
      }
    } else if(velocity.y == maxVelocity && animation != jumpingAnimation) {
      animation = jumpingAnimation;
    }

    if((isFlippedHorizontally && horizontalDirection > 0) || (!isFlippedHorizontally && horizontalDirection < 0)) {
      if(!isAnimationReversed) {
        animation = animation?.reversed();
        isAnimationReversed = true;
      }
    } else if(isAnimationReversed) {
      if(isAnimationReversed) {
        isAnimationReversed = false;
        animation = animation?.reversed();
      }
    }
  }

  void _updatePlayerSpriteOrientation(){
    if(shotDirection.x < 0 && scale.x > 0){
      flipHorizontally();
    } else if(shotDirection.x >= 0 && scale.x < 0){
      flipHorizontally();
    }
  }

  void _updatePlayerArm(){
    Vector2 direction = shotDirection.clone();
    direction.y = -direction.y;
    direction.x = scale.x >= 0 ? direction.x : -direction.x;
    arm.angle = direction.angleToSigned(Vector2(1, 0));
  }

  Vector2 findMostIsolatedSpawnFromOtherPlayers() {
    Vector2 furthest = Vector2.zero();
    double furthestLength = 0;

    // Calculate the mean position of all players
    Vector2 currentMeanPlayerPos = position;
    for(final player in game.otherPlayers) {
      currentMeanPlayerPos += player.position;
    }

    final numberOfPlayers = game.otherPlayers.length + 1; // Including current player
    currentMeanPlayerPos = Vector2(
        currentMeanPlayerPos.x / numberOfPlayers,
        currentMeanPlayerPos.y / numberOfPlayers
    );

    // find furthest spawn from mean player position
    for(final spawn in game.map.spawnPoints) {
      final spawnPos = spawn.position * GameMap.scaleFactor;
      final currentLength = (currentMeanPlayerPos - spawnPos).length;
      if(currentLength > furthestLength) {
        furthest = spawnPos;
        furthestLength = currentLength;
      }
    }
    return furthest;
  }

  void death(double dt){
    if(dtDeath == 0){
      lifeNumber--;
      isVisible = false;
      if(lifeNumber > 0) {
        healthBar.resetHealthPoints();
        shotCounter = 0;
        dtlastShot = 0;

        position = findMostIsolatedSpawnFromOtherPlayers();
      }
    }
    dtDeath+=dt;
  }
}

class OtherPlayer extends Player{
  OtherPlayer({required int id, required PlayerColors color, required String pseudo, required Vector2 spawnPos}) : super(id: id, color: color, pseudo: pseudo, spawnPos: spawnPos);

  late TextComponent pseudoComponent;

  Vector2 _shotDirection = Vector2.zero();
  @override
  Vector2 get shotDirection => _shotDirection;

  void setShotDirection(Vector2 direction) {
    _shotDirection = direction;
  }

  @override
  FutureOr<void> onLoad() async {
    await _onLoad();
    pseudoComponent = TextComponent(
      text: pseudo,
      anchor: Anchor.center,
      position: Vector2(size.x/2, -8),
      scale: scale/6,
    );
    healthBar = HealthBar(Vector2(size.x/2, 0), Vector2(30, 3));
    addAll([
      pseudoComponent,
      healthBar,
    ]);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if(!isDead) {
      _updatePosition(dt);
      _shoot(dt);
      _updatePlayerArm();
    }
    super.update(dt);
  }

  @override
  void _updatePlayerSpriteOrientation() {
    if(shotDirection.x < 0 && scale.x > 0){
      flipHorizontally();
      pseudoComponent.flipHorizontally();
      healthBar.flipHorizontally();
    } else if(shotDirection.x >= 0 && scale.x < 0){
      flipHorizontally();
      pseudoComponent.flipHorizontally();
      healthBar.flipHorizontally();
    }
  }

}

class MyPlayer extends Player with KeyboardHandler {
  MyPlayer({required int id, required PlayerColors color, required String pseudo, required Vector2 spawnPos}) : super(id: id, color: color, pseudo: pseudo, spawnPos:spawnPos);

  late OtherPlayer? killedBy;
  late Crosshair crosshair;

  //mobile controller
  JoystickComponent? movementJoystick; //for mobile
  JoystickComponent? shootJoystick; //for mobile

  @override
  Vector2 get shotDirection {
    if(isOnPhone()){
      return shootJoystick!.delta.normalized();
    }
    return game.cursorPosition - (game.size/2 + game.camera.viewport.position) - (arm.absolutePosition - absolutePosition);
  }

  @override
  FutureOr<void> onLoad() async {
    await _onLoad();
    healthBar = HealthBar(Vector2(game.size.x/2,game.size.y-40), Vector2(300, 9));
    crosshair = Crosshair(maxDistance: weaponRange);
    game.add(crosshair..priority=1);
    game.add(healthBar..priority=1);
    return super.onLoad();
  }

  @override
  void update(double dt) async {
    if(isOnPhone()) {
      horizontalDirection = 0;
      if(movementJoystick != null) {
        if (movementJoystick!.direction != JoystickDirection.idle) {
          horizontalDirection = movementJoystick!.delta.x > 0 ? 1 : -1;
          hasJumped = movementJoystick!.delta.y <= -25;
        } else {
          hasJumped = false;
        }
      }
      isShooting = shootJoystick?.direction != JoystickDirection.idle;
    }
    if(!isDead) {
      _updatePosition(dt);
      _updatePlayerArm();
      crosshair.updateCrosshairPosition(shotDirection, scale.x < 0, game.cursorPosition.clone());
      _shoot(dt);
    }

    final lobbyPlayer = LobbyPlayer(
      name: pseudo, id: id,
      horizontalDirection: horizontalDirection.toDouble(),
      hasJumped: hasJumped,
      aimDirection: shotDirection,
      hasShot: isShooting,
      healthPoints: healthBar.healthPoints,
      isReloading: isReloading,
      isDead: isDead,
      position: position,
    );
    LobbyService().updatePlayer(lobbyPlayer);

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

    if(!isReloading && shotCounter > 0) {
      // reload
      isReloading = keysPressed.contains(LogicalKeyboardKey.keyR);
    }
    return true;
  }

  @override
  void onGameResize(Vector2 size) {
    healthBar.position = Vector2(game.size.x/2,game.size.y-40);
    super.onGameResize(size);
  }

  void takeDamage(int damage, OtherPlayer from){
    if(!isDead){
      if(damage >= healthBar.healthPoints){
        healthBar.healthPoints = 0;
        isDead = true;
        killedBy = from;

        game.followPlayer(killedBy!);
      } else {
        healthBar.healthPoints -= damage;
      }
    }
  }

  @override
  void death(double dt) {
    if(dtDeath == 0) {
      game.overlays.add(Overlays.respawnTimer.name);
    }

    super.death(dt);

    if(lifeNumber == 0) {
      lifeNumber = -1;

      game.remove(healthBar);
      game.remove(crosshair);
      game.remove(game.magazine);
      game.remove(game.lifeheart);

      game.followPlayer(killedBy!);
      game.mouseCursor = SystemMouseCursors.basic;
      game.overlays.add(Overlays.gameOver.name);
    } else if (lifeNumber > 0 && dtDeath >= Player.respawnDuration) {
      game.overlays.remove(Overlays.respawnTimer.name);
      game.followPlayer(this);
      isDead = false;
    }
  }
}