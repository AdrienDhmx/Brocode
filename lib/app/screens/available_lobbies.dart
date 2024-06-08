
import 'dart:async';

import 'package:brocode/app/blocks/lobby_discovery_item.dart';
import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_bloc.dart';
import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_events.dart';
import 'package:brocode/core/blocs/fetch_lobbies/fetch_lobbies_states.dart';
import 'package:brocode/core/services/bloc_service.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/lobbies/lobby.dart';
import '../../core/widgets/buttons.dart';
import '../modals/join_lobby_modal.dart';

class AvailableLobbies extends StatefulWidget {
  const AvailableLobbies({super.key});

  @override
  State<StatefulWidget> createState() => _AvailableLobbies();
}

class _AvailableLobbies extends State<AvailableLobbies> {
  @override
  void initState() {
    // start fetching available lobbies
    BlocService().fetchLobbiesBloc.add(FetchLobbiesFetchEvent());
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    BlocService().fetchLobbiesBloc.add(FetchLobbiesFetchEvent());
  }

  void joinLobby(BuildContext context, Lobby lobby) {
    showModalBottomSheet(context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
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
        leading: const BackButton(),
        title: const Text("Rejoindre un lobby"),
        elevation: 2,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        shadowColor: theme.colorScheme.shadow,
      ),
      body: BlocBuilder<FetchLobbiesBloc, FetchLobbiesState>(
        builder: (context, lobbiesState) {
          if(lobbiesState is FetchLobbiesLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          final lobbies = lobbiesState.lobbies;
          if(lobbies.isEmpty) {
            return const Center(child: Text("Aucun lobby disponible de trouvé."));
          }

          return ListView.builder(
              itemCount: lobbies.length,
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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