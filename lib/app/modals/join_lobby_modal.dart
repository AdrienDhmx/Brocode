
import 'dart:async';

import 'package:brocode/app/router.dart';
import 'package:brocode/core/blocs/join_lobby/join_lobby_bloc.dart';
import 'package:brocode/core/blocs/join_lobby/join_lobby_events.dart';
import 'package:brocode/core/blocs/join_lobby/join_lobby_states.dart';
import 'package:brocode/core/services/bloc_service.dart';
import 'package:brocode/core/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/lobbies/lobby.dart';

class JoinLobbyModal extends StatefulWidget {
  const JoinLobbyModal({super.key, required this.lobby});
  final Lobby lobby;

  @override
  State<StatefulWidget> createState() => _JoinLobbyModal();
}

class _JoinLobbyModal extends State<JoinLobbyModal> {
  final _formKey = GlobalKey<FormState>();
  final playerNameController = TextEditingController();

  Future joinLobby() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      BlocService().joinLobbyBloc.add(JoinLobbyJoinEvent(lobbyId: widget.lobby.id, playerName: playerNameController.text));
    }
  }

  @override
  void dispose() {
    super.dispose();
    playerNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<JoinLobbyBloc, JoinLobbyState>(
      listener: (BuildContext context, JoinLobbyState state) {
        if(state is JoinLobbySuccessState) {
          context.go(Routes.lobby.route);
        } else if (state is JoinLobbyErrorState) {
          context.pop(); // close modal
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: theme.colorScheme.errorContainer,
                content: Text(
                  state.errorMessage,
                  style: TextStyle(
                    color:  theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                )
              )
          );
        }
      },
      child: BlocBuilder<JoinLobbyBloc, JoinLobbyState>(
        builder: (context, joinState) {
          return Padding(
            padding: EdgeInsets.only(top: 8, left: 12, right: 12, bottom: 8 + MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                            child: TextFormField(
                              controller: playerNameController,
                              autofocus: true,
                              decoration: const InputDecoration(
                                labelText: "Votre pseudo",
                              ),
                              validator: (text) {
                                if(text == null || text.isEmpty) {
                                  return "Le pseudo est obligatoire";
                                }
                                return null;
                              },
                            ),
                          ),
                          if(joinState is JoinLobbyLoadingState)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: LinearProgressIndicator(),
                            )
                          else
                            PrimaryFlatButton(text: "Rejoindre", onPressed: joinLobby, theme: theme)
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          );
        }
      ),
    );
  }
}