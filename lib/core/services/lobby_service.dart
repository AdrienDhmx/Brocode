
import 'dart:async';

import 'package:brocode/base_lobby_peer.dart';
import 'package:brocode/lobby_event_payload.dart';
import 'package:brocode/lobby_events.dart';
import 'package:brocode/lobby_owner.dart';
import 'package:brocode/lobby_peer.dart';

import '../../game/brocode.dart';

/// Handles all event related to the lobby, as well as emitting events to other players. <br>
/// It handles both the lobby owner (i.e. server) and the lobby peers (i.e. clients). <br>
/// This class is a singleton, it's instance can be accessed either by the constructor or by the static getter "instance".
class LobbyService {
  static final LobbyService _instance = LobbyService._internal();
  static LobbyService get instance => _instance;

  factory LobbyService() {
    return _instance;
  }
  LobbyService._internal();

  bool _isLobbyOwner = false;
  BaseLobbyPeer? _lobbyPeer;
  Brocode? _game;
  late Map<String, String> _peersInLobby = {};

  /// Whether the peer is created and open to connect to other peers
  bool get hasOpenPeer => _lobbyPeer != null && _lobbyPeer!.peer.open;

  final _isConnectedToLobbyController = StreamController<bool>.broadcast();
  /// a stream to listen to changes of "isConnectedToLobby"
  Stream<bool> get isConnectedToLobbyStream => _isConnectedToLobbyController.stream;
  /// Whether the peer is connected to a lobby (for the lobby owner it's always true)
  bool isConnectedToLobby = false;

  final _lobbyNameController = StreamController<String>.broadcast();
  /// A stream to listen to changes of "lobbyName"
  Stream<String> get lobbyNameControllerStream => _lobbyNameController.stream;
  /// The name of the current lobby (null when not connected to a lobby)
  String? lobbyName;

  final _playersController = StreamController<List<String>>.broadcast();
  /// A stream to listen to changes of "playersInLobby"
  Stream<List<String>> get playersInLobbyStream => _playersController.stream;
  /// A list of the name of the all players currently in the lobby (empty when not connected to a lobby)
  List<String> get playersInLobby => _peersInLobby.values.toList();

  /// Create a peer (client). <br>
  /// name: Name of the player
  void createPeer(String name) {
    playersInLobby.clear();
    _updatePlayersInLobby();
    isConnectedToLobby = false;

    if(!_isLobbyOwner && hasOpenPeer) {
      return;
    } else if(hasOpenPeer) { // the peer is a LobbyOwner
      _lobbyPeer!.dispose();
    }

    _isLobbyOwner = false;
    _lobbyPeer = LobbyPeer(name: name, onEvent: _onLobbyEvent);
  }

  /// Create a lobby owner (server), if there is already one then only the name is updated <br>
  /// lobbyName: Name of the lobby <br>
  /// name: Name of the player
  String? createLobby(String lobbyName, String name) {
    this.lobbyName = lobbyName;
    _updateLobbyName();

    if(_isLobbyOwner && hasOpenPeer) {
      return _lobbyPeer!.peer.id;
    } else if(hasOpenPeer) { // the peer is not a LobbyOwner
      _lobbyPeer!.dispose();
    }

    _isLobbyOwner = true;
    _lobbyPeer = LobbyOwner(lobbyName: lobbyName, name: name, onEvent: _onLobbyEvent);
    isConnectedToLobby = true;

    _peersInLobby.clear();
    _peersInLobby.putIfAbsent(_lobbyPeer!.peer.id!, () => name);
    _updatePlayersInLobby();
    return _lobbyPeer?.peer.id;
  }

  /// Tries to join a lobby, a lobby owner can't join another lobby. <br>
  /// lobbyId: The id of the lobby to join
  /// return true if the peer is able to send a connection request, false otherwise.
  /// It DOESN'T mean the peer is connected to the lobby, for that listen to "isConnectedToLobbyStream"
  bool joinLobby(String lobbyId) {
    if(_isLobbyOwner) {
      return false;
    }
    final metadata = {
      "senderName": _lobbyPeer!.name,
    };
    return (_lobbyPeer as LobbyPeer).joinLobby(lobbyId, metadata);
  }

  void startGame(Brocode game) {
    _game = game;
  }

  /// emit an event to other peers in lobby <br>
  /// event: The event type to emit
  /// data: The data to send to other players
  void emit(LobbyEvents event, dynamic data) {
    if(_lobbyPeer != null) {
      event.emit(data, _lobbyPeer!);
    }
  }

  void _onLobbyEvent(dynamic lobbyEvent) {
    print("[MULTIPLAYER_SERVICE] event received: $lobbyEvent");
    LobbyEventPayload payload = LobbyEventPayload.fromLobbyEventMessage(lobbyEvent);

    final eventId = payload.eventId;
    if(eventId == LobbyEvents.connectionOpened.index) { // a new player joined lobby / the peer joined the lobby
      if(_isLobbyOwner) {
        _peersInLobby.putIfAbsent(payload.data["peerId"], () => payload.data["peerName"]);
        _updatePlayersInLobby();
        final data = {
          "lobbyName": lobbyName,
          "players": _peersInLobby,
        };
        // notify this new player about the current state of the lobby
        (_lobbyPeer as LobbyOwner).emitToOne(payload.data["peerId"], LobbyEvents.lobbyState.eventMessage(data, _lobbyPeer!));
        return;
      }
      isConnectedToLobby = true;
      _updateIsConnectedToLobby();
    } if(eventId == LobbyEvents.playerLeaving.index) { // player left lobby
      _peersInLobby.remove(payload.data);
      _updatePlayersInLobby();
    } if(eventId == LobbyEvents.lobbyState.index) { // update lobby state
        lobbyName = payload.data["lobbyName"];
        for (var entry in (payload.data["players"] as Map<dynamic, dynamic>).entries) {
          _peersInLobby.putIfAbsent(entry.key.toString(), () => entry.value.toString());
        }
        _updatePlayersInLobby();
        _updateLobbyName();
    } else if(eventId == LobbyEvents.connectionFailed.index) { // a connection failed
      disposeAllConnections(); // clean up

      isConnectedToLobby = false;
      _updateIsConnectedToLobby();
      _updatePlayersInLobby();
    }
  }

  void _updateIsConnectedToLobby() {
    _isConnectedToLobbyController.add(isConnectedToLobby);
  }

  void _updateLobbyName() {
    _lobbyNameController.add(lobbyName??"");
  }

  void _updatePlayersInLobby() {
    _playersController.add(playersInLobby);
  }

  /// Closes all the connections of the peer
  void disposeAllConnections() {
    _lobbyPeer?.close();

    // reset data
    lobbyName = null;
    _peersInLobby.clear();
    _updatePlayersInLobby();
  }

  /// Dispose of the peer
  void disposePeer() {
    disposeAllConnections();
    _lobbyPeer?.dispose();
  }

  /// Dispose of the peer and all the resources of this singleton instance
  void dispose() {
    disposePeer();

    _isConnectedToLobbyController.close();
    _lobbyNameController.close();
    _playersController.close();
  }
}