
import 'package:brocode/app/blocks/lobby_discovery_item.dart';
import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/buttons.dart';
import '../modals/join_lobby_modal.dart';
import '../models/lobbies_discovery_model.dart';


class AvailableLobbies extends ConsumerWidget {
  const AvailableLobbies({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    BonsoirDiscoveryModel discoveryModel = ref.watch(discoveryModelProvider);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const NavigateBackButton(),
        title: const Text("Rejoindre un lobby"),
        elevation: 2,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shadowColor: theme.colorScheme.shadow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: discoveryModel.services.isEmpty
          ? const Center(child: Text("Aucun lobby disponible de trouvé."))
          : ListView.builder(
            itemCount: discoveryModel.services.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return LobbyDiscoveryItem(
                  service: discoveryModel.services[index],
                  joinLobby: (connectionInfo) => joinLobby(context, connectionInfo)
              );
            }
          ),
      )
    );
  }

}