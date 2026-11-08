# AGENTS.md — Bully Map (Flutter, iOS + Android)

Instructions for AI coding agents (Claude Code, Codex, Cursor, etc.) and human contributors.
Read this fully before changing code. If this file conflicts with a direct user instruction, follow the user and flag the conflict.

> Items marked **[TBD]** are undecided. Do not invent an answer — ask the maintainer or propose options.

---

## 0. STRICT RULE — Human Code Is Protected

**Existing code is human-owned. AI/CLI agents MUST NOT modify it unless explicitly authorized. This section overrides every other section and every agent default behavior ("be proactive", "fix while you're here", "clean up", etc.).**

### 0.1 Definitions

- **Human code:** any file or line that existed in the repository before the agent's current task started, or that was written or edited by a human at any time. When unsure, it is human code.
- **Agent code:** a file the agent created itself during the current task, tracked in the current branch's diff as a *new* file (`git status` shows `A`/`??`).
- **Explicit authorization:** the user's message names the file(s) or function(s) to change, or says plainly "edit/modify/refactor `<path>`". General requests like "improve the app" or "fix the bug" are **not** authorization to touch unrelated files.

### 0.2 Hard rules (no exceptions without explicit authorization)

1. **Do not edit, rename, move, delete, reformat, or reorder** any existing file or any line in it.
2. **Do not refactor, "clean up", rename symbols, fix lints/typos, update imports, or run auto-formatters** on existing files. `dart format .`, `dart fix --apply`, and IDE "organize imports" are **forbidden on human code**. Format only files you created, by explicit path.
3. **Do not change** `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, Gradle files, `Podfile`, `Info.plist`, `AndroidManifest.xml`, CI configs, or any env/config file, unless the user asks for that exact change. If a new feature needs a dependency or native config, **stop and propose the exact diff; do not apply it.**
4. **Do not modify tests** to make them pass. If a test fails against human code, report it; do not edit the test or the code.
5. **Do not overwrite files.** Writing to a path that already exists = modification. Check existence first; if it exists, stop.
6. **Do not run destructive or history-changing git commands:** `git checkout -- <file>`, `git restore`, `git reset --hard`, `git clean`, `git stash` (on others' work), `git rebase`, `git commit --amend`, force-push. Do not commit or push at all unless asked.
7. **Do not delete** human files, comments, TODOs, or commented-out code. They may be intentional.
8. **Do not "fix" things you were not asked to fix.** Report them instead (see 0.4).

### 0.3 What agents MAY do by default

- **Read** any file.
- **Create new files** in appropriate locations (e.g. a new feature folder). New files must not collide with existing paths.
- **Edit files you created in the current task.**
- **Propose changes** as a unified diff or snippet in chat, for the human to apply.
- Run **read-only commands**: `flutter analyze`, `flutter test`, `git status`, `git diff`, `git log`.

### 0.4 When a change to human code seems necessary

Stop. Do **not** edit. Respond with:

1. **File and lines** that would need to change.
2. **Why** it is necessary (what breaks without it).
3. **Exact proposed diff.**
4. **Smaller alternatives** that avoid touching human code (adapter, wrapper, new file, extension method).

Wait for explicit approval. Approval applies **only** to the files and changes named, not to the rest of the task.

### 0.5 Minimal-integration pattern

When new code must connect to human code, prefer **additive** wiring:

- New file + one-line registration proposed to the human, instead of rewriting the existing file.
- Wrapper/adapter/extension around existing classes instead of modifying them.
- New provider/route/entry added by the human from your proposed snippet.

### 0.6 Human-owned markers

Code marked with any of these is **locked**, even if the user authorized broader edits. Agents must ask again before touching it:

```dart
// HUMAN-OWNED: do not modify without explicit approval
// @protected
```

### 0.7 Strict Code Rules (apply to all code the agent writes)

**Rule 1 — No over-engineering.**

- Write the simplest code that meets the request. Plain widgets and plain functions first.
- No abstractions, interfaces, base classes, generics, factories, mixins, or design patterns until there is a second real use. Three similar lines beat a premature helper.
- No speculative features, config flags, extension points, or "future-proofing". Build only what was asked.
- No extra files, classes, or layers beyond what the feature needs. The folders marked *planned* in §4 are a guide, not a requirement: create a folder only when it has something to put in it.
- No new dependencies (see §2).
- If complexity is truly needed, justify it in one sentence in your reply before writing it.

**Rule 2 — Be consistent with the existing human code.**

- Before writing, read the neighboring files in the same feature/folder. Match their naming, structure, state-management approach, error handling, widget style, import style, and formatting.
- Do not introduce a new pattern, library, or style when the codebase already has one for that job.
- If human code differs from the conventions in §7, **follow the human code** and mention the difference in your reply. Do not "fix" it (see §0.2).
- If existing code is internally inconsistent, follow the pattern most used in that folder and say which one you picked.
- Match the existing naming of files, classes, providers, routes, and tests.

**Rule 3 — No over-commenting.**

- Code should explain itself through clear names. Comment only the **why** that the code cannot show: a non-obvious decision, a workaround (with the reason), a platform quirk, a gotcha.
- Do not comment what the code does. No `// set state`, `// loop through items`, `// returns the value`.
- No section banners, no divider lines, no docstring on every function, no docs on trivial or private members.
- No commented-out code. No `TODO`/`FIXME` unless asked. No attribution or changelog comments ("added by AI", "updated for X").
- Match the comment density and style of the surrounding human code. If it has few comments, you have few comments.

