[← Docs index](README.md)

# Secrets & Configuration (CRITICAL)

The previous app stored its Mapbox token in a committed XML file. **Do not repeat that.**

- **Public Mapbox token (`pk.`)** — injected at build time via `--dart-define-from-file`. Not hardcoded in Dart, XML, plist, or Gradle files.
- **Secret Mapbox token (`sk.`)** — never in the repo, never in app code, never in the app bundle. If the build tooling needs it (check current Mapbox docs; recent SDK versions may not), keep it in the developer's local `~/.gradle/gradle.properties` (Android) and `~/.netrc` (iOS) only.
- `env/*.json` real files are **gitignored**; commit only `env/dev.example.json` with placeholder values.
- Restrict the public token in the Mapbox dashboard (URL/bundle ID restrictions where supported) and keep scopes minimal.
- If a secret is ever committed: treat it as leaked, rotate it, then clean history. Do not just delete the file.
- Agents: never print, log, or paste token values into chat, commits, or issues.
