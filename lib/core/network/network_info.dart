import 'package:connectivity_plus/connectivity_plus.dart';

abstract interface class NetworkInfo {
  Future<bool> get isConnected;
}

class ConnectivityNetworkInfo implements NetworkInfo {
  ConnectivityNetworkInfo({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      // If the platform cannot tell us, let the request decide.
      return true;
    }
  }
}
