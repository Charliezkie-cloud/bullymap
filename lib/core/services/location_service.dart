import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bullymap/core/config/env.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  static Future<PinnedLocation?> reverseGeocode({ required double latitude, required double longitude}) async {
    final uri = Uri.https(
      'api.mapbox.com',
      '/search/geocode/v6/reverse',
      {
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        'access_token': Env.mapBoxAccessToken,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to retrieve location information');
    }

    final data = jsonDecode(response.body);
    final features = data['features'] as List;

    if (features.isEmpty) return null;
    
    final properties = features.first['properties'] as Map<String, dynamic>;
    return PinnedLocation.fromJson(
      properties,
      latitude,
      longitude,
    );
  }
}