Bad/Good code examples for these rules and for control flow: see **§14**.

---

### 0.8 Verification before finishing (mandatory)

Before reporting a task as done, the agent MUST run and report:

```bash
git status --short          # only new (A / ??) files expected, unless authorized
git diff --stat             # must show no changes to existing files, unless authorized
```

If `git diff --stat` shows any existing file modified without authorization: **revert only your own change to that file, tell the user exactly what happened, and do not continue.** Never hide or minimize such a violation.

### 0.9 Enforcement (maintainers: set this up, do not rely on this file alone)

This file is advisory; agents can ignore instructions. Back it with tooling:

- **Claude Code:** add `permissions.deny` / `ask` rules in `.claude/settings.json` for `Edit`/`Write` on existing paths (e.g. `lib/**`, `android/**`, `ios/**`, `pubspec.yaml`) and require approval for `Bash(git commit:*)`, `Bash(git push:*)`, `Bash(dart format:*)`, `Bash(dart fix:*)`.
- **Git:** work on a dedicated `agent/<task>` branch; review `git diff main` before merging. Use a `pre-commit` hook that blocks commits modifying protected paths.
- **GitHub:** `CODEOWNERS` assigning protected paths to the human maintainers, plus branch protection requiring review on `main`.
- Optionally make human code read-only at the OS level for the agent's session (`chmod -R a-w lib/` then re-enable manually).

---

## 1. Project Overview

Bully Map is a geolocation/map app built with **Flutter** for **iOS and Android**. It is a ground-up rebuild of a previous native Kotlin (Android-only) app. **Do not port or copy code from the legacy Kotlin project**; use it only as a rough feature reference.

**Planned screens (MVP):**

| Screen | Purpose |
|---|---|
| Intro | First-launch onboarding, permission explanation |
| Home (Map) | Mapbox map, user location, markers, destination search |
| Navigation | Route to a destination, turn guidance |
| Settings | Preferences, permissions status, about/legal |

**Maintainers:** Charles Henry M. Tinoy Jr. (lead), Zechariah Etcuban.
**Client owns:** Mapbox account, Apple Developer account, Google Play Console account **[TBD: confirm]**.

---

## 2. Tech Stack

| Concern | Choice | Notes |
|---|---|---|
| Framework | Flutter (stable channel) | Pin exact version via FVM, see §3 |
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

---

## 3. Environment Setup

```bash
# 1. Install FVM and pin Flutter (version recorded in .fvmrc)
dart pub global activate fvm
fvm install
fvm flutter pub get

# 2. Verify toolchains
fvm flutter doctor -v

# 3. Run (token passed at build time, see §5)
fvm flutter run --dart-define-from-file=env/dev.json
```

