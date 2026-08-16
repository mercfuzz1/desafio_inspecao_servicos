import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity =
           connectivity ?? Connectivity();

  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (results) {
        return results.any(
          (result) =>
              result != ConnectivityResult.none,
        );
      },
    );
  }

  Future<bool> get isConnected async {
    final results =
        await _connectivity.checkConnectivity();

    return results.any(
      (result) =>
          result != ConnectivityResult.none,
    );
  }
}