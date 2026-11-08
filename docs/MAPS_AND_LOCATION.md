[← Docs index](README.md)

# Maps & Location Rules

Highest-risk area of the app (battery, privacy, cost, platform differences).

- **Cost control:** Mapbox bills per map load, API request, and monitored user. Do not add polling, per-keystroke search without **debounce (≥300 ms)**, or repeated route requests. Cache results where safe. Any new Mapbox product (Search, Directions, Navigation) must be flagged to the maintainer before use because it changes the bill.
- **Permissions:** request location *in context* (after the Intro screen explains why), handle all states: granted, denied, denied-forever, services off, and iOS "approximate location".
- **Background location is out of scope** unless explicitly requested. Do not add background modes or `ACCESS_BACKGROUND_LOCATION` without approval (store-review and privacy impact).
- **Battery:** stop location streams when the screen is not visible; choose accuracy/distance-filter deliberately.
- **Platform parity:** test every map/location change on both Android and iOS. Do not assume behavior is identical.
- **Offline:** no offline maps in MVP **[TBD]**. Handle no-network gracefully (clear message, no crash).

Native config touchpoints (edit carefully, keep both in sync):

- Android: `android/app/src/main/AndroidManifest.xml` (location permissions, internet)
- iOS: `ios/Runner/Info.plist` (`NSLocationWhenInUseUsageDescription` with a clear, honest reason), deployment target, Podfile