Platform requirements:

- **Android:** JDK 17, Android SDK, device or emulator with Google Play services. Check `minSdk` against the current `mapbox_maps_flutter` requirement before changing it.
- **iOS:** macOS + Xcode, CocoaPods, a real device for reliable location testing. Check the minimum iOS deployment target against the current plugin requirement.
- Never commit `.fvm/flutter_sdk`, `build/`, `Pods/`, `.gradle/`, `.idea/`, `.dart_tool/`.

---

## 4. Project Structure

Feature-first layout. It matches the current project. Folders marked *(planned)* do not exist yet: create one only when its first file is needed (§0.7, Rule 1). Never move or rename existing folders or files (§0.2).

```
lib/
├── main.dart                         # entry point
├── app/
│   ├── app.dart                      # root App widget
│   ├── router.dart                   # router setup
│   └── routes.dart                   # route names/paths
├── core/
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── light_theme.dart
│   │   ├── dark_theme.dart
│   │   └── theme_controller.dart
│   ├── constants/                    # (planned) app constants, build-time config
│   ├── services/                     # (planned) app-wide services, e.g. location_service.dart
│   └── utils/                        # (planned) pure helper functions
├── features/
│   ├── intro/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/              # (planned) widgets used only by this feature
│   │       └── controllers/          # (planned) state/controllers for this feature
│   ├── home/                         # Home (Map) screen, same layout as intro/
│   ├── navigation/                   # same layout as intro/
│   └── settings/                     # same layout as intro/
├── widgets/                          # shared widgets used by 2+ features
│   └── theme_switch.dart
└── data/                             # (planned) shared models, repositories, datasources
    ├── models/
    ├── repositories/
    └── datasources/
test/                                 # mirrors lib/ structure
integration_test/
env/                                  # dev.json / prod.json templates (real tokens gitignored)
```

### Where new code goes

| What | Where |
|---|---|
| New screen | `features/<feature>/presentation/screens/<name>_screen.dart` |
| Widget used by one feature | `features/<feature>/presentation/widgets/` |
| Widget used by 2+ features | `widgets/` |
| Screen state / controller | `features/<feature>/presentation/controllers/` (app-wide theme state stays in `core/theme/`) |
| Model | `data/models/` |
| Repository | `data/repositories/` |
| HTTP / SDK / storage access | `data/datasources/` (may live inside the repository while there is only one source) |
| Location / permission logic | `core/services/` |
| Constants, build-time config (Mapbox token) | `core/constants/` |
| Pure helper function | `core/utils/` |
| New route | `app/routes.dart` + `app/router.dart` (existing human files: propose the snippet, do not edit, §0.5) |

### Dependency rules

- Direction: `screens / widgets / controllers → data/repositories → data/datasources`. There is no `domain/` layer by default.
- Widgets never call HTTP or SDKs directly; they go through a controller or repository.
- Features do not import each other. Shared code goes in `widgets/`, `core/`, or `data/`.
- There is no `shared/` folder. Shared widgets live in `widgets/`.
- There is no authentication feature: the MVP has no accounts and no backend (§2).

---

## 5. Secrets & Configuration (CRITICAL)

The previous app stored its Mapbox token in a committed XML file. **Do not repeat that.**

- **Public Mapbox token (`pk.`)** — injected at build time via `--dart-define-from-file`. Not hardcoded in Dart, XML, plist, or Gradle files.
- **Secret Mapbox token (`sk.`)** — never in the repo, never in app code, never in the app bundle. If the build tooling needs it (check current Mapbox docs; recent SDK versions may not), keep it in the developer's local `~/.gradle/gradle.properties` (Android) and `~/.netrc` (iOS) only.
- `env/*.json` real files are **gitignored**; commit only `env/dev.example.json` with placeholder values.
- Restrict the public token in the Mapbox dashboard (URL/bundle ID restrictions where supported) and keep scopes minimal.
- If a secret is ever committed: treat it as leaked, rotate it, then clean history. Do not just delete the file.
- Agents: never print, log, or paste token values into chat, commits, or issues.

