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
}