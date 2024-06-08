import 'package:flutter/material.dart';

import '../../core/lobbies/lobby.dart';

class LobbyDiscoveryItem extends StatelessWidget {
  const LobbyDiscoveryItem({super.key, required this.lobby, required this.joinLobby});

  final Lobby lobby;
  final Function(Lobby lobby) joinLobby;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String nbPlayer = '${lobby.activePlayers.length} joueur${lobby.activePlayers.length > 1 ? "s" : ""}';
    String openBy = 'Ouvert par ${lobby.players[0].name}';

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.wifi),
          title: Text(lobby.name, style: theme.textTheme.titleMedium,),
          subtitle: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(openBy),
              Text(nbPlayer),
            ],
          ),
          trailing: IconButton(
            onPressed: () => joinLobby(lobby),
            icon: Icon(Icons.login_rounded, color: theme.colorScheme.primary,),
          ),
          isThreeLine: false,
        ),
      ),
    );
  }

}