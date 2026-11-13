
import 'dart:convert';
import 'package:bullymap/core/config/env.dart';
import 'package:bullymap/features/home/models/pinned_location.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LocationSearchService {
  // Constants
  static final String sessionToken = const Uuid().v4();

  // Methods
  static Future<List<Map<String, dynamic>>> searchLocations(String query, { required double latitude, required double longitude }) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.https(
      'api.mapbox.com',
      '/search/searchbox/v1/suggest',
      {
        'q': query,
        'access_token': Env.mapBoxAccessToken,
        'session_token': sessionToken,
        'limit': '10',
        'language': 'en',
        'proximity': '$longitude,$latitude',
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to search locations');
    }

    final data = jsonDecode(response.body);

    return List<Map<String, dynamic>>.from(
      data['suggestions'],
    );
  }

  static Future<Map<String, dynamic>> retrieveLocation(String mapboxId) async {
    final uri = Uri.https(
      'api.mapbox.com',
      '/search/searchbox/v1/retrieve/$mapboxId',
      {
        'access_token': Env.mapBoxAccessToken,
        'session_token': sessionToken,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to retrieve location');
    }

    final data = jsonDecode(response.body);

    return data['features'][0];
  }

  static Future<PinnedLocation> retrieve(String mapboxId) async {
    final uri = Uri.https(
      'api.mapbox.com',
      '/search/searchbox/v1/retrieve/$mapboxId',
      {'session_token': sessionToken, 'access_token': Env.mapBoxAccessToken},
    );

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Retrieve failed: ${res.statusCode}');
    }

    final feature = (jsonDecode(res.body)['features'] as List).first;
    final coords = feature['geometry']['coordinates'] as List;
    final props = feature['properties'] as Map<String, dynamic>;

    return PinnedLocation(
      name: props['name'] as String? ?? '',
      address: props['address'] as String? ?? '',
      longitude: (coords[0] as num).toDouble(),
      latitude: (coords[1] as num).toDouble(),
    );
  }
}
