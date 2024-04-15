
import 'package:bonsoir/bonsoir.dart';
import 'package:brocode/app/blocks/lobby_discovery_item.dart';
import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/buttons.dart';
import '../modals/join_lobby_modal.dart';
import '../models/lobbies_discovery_model.dart';

class AvailableLobbies extends StatefulWidget {
  const AvailableLobbies({super.key});

  @override
  State<StatefulWidget> createState() => _AvailableLobbies();
}

class _AvailableLobbies extends State<AvailableLobbies> {
  final BonsoirDiscoveryModel discovery = BonsoirDiscoveryModel();
  List<BonsoirService> lobbies = [];

  @override
  void initState() {
    discovery.start(LobbyService.serviceType);
    discovery.addListener(onDiscoveryChange);
    super.initState();
  }

  void onDiscoveryChange() {
    setState(() {
      lobbies = discovery.services;
    });
  }

  void joinLobby(BuildContext context, LobbyConnectionInfo connectionInfo) {
    showModalBottomSheet(context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        builder: (context) => JoinLobbyModal(connectionInfo: connectionInfo));
  }

  @override
  void dispose() {
    discovery.removeListener(onDiscoveryChange);
    discovery.stop(LobbyService.serviceType);
    discovery.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const NavigateBackButton(),
        title: const Text("Rejoindre un lobby"),
        elevation: 2,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shadowColor: theme.colorScheme.shadow,
      ),
      body: Builder(
        builder: (context) {
          if(lobbies.isEmpty) {
            return const Center(child: Text("Aucun lobby disponible de trouvé."));
          }

          return ListView.builder(
              itemCount: lobbies.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return LobbyDiscoveryItem(
                    service: lobbies[index],
                    joinLobby: (connectionInfo) => joinLobby(context, connectionInfo)
                );
              }
          );
        },
      )
    );
  }
}