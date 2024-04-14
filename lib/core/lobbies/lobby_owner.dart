
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bonsoir/bonsoir.dart';
import 'package:brocode/core/lobbies/lobby_connection.dart';
import 'package:brocode/core/lobbies/lobby_event_payload.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../services/lobby_service.dart';
import '../utils/typedefs.dart';
import 'lobby_peer_interface.dart';

class Lobby implements LobbyInterface {
  Lobby({required this.lobbyName, required this.name, required this.onEvent});

  final String lobbyName;
  @override
  final String name;
  @override
  final VoidCallback<LobbyEventPayload> onEvent;
  @override
  LobbyConnectionInfo? connectionInfo;

  late ServerSocket? _server;
  BonsoirBroadcast? _bonsoirBroadcast;

  final Set<Socket> _sockets = {};
  final Map<LobbyConnectionInfo, StreamSubscription<Uint8List>> _connections = {};
  StreamSubscription<dynamic>? _serverStreamSub;

  Future<LobbyConnectionInfo?> createLobby() async {
    final ipAddress = await NetworkInfo().getWifiIP();
    _server = await ServerSocket.bind(ipAddress, 57860);

    if(_server != null) {
      connectionInfo = LobbyConnectionInfo(address: _server!.address, port: _server!.port);

      final service = BonsoirService(
        name: lobbyName,
        type: LobbyService.serviceType,
        port: _server!.port,
        attributes: {
          "address": ipAddress!,
          "port": _server!.port.toString(),
          "ownerName": name,
          // can add more info about the lobby to display in the lobby list
        }
      );

      _bonsoirBroadcast = BonsoirBroadcast(service: service);
      await _bonsoirBroadcast!.ready;
      await _bonsoirBroadcast!.start();

      _serverStreamSub = _server!.listen((Socket clientSocket) {
        LobbyConnectionInfo lobbyConnection = clientSocket.toLobbyConnection();
        _sockets.add(clientSocket);

        StreamSubscription<Uint8List> subscription = clientSocket.listen(
          (event) => listenSocketEvent(clientSocket, event),
          onDone: () async => await onConnectionClosedWithSocket(clientSocket),
          onError: (error) async => await onErrorWithSocket(error, clientSocket),
        );

        _connections.putIfAbsent(lobbyConnection, () => subscription);
      });

      return LobbyConnectionInfo(address: _server!.address, port: _server!.port);
    }
    return null;
  }

  void listenSocketEvent(Socket socket, Uint8List event) {
    String message = String.fromCharCodes(event).trim();
    final json = jsonDecode(message);

    print('[Server] Event received from ${socket.fullAddress()} : $json');
    onEvent(LobbyEventPayload.fromLobbyEventMessage(json));
  }

  Future onConnectionClosedWithSocket(Socket socket) async {
    print('[Server] Connection closed with ${socket.fullAddress()}');
    // TODO: player leaving event
    disposeSocket(socket);
  }

  Future onErrorWithSocket(dynamic error, Socket socket) async {
    print('[Server] Error with ${socket.fullAddress()}: $error');
    // TODO: player leaving event
    disposeSocket(socket);
  }

  @override
  void emit(dynamic data) {
    if(_server == null) {
      return;
    }
    for (final socket in _sockets) {
      socket.write(data);
    }
  }

  void emitIf(dynamic data, Predicate<Socket> condition)  {
    if(_server == null) {
      return;
    }
    for (final socket in _sockets) {
      if(condition(socket)) {
        print("[SERVER] Emitting to ${socket.fullAddress()}");
        socket.write(data);
      }
    }
  }

  void emitToOne(LobbyConnectionInfo connectionInfo, dynamic data) {
    return emitIf(data, (value) => value.equalLobbyConnection(connectionInfo));
  }

  Future disposeSocket(Socket socket) async {
    _sockets.remove(socket);
    final lobbyConnectionInfo = socket.toLobbyConnection();
    await _connections[lobbyConnectionInfo]?.cancel();
    _connections.remove(lobbyConnectionInfo);
    await socket.flush();
    await socket.close();
  }

  /// Dispose of all the connections to this lobby
  Future close() async {
    if(_server == null) {
      return;
    }

    await _server!.forEach((socket) async {
      disposeSocket(socket);
    });

    _connections.clear();
  }

  Future stopBroadcast() async {
    await _bonsoirBroadcast?.stop();
    _bonsoirBroadcast = null;
  }

  /// Dispose of this lobby
  @override
  Future dispose() async {
    await stopBroadcast();
    await _serverStreamSub?.cancel();
    _serverStreamSub = null;
    await _server?.close();
    _server = null;
    await close();
  }
}