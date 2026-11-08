[← Docs index](README.md)

# Agent Rules (Do / Don't)

**Do**

- Read relevant files before editing; match existing patterns.
- State assumptions and open questions up front for anything marked **[TBD]**.
- Warn about bugs, scaling, cost, security, or tech-debt risks you notice, even if not asked.
- Keep diffs minimal and scoped to the task.
- Follow **[§0](HUMAN_CODE_PROTECTION.md) (Human Code Is Protected)** first. When [§0](HUMAN_CODE_PROTECTION.md) and any other rule conflict, [§0](HUMAN_CODE_PROTECTION.md) wins.
- Report what you ran and what you could not verify.

**Don't**

- Commit secrets, keystores, `google-services.json`/`GoogleService-Info.plist` (if ever added), `key.properties`, `.p12`, `.jks`, or provisioning profiles.
- Add dependencies, Mapbox products, background location, analytics, or ad SDKs without approval.
- Modify existing human code at all without explicit authorization ([§0](HUMAN_CODE_PROTECTION.md)).
- Refactor unrelated code or reformat whole files in a feature PR.
- Edit generated files (`*.g.dart`, `*.freezed.dart`, `GeneratedPluginRegistrant.*`) by hand.
- Disable lints, skip tests, or silence errors to make a build pass.
- Copy code from the legacy Kotlin app.
- Run destructive commands (`git reset --hard`, `flutter clean` is fine; deleting directories outside the repo is not) without asking.
