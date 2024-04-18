
import 'package:brocode/app/router.dart';
import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/lobby_service.dart';
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
  late bool failedToCreateLobby = false;

  Future createLobby(BuildContext context) async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      LobbyConnectionInfo? connectionInfo = await LobbyService().createLobby(lobbyNameController.text, playerNameController.text);

      if(connectionInfo == null) {
        setState(() {
          failedToCreateLobby = true;
        });
        return;
      }

      if(mounted && context.mounted) { // make sure the context has not been disposed
        context.go(Routes.lobby.route);
      }
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
      body: Container(
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
                  if(failedToCreateLobby)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Le lobby n'a pas pu être créer, vérifier votre connection internet et réessayer.",
                        style: TextStyle(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  PrimaryFlatButton(text: "Créer", onPressed: () => createLobby(context), theme: theme),
                ],
              ),
            ),
          )
      ),
    );
  }

}