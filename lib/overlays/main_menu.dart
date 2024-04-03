

import 'dart:ui';

import 'package:brocode/brocode.dart';
import 'package:brocode/main.dart';
import 'package:brocode/overlays/widgets/buttons.dart';
import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../utils/platform_utils.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key, required this.game});

  final Brocode game;

  @override
  State<StatefulWidget> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  void startGame() {
    widget.game.overlays.remove(Routes.mainMenu.name);
  }

  void createLobby() {
    // open bottomSheet or Dialog, or go to another page ?
  }

  void seeAvailableLobbies() {
    // open bottomSheet or Dialog, or go to another page ?
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
            Padding(
              padding: EdgeInsets.only(bottom: isOnPhone() ? 10 : 30),
              child: Text("Brocode", textAlign: TextAlign.center, style: theme.textTheme.headlineLarge,),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  transform: Matrix4.translation(Vector3(0, 8, 0)), // move the image downward by 8 pixels
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/character_sprites/Blue/Gunner_Blue_Run.png'),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                PrimaryFlatButton(text: "Démo", onPressed: startGame, theme: theme, width: 250, height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                    child: TertiaryFlatButton(text: "Créer lobby", onPressed: createLobby, theme: theme, width: 200),
                ),
                TertiaryFlatButton(text: "Rejoindre lobby", onPressed: seeAvailableLobbies, theme: theme, width: 200),
              ],
            ),
          ],
        ),
      ),
    );
  }

}