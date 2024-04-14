
import 'package:bonsoir/bonsoir.dart';
import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:flutter/material.dart';

class LobbyDiscoveryItem extends StatelessWidget {
  const LobbyDiscoveryItem({super.key, required this.service, required this.joinLobby});

  final BonsoirService service;
  final Function(LobbyConnectionInfo) joinLobby;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final LobbyConnectionInfo? connectionInfo = LobbyConnectionInfo.fromJson(service.attributes);

    if(connectionInfo == null) {
      return const SizedBox();
    }

    String subtitle = 'Ouvert par ${service.attributes["ownerName"]}';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.wifi),
        title: Text(service.name),
        subtitle: Text(subtitle),
        trailing: IconButton(
          onPressed: () => joinLobby(connectionInfo),
          icon: Icon(Icons.login_rounded, color: theme.colorScheme.primary,),
        ),
        isThreeLine: false,
      ),
    );
  }

}