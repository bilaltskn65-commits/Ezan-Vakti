import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled()
          .timeout(const Duration(seconds: 2));
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 2));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission()
            .timeout(const Duration(seconds: 4));
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {
      return null;
    }
  }

  static Future<String> getCityFromCoordinates(double lat, double lng) async {
    try {
      final geocoding = Geocoding();
      final placemarks = await geocoding
          .placemarkFromCoordinates(lat, lng)
          .timeout(const Duration(seconds: 3));
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return place.administrativeArea ??
            place.locality ??
            place.subAdministrativeArea ??
            'İstanbul';
      }
    } catch (_) {}
    return 'İstanbul';
  }
}

