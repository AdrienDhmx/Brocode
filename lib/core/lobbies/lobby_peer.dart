import 'package:brocode/core/utils/multiplayer_utils.dart';
import 'package:brocode/core/lobbies/lobby_events.dart';
import 'package:peerdart/peerdart.dart';

import 'lobby_peer_interface.dart';

class LobbyPeer implements LobbyPeerInterface {
  LobbyPeer({required this.name, required this.onEvent}) {
    peer = Peer(id: MultiplayerUtil.getRandomUniqueIdentifier(5),
      options: PeerOptions(
        debug: LogLevel.All,
      ),
    );

    _init();
  }

  @override
  final String name;
  @override
  final Function(dynamic) onEvent;
  @override
  late Peer peer;

  bool get isConnectedToLobby => _connectionWithLobby != null;

  late String? lobbyId;
  DataConnection? _connectionWithLobby;

  void _init() {
    peer.on("open").listen((peerId) {
      print('[PEER] opened with id \'$peerId\'');
    });

    peer.on("close").listen((peerId) {
      print('[PEER] closing (\'$peerId\')');
    });

    peer.on('error').listen((error) {
      print('[PEER] error: $error');
      _connectionWithLobby = null; // almost all errors are fatal
      onEvent(LobbyEvents.connectionFailed.eventMessage(error, this));
    });
  }

  void _initListeners() {
    if(_connectionWithLobby == null) {
      return;
    }

    _connectionWithLobby!.on('open').listen((peerId) { // save id to send message to them
      lobbyId = peerId;
      // will update the connection status
      onEvent(LobbyEvents.connectionOpened.eventMessage(null, this));
      print('[PEER] connected to lobby (${_connectionWithLobby!.peer})');
    });

    // connection with other user closed
    _connectionWithLobby!.on("close").listen((peerId) {
      print('[PEER] disconnected from lobby (${_connectionWithLobby!.peer})');
      onEvent(LobbyEvents.connectionFailed.eventMessage(null, this));
    });

    _connectionWithLobby!.on("error").listen((error) {
      print('[PEER] Error with lobby ${_connectionWithLobby!.peer}: $error');
    });

    _connectionWithLobby!.on("data").listen((event) {
      onEvent(event);
    });
  }

  @override
  void emit(dynamic data) {
    if(_connectionWithLobby != null) {
      print("[PEER] (${peer.id}) Emitting: $data");
      _connectionWithLobby!.send(data);
    }
  }

  bool joinLobby(String id, dynamic metadata) {
    if(isConnectedToLobby) {
      print("[PEER] already connected to lobby: $lobbyId");
      return false;
    }

    _connectionWithLobby = peer.connect(id, options: PeerConnectOption(
      metadata: metadata,
    ));
    _initListeners();
    return true;
  }

  /// Close and dispose of the connection with the lobby
  @override
  void close() {
    if(isConnectedToLobby) {
      _connectionWithLobby!.close();
      _connectionWithLobby!.dispose();

      _connectionWithLobby = null;
    }
  }

  @override
  void dispose() {
    close();
    peer.disconnect();
    peer.dispose();
  }
}