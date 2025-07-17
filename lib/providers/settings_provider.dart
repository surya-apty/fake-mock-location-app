import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _updateIntervalKey = 'update_interval';
  static const String _backgroundMockingKey = 'background_mocking';
  static const String _locationFormatKey = 'location_format';
  static const String _developerModeEnabledKey = 'developer_mode_enabled';
  static const String _mockLocationAppSelectedKey = 'mock_location_app_selected';

  int _updateInterval = 1000; // milliseconds
  bool _backgroundMocking = true;
  LocationFormat _locationFormat = LocationFormat.decimalDegrees;
  bool _developerModeEnabled = false;
  bool _mockLocationAppSelected = false;

  // Getters
  int get updateInterval => _updateInterval;
  bool get backgroundMocking => _backgroundMocking;
  LocationFormat get locationFormat => _locationFormat;
  bool get developerModeEnabled => _developerModeEnabled;
  bool get mockLocationAppSelected => _mockLocationAppSelected;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _updateInterval = prefs.getInt(_updateIntervalKey) ?? 1000;
      _backgroundMocking = prefs.getBool(_backgroundMockingKey) ?? true;
      _locationFormat = LocationFormat.values[
        prefs.getInt(_locationFormatKey) ?? LocationFormat.decimalDegrees.index
      ];
      _developerModeEnabled = prefs.getBool(_developerModeEnabledKey) ?? false;
      _mockLocationAppSelected = prefs.getBool(_mockLocationAppSelectedKey) ?? false;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setUpdateInterval(int interval) async {
    _updateInterval = interval;
    await _saveSetting(_updateIntervalKey, interval);
    notifyListeners();
  }

  Future<void> setBackgroundMocking(bool enabled) async {
    _backgroundMocking = enabled;
    await _saveSetting(_backgroundMockingKey, enabled);
    notifyListeners();
  }

  Future<void> setLocationFormat(LocationFormat format) async {
    _locationFormat = format;
    await _saveSetting(_locationFormatKey, format.index);
    notifyListeners();
  }

  Future<void> setDeveloperModeEnabled(bool enabled) async {
    _developerModeEnabled = enabled;
    await _saveSetting(_developerModeEnabledKey, enabled);
    notifyListeners();
  }

  Future<void> setMockLocationAppSelected(bool selected) async {
    _mockLocationAppSelected = selected;
    await _saveSetting(_mockLocationAppSelectedKey, selected);
    notifyListeners();
  }

  Future<void> _saveSetting<T>(String key, T value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (value is int) {
        await prefs.setInt(key, value);
      } else if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      debugPrint('Error saving setting: $e');
    }
  }

  String formatCoordinate(double coordinate) {
    switch (_locationFormat) {
      case LocationFormat.decimalDegrees:
        return coordinate.toStringAsFixed(6);
      case LocationFormat.degreesMinutes:
        return _convertToDegreesMinutes(coordinate);
      case LocationFormat.degreesMinutesSeconds:
        return _convertToDegreesMinutesSeconds(coordinate);
    }
  }

  String _convertToDegreesMinutes(double coordinate) {
    final degrees = coordinate.floor();
    final minutes = (coordinate - degrees) * 60;
    return '${degrees.toStringAsFixed(0)}° ${minutes.toStringAsFixed(4)}\'';
  }

  String _convertToDegreesMinutesSeconds(double coordinate) {
    final degrees = coordinate.floor();
    final minutesDecimal = (coordinate - degrees) * 60;
    final minutes = minutesDecimal.floor();
    final seconds = (minutesDecimal - minutes) * 60;
    return '${degrees.toStringAsFixed(0)}° ${minutes.toStringAsFixed(0)}\' ${seconds.toStringAsFixed(2)}"';
  }
}

enum LocationFormat {
  decimalDegrees,
  degreesMinutes,
  degreesMinutesSeconds,
} 