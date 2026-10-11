import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../services/hive_service.dart';
import '../services/api_service.dart';

class AssetProvider extends ChangeNotifier {
  List<Asset> _assets = [];
  int _queueCount = 0;
  bool _isLoading = false;

  List<Asset> get assets => _assets;
  int get queueCount => _queueCount;
  bool get isLoading => _isLoading;

  final ApiService _api = ApiService();

  Future<void> loadAssets() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Read from local Hive storage
      final assetData = HiveService.assets.values;
      _assets = assetData.map((e) {
        try {
          return Asset.fromJson(e as Map<dynamic, dynamic>);
        } catch (e) {
          debugPrint('Error parsing asset: $e');
          return null;
        }
      }).whereType<Asset>().toList();
      _queueCount = HiveService.queue.length;
    } catch (e) {
      debugPrint('Hive load error: $e');
    }
    
    _isLoading = false;
    notifyListeners();

      // 2. Fetch from remote API
      try {
        final res = await _api.dio.get('/assets');
        if (res.statusCode == 200 && res.data != null) {
          final List<dynamic> remoteData = res.data;
          for (var item in remoteData) {
            item['is_synced'] = true;
            await HiveService.assets.put(item['id'], item);
          }
          final updatedData = HiveService.assets.values;
          _assets = updatedData.map((e) => Asset.fromJson(e as Map<dynamic, dynamic>)).toList();
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Remote fetch error: $e');
      }
  }

  Future<void> manualSync() async {
    if (HiveService.queue.isEmpty) return;
    
    final items = HiveService.queue.values.toList();
    try {
      await _api.post('/sync', {'assets': items});
      await HiveService.queue.clear();
      // Mark local as synced
      for (var item in items) {
        item['is_synced'] = true;
        await HiveService.assets.put(item['id'], item);
      }
      await loadAssets();
    } catch (e) {
      debugPrint('Manual sync error: $e');
    }
  }
}
