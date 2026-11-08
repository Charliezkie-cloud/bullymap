[← Docs index](README.md)

# Naming Conventions

Dart uses camelCase for most names. Follow the official [Effective Dart: Style](https://dart.dev/effective-dart/style). If existing human code names something differently, match the human code ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 2) and do not rename it ([§0.2](HUMAN_CODE_PROTECTION.md)).

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

## Examples

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

## File naming

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

## Bully Map examples

Names and paths follow [§4](PROJECT_STRUCTURE.md).

```
features/home/presentation/screens/home_screen.dart          -> class HomeScreen
features/home/presentation/widgets/recenter_button.dart      -> class RecenterButton
features/settings/presentation/screens/settings_screen.dart  -> class SettingsScreen
data/repositories/place_search_repository.dart               -> class PlaceSearchRepository
core/services/location_service.dart                          -> class LocationService
```

## Rules to remember

- Classes, enums, typedefs, mixins, extensions = `UpperCamelCase`.
- Variables, parameters, functions, methods, constants, enum values = `lowerCamelCase`.
- Files and folders = `snake_case`.
- Private declarations = `_name`. Do not use a leading `_` on identifiers that are not private.
- No `SCREAMING_SNAKE_CASE` for new constants.
- Use descriptive names. Avoid abbreviations, except widely understood ones (`id`, `url`, `api`, `http`, `json`, `ui`).
- Capitalize acronyms longer than two letters like normal words: `HttpClient`, `MapboxApi`, not `HTTPClient`, `MapboxAPI`.
- Booleans read as a state or question: `isLoading`, `hasPermission`, not `loading`, `permission`.
