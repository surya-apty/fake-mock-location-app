import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_gps_location_app/providers/settings_provider.dart';
import 'package:mock_gps_location_app/services/mock_location_service.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({super.key});

  @override
  State<SettingsDrawer> createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  final MockLocationService _mockLocationService = MockLocationService();
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _checkDeveloperModeStatus();
  }

  Future<void> _checkDeveloperModeStatus() async {
    setState(() => _isCheckingStatus = true);
    try {
      final settingsProvider = context.read<SettingsProvider>();
      final isDeveloperModeEnabled = await _mockLocationService.isDeveloperModeEnabled();
      final isMockLocationAppSelected = await _mockLocationService.isMockLocationAppSelected();
      
      await settingsProvider.setDeveloperModeEnabled(isDeveloperModeEnabled);
      await settingsProvider.setMockLocationAppSelected(isMockLocationAppSelected);
    } catch (e) {
      // Handle error silently
    } finally {
      setState(() => _isCheckingStatus = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
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
                      Icons.settings,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Configure your app preferences',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDeveloperModeSection(settingsProvider),
                    const Divider(),
                    _buildLocationFormatSection(settingsProvider),
                    const Divider(),
                    _buildUpdateIntervalSection(settingsProvider),
                    const Divider(),
                    _buildBackgroundMockingSection(settingsProvider),
                    const Divider(),
                    _buildAboutSection(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeveloperModeSection(SettingsProvider settingsProvider) {
    return ExpansionTile(
      leading: const Icon(Icons.developer_mode),
      title: const Text('Developer Mode'),
      subtitle: Text(
        settingsProvider.developerModeEnabled ? 'Enabled' : 'Disabled',
        style: TextStyle(
          color: settingsProvider.developerModeEnabled ? Colors.green : Colors.red,
        ),
      ),
      children: [
        ListTile(
          title: const Text('Enable Developer Options'),
          subtitle: const Text('Required for mock location'),
          trailing: ElevatedButton(
            onPressed: () => _mockLocationService.openDeveloperOptions(),
            child: const Text('Open'),
          ),
        ),
        ListTile(
          title: const Text('Select Mock Location App'),
          subtitle: const Text('Choose this app as mock provider'),
          trailing: ElevatedButton(
            onPressed: () => _mockLocationService.openMockLocationSettings(),
            child: const Text('Open'),
          ),
        ),
        ListTile(
          title: const Text('Status Check'),
          subtitle: const Text('Verify developer mode setup'),
          trailing: _isCheckingStatus
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  onPressed: _checkDeveloperModeStatus,
                  icon: const Icon(Icons.refresh),
                ),
        ),
        if (settingsProvider.mockLocationAppSelected)
          const ListTile(
            leading: Icon(Icons.check_circle, color: Colors.green),
            title: Text('Mock Location App Selected'),
            subtitle: Text('This app is set as mock location provider'),
          ),
      ],
    );
  }

  Widget _buildLocationFormatSection(SettingsProvider settingsProvider) {
    return ListTile(
      leading: const Icon(Icons.format_list_numbered),
      title: const Text('Location Format'),
      subtitle: Text(_getLocationFormatName(settingsProvider.locationFormat)),
      onTap: () => _showLocationFormatDialog(settingsProvider),
    );
  }

  Widget _buildUpdateIntervalSection(SettingsProvider settingsProvider) {
    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('Update Interval'),
      subtitle: Text('${settingsProvider.updateInterval}ms'),
      onTap: () => _showUpdateIntervalDialog(settingsProvider),
    );
  }

  Widget _buildBackgroundMockingSection(SettingsProvider settingsProvider) {
    return SwitchListTile(
      secondary: const Icon(Icons.background_timer),
      title: const Text('Background Mocking'),
      subtitle: const Text('Continue mocking when app is in background'),
      value: settingsProvider.backgroundMocking,
      onChanged: (value) => settingsProvider.setBackgroundMocking(value),
    );
  }

  Widget _buildAboutSection() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('About'),
      subtitle: const Text('Mock GPS Location v1.0.0'),
      onTap: () => _showAboutDialog(),
    );
  }

  String _getLocationFormatName(LocationFormat format) {
    switch (format) {
      case LocationFormat.decimalDegrees:
        return 'Decimal Degrees (DD)';
      case LocationFormat.degreesMinutes:
        return 'Degrees Minutes (DM)';
      case LocationFormat.degreesMinutesSeconds:
        return 'Degrees Minutes Seconds (DMS)';
    }
  }

  void _showLocationFormatDialog(SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LocationFormat.values.map((format) {
            return RadioListTile<LocationFormat>(
              title: Text(_getLocationFormatName(format)),
              value: format,
              groupValue: settingsProvider.locationFormat,
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setLocationFormat(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUpdateIntervalDialog(SettingsProvider settingsProvider) {
    final controller = TextEditingController(
      text: settingsProvider.updateInterval.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set the interval for location updates (in milliseconds)'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Interval (ms)',
                hintText: '1000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final interval = int.tryParse(controller.text);
              if (interval != null && interval > 0) {
                settingsProvider.setUpdateInterval(interval);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Mock GPS Location'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A Flutter app for mocking GPS location on Android devices.'),
            SizedBox(height: 16),
            Text(
              'Note: This app requires Developer Options to be enabled and must be selected as the mock location app.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 