---

## 6. Commands

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

---

## 7. Code Conventions

- Follow `flutter_lints` (or stricter) in `analysis_options.yaml`. No `// ignore` without a comment explaining why.
- Prefer `const` constructors; small widgets over deep `build()` methods; no business logic in widgets.
- Naming follows §7.1. One primary public class per file.
- Use `async/await`; handle every failure path. No empty `catch`. Return typed failures from repositories, show user-friendly messages in UI.
- Always dispose controllers, stream subscriptions, and Mapbox map/annotation managers.
- No hardcoded user-facing strings in widgets once localization is set up **[TBD: languages]**.
- No hardcoded URLs. The legacy app hardcoded an ads video URL; any remote asset URL goes in config.
- Keep functions small. Favor the simplest solution; justify any added abstraction in the PR.

### 7.1 Naming Conventions

Dart uses camelCase for most names. Follow the official [Effective Dart: Style](https://dart.dev/effective-dart/style). If existing human code names something differently, match the human code (§0.7, Rule 2) and do not rename it (§0.2).

| Element         | Convention                 | Example             |
| --------------- | -------------------------- | ------------------- |
| Variables       | lowerCamelCase             | `userName`          |
| Classes         | UpperCamelCase             | `UserProfile`       |
| Methods         | lowerCamelCase             | `getUser()`         |
| Functions       | lowerCamelCase             | `calculateTotal()`  |
| Constants       | lowerCamelCase             | `maxRetries`        |
| Enums           | UpperCamelCase             | `UserRole`          |
| Enum values     | lowerCamelCase             | `adminUser`         |
| Typedefs        | UpperCamelCase             | `UserCallback`      |
| Mixins          | UpperCamelCase             | `LoggerMixin`       |
| Extensions      | UpperCamelCase             | `StringExtensions`  |
| Parameters      | lowerCamelCase             | `userId`            |
| Private members | `_lowerCamelCase`          | `_userName`         |
| Files           | lowercase_with_underscores | `user_profile.dart` |
| Folders         | lowercase_with_underscores | `user_management`   |

#### Examples

Variables and constants

```dart
String userName = 'Charlie';
int userAge = 20;

final emailAddress = 'user@gmail.com';
const maxLoginAttempts = 5;
```

Classes

```dart
class UserProfile {
  String userName;
  int userAge;

  UserProfile(this.userName, this.userAge);

  void updateProfile() {
    print('Profile updated');
  }
}
```

Private variables and methods. A leading `_` makes a declaration private to its Dart library.

```dart
class AuthenticationService {
  String _accessToken = '';

  void _refreshToken() {
    print('Refreshing token');
  }
}
```

Enums

```dart
enum UserRole {
  admin,
  moderator,
  regularUser,
}
```

Functions

```dart
double calculateTotal(double price, int quantity) {
  return price * quantity;
}
```

#### File naming

Use `snake_case` (lowercase with underscores). The file name matches its main class.

✅ Good:

```
user_profile.dart
authentication_service.dart
home_screen.dart
theme_provider.dart
```

❌ Bad:

```
UserProfile.dart
userProfile.dart
AuthenticationService.dart
```

#### Bully Map examples

Names and paths follow §4.

```
features/home/presentation/screens/home_screen.dart          -> class HomeScreen
features/home/presentation/widgets/recenter_button.dart      -> class RecenterButton
features/settings/presentation/screens/settings_screen.dart  -> class SettingsScreen
data/repositories/place_search_repository.dart               -> class PlaceSearchRepository
core/services/location_service.dart                          -> class LocationService
```

#### Rules to remember

- Classes, enums, typedefs, mixins, extensions = `UpperCamelCase`.
- Variables, parameters, functions, methods, constants, enum values = `lowerCamelCase`.
- Files and folders = `snake_case`.
- Private declarations = `_name`. Do not use a leading `_` on identifiers that are not private.
- No `SCREAMING_SNAKE_CASE` for new constants.
- Use descriptive names. Avoid abbreviations, except widely understood ones (`id`, `url`, `api`, `http`, `json`, `ui`).
- Capitalize acronyms longer than two letters like normal words: `HttpClient`, `MapboxApi`, not `HTTPClient`, `MapboxAPI`.
- Booleans read as a state or question: `isLoading`, `hasPermission`, not `loading`, `permission`.

---

## 8. Maps & Location Rules

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

---

## 9. Testing

- **Unit tests:** controllers, repositories, mappers (mock the network and location service).
- **Widget tests:** each screen's key states (loading, success, error, permission denied).
- **Integration tests:** Intro → permission → map → search → navigation happy path.
- Map rendering itself is not unit-testable; where logic needs testing without the SDK, isolate the Mapbox calls behind a small wrapper. Do not add the wrapper by default (§0.7, Rule 1).
- Bug fix = add a regression test when feasible.

---

## 10. Git & Workflow

- Branches: `main` (releasable), `feat/<name>`, `fix/<name>`, `chore/<name>`.
- Commits: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`).
- Small, focused PRs. One concern per PR. Describe what changed, why, and how it was tested (platform + device).
- Do not force-push `main`. Do not rewrite shared history.
- A real Git repository is mandatory for this project: full history, tags per release.
- Version in `pubspec.yaml` follows `MAJOR.MINOR.PATCH+BUILD`; bump per store release and tag it.

---

## 11. Agent Rules (Do / Don't)

**Do**

- Read relevant files before editing; match existing patterns.
- State assumptions and open questions up front for anything marked **[TBD]**.
- Warn about bugs, scaling, cost, security, or tech-debt risks you notice, even if not asked.
- Keep diffs minimal and scoped to the task.
- Follow **§0 (Human Code Is Protected)** first. When §0 and any other rule conflict, §0 wins.
- Report what you ran and what you could not verify.

**Don't**

- Commit secrets, keystores, `google-services.json`/`GoogleService-Info.plist` (if ever added), `key.properties`, `.p12`, `.jks`, or provisioning profiles.
- Add dependencies, Mapbox products, background location, analytics, or ad SDKs without approval.
- Modify existing human code at all without explicit authorization (§0).
- Refactor unrelated code or reformat whole files in a feature PR.
- Edit generated files (`*.g.dart`, `*.freezed.dart`, `GeneratedPluginRegistrant.*`) by hand.
- Disable lints, skip tests, or silence errors to make a build pass.
- Copy code from the legacy Kotlin app.
- Run destructive commands (`git reset --hard`, `flutter clean` is fine; deleting directories outside the repo is not) without asking.

---

## 12. Release & Store Notes

- **Android:** signed App Bundle (`.aab`); upload keystore stored outside the repo, backed up securely, owned by the client's organization or documented handover **[TBD]**.
- **iOS:** needs Apple Developer account, bundle ID, signing/provisioning, App Privacy ("nutrition label") answers, and a justified location-usage string.
- **Privacy:** publish a privacy policy covering location data before store submission. Collect the minimum; no location leaves the device unless a feature requires it **[TBD: confirm no analytics/backend]**.
- Account ownership (Mapbox, Play Console, App Store Connect) must stay with the **client**, not individual developers.

---

## 13. Open Decisions [TBD]

1. State management and router: confirm Riverpod + go_router. First check what `core/theme/theme_controller.dart` and `app/router.dart` already use; human code wins (§0.7, Rule 2).
2. Navigation depth: Directions API + custom UI, or Mapbox Navigation SDK (higher cost, more native work)?
3. Backend: truly none? Any markers/user data stored server-side?
4. Ads: does the legacy ads video feature carry over?
5. Offline maps required?
6. Localization languages.
7. Minimum OS versions (Android minSdk, iOS target).
8. Analytics/crash reporting (e.g. Crashlytics), and its privacy impact.

---

## 14. Code Examples: Control Flow & Structure

Examples are illustrative. Obey §0 first: match the existing human code (§0.7, Rule 2), and do not touch existing files to "apply" these examples.
Examples assume Dart 3+. Names like `Place` and `SearchFailure` are placeholders.

### 14.1 Control Flow

#### A. Guard clauses, not deep nesting

❌ Bad: pyramid of nested `if`/`else`; the happy path is buried.

```dart
Future<void> startTracking() async {
  if (await Geolocator.isLocationServiceEnabled()) {
    final permission = await Geolocator.checkPermission();
    if (permission != LocationPermission.denied) {
      if (permission != LocationPermission.deniedForever) {
        _listen();
      } else {
        _showError('Enable location in Settings');
      }
    } else {
      _showError('Location permission is required');
    }
  } else {
    _showError('Turn on location services');
  }
}
```

✅ Good: handle failures first and exit early; the happy path reads straight down.

```dart
Future<void> startTracking() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    _showError('Turn on location services');
    return;
  }

  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    _showError('Enable location in Settings');
    return;
  }
  if (permission == LocationPermission.denied) {
    _showError('Location permission is required');
    return;
  }

  _listen();
}
```

#### B. Exhaustive `switch` on enums, not `if/else` on strings

❌ Bad: stringly-typed; a typo or a new state compiles silently.

```dart
String statusMessage(String status) {
  if (status == 'granted') {
    return 'Location on';
  } else if (status == 'denied') {
    return 'Allow location to see your position';
  } else if (status == 'deniedForever') {
    return 'Enable location in Settings';
  }
  return '';
}
```

✅ Good: the compiler forces every case to be handled.

```dart
enum LocationStatus { granted, denied, deniedForever, serviceOff }

