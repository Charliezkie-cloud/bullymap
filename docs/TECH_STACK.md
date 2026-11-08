[← Docs index](README.md)

# Tech Stack

| Concern | Choice | Notes |
|---|---|---|
| Framework | Flutter (stable channel) | Pin exact version via FVM, see [§3](ENVIRONMENT_SETUP.md) |
| Language | Dart (null-safe, strict analysis) | |
| Maps | `mapbox_maps_flutter` | Official Mapbox plugin |
| Location | `geolocator` | Permissions via `permission_handler` only if needed |
| Search/Geocoding | Mapbox Search/Geocoding HTTP API | Via `dio` or `http`, behind a repository **[TBD]** |
| Routing | Mapbox Directions API | Turn-by-turn SDK is a separate decision **[TBD]** |
| State management | `flutter_riverpod` | Proposed default **[TBD: confirm]** |
| Routing (screens) | `go_router` | Proposed default **[TBD: confirm]** |
| Local storage | `shared_preferences` (settings only) | No backend in MVP |
| Backend | None | Keep it that way unless the maintainer says otherwise |

Rule: **do not add a dependency without stating why** in the PR/commit message. Prefer the Flutter SDK or an existing dependency first.
