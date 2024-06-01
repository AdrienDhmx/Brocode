import 'dart:async';

import 'package:brocode/app/router.dart';
import 'package:brocode/core/widgets/buttons.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/lobbies/lobby.dart';
import '../../core/services/lobby_service.dart';

class LobbyWaitingPage extends StatefulWidget {
  const LobbyWaitingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LobbyWaitingPage();
}

class _LobbyWaitingPage extends State<LobbyWaitingPage> {
  late Lobby lobby;
  late Timer updateLobbyTimer;

  void updateLobby() async {
    final updatedLobby = await LobbyService().getLobby();

    if(updatedLobby == null) { // lobby got deleted
      if(mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Le lobby à été fermer.")));
        leaveLobby();
      }
      return;
    } else if(updatedLobby.status == LobbyStatus.inGame) {
      startGame();
    }

    setState(() {
      lobby = updatedLobby;
    });
  }

  @override
  void initState() {
    lobby = LobbyService().lobby!;
    updateLobbyTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      updateLobby();
    });
    super.initState();
  }

  void leaveLobby() {
      updateLobbyTimer.cancel();
      LobbyService().leaveLobby();
      if(mounted && context.mounted) {
        context.go(Routes.mainMenu.route);
      }
  }

  void startGame() {
    Flame.device.setLandscape();
    GoRouter.of(context).go(Routes.game.route);
  }

  @override
  void dispose() {
    if(LobbyService().lobby?.status != LobbyStatus.inGame) {
      LobbyService().leaveLobby();
    }
    updateLobbyTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: NavigateBackButton(
          onPressed: leaveLobby,
        ),
        elevation: 2,
        shadowColor: theme.colorScheme.shadow,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        title: Text(lobby.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Joueurs présents", style: theme.textTheme.headlineSmall, textAlign: TextAlign.center,)
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lobby.activePlayer.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: ListTile(
                      title: Text(lobby.activePlayer[index].name),
                      textColor: theme.colorScheme.onPrimaryContainer,
                      tileColor: theme.colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
              ),
            ),
            if(LobbyService().isLobbyOwner)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TertiaryFlatButton(
                    text: "Lancer la partie",
                    onPressed: startGame,
                    theme: theme
                ),
              ),
          ],
        ),
      ),
    );
  }
}