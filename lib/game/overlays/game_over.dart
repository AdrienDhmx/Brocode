

import 'package:brocode/core/widgets/buttons.dart';
import 'package:brocode/game/player.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/utils/platform_utils.dart';
import '../brocode.dart';

class GameOver extends StatefulWidget {
  final Brocode game;

  const GameOver({super.key, required this.game});

  @override
  State<StatefulWidget> createState() => _GameOver();
}

class _GameOver extends State<GameOver> {
  void navigateHome(BuildContext context) async {
    if(isOnPhone()) {
      await Flame.device.setPortrait();
    }
    if(context.mounted) {
      context.go(Routes.mainMenu.route);
    }
  }

  void nextPlayer() {
    widget.game.followNextPlayer();
    setState(() { }); // trigger rebuild of widget
  }

  void previousPlayer() {
    widget.game.followPreviousPlayer();
    setState(() { }); // trigger rebuild of widget
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 70,
        child: Material(
          color: theme.colorScheme.surfaceContainer,
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    "Partie terminée",
                    style: theme.textTheme.headlineMedium,
                  ),
                ),

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(widget.game.otherPlayers.length > 1)
                        IconButton(
                            onPressed: previousPlayer,
                            icon: const Icon(Icons.arrow_back_ios_new_rounded)
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          widget.game.followingPlayer?.pseudo ?? "",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if(widget.game.otherPlayers.length > 1)
                        IconButton(
                          onPressed: nextPlayer,
                          icon: const Icon(Icons.arrow_forward_ios_rounded),
                        ),
                    ]
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: PrimaryFlatButton(
                      text: "Home",
                      onPressed: () => navigateHome(context),
                      theme: theme,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}