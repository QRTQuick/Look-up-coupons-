import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyThemeMode = 'theme_mode';
  static const _keyNotificationsEnabled = 'notifications_enabled';
  static const _keyRequirePin = 'require_pin';
  static const _keyPin = 'pin';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  ThemeMode get themeMode {
    final value = _prefs.getString(_keyThemeMode);
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_keyThemeMode, value);
  }

  bool get notificationsEnabled =>
      _prefs.getBool(_keyNotificationsEnabled) ?? true;

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_keyNotificationsEnabled, enabled);
  }

  bool get requirePin => _prefs.getBool(_keyRequirePin) ?? false;

  Future<void> setRequirePin(bool requirePin) async {
    await _prefs.setBool(_keyRequirePin, requirePin);
  }

  String? get pin => _prefs.getString(_keyPin);

  Future<void> setPin(String? pin) async {
    if (pin == null || pin.isEmpty) {
      await _prefs.remove(_keyPin);
    } else {
      await _prefs.setString(_keyPin, pin);
    }
  }
}
