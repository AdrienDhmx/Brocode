import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/platform_utils.dart';
import '../../core/widgets/buttons.dart';
import '../modals/create_lobby_modal.dart';
import '../router.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<StatefulWidget> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  void startGame() {
    context.go(Routes.game.route); // go clear the navigation history, use push otherwise (context.pop())
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