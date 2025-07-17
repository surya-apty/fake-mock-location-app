import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mock_gps_location_app/models/saved_location.dart';

class StorageService {
  static const String _savedLocationsKey = 'saved_locations';

  Future<List<SavedLocation>> getSavedLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locationsJson = prefs.getStringList(_savedLocationsKey) ?? [];
      
      return locationsJson
          .map((json) => SavedLocation.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      throw Exception('Failed to load saved locations: $e');
    }
  }

  Future<void> saveLocation(SavedLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locations = await getSavedLocations();
      
      // Check if location with same name already exists
      final existingIndex = locations.indexWhere((loc) => loc.name == location.name);
      if (existingIndex != -1) {
        locations[existingIndex] = location;
      } else {
        locations.add(location);
      }
      
      final locationsJson = locations
          .map((location) => jsonEncode(location.toJson()))
          .toList();
      
      await prefs.setStringList(_savedLocationsKey, locationsJson);
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locations = await getSavedLocations();
      
      locations.removeWhere((location) => location.id == id);
      
      final locationsJson = locations
          .map((location) => jsonEncode(location.toJson()))
          .toList();
      
      await prefs.setStringList(_savedLocationsKey, locationsJson);
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  Future<void> clearAllLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedLocationsKey);
    } catch (e) {
      throw Exception('Failed to clear locations: $e');
    }
  }
} 