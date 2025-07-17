import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final bool isMocking;
  final bool isLoading;
  final bool hasSelectedLocation;
  final VoidCallback onStartMocking;
  final VoidCallback onStopMocking;
  final VoidCallback onSaveLocation;

  const ControlButtons({
    super.key,
    required this.isMocking,
    required this.isLoading,
    required this.hasSelectedLocation,
    required this.onStartMocking,
    required this.onStopMocking,
    required this.onSaveLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMainButton(context),
                ),
                const SizedBox(width: 12),
                _buildSaveButton(context),
              ],
            ),
            if (isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context) {
    if (isLoading) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.grey,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Processing...'),
          ],
        ),
      );
    }

    if (isMocking) {
      return ElevatedButton.icon(
        onPressed: onStopMocking,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.stop),
        label: const Text('Stop Mocking'),
      );
    }

    return ElevatedButton.icon(
      onPressed: hasSelectedLocation ? onStartMocking : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: hasSelectedLocation ? Colors.green : Colors.grey,
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.play_arrow),
      label: Text(
        hasSelectedLocation ? 'Start Mocking' : 'Select Location First',
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return IconButton(
      onPressed: hasSelectedLocation ? onSaveLocation : null,
      style: IconButton.styleFrom(
        backgroundColor: hasSelectedLocation ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
      ),
      icon: const Icon(Icons.bookmark_add),
      tooltip: 'Save Location',
    );
  }
} 