String statusMessage(LocationStatus status) => switch (status) {
      LocationStatus.granted => 'Location on',
      LocationStatus.denied => 'Allow location to see your position',
      LocationStatus.deniedForever => 'Enable location in Settings',
      LocationStatus.serviceOff => 'Turn on location services',
    };
```

#### C. Error handling: never swallow, always handle the failure path

❌ Bad: empty `catch`, no UI feedback, uses `context`/`setState` after `await` without checking `mounted`.

```dart
Future<void> _search(String query) async {
  try {
    final places = await _repo.search(query);
    setState(() => _results = places);
  } catch (_) {}
}
```

✅ Good: catch the specific failure, show it, check `mounted` after every `await`.

```dart
Future<void> _search(String query) async {
  try {
    final places = await _repo.search(query);
    if (!mounted) return;
    setState(() {
      _results = places;
      _error = null;
    });
  } on SearchFailure catch (e) {
    if (!mounted) return;
    setState(() => _error = e.message);
  }
}
```

#### D. Debounce user input (Mapbox bills per request)

❌ Bad: one API request per keystroke.

```dart
TextField(onChanged: _search)
```

✅ Good: debounce, and cancel the timer in `dispose`.

```dart
Timer? _debounce;

void _onQueryChanged(String query) {
  _debounce?.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
}

