import 'package:flutter/foundation.dart';
import '../models/asset_model.dart';
import '../services/data_service.dart';

class AssetProvider extends ChangeNotifier {
  final DataService _dataService = DataService();

  List<AssetModel> _assets = [];
  bool _isLoading = false;

  List<AssetModel> get assets => _assets;
  bool get isLoading => _isLoading;

  double get totalAssets => _dataService.getTotalAssets(_assets);

  Map<AssetType, double> get assetsByType {
    final map = <AssetType, double>{};
    for (final asset in _assets) {
      map[asset.type] = (map[asset.type] ?? 0) + asset.balance;
    }
    return map;
  }

  Future<void> loadAssets() async {
    _isLoading = true;
    notifyListeners();

    _assets = await _dataService.getAssets();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAsset(AssetModel asset) async {
    _assets.add(asset);
    await _dataService.saveAssets(_assets);
    notifyListeners();
  }

  Future<void> updateAsset(AssetModel asset) async {
    final index = _assets.indexWhere((a) => a.id == asset.id);
    if (index != -1) {
      _assets[index] = asset;
      await _dataService.saveAssets(_assets);
      notifyListeners();
    }
  }

  Future<void> deleteAsset(String id) async {
    _assets.removeWhere((a) => a.id == id);
    await _dataService.saveAssets(_assets);
    notifyListeners();
  }
}