import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
// Check if location services are enabled
Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
}

// Check location permission status
Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
}

// Request location permission
Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
}

// Show dialog to enable GPS
Future<bool> showLocationDialog(BuildContext context) async {
    return await showDialog(
    context: context,
    builder: (BuildContext context) {
        return AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
            'Please enable location services to use this feature.'),
        actions: <Widget>[
            TextButton(
            child: const Text('Cancel'),
            onPressed: () {
                Navigator.of(context).pop(false);
            },
            ),
            TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
                Navigator.of(context).pop(true);
                Geolocator.openLocationSettings();
            },
            ),
        ],
        );
    },
    );
}

// Get current location with permission handling
Future<Position?> getCurrentLocation(BuildContext context) async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
    final openSettings = await showLocationDialog(context);
    if (!openSettings) {
        return null;
    }
    return null;
    }

    // Check and request location permission
    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
    permission = await requestPermission();
    if (permission == LocationPermission.denied) {
        // Permission still denied
        return null;
    }
    }

    // Handle permanently denied permission
    if (permission == LocationPermission.deniedForever) {
    // Show dialog informing user they need to enable permissions in settings
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
        content: Text(
            'Location permissions are permanently denied. Please enable them in settings.'),
        ),
    );
    return null;
    }

    // Get location if all checks pass
    try {
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
    );
    } catch (e) {
    debugPrint('Error getting location: $e');
    return null;
    }
}
}

