import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:brocode/core/lobbies/lobby_event_payload.dart';
import 'package:brocode/core/lobbies/lobby_events.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../utils/typedefs.dart';
import 'lobby_peer_interface.dart';

class LobbyPeer implements LobbyInterface {
  LobbyPeer({required this.name, required this.onEvent});

  @override
  final String name;
  @override
  final VoidCallback<LobbyEventPayload> onEvent;
  @override
  LobbyConnectionInfo? connectionInfo;
  late Socket? socket;

  bool get isConnectedToLobby => socket != null;

  late String? lobbyId;

  StreamSubscription<dynamic>? socketStreamSub;

  Future<bool> connectToLobby(InternetAddress address, int port) async {
    try {
      final ipAddress = await NetworkInfo().getWifiIP();
      socket = await Socket.connect(address, port);
      connectionInfo = LobbyConnectionInfo(address: InternetAddress(ipAddress!), port: socket!.port);
      socketStreamSub = socket!.listen(listenEvent, onDone: onConnectionClosed, onError: onSocketError);
      // emit joining event to send lobby player info
      LobbyEvents.playerJoining.emit("none", this);
      return isConnectedToLobby;
    } catch(err) {
      print("[CLIENT] Error connecting: $err");
      return false;
    }
  }

  void listenEvent(Uint8List event) {
    String message = String.fromCharCodes(event).trim();
    final json = jsonDecode(message);

    print('[CLIENT] Event received from ${socket!.fullRemoteAddress()} : $json');
    onEvent(LobbyEventPayload.fromLobbyEventMessage(json));
  }

  Future onConnectionClosed() async {
    if(isConnectedToLobby) {
      print('[CLIENT] Connection closed with ${socket!.fullRemoteAddress()}');
      onEvent(LobbyEventPayload.fromLobbyEvent(LobbyEvents.connectionFailed, "none", this));
      await dispose();
    }
  }

  Future onSocketError(dynamic error) async {
    if(isConnectedToLobby) {
      print("[CLIENT] Error with socket: $error");
      onEvent(LobbyEventPayload.fromLobbyEvent(LobbyEvents.connectionFailed, "none", this));
      await dispose();
    }
  }

  @override
  FutureOr emit(dynamic data) {
    if(socket != null) {
      print("[CLIENT] (${connectionInfo.toString()}) Emitting to ${socket!.fullRemoteAddress()} : $data");
      socket!.write(data);
    }
  }

  @override
  Future dispose() async {
    await socketStreamSub?.cancel();
    socketStreamSub = null;
    await socket?.flush();
    await socket?.close();
    socket = null;
  }
}