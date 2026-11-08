[← Docs index](README.md)

# Code Examples: Control Flow & Structure

Examples are illustrative. Obey [§0](HUMAN_CODE_PROTECTION.md) first: match the existing human code ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 2), and do not touch existing files to "apply" these examples.
Examples assume Dart 3+. Names like `Place` and `SearchFailure` are placeholders.

## 14.1 Control Flow

### A. Guard clauses, not deep nesting

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

### B. Exhaustive `switch` on enums, not `if/else` on strings

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

### C. Error handling: never swallow, always handle the failure path

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

### D. Debounce user input (Mapbox bills per request)

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

### E. Null safety: no `!` on values that can change

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

## 14.2 Code Structure

### A. Keep layers separate: no HTTP, tokens, or URLs in widgets

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

✅ Good: the widget only talks to a repository; the token comes from build-time config ([§5](SECRETS_AND_CONFIGURATION.md)).

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

### B. Small widgets, not one giant `build()`

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

### C. No over-engineering ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 1)

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

### D. No magic values

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

### E. Comments: why, not what ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 3)

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

## 14.3 Working Around Human Code ([§0.2](HUMAN_CODE_PROTECTION.md), [§0.4](HUMAN_CODE_PROTECTION.md), [§0.5](HUMAN_CODE_PROTECTION.md))

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

## 14.4 Consistency Check ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 2)

If neighboring human code uses `StatefulWidget` + `ChangeNotifier`:

- ❌ Bad: introduce Riverpod, BLoC, or `freezed` for one new screen.
- ✅ Good: use `StatefulWidget` + `ChangeNotifier` with the same naming and file layout, and mention in your reply that the codebase and [§2](TECH_STACK.md) differ so the maintainer can decide.
