import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged;

  Future<bool> isInternetAvailable() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<ConnectivityResult> getCurrentConnectivity() async {
    return await _connectivity.checkConnectivity();
  }
}
