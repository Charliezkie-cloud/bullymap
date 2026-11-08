[← Docs index](README.md)

# Code Conventions

- Follow `flutter_lints` (or stricter) in `analysis_options.yaml`. No `// ignore` without a comment explaining why.
- Prefer `const` constructors; small widgets over deep `build()` methods; no business logic in widgets.
- Naming follows [§7.1](NAMING_CONVENTIONS.md). One primary public class per file.
- Use `async/await`; handle every failure path. No empty `catch`. Return typed failures from repositories, show user-friendly messages in UI.
- Always dispose controllers, stream subscriptions, and Mapbox map/annotation managers.
- No hardcoded user-facing strings in widgets once localization is set up **[TBD: languages]**.
- No hardcoded URLs. The legacy app hardcoded an ads video URL; any remote asset URL goes in config.
- Keep functions small. Favor the simplest solution; justify any added abstraction in the PR.
