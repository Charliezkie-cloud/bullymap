[← Docs index](README.md)

# Open Decisions [TBD]

1. State management and router: confirm Riverpod + go_router. First check what `core/theme/theme_controller.dart` and `app/router.dart` already use; human code wins ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 2).
2. Navigation depth: Directions API + custom UI, or Mapbox Navigation SDK (higher cost, more native work)?
3. Backend: truly none? Any markers/user data stored server-side?
4. Ads: does the legacy ads video feature carry over?
5. Offline maps required?
6. Localization languages.
7. Minimum OS versions (Android minSdk, iOS target).
8. Analytics/crash reporting (e.g. Crashlytics), and its privacy impact.
