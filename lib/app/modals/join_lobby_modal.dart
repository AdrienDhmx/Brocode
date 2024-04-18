
import 'dart:async';

import 'package:brocode/app/router.dart';
import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:brocode/core/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/lobby_service.dart';

class JoinLobbyModal extends StatefulWidget {
  const JoinLobbyModal({super.key, required this.connectionInfo});
  final LobbyConnectionInfo connectionInfo;

  @override
  State<StatefulWidget> createState() => _JoinLobbyModal();
}

class _JoinLobbyModal extends State<JoinLobbyModal> {
  final _formKey = GlobalKey<FormState>();
  final playerNameController = TextEditingController();
  late bool tryingToConnect = false;
  late bool failedToJoinLobby = false;

  StreamSubscription<bool>? _isConnectedToLobbySubscription;

  Future joinLobby() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      if(!LobbyService().hasOpenPeer) { // peer already created and ready to connect
        LobbyService().createPeer(playerNameController.text);
      }

      setState(() {
        tryingToConnect = true;
      });
      final success = await LobbyService().joinLobby(widget.connectionInfo);
      if(success) {
        if(mounted) {
          context.go(Routes.lobby.route);
        }
      } else {
        failedToConnectToLobby();
      }

      // final timeoutTimer = Timer(const Duration(seconds: 5), failedToConnectToLobby);
      //
      // // starts listening to know the result of the connection request
      // _isConnectedToLobbySubscription = LobbyService().isConnectedToLobbyStream.listen((isConnected) {
      //   if(isConnected) { // go to the lobby
      //     timeoutTimer.cancel(); // stop timeout timer
      //     context.go(Routes.lobby.withParameters({"lobbyId": lobbyId}));
      //   } else {
      //     failedToConnectToLobby();
      //   }
      // });
    }
  }

  void failedToConnectToLobby() {
    cancelConnection();
    if(mounted && context.mounted) {
      setState(() {
        failedToJoinLobby = true;
        tryingToConnect = false;
      });
    };
  }

  void cancelConnection() {
    setState(() {
      tryingToConnect = false;
    });
    LobbyService().disposePeer();
  }

  @override
  void dispose() {
    super.dispose();
    _isConnectedToLobbySubscription?.cancel();

    if(!LobbyService().isConnectedToLobby) {
      LobbyService().disposePeer();
    }

    playerNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    if(failedToJoinLobby)
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("La connection au lobby à échouée.", style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center,),
                      ),
                    if(tryingToConnect) ...[
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: LinearProgressIndicator(),
                      ),
                      SurfaceVariantFlatButton(text: "Annuler", onPressed: cancelConnection, theme: theme),
                    ]
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
}