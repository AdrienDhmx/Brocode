import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:brocode/core/services/lobby_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bonsoir_discovery_model.dart';


/// Provider model that allows to handle Bonsoir discoveries.
class BonsoirDiscoveryModel extends BonsoirActionModel<String, BonsoirDiscovery, BonsoirDiscoveryEvent> {
  /// A list containing all discovered services.
  final List<BonsoirService> _services = [];

  @override
  BonsoirDiscovery createAction(String argument) => BonsoirDiscovery(type: argument);

  @override
  Future<void> start(String argument, {bool notify = true}) async {
    await super.start(argument, notify: notify);
  }

  List<BonsoirService> get services => _services;

  @override
  void onEventOccurred(BonsoirDiscoveryEvent event) {
    if (event.service == null) {
      return;
    }

    BonsoirService service = event.service!;
    if (event.type == BonsoirDiscoveryEventType.discoveryServiceFound) {
      services.add(service);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceResolved) {
      services.removeWhere((foundService) => foundService.name == service.name);
      services.add(service);
    } else if (event.type == BonsoirDiscoveryEventType.discoveryServiceLost) {
      services.removeWhere((foundService) => foundService.name == service.name);
    }
    services.sort((a, b) => a.name.compareTo(b.name));
    notifyListeners();
  }

  @override
  Future<void> stop(String argument, {bool notify = true}) async {
    await super.stop(argument, notify: false);
    _services.remove(argument);
    if (notify) {
      notifyListeners();
    }
  }

  /// Resolves the given service.
  void resolveService(BonsoirService service) {
    BonsoirDiscovery? discovery = getAction(service.type);
    if (discovery != null) {
      service.resolve(discovery.serviceResolver);
    }
  }
}