import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mock_gps_location_app/models/saved_location.dart';
import 'package:mock_gps_location_app/services/mock_location_service.dart';
import 'package:mock_gps_location_app/services/storage_service.dart';

class LocationProvider with ChangeNotifier {
  final MockLocationService _mockLocationService = MockLocationService();
  final StorageService _storageService = StorageService();
  
  Position? _currentPosition;
  Position? _selectedPosition;
  bool _isMocking = false;
  List<SavedLocation> _savedLocations = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Position? get currentPosition => _currentPosition;
  Position? get selectedPosition => _selectedPosition;
  bool get isMocking => _isMocking;
  List<SavedLocation> get savedLocations => _savedLocations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  LocationProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSavedLocations();
    await _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _setLoading(true);
      _clearError();
      
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to get current location: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectLocation(Position position) async {
    _selectedPosition = position;
    notifyListeners();
  }

  Future<void> startMocking() async {
    if (_selectedPosition == null) {
      _setError('Please select a location first');
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      
      await _mockLocationService.startMocking(_selectedPosition!);
      _isMocking = true;
      notifyListeners();
    } catch (e) {
      _setError('Failed to start mocking: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> stopMocking() async {
    try {
      _setLoading(true);
      _clearError();
      
      await _mockLocationService.stopMocking();
      _isMocking = false;
      notifyListeners();
    } catch (e) {
      _setError('Failed to stop mocking: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveLocation(String name) async {
    if (_selectedPosition == null) {
      _setError('No location selected to save');
      return;
    }

    try {
      final savedLocation = SavedLocation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        latitude: _selectedPosition!.latitude,
        longitude: _selectedPosition!.longitude,
        timestamp: DateTime.now(),
      );

      await _storageService.saveLocation(savedLocation);
      await _loadSavedLocations();
    } catch (e) {
      _setError('Failed to save location: $e');
    }
  }

  Future<void> loadSavedLocation(SavedLocation location) async {
    final position = Position(
      latitude: location.latitude,
      longitude: location.longitude,
      timestamp: location.timestamp,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    
    await selectLocation(position);
  }

  Future<void> deleteSavedLocation(String id) async {
    try {
      await _storageService.deleteLocation(id);
      await _loadSavedLocations();
    } catch (e) {
      _setError('Failed to delete location: $e');
    }
  }

  Future<void> _loadSavedLocations() async {
    try {
      _savedLocations = await _storageService.getSavedLocations();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load saved locations: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
} 