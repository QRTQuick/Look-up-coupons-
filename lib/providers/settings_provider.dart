import 'package:flutter/material.dart';

import 'package:look_up_coupons/services/local_storage_service.dart';
import 'package:look_up_coupons/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required this.localStorageService,
    required this.notificationService,
  });

  final LocalStorageService localStorageService;
  final NotificationService notificationService;

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _requirePin = false;
  String? _pin;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get requirePin => _requirePin;
  bool get hasPin => _pin != null && _pin!.isNotEmpty;

  Future<void> initialize() async {
    _themeMode = localStorageService.themeMode;
    _notificationsEnabled = localStorageService.notificationsEnabled;
    _requirePin = localStorageService.requirePin;
    _pin = localStorageService.pin;

    if (_notificationsEnabled) {
      await notificationService.scheduleDailySummary();
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await localStorageService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await localStorageService.setNotificationsEnabled(enabled);

    if (enabled) {
      await notificationService.requestPermissions();
      await notificationService.scheduleDailySummary();
    } else {
      await notificationService.cancelAll();
    }

    notifyListeners();
  }

  Future<void> setRequirePin(bool requirePin) async {
    _requirePin = requirePin;
    await localStorageService.setRequirePin(requirePin);
    notifyListeners();
  }

  Future<void> setPin(String? pin) async {
    _pin = pin;
    await localStorageService.setPin(pin);
    notifyListeners();
  }

  bool verifyPin(String pin) {
    return _pin != null && _pin == pin;
  }
}
