import 'package:brocode/core/services/lobby_service.dart';
import 'package:brocode/game/overlays/pause_menu.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';

import '../../game/brocode.dart';

enum Overlays {
  pause(name: "Pause");

  const Overlays({required this.name});

  final String name;
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GameScreen();
}

class _GameScreen extends State<GameScreen> {
  @override
  void initState() {
    LobbyService().startGame();
    super.initState();
  }

  @override
  void dispose() async {
    super.dispose();
    await LobbyService().leaveLobby();
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget<Brocode>.controlled(
      gameFactory: Brocode.new,
      initialActiveOverlays: [
        Overlays.pause.name,
      ],
      overlayBuilderMap: {
        Overlays.pause.name: (context, game) => PauseMenu(game: game,),
      },
    );
  }

}