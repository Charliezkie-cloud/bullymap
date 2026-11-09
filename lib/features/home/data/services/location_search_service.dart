
import 'dart:convert';
import 'package:bullymap/core/config/env.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LocationSearchService {
  final String sessionToken = const Uuid().v4();

  Future<List<Map<String, dynamic>>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.https(
      'api.mapbox.com',
      '/search/searchbox/v1/suggest',
      {
        'q': query,
        'access_token': Env.mapBoxAccessToken,
        'session_token': sessionToken,
        'limit': '5',
        'language': 'en',
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

  Future<Map<String, dynamic>> retrieveLocation(String mapboxId) async {
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
}
