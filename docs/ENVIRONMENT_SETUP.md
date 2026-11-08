[← Docs index](README.md)

# Environment Setup

```bash
# 1. Install FVM and pin Flutter (version recorded in .fvmrc)
dart pub global activate fvm
fvm install
fvm flutter pub get

# 2. Verify toolchains
fvm flutter doctor -v

# 3. Run (token passed at build time, see SECRETS_AND_CONFIGURATION.md)
fvm flutter run --dart-define-from-file=env/dev.json
```

Platform requirements:

- **Android:** JDK 17, Android SDK, device or emulator with Google Play services. Check `minSdk` against the current `mapbox_maps_flutter` requirement before changing it.
- **iOS:** macOS + Xcode, CocoaPods, a real device for reliable location testing. Check the minimum iOS deployment target against the current plugin requirement.
- Never commit `.fvm/flutter_sdk`, `build/`, `Pods/`, `.gradle/`, `.idea/`, `.dart_tool/`.
