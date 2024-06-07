
import 'package:brocode/app/blocks/lobby_discovery_item.dart';
import 'package:brocode/core/utils/server_util.dart';
import 'package:flutter/material.dart';

import '../../core/lobbies/lobby.dart';
import '../../core/widgets/buttons.dart';
import '../modals/join_lobby_modal.dart';

class AvailableLobbies extends StatefulWidget {
  const AvailableLobbies({super.key});

  @override
  State<StatefulWidget> createState() => _AvailableLobbies();
}

class _AvailableLobbies extends State<AvailableLobbies> {
  late bool loading = true;
  List<Lobby> lobbies = [];

  @override
  void initState() {
    ServerUtil.getAvailableLobbies().then((values) => {
      if(mounted) {
        setState(() {
          lobbies = values;
        })
      }
    });
    super.initState();
  }

  void joinLobby(BuildContext context, Lobby lobby) {
    showModalBottomSheet(context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        builder: (context) => JoinLobbyModal(lobby: lobby));
  }

  @override
  void dispose() {
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
                    lobby: lobbies[index],
                    joinLobby: (connectionInfo) => joinLobby(context, connectionInfo)
                );
              }
          );
        },
      )
    );
  }
}