
import 'dart:async';

import 'package:brocode/app/router.dart';
import 'package:brocode/core/widgets/buttons.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/lobbies/lobby.dart';
import '../../core/services/lobby_service.dart';

class LobbyWaitingPage extends StatefulWidget {
  const LobbyWaitingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LobbyWaitingPage();
}

class _LobbyWaitingPage extends State<LobbyWaitingPage> {
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();
    _periodicTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if(mounted) {
        if(LobbyService().lobby?.status == LobbyStatus.inGame) {
          startGame();
        } else {
          setState(() {}); // trigger build
        }
      }
    });
  }

  void leaveLobby() {
      LobbyService().leaveLobby();
      context.go(Routes.mainMenu.route);
  }

  void startGame() {
    Flame.device.setLandscape();
    GoRouter.of(context).go(Routes.game.route);
  }

  void copyLobbyId(BuildContext context, String lobbyId) {
    Clipboard.setData(ClipboardData(text: lobbyId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("L'identifiant du lobby à copier !"))
    );
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    if(LobbyService().lobby?.status != LobbyStatus.inGame) {
      LobbyService().leaveLobby();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final lobby = LobbyService().lobby;
    if(lobby == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Ce lobby n'existe plus !",
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 12,),
          BackButton(onPressed: leaveLobby),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: leaveLobby,
        ),
        elevation: 2,
        shadowColor: theme.colorScheme.shadow,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        title: Text(lobby.name),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: OutlinedButton(onPressed: () => copyLobbyId(context, lobby.id),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.copy_rounded, size: 20,),
                  const SizedBox(width: 8,),
                  Text(lobby.id),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${lobby.activePlayers.length} joueur${lobby.activePlayers.length > 1 ? "s" : ""} présents",
                  style: theme.textTheme.headlineSmall, textAlign: TextAlign.center,
                )
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: lobby.activePlayers.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: ListTile(
                      title: Text(lobby.activePlayers[index].name),
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
                  theme: theme,
                  height: 50,
                ),
              ),
          ],
        ),
      ),
    );
  }
}