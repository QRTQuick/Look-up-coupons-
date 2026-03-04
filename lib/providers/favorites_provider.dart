import 'package:flutter/material.dart';

import 'package:look_up_coupons/services/database_service.dart';

class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(this._databaseService);

  final DatabaseService _databaseService;

  final Set<int> _favoriteDealIds = {};
  final Set<String> _favoriteShops = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<String> get favoriteShops => _favoriteShops.toList()..sort();

  Future<void> loadFavorites() async {
    _favoriteDealIds
      ..clear()
      ..addAll(await _databaseService.getFavoriteDealIds());
    _favoriteShops
      ..clear()
      ..addAll(await _databaseService.getFavoriteShops());

    _loaded = true;
    notifyListeners();
  }

  bool isDealFavorite(int? id) => id != null && _favoriteDealIds.contains(id);

  bool isShopFavorite(String shopName) => _favoriteShops.contains(shopName);

  Future<void> toggleFavoriteDeal(int dealId) async {
    if (_favoriteDealIds.contains(dealId)) {
      _favoriteDealIds.remove(dealId);
      await _databaseService.removeFavoriteDeal(dealId);
    } else {
      _favoriteDealIds.add(dealId);
      await _databaseService.addFavoriteDeal(dealId);
    }
    notifyListeners();
  }

  Future<void> toggleFavoriteShop(String shopName) async {
    if (_favoriteShops.contains(shopName)) {
      _favoriteShops.remove(shopName);
      await _databaseService.removeFavoriteShop(shopName);
    } else {
      _favoriteShops.add(shopName);
      await _databaseService.addFavoriteShop(shopName);
    }
    notifyListeners();
  }
}
