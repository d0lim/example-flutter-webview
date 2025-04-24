import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/constants.dart';

/// Service that handles geolocation operations
class LocationService {
  /// Check and request location permissions
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      return false;
    }

    return true;
  }

  /// Handles a request to get the current location
  static Future<Map<String, dynamic>> handleGetLocation(List<dynamic> args) async {
    try {
      // Check if high accuracy is requested
      bool highAccuracy = args.isNotEmpty && args[0] == true;
      
      // Check permission
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return {
          'status': 'ERROR',
          'message': 'Location permission denied',
        };
      }
      
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: highAccuracy ? 
          LocationAccuracy.high : LocationAccuracy.medium
      );
      
      return {
        'status': 'OK',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'timestamp': position.timestamp?.millisecondsSinceEpoch,
      };
    } catch (e) {
      debugPrint('Location error: $e');
      return {
        'status': 'ERROR',
        'message': e.toString(),
      };
    }
  }

  /// Injects the JavaScript function for accessing location
  static Future<void> injectJsHandler(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: '''
      window.getNativeLocation = function(highAccuracy = false) {
        return window.flutter_inappwebview.callHandler('${AppConstants.jsHandlerGetLocation}', highAccuracy);
      };
    ''');
  }
}