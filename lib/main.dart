import 'dart:async';

import 'package:flutter/material.dart';

import 'screens/webview_screen.dart';
import 'services/location_service.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run app in error catching zone for better error handling
  runZonedGuarded<Future<void>>(() async {
    try {
      // Initialize services
      await _initializeServices();
      
      // Run the app
      runApp(const MyApp());
    } catch (e, stackTrace) {
      debugPrint('Error during app initialization: $e');
      
      // Start the app regardless of initialization errors
      runApp(const MyApp());
    }
  }, (error, stackTrace) {
    // Catch any errors not caught by Flutter's error handling
    debugPrint('Uncaught error: $error');
  });
}

/// Initialize all app services
Future<void> _initializeServices() async {
  try {
    // Request permissions
    await LocationService.requestLocationPermission();
    debugPrint('Location permissions requested');
    
    // Other service initializations can be added here
  } catch (e) {
    debugPrint('Error initializing services: $e');
  }
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Bridge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const WebViewScreen(),
    );
  }
}
