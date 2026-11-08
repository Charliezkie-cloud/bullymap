# Bully Map: Developer Documentation

Documentation for developers of the Bully Map Flutter app (iOS + Android).
Each file below is one section of [`../AGENTS.md`](../AGENTS.md), split out for easier reading.

> **Keep in sync.** `AGENTS.md` is the file AI agents read. These docs are the same content in separate files. If you change one, change the other, or they will drift apart.
> Items marked **[TBD]** are undecided. See [OPEN_DECISIONS.md](OPEN_DECISIONS.md).

Start with [HUMAN_CODE_PROTECTION.md](HUMAN_CODE_PROTECTION.md). It overrides every other document.

| Document | Contents | AGENTS.md section |
|---|---|---|
| [HUMAN_CODE_PROTECTION.md](HUMAN_CODE_PROTECTION.md) | Strict rules: agents must not modify existing human code; code quality rules; verification and enforcement | §0 |
| [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) | What Bully Map is, planned screens, maintainers | §1 |
| [TECH_STACK.md](TECH_STACK.md) | Framework, packages, and what is still undecided | §2 |
| [ENVIRONMENT_SETUP.md](ENVIRONMENT_SETUP.md) | Install Flutter (FVM), toolchains, platform requirements | §3 |
| [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) | `lib/` folder layout, where new code goes, dependency rules | §4 |
| [SECRETS_AND_CONFIGURATION.md](SECRETS_AND_CONFIGURATION.md) | Mapbox tokens and secrets handling | §5 |
| [COMMANDS.md](COMMANDS.md) | Run, analyze, format, test, and release build commands | §6 |
| [CODE_CONVENTIONS.md](CODE_CONVENTIONS.md) | General Dart/Flutter code conventions | §7 |
| [NAMING_CONVENTIONS.md](NAMING_CONVENTIONS.md) | Naming for variables, classes, files, folders, and more | §7.1 |
| [MAPS_AND_LOCATION.md](MAPS_AND_LOCATION.md) | Mapbox cost control, permissions, battery, platform parity | §8 |
| [TESTING.md](TESTING.md) | Unit, widget, and integration test guidance | §9 |
| [GIT_WORKFLOW.md](GIT_WORKFLOW.md) | Branches, commits, pull requests, versioning | §10 |
| [AGENT_RULES.md](AGENT_RULES.md) | Do / Don't list for AI agents and contributors | §11 |
| [RELEASE_AND_STORE.md](RELEASE_AND_STORE.md) | Android and iOS release, privacy, account ownership | §12 |
| [OPEN_DECISIONS.md](OPEN_DECISIONS.md) | Undecided items (TBD) that need a maintainer answer | §13 |
| [CODE_EXAMPLES.md](CODE_EXAMPLES.md) | Bad and good code examples for control flow and structure | §14 |
