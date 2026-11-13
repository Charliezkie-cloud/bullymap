import 'dart:convert';

import 'package:bullymap/core/config/env.dart';
import 'package:bullymap/features/home/models/navigation_route.dart';
import 'package:http/http.dart' as http;

class DirectionsService {
  // Methods
  static Future<NavigationRoute?> getDrivingRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final coordinates = '$originLng,$originLat;$destLng,$destLat';
    final uri = Uri.https(
      'api.mapbox.com',
      '/directions/v5/mapbox/driving/$coordinates',
      {
        'geometries': 'geojson',
        'steps': 'true',
        'overview': 'full',
        'access_token': Env.mapBoxAccessToken,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch directions: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>?;

    if (routes == null || routes.isEmpty) return null;

    return NavigationRoute.fromJson(routes.first as Map<String, dynamic>);
  }
}
