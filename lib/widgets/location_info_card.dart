import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mock_gps_location_app/providers/settings_provider.dart';

class LocationInfoCard extends StatelessWidget {
  final Position? selectedPosition;
  final Position? currentPosition;
  final bool isMocking;
  final SettingsProvider settingsProvider;

  const LocationInfoCard({
    super.key,
    required this.selectedPosition,
    required this.currentPosition,
    required this.isMocking,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: isMocking ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  isMocking ? 'Mocking Location' : 'Selected Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isMocking ? Colors.green : Colors.blue,
                  ),
                ),
                if (isMocking) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (selectedPosition != null) ...[
              _buildCoordinateRow(
                'Latitude',
                settingsProvider.formatCoordinate(selectedPosition!.latitude),
                Icons.north,
              ),
              const SizedBox(height: 4),
              _buildCoordinateRow(
                'Longitude',
                settingsProvider.formatCoordinate(selectedPosition!.longitude),
                Icons.east,
              ),
            ] else ...[
              const Text(
                'Tap on the map to select a location',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
            ],
            if (currentPosition != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.my_location, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Current Location',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _buildCoordinateRow(
                'Latitude',
                settingsProvider.formatCoordinate(currentPosition!.latitude),
                Icons.north,
                isSmall: true,
              ),
              const SizedBox(height: 2),
              _buildCoordinateRow(
                'Longitude',
                settingsProvider.formatCoordinate(currentPosition!.longitude),
                Icons.east,
                isSmall: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow(
    String label,
    String value,
    IconData icon, {
    bool isSmall = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isSmall ? 12 : 16,
          color: isSmall ? Colors.grey : Colors.blue,
        ),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: isSmall ? 11 : 13,
            fontWeight: FontWeight.w500,
            color: isSmall ? Colors.grey : Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: isSmall ? 11 : 13,
              fontFamily: 'monospace',
              color: isSmall ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
} 