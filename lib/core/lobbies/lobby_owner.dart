
import 'dart:async';

import 'package:brocode/core/utils/multiplayer_utils.dart';
import 'package:brocode/core/lobbies/lobby_events.dart';
import 'package:peerdart/peerdart.dart';

import 'lobby_peer_interface.dart';


class LobbyOwner implements LobbyPeerInterface {
  LobbyOwner({required this.lobbyName, required this.name, required this.onEvent}) {
    peer = Peer(id: MultiplayerUtil.getRandomUniqueIdentifier(5),
      options: PeerOptions(
        debug: LogLevel.All,
      ),
    );

    _init();
  }

  final String lobbyName;
  @override
  final String name;
  @override
  final Function(dynamic) onEvent;
  @override
  late Peer peer;

  final List<DataConnection> _connections = [];
  List<dynamic> get connectionMetadata => _connections.map((c) => c.metadata).toList();

  StreamSubscription<dynamic>? peerOpenedStreamSub;
  StreamSubscription<dynamic>? peerClosedStreamSub;
  StreamSubscription<dynamic>? peerErrorStreamSub;

  void _init() {
    peerOpenedStreamSub = peer.on("open").listen((peerId) {
      print('[LOBBY] opened with id \'$peerId\'');
    });

    peerClosedStreamSub = peer.on("close").listen((peerId) {
      print('[LOBBY] closing (\'$peerId\')');
    });

    peerErrorStreamSub = peer.on('error').listen((error) {
      print('[LOBBY] error: $error');
    });

    peer.on<DataConnection>('connection').listen((connection) {

      // connection with lobby opened
      _connections.add(connection);
      print('[LOBBY] connected to peer (${connection.peer})');

      connection.on("open").listen((_) {
        print("[LOBBY] connection open with (${connection.peer})");
        final data = {
          "peerId": connection.peer,
          "peerName": connection.metadata["senderName"],
        };
        // will notify the new player of the current lobby status
        onEvent(LobbyEvents.connectionOpened.eventMessage(data, this));
      });

      connection.on("error").listen((error) {
        print('[LOBBY] Error with peer ${connection.peer}: $error');
      });

      connection.on('data').listen((event) {
        emitToAllExcept(event, connection);
        onEvent(event);
      });

      // connection with other user closed
      connection.on("close").listen((peerId) {
        // update the lobby state
        final eventMessage = LobbyEvents.playerLeaving.eventMessage(connection.peer, this);
        onEvent(eventMessage); // bubble up the event
        emit(eventMessage); // notify all other peers
        _connections.remove(connection);
        print('[LOBBY] disconnected with peer (${connection.peer})');
      });
    });
  }

  @override
  void emit(dynamic data) {
    for(DataConnection connection in _connections) {
      if(connection.open) {
        print("[LOBBY] (${peer.id}) Emitting to ${connection.peer}: $data");
        connection.send(data);
      }
    }
  }

  void emitToOne(String peerId, dynamic data) {
    for (DataConnection connection in _connections) {
      if (connection.peer == peerId || !connection.open) {
        connection.send(data);
      }
    }
  }

  void emitToAllExcept(dynamic data, DataConnection except) {
    for(DataConnection connection in _connections) {
      if(connection == except || !connection.open) {
        continue;
      }
      connection.send(data);
    }
  }

  void emitToAllExceptById(dynamic data, String except) {
    for(DataConnection connection in _connections) {
      if(connection.peer == except || !connection.open) {
        continue;
      }
      connection.send(data);
    }
  }

  /// Dispose of all the connections to this lobby
  @override
  void close() {
    for(DataConnection connection in _connections) {
      connection.close();
      connection.dispose();
    }
  }

  /// Dispose of this lobby
  @override
  void dispose() {
    close();
    peerOpenedStreamSub?.cancel();
    peerClosedStreamSub?.cancel();
    peerErrorStreamSub?.cancel();

    peer.disconnect();
    peer.dispose();
  }
}