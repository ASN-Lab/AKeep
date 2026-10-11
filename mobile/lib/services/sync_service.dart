import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/services/hive_service.dart';

class SyncService {
  final ApiService _api = ApiService();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  void init() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi)) {
        _sync();
      }
    });
  }

  Future<void> _sync() async {
    final queue = HiveService.queue;
    if (queue.isEmpty) return;

    final List<dynamic> items = queue.values.toList();
    try {
      await _api.post('/sync', {'assets': items});
      await queue.clear();
    } catch (e) {
      // Ponytail: Silent fail if sync fails, retry on next connectivity event
    }
  }

  void dispose() => _connectivitySubscription.cancel();
}
