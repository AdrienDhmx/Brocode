
import 'dart:async';
import 'dart:convert';

import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:brocode/core/lobbies/lobby_event_payload.dart';
import 'package:brocode/core/lobbies/lobby_events.dart';
import 'package:brocode/core/lobbies/lobby_owner.dart';
import 'package:brocode/core/lobbies/lobby_peer.dart';
import 'package:flutter/foundation.dart';

import '../../game/brocode.dart';
import '../lobbies/lobby_peer_interface.dart';

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

  static const String serviceName = "_brocode-lobby";
  static const String serviceConnectionType = "_tcp";
  static const String serviceType = "$serviceName.$serviceConnectionType";

  bool _isLobbyOwner = false;
  LobbyInterface? _lobbyPeer;
  Brocode? _game;
  final Map<LobbyConnectionInfo, String> _peersInLobby = {};

  /// Whether the peer is created and open to connect to other peers
  bool get hasOpenPeer => _lobbyPeer != null && _lobbyPeer!.connectionInfo != null;

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
  FutureOr<LobbyConnectionInfo?>? createLobby(String lobbyName, String name) async {
    this.lobbyName = lobbyName;
    _updateLobbyName();

    if(_isLobbyOwner && hasOpenPeer) {
      return _lobbyPeer!.connectionInfo;
    } else if(hasOpenPeer) { // the peer is not a LobbyOwner
      _lobbyPeer!.dispose();
    }

    final lobby = Lobby(lobbyName: lobbyName, name: name, onEvent: _onLobbyEvent);
    final connectionInfo = await lobby.createLobby();
    if(connectionInfo == null) {
      return null;
    }
    _isLobbyOwner = true;
    isConnectedToLobby = true;

    _lobbyPeer = lobby;
    _peersInLobby.clear();
    _peersInLobby.putIfAbsent(connectionInfo, () => name);
    _updatePlayersInLobby();
    return connectionInfo;
  }

  /// Tries to join a lobby, a lobby owner can't join another lobby. <br>
  /// lobbyId: The id of the lobby to join
  /// return true if the peer is able to send a connection request, false otherwise.
  /// It DOESN'T mean the peer is connected to the lobby, for that listen to "isConnectedToLobbyStream"
  Future<bool> joinLobby(LobbyConnectionInfo connectionInfo) async {
    if(_isLobbyOwner) {
      return false;
    }
    isConnectedToLobby = await connectionInfo.connectToLobby((_lobbyPeer as LobbyPeer));
    _updateIsConnectedToLobby();
    return isConnectedToLobby;
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

  void _onLobbyEvent(LobbyEventPayload payload) {
    final eventId = payload.eventId;

    switch(LobbyEvents.values[eventId]) {
      case LobbyEvents.playerJoining:
        _newPlayerJoined(payload);
        break;
      case LobbyEvents.playerLeaving: // the peer was connected to the lobby but not anymore
        _peersInLobby.remove(payload.data);
        _updatePlayersInLobby();
        break;
      case LobbyEvents.playerState:
        // TODO: update a player state
        break;
      case LobbyEvents.lobbyState:
        _updateLobbyState(payload);
        break;
      case LobbyEvents.connectionFailed:
        isConnectedToLobby = false;
        _updateIsConnectedToLobby();

        // the peer tried to connect to another peer but failed
        // the lobby closed, or this peer lost connection
        disposeAllConnections(); // clean up
        break;
    }
  }

  void _newPlayerJoined(LobbyEventPayload payload) {
    _peersInLobby.putIfAbsent(payload.senderConnectionInfo, () => payload.senderName);
    _updatePlayersInLobby();

    if(_isLobbyOwner) { // notify this new player about the current state of the lobby
      final players = [];
      _peersInLobby.forEach((key, value) {
        players.add({
          ...key.toJson(),
          "playerName": value,
        });
      });
      final data = {
        "lobbyName": lobbyName,
        "players": players,
      };
      (_lobbyPeer as Lobby).emitToOne(payload.senderConnectionInfo, jsonEncode(LobbyEvents.lobbyState.eventMessage(data, _lobbyPeer!)));
    }
  }

  void _updateLobbyState(LobbyEventPayload payload) {
    lobbyName = payload.data["lobbyName"];
    for (final entry in payload.data["players"] as Iterable<dynamic>) {
      _peersInLobby.putIfAbsent(LobbyConnectionInfo.fromJson(entry)!, () => entry["playerName"].toString());
    }
    _updatePlayersInLobby();
    _updateLobbyName();
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

  }

  /// Dispose of the peer
  Future disposePeer() async {
    await _lobbyPeer?.dispose();
    // reset data
    lobbyName = null;
    _peersInLobby.clear();
    _isLobbyOwner = false;
    if(isConnectedToLobby) { // if it's already false this has been called because the connection was lost
      isConnectedToLobby = false;
      _updateIsConnectedToLobby();
    }
    _updatePlayersInLobby();
  }

  /// Dispose of the peer and all the resources of this singleton instance
  void dispose() {
    disposePeer();

    _isConnectedToLobbyController.close();
    _lobbyNameController.close();
    _playersController.close();
  }
}