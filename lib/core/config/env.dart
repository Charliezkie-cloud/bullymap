class Env {
  static const mapBoxAccessToken = String.fromEnvironment("MAPBOX_ACCESS_TOKEN");

  static void validate() {
    if (mapBoxAccessToken.isEmpty || !mapBoxAccessToken.startsWith("pk")) {
      throw StateError(
        'Missing or invalid MAPBOX_ACCESS_TOKEN.'
        'Run with --dart-define-from-file=env.json',
      );
    }
  }
}