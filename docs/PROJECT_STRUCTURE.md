[← Docs index](README.md)

# Project Structure

Feature-first layout. It matches the current project. Folders marked *(planned)* do not exist yet: create one only when its first file is needed ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 1). Never move or rename existing folders or files ([§0.2](HUMAN_CODE_PROTECTION.md)).

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

## Where new code goes

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
| New route | `app/routes.dart` + `app/router.dart` (existing human files: propose the snippet, do not edit, [§0.5](HUMAN_CODE_PROTECTION.md)) |

## Dependency rules

- Direction: `screens / widgets / controllers → data/repositories → data/datasources`. There is no `domain/` layer by default.
- Widgets never call HTTP or SDKs directly; they go through a controller or repository.
- Features do not import each other. Shared code goes in `widgets/`, `core/`, or `data/`.
- There is no `shared/` folder. Shared widgets live in `widgets/`.
- There is no authentication feature: the MVP has no accounts and no backend ([§2](TECH_STACK.md)).
