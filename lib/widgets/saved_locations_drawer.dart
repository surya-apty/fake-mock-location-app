import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mock_gps_location_app/providers/location_provider.dart';
import 'package:mock_gps_location_app/models/saved_location.dart';

class SavedLocationsDrawer extends StatelessWidget {
  const SavedLocationsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.bookmark,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Saved Locations',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your bookmarked locations',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: locationProvider.savedLocations.isEmpty
                    ? _buildEmptyState()
                    : _buildLocationsList(locationProvider),
              ),
              if (locationProvider.savedLocations.isNotEmpty)
                _buildClearAllButton(context, locationProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No saved locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Save locations to access them quickly',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList(LocationProvider locationProvider) {
    return ListView.builder(
      itemCount: locationProvider.savedLocations.length,
      itemBuilder: (context, index) {
        final location = locationProvider.savedLocations[index];
        return _buildLocationTile(context, location, locationProvider);
      },
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    SavedLocation location,
    LocationProvider locationProvider,
  ) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.blue,
        child: Icon(
          Icons.location_on,
          color: Colors.white,
        ),
      ),
      title: Text(
        location.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lat: ${location.latitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Lng: ${location.longitude.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 12),
          ),
          Text(
            'Saved: ${DateFormat('MMM dd, yyyy').format(location.timestamp)}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(value, location, locationProvider),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'load',
            child: Row(
              children: [
                Icon(Icons.location_on),
                SizedBox(width: 8),
                Text('Load Location'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () => _loadLocation(location, locationProvider),
    );
  }

  Widget _buildClearAllButton(BuildContext context, LocationProvider locationProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _showClearAllDialog(context, locationProvider),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.clear_all),
          label: const Text('Clear All'),
        ),
      ),
    );
  }

  void _handleMenuAction(
    String action,
    SavedLocation location,
    LocationProvider locationProvider,
  ) {
    switch (action) {
      case 'load':
        _loadLocation(location, locationProvider);
        break;
      case 'delete':
        _deleteLocation(location, locationProvider);
        break;
    }
  }

  void _loadLocation(SavedLocation location, LocationProvider locationProvider) {
    locationProvider.loadSavedLocation(location);
    Navigator.pop(context);
  }

  void _deleteLocation(SavedLocation location, LocationProvider locationProvider) {
    locationProvider.deleteSavedLocation(location.id);
  }

  void _showClearAllDialog(BuildContext context, LocationProvider locationProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Locations'),
        content: const Text(
          'Are you sure you want to delete all saved locations? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear all locations
              for (final location in locationProvider.savedLocations) {
                locationProvider.deleteSavedLocation(location.id);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
} 