
import 'dart:async';

import 'package:brocode/app/router.dart';
import 'package:brocode/core/blocs/create_lobby/create_lobby_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/blocs/create_lobby/create_lobby_bloc.dart';
import '../../core/blocs/create_lobby/create_lobby_states.dart';
import '../../core/widgets/buttons.dart';

class CreateLobby extends StatefulWidget {
  const CreateLobby({super.key});

  @override
  State<StatefulWidget> createState() => _CreateLobby();
}

class _CreateLobby extends State<CreateLobby> {
  final _formKey = GlobalKey<FormState>();
  final lobbyNameController = TextEditingController();
  final playerNameController = TextEditingController();

  Future createLobby(BuildContext context) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      context.read<CreateLobbyBloc>().add(
          CreateLobbyCreateEvent(name: lobbyNameController.text, ownerName: playerNameController.text)
      );
    }
  }

  void navigateBack() {
    context.pop();
  }

  @override
  void dispose() {
    super.dispose();
    lobbyNameController.dispose();
    playerNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 60,
        leading: IconButton(onPressed: navigateBack, icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text("Créer un lobby"),
        elevation: 2,
        shadowColor: theme.colorScheme.shadow,
      ),
      body: BlocListener<CreateLobbyBloc, CreateLobbyState>(
        listener: (BuildContext context, state) {
          if(state is CreateLobbyCreatedState) {
            context.go(Routes.lobby.route);
          } else if(state is CreateLobbyErrorState) {
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
        child: BlocBuilder<CreateLobbyBloc, CreateLobbyState>(
          builder: (context, createState) {
            return SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: lobbyNameController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: "Nom du lobby",
                            ),
                            validator: (text) {
                              if(text == null || text.isEmpty) {
                                return "Le nom du lobby est obligatoire";
                              }
                              return null;
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, bottom: 12),
                            child: TextFormField(
                              controller: playerNameController,
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
                          if(createState is CreateLobbyLoadingState) ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text("Création en cours..."),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: LinearProgressIndicator(),
                            ),
                          ]
                          else
                            PrimaryFlatButton(text: "Créer", onPressed: () => createLobby(context), theme: theme),
                        ],
                      ),
                    ),
                  )
              ),
            );
          }
        ),
      ),
    );
  }

}