
import 'dart:io';

import 'package:brocode/core/lobbies/lobby_peer.dart';

class LobbyConnectionInfo {
  LobbyConnectionInfo({required this.address, required this.port});

  static LobbyConnectionInfo fromSocket(Socket socket, {bool fromRemote = false}) {
    if(fromRemote) {
      return LobbyConnectionInfo(address: socket.remoteAddress, port: socket.remotePort);
    }
    return LobbyConnectionInfo(address: socket.address, port: socket.port);
  }

  static LobbyConnectionInfo? fromJson(Map<dynamic, dynamic> json) {
    final jsonAddress = json["address"];
    final jsonPort = int.tryParse(json["port"] ?? "");
    if(jsonAddress != null && jsonPort != null) {
      return LobbyConnectionInfo(address: InternetAddress(jsonAddress), port: jsonPort);
    }
    return null;
  }

  final InternetAddress address;
  final int port;

  Future<bool> connectToLobby(LobbyPeer peer) async {
    return await peer.connectToLobby(address, port);
  }

  @override
  String toString() {
    return "${address.address}:$port";
  }

  Map<String, String> toJson() {
    return {
      "address": address.address,
      "port": port.toString(),
    };
  }
}

extension SocketExtension on Socket {
  String fullAddress() => "${address.address}:$port";
  String fullRemoteAddress() => "${remoteAddress.address}:$remotePort";

  LobbyConnectionInfo toLobbyConnection({bool fromRemote = false}) => LobbyConnectionInfo.fromSocket(this, fromRemote: fromRemote);

  bool equalLobbyConnection(LobbyConnectionInfo connectionInfo)
      => remoteAddress.address == connectionInfo.address.address && remotePort == connectionInfo.port;
}