@override
void dispose() {
  _debounce?.cancel();
  super.dispose();
}
```

#### E. Null safety: no `!` on values that can change

❌ Bad: the bang operator crashes if the value becomes null between check and use.

```dart
if (_position != null) {
  _moveCamera(_position!.latitude, _position!.longitude);
}
```

✅ Good: copy to a local so promotion is safe.

```dart
final position = _position;
if (position == null) return;
_moveCamera(position.latitude, position.longitude);
```

### 14.2 Code Structure

#### A. Keep layers separate: no HTTP, tokens, or URLs in widgets

❌ Bad: widget calls the network directly, hardcodes URL and token, mixes parsing with UI.

```dart
class _HomeScreenState extends State<HomeScreen> {
  Future<void> _search(String q) async {
    final res = await http.get(Uri.parse(
        'https://api.mapbox.com/<endpoint>/$q.json?access_token=pk.HARDCODED'));
    final data = jsonDecode(res.body);
    setState(() => _results = data['features']);
  }
  // 400 more lines of build() ...
}
```

✅ Good: the widget only talks to a repository; the token comes from build-time config (§5).

```dart
// core/constants/app_config.dart
const mapboxToken = String.fromEnvironment('MAPBOX_TOKEN');

// data/repositories/place_search_repository.dart
class PlaceSearchRepository {
  PlaceSearchRepository(this._client);
  final http.Client _client;

