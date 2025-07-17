import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mock_gps_location_app/providers/location_provider.dart';
import 'package:mock_gps_location_app/providers/settings_provider.dart';
import 'package:mock_gps_location_app/widgets/location_info_card.dart';
import 'package:mock_gps_location_app/widgets/control_buttons.dart';
import 'package:mock_gps_location_app/widgets/saved_locations_drawer.dart';
import 'package:mock_gps_location_app/widgets/settings_drawer.dart';
import 'package:mock_gps_location_app/widgets/developer_mode_guide.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _isMapReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.blue),
            SizedBox(width: 8),
            Text('Mock GPS Location'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showSavedLocations(),
            tooltip: 'Saved Locations',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(),
            tooltip: 'Settings',
          ),
        ],
      ),
      drawer: const SavedLocationsDrawer(),
      endDrawer: const SettingsDrawer(),
      body: Consumer2<LocationProvider, SettingsProvider>(
        builder: (context, locationProvider, settingsProvider, child) {
          return Stack(
            children: [
              // Google Map
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    locationProvider.currentPosition?.latitude ?? 37.7749,
                    locationProvider.currentPosition?.longitude ?? -122.4194,
                  ),
                  zoom: 15,
                ),
                markers: _markers,
                onTap: _onMapTap,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                onCameraMove: _onCameraMove,
              ),
              
              // Location Info Card
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: LocationInfoCard(
                  selectedPosition: locationProvider.selectedPosition,
                  currentPosition: locationProvider.currentPosition,
                  isMocking: locationProvider.isMocking,
                  settingsProvider: settingsProvider,
                ),
              ),
              
              // Control Buttons
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ControlButtons(
                  isMocking: locationProvider.isMocking,
                  isLoading: locationProvider.isLoading,
                  hasSelectedLocation: locationProvider.selectedPosition != null,
                  onStartMocking: locationProvider.startMocking,
                  onStopMocking: locationProvider.stopMocking,
                  onSaveLocation: _showSaveLocationDialog,
                ),
              ),
              
              // Error Message
              if (locationProvider.errorMessage != null)
                Positioned(
                  top: 100,
                  left: 16,
                  right: 16,
                  child: _buildErrorCard(locationProvider.errorMessage!),
                ),
              
              // Developer Mode Guide
              if (!settingsProvider.developerModeEnabled)
                Positioned(
                  top: 120,
                  left: 16,
                  right: 16,
                  child: const DeveloperModeGuide(),
                ),
            ],
          );
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _isMapReady = true;
    _updateMarkers();
  }

  void _onMapTap(LatLng position) {
    final locationProvider = context.read<LocationProvider>();
    final newPosition = Position(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
    
    locationProvider.selectLocation(newPosition);
    _updateMarkers();
  }

  void _onCameraMove(CameraPosition position) {
    // Optional: Update markers or perform other actions on camera move
  }

  void _updateMarkers() {
    final locationProvider = context.read<LocationProvider>();
    final markers = <Marker>{};

    // Add current location marker
    if (locationProvider.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            locationProvider.currentPosition!.latitude,
            locationProvider.currentPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Current Location',
            snippet: 'Your actual location',
          ),
        ),
      );
    }

    // Add selected location marker
    if (locationProvider.selectedPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: LatLng(
            locationProvider.selectedPosition!.latitude,
            locationProvider.selectedPosition!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Selected Location',
            snippet: locationProvider.isMocking 
                ? 'Currently mocking this location'
                : 'Tap to start mocking',
          ),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.read<LocationProvider>().clearError(),
            ),
          ],
        ),
      ),
    );
  }

  void _showSavedLocations() {
    Scaffold.of(context).openDrawer();
  }

  void _showSettings() {
    Scaffold.of(context).openEndDrawer();
  }

  void _showSaveLocationDialog() {
    final locationProvider = context.read<LocationProvider>();
    if (locationProvider.selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location first')),
      );
      return;
    }

    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Location'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Location Name',
            hintText: 'e.g., Home, Office, Park',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                locationProvider.saveLocation(nameController.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Location saved!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 