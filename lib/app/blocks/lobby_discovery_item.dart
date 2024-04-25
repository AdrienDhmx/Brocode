import 'package:flutter/material.dart';

import '../../core/lobbies/lobby.dart';

class LobbyDiscoveryItem extends StatelessWidget {
  const LobbyDiscoveryItem({super.key, required this.lobby, required this.joinLobby});

  final Lobby lobby;
  final Function(Lobby lobby) joinLobby;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String subtitle = 'Ouvert par ${lobby.players[0].name}';

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.wifi),
          title: Text(lobby.name),
          subtitle: Text(subtitle),
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