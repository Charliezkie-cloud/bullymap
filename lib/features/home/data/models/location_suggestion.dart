class LocationSuggestion {
  final String mapboxId;
  final String name;
  final String placeFormatted;

  const LocationSuggestion({
    required this.mapboxId,
    required this.name,
    this.placeFormatted = '',
  });

  // Factory methods
  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      mapboxId: json['mapbox_id'] as String,
      name: (json['name'] as String?) ?? '',
      placeFormatted: (json['place_formatted'] as String?) ?? '',
    );
  }
}