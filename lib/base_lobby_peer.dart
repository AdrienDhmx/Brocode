
import 'package:peerdart/peerdart.dart';

import 'core/utils/multiplayer_utils.dart';

/// Expose the common methods and properties of a lobby as well as handle the common logic (peer creation)
abstract class BaseLobbyPeer {
  BaseLobbyPeer({required this.name, required this.onEvent}) {
    peer = Peer(id: MultiplayerUtil.getRandomUniqueIdentifier(6),
      options: PeerOptions(
        debug: LogLevel.Errors,
      ),
    );
  }

  final String name;
  final Function(dynamic) onEvent;
  late Peer peer;

  /// emit the data to all connections
  void emit(dynamic data);

  /// Closes and dipose of all the connection the Peer has
  void close();

  /// Dispose of this Peer
  void dispose();
}