  Future<List<Place>> search(String query) async {
    final uri = Uri.https('api.mapbox.com', '<endpoint>/$query.json', {
      'access_token': mapboxToken,
    });
    final res = await _client.get(uri);
    if (res.statusCode != 200) throw const SearchFailure('Search failed');
    return Place.listFromJson(jsonDecode(res.body));
  }
}

// features/home/presentation/screens/home_screen.dart
// Widget calls _repo.search(query); no http, no JSON, no token here.
```

#### B. Small widgets, not one giant `build()`

❌ Bad: one 300-line `build()` with nested widgets and inline logic.

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(children: [
      MapWidget(/* ... */),
      Positioned(top: 40, left: 16, right: 16, child: Container(/* 60 lines: search bar */)),
      Positioned(bottom: 24, right: 16, child: Container(/* 40 lines: recenter button */)),
      // ...
    ]),
  );
}
```

✅ Good: extract by responsibility into widget classes (not helper methods that return widgets).

```dart
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        MapWidget(/* ... */),
        const Positioned(top: 40, left: 16, right: 16, child: SearchBar()),
        Positioned(bottom: 24, right: 16, child: RecenterButton(onPressed: _recenter)),
      ],
    ),
  );
}
```

#### C. No over-engineering (§0.7, Rule 1)

❌ Bad: interface + implementation + factory for a single boolean setting.

```dart
abstract class SettingsStorage {
  bool get useMetric;
  Future<void> setUseMetric(bool value);
}

class SharedPrefsSettingsStorage implements SettingsStorage { /* ... */ }

class SettingsStorageFactory {
  static SettingsStorage create() => SharedPrefsSettingsStorage(/* ... */);
}
```

✅ Good: one small class. Add an interface later, when a second implementation exists.

```dart
class SettingsStore {
  SettingsStore(this._prefs);
  final SharedPreferences _prefs;

  bool get useMetric => _prefs.getBool('useMetric') ?? true;
  Future<void> setUseMetric(bool value) => _prefs.setBool('useMetric', value);
}
```

#### D. No magic values

❌ Bad: unexplained literals scattered through the code.

```dart
if (distanceMeters < 50) _showArrivedBanner();
Timer(const Duration(milliseconds: 300), _search);
```

✅ Good: name the value once, where it is used, only when it has meaning.

```dart
const arrivalThresholdMeters = 50;
if (distanceMeters < arrivalThresholdMeters) _showArrivedBanner();
```

#### E. Comments: why, not what (§0.7, Rule 3)

❌ Bad: comments restate the code.

```dart
// Increment the counter by one
count++;

// Check if position is null
if (position == null) return;

// ===== Search Section =====
```

✅ Good: one comment, and only for what the code cannot say.

```dart
// Debounce: Mapbox bills per search request.
_debounce = Timer(const Duration(milliseconds: 300), () => _search(query));
```

### 14.3 Working Around Human Code (§0.2, §0.4, §0.5)

Task: "Add a recenter button to the map screen."

❌ Bad: agent opens existing `home_screen.dart`, rewrites `build()`, renames variables, reformats the file.

✅ Good: agent creates a **new** file, then **proposes** the one-line wiring and waits.

```dart
// NEW FILE: features/home/presentation/widgets/recenter_button.dart
class RecenterButton extends StatelessWidget {
  const RecenterButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      child: const Icon(Icons.my_location),
    );
  }
}
```

Agent reply to the human:

```
I did not edit home_screen.dart. To wire it in, add this inside the Stack
children (around line 84) and an import for recenter_button.dart:

  Positioned(bottom: 24, right: 16, child: RecenterButton(onPressed: _recenter)),

_recenter() does not exist yet. Want me to propose it, or will you write it?
```

### 14.4 Consistency Check (§0.7, Rule 2)

If neighboring human code uses `StatefulWidget` + `ChangeNotifier`:

- ❌ Bad: introduce Riverpod, BLoC, or `freezed` for one new screen.
- ✅ Good: use `StatefulWidget` + `ChangeNotifier` with the same naming and file layout, and mention in your reply that the codebase and §2 differ so the maintainer can decide.