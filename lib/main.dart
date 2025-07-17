import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_gps_location_app/providers/location_provider.dart';
import 'package:mock_gps_location_app/providers/settings_provider.dart';
import 'package:mock_gps_location_app/screens/home_screen.dart';
import 'package:mock_gps_location_app/services/background_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service
  await BackgroundService.initialize();
  
  runApp(const MockGPSLocationApp());
}

class MockGPSLocationApp extends StatelessWidget {
  const MockGPSLocationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Mock GPS Location',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
          ),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
} 