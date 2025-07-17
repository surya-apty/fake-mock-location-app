import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class MockLocationService {
  static const MethodChannel _channel = MethodChannel('mock_location_service');

  Future<void> startMocking(Position position) async {
    try {
      await _channel.invokeMethod('startMocking', {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to start mocking: ${e.message}');
    }
  }

  Future<void> stopMocking() async {
    try {
      await _channel.invokeMethod('stopMocking');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop mocking: ${e.message}');
    }
  }

  Future<bool> isMockLocationEnabled() async {
    try {
      final result = await _channel.invokeMethod('isMockLocationEnabled');
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to check mock location status: ${e.message}');
    }
  }

  Future<bool> isDeveloperModeEnabled() async {
    try {
      final result = await _channel.invokeMethod('isDeveloperModeEnabled');
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to check developer mode: ${e.message}');
    }
  }

  Future<bool> isMockLocationAppSelected() async {
    try {
      final result = await _channel.invokeMethod('isMockLocationAppSelected');
      return result as bool;
    } on PlatformException catch (e) {
      throw Exception('Failed to check mock location app selection: ${e.message}');
    }
  }

  Future<void> openDeveloperOptions() async {
    try {
      await _channel.invokeMethod('openDeveloperOptions');
    } on PlatformException catch (e) {
      throw Exception('Failed to open developer options: ${e.message}');
    }
  }

  Future<void> openMockLocationSettings() async {
    try {
      await _channel.invokeMethod('openMockLocationSettings');
    } on PlatformException catch (e) {
      throw Exception('Failed to open mock location settings: ${e.message}');
    }
  }
} 