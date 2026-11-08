[← Docs index](README.md)

# Commands

```bash
fvm flutter pub get
fvm flutter analyze                       # must pass with zero issues
dart format --set-exit-if-changed .       # must pass
fvm flutter test                          # unit + widget tests
fvm flutter test integration_test         # on a device/emulator
fvm flutter run --dart-define-from-file=env/dev.json

# Release builds (never commit outputs)
fvm flutter build appbundle --release --dart-define-from-file=env/prod.json
fvm flutter build ipa --release --dart-define-from-file=env/prod.json
```

Before declaring any task done, run `analyze`, `format`, and `test`. If you could not run something (no device, no macOS), **say so explicitly** instead of implying it passed.
