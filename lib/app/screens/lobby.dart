import 'package:brocode/core/widgets/buttons.dart';
import 'package:brocode/lobby_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/services/lobby_service.dart';

class LobbyWaitingPage extends StatefulWidget {
  const LobbyWaitingPage({super.key, required this.lobbyId});
  final String lobbyId;

  @override
  State<StatefulWidget> createState() => _LobbyWaitingPage();
}

class _LobbyWaitingPage extends State<LobbyWaitingPage> {
  late Stream<String> _lobbyNameStream;
  late String lobbyName = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _lobbyNameStream = LobbyService().lobbyNameControllerStream;
    _lobbyNameStream.listen((event) {
      if(mounted) {
        print("Lobby name changing to: $event");
        setState(() {
          lobbyName = event;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    // leave the lobby, dispose of the connections
    LobbyService().disposeAllConnections();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if(lobbyName.isEmpty) {
      lobbyName = LobbyService().lobbyName ?? "";
    }
    return Scaffold(
      appBar: AppBar(
        leading: const NavigateBackButton(),
        elevation: 2,
        shadowColor: theme.colorScheme.shadow,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(lobbyName),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: OutlinedButton(
                style: ButtonStyle(
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  )),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.lobbyId));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.lobbyId),
                    const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Icon(Icons.copy_rounded, size: 16,),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Joueurs présents", style: theme.textTheme.headlineSmall, textAlign: TextAlign.center,)
            ),
            StreamBuilder(
              stream: LobbyService().playersInLobbyStream,
              builder: (context, snapshot) {
                if(snapshot.data == null && LobbyService().playersInLobby.isEmpty) {
                  return const SizedBox();
                }

                final players = snapshot.data ?? LobbyService().playersInLobby;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: players.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                      child: ListTile(
                        title: Text(players[index]),
                        textColor: theme.colorScheme.onPrimaryContainer,
                        tileColor: theme.colorScheme.primaryContainer,
                      ),
                    );
                  },
                );
              }
            ),
          ],
        ),
      ),
    );
  }

}