class PinnedLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  const PinnedLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory PinnedLocation.fromJson(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
  ) {
    return PinnedLocation(
      name: json['name_preferred'] ?? json['name'] ?? 'Dropped pin',
      address: json['full_address'] ?? json['place_formatted'] ?? 'Address unavailable',
      latitude: latitude,
      longitude: longitude,
    );
  }

  factory PinnedLocation.fromMapboxFeature(Map<String, dynamic> feature) {
    final coords = (feature['geometry'] as Map<String, dynamic>?)?['coordinates'] as List?;
    if (coords == null || coords.length < 2) {
      throw const FormatException('Mapbox feature has no coordinates');
    }
    final props = (feature['properties'] as Map<String, dynamic>?) ?? const {};

    return PinnedLocation(
      name: props['name'] as String? ?? 'Selected place',
      address: props['full_address'] as String? ??
          props['place_formatted'] as String? ??
          '',
      latitude: (coords[1] as num).toDouble(),
      longitude: (coords[0] as num).toDouble(),
    );
  }
}