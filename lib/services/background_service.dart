import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mock_gps_location_app/services/mock_location_service.dart';

class BackgroundService {
  static const String _locationKey = 'mock_location';
  static const String _isMockingKey = 'is_mocking';

  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'mock_gps_location',
        initialNotificationTitle: 'Mock GPS Location',
        initialNotificationContent: 'Running in background',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<void> startService(Position position) async {
    final service = FlutterBackgroundService();
    
    await service.invoke('setAsForeground');
    await service.invoke('setAsBackground');
    
    await service.invoke('update', {
      _locationKey: {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'heading': position.heading,
        'speed': position.speed,
      },
      _isMockingKey: true,
    });
  }

  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    
    await service.invoke('update', {
      _isMockingKey: false,
    });
    
    await service.invoke('stopService');
  }

  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('update').listen((event) async {
    final data = event!;
    final isMocking = data[_BackgroundService._isMockingKey] ?? false;
    
    if (isMocking) {
      final locationData = data[_BackgroundService._locationKey];
      if (locationData != null) {
        final position = Position(
          latitude: locationData['latitude'],
          longitude: locationData['longitude'],
          timestamp: DateTime.now(),
          accuracy: locationData['accuracy'] ?? 0,
          altitude: locationData['altitude'] ?? 0,
          heading: locationData['heading'] ?? 0,
          speed: locationData['speed'] ?? 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        
        await _BackgroundService._mockLocationService.startMocking(position);
      }
    } else {
      await _BackgroundService._mockLocationService.stopMocking();
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

class _BackgroundService {
  static const String _locationKey = 'mock_location';
  static const String _isMockingKey = 'is_mocking';
  static final MockLocationService _mockLocationService = MockLocationService();
} 