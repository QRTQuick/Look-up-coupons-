import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:look_up_coupons/models/deal.dart';
import 'package:look_up_coupons/services/database_service.dart';
import 'package:look_up_coupons/services/location_service.dart';

class DealsProvider extends ChangeNotifier {
  DealsProvider(this._databaseService);

  final DatabaseService _databaseService;
  final LocationService _locationService = LocationService();

  List<Deal> _allDeals = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  double? _distanceFilterKm;
  Position? _currentPosition;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  String get selectedCategory => _selectedCategory;
  double? get distanceFilterKm => _distanceFilterKm;
  List<Deal> get allDeals => List.unmodifiable(_allDeals);

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allDeals = await _databaseService.getDeals();
      _error = null;
    } catch (_) {
      _error = 'Failed to load deals.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> reloadDeals() async {
    await initialize();
  }

  Future<void> refreshLocation() async {
    try {
      _currentPosition = await _locationService.getCurrentPosition();
      _error = null;
    } catch (_) {
      _error = 'Location unavailable.';
    }
    notifyListeners();
  }

  double? distanceTo(Deal deal) {
    final position = _currentPosition;
    if (position == null) return null;
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      deal.latitude,
      deal.longitude,
    );
  }

  List<String> get categories {
    final set = <String>{};
    for (final deal in _allDeals) {
      set.add(deal.category);
    }
    final list = set.toList()..sort();
    return ['All', ...list];
  }

  void setSearchQuery(String value) {
    _searchQuery = value.trim();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDistanceFilterKm(double? km) {
    _distanceFilterKm = km;
    notifyListeners();
  }

  List<Deal> get filteredDeals {
    final query = _searchQuery.toLowerCase();

    final filtered = _allDeals.where((deal) {
      final matchesQuery = query.isEmpty ||
          deal.title.toLowerCase().contains(query) ||
          deal.shopName.toLowerCase().contains(query) ||
          deal.category.toLowerCase().contains(query);

      final matchesCategory =
          _selectedCategory == 'All' || deal.category == _selectedCategory;

      final distanceMeters = distanceTo(deal);
      final matchesDistance = _distanceFilterKm == null ||
          (distanceMeters != null &&
              distanceMeters <= _distanceFilterKm! * 1000);

      return matchesQuery && matchesCategory && matchesDistance;
    }).toList();

    // Sort by proximity when location is available; otherwise by expiration date.
    if (_currentPosition != null) {
      filtered.sort((a, b) {
        final distanceA = distanceTo(a) ?? double.infinity;
        final distanceB = distanceTo(b) ?? double.infinity;
        return distanceA.compareTo(distanceB);
      });
    } else {
      filtered.sort((a, b) => a.expiresAt.compareTo(b.expiresAt));
    }

    return filtered;
  }

  Future<void> addDeal(Deal deal) async {
    await _databaseService.insertDeal(deal);
    await reloadDeals();
  }

  Future<void> updateDeal(Deal deal) async {
    await _databaseService.updateDeal(deal);
    await reloadDeals();
  }

  Future<void> deleteDeal(Deal deal) async {
    if (deal.id == null) return;
    await _databaseService.deleteDeal(deal.id!);
    await reloadDeals();
  }

  List<Deal> get userAddedDeals =>
      _allDeals.where((deal) => deal.isUserAdded).toList();
}
