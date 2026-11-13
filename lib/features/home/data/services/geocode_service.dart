import 'dart:convert';

import 'package:bullymap/core/config/env.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class GeocodeService {
  // Constants
  static final String sessionToken = const Uuid().v4();

  // Methods
  static Future<PinnedLocation?> reverseGeocode({ required double latitude, required double longitude, required  }) async {
    final uri = Uri.https(
      'api.mapbox.com',
      '/search/geocode/v6/reverse',
      {
        'longitude': longitude.toString(),
        'latitude': latitude.toString(),
        'access_token': Env.mapBoxAccessToken,
        'session_token': sessionToken
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