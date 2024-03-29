

import 'dart:ui';

import 'package:brocode/brocode.dart';
import 'package:brocode/main.dart';
import 'package:brocode/overlays/widgets/buttons.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/platform_utils.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key, required this.game});

  final Brocode game;

  @override
  State<StatefulWidget> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  void startGame() {
    // can add in game overlays here (health bar, ammo...)

    widget.game.overlays.remove(Routes.mainMenu.name);
  }

  void createLobby() {

  }

  void seeAvailableLobbies() {

  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Brocode", textAlign: TextAlign.center, style: theme.textTheme.headlineLarge,),
            SizedBox(height: isOnPhone() ? 10 : 30,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  transform: Matrix4.translation(Vector3(0, 8, 0)),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/character_sprites/Blue/Gunner_Blue_Run.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                primaryFlatButton(theme, "Démo", startGame, width: 250, height: 50),
                const SizedBox(height: 20,),
                tertiaryFlatButton(theme, "Créer lobby", createLobby, width: 200),
                const SizedBox(height: 20,),
                tertiaryFlatButton(theme, "Rejoindre lobby", seeAvailableLobbies, width: 200),
              ],
            ),
          ],
        ),
      ),
    );
  }

}