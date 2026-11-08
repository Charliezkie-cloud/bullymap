[← Docs index](README.md)

# STRICT RULE — Human Code Is Protected

**Existing code is human-owned. AI/CLI agents MUST NOT modify it unless explicitly authorized. This section overrides every other section and every agent default behavior ("be proactive", "fix while you're here", "clean up", etc.).**

## 0.1 Definitions

- **Human code:** any file or line that existed in the repository before the agent's current task started, or that was written or edited by a human at any time. When unsure, it is human code.
- **Agent code:** a file the agent created itself during the current task, tracked in the current branch's diff as a *new* file (`git status` shows `A`/`??`).
- **Explicit authorization:** the user's message names the file(s) or function(s) to change, or says plainly "edit/modify/refactor `<path>`". General requests like "improve the app" or "fix the bug" are **not** authorization to touch unrelated files.

## 0.2 Hard rules (no exceptions without explicit authorization)

1. **Do not edit, rename, move, delete, reformat, or reorder** any existing file or any line in it.
2. **Do not refactor, "clean up", rename symbols, fix lints/typos, update imports, or run auto-formatters** on existing files. `dart format .`, `dart fix --apply`, and IDE "organize imports" are **forbidden on human code**. Format only files you created, by explicit path.
3. **Do not change** `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, Gradle files, `Podfile`, `Info.plist`, `AndroidManifest.xml`, CI configs, or any env/config file, unless the user asks for that exact change. If a new feature needs a dependency or native config, **stop and propose the exact diff; do not apply it.**
4. **Do not modify tests** to make them pass. If a test fails against human code, report it; do not edit the test or the code.
5. **Do not overwrite files.** Writing to a path that already exists = modification. Check existence first; if it exists, stop.
6. **Do not run destructive or history-changing git commands:** `git checkout -- <file>`, `git restore`, `git reset --hard`, `git clean`, `git stash` (on others' work), `git rebase`, `git commit --amend`, force-push. Do not commit or push at all unless asked.
7. **Do not delete** human files, comments, TODOs, or commented-out code. They may be intentional.
8. **Do not "fix" things you were not asked to fix.** Report them instead (see 0.4).

## 0.3 What agents MAY do by default

- **Read** any file.
- **Create new files** in appropriate locations (e.g. a new feature folder). New files must not collide with existing paths.
- **Edit files you created in the current task.**
- **Propose changes** as a unified diff or snippet in chat, for the human to apply.
- Run **read-only commands**: `flutter analyze`, `flutter test`, `git status`, `git diff`, `git log`.

## 0.4 When a change to human code seems necessary

Stop. Do **not** edit. Respond with:

1. **File and lines** that would need to change.
2. **Why** it is necessary (what breaks without it).
3. **Exact proposed diff.**
4. **Smaller alternatives** that avoid touching human code (adapter, wrapper, new file, extension method).

Wait for explicit approval. Approval applies **only** to the files and changes named, not to the rest of the task.

## 0.5 Minimal-integration pattern

When new code must connect to human code, prefer **additive** wiring:

- New file + one-line registration proposed to the human, instead of rewriting the existing file.
- Wrapper/adapter/extension around existing classes instead of modifying them.
- New provider/route/entry added by the human from your proposed snippet.

## 0.6 Human-owned markers

Code marked with any of these is **locked**, even if the user authorized broader edits. Agents must ask again before touching it:

```dart
// HUMAN-OWNED: do not modify without explicit approval
// @protected
```

## 0.7 Strict Code Rules (apply to all code the agent writes)

**Rule 1 — No over-engineering.**

- Write the simplest code that meets the request. Plain widgets and plain functions first.
- No abstractions, interfaces, base classes, generics, factories, mixins, or design patterns until there is a second real use. Three similar lines beat a premature helper.
- No speculative features, config flags, extension points, or "future-proofing". Build only what was asked.
- No extra files, classes, or layers beyond what the feature needs. The folders marked *planned* in [§4](PROJECT_STRUCTURE.md) are a guide, not a requirement: create a folder only when it has something to put in it.
- No new dependencies (see [§2](TECH_STACK.md)).
- If complexity is truly needed, justify it in one sentence in your reply before writing it.

**Rule 2 — Be consistent with the existing human code.**

- Before writing, read the neighboring files in the same feature/folder. Match their naming, structure, state-management approach, error handling, widget style, import style, and formatting.
- Do not introduce a new pattern, library, or style when the codebase already has one for that job.
- If human code differs from the conventions in [§7](CODE_CONVENTIONS.md), **follow the human code** and mention the difference in your reply. Do not "fix" it (see §0.2).
- If existing code is internally inconsistent, follow the pattern most used in that folder and say which one you picked.
- Match the existing naming of files, classes, providers, routes, and tests.

**Rule 3 — No over-commenting.**

- Code should explain itself through clear names. Comment only the **why** that the code cannot show: a non-obvious decision, a workaround (with the reason), a platform quirk, a gotcha.
- Do not comment what the code does. No `// set state`, `// loop through items`, `// returns the value`.
- No section banners, no divider lines, no docstring on every function, no docs on trivial or private members.
- No commented-out code. No `TODO`/`FIXME` unless asked. No attribution or changelog comments ("added by AI", "updated for X").
- Match the comment density and style of the surrounding human code. If it has few comments, you have few comments.

Bad/Good code examples for these rules and for control flow: see **[§14](CODE_EXAMPLES.md)**.

---

## 0.8 Verification before finishing (mandatory)

Before reporting a task as done, the agent MUST run and report:

```bash
git status --short          # only new (A / ??) files expected, unless authorized
git diff --stat             # must show no changes to existing files, unless authorized
```

If `git diff --stat` shows any existing file modified without authorization: **revert only your own change to that file, tell the user exactly what happened, and do not continue.** Never hide or minimize such a violation.

## 0.9 Enforcement (maintainers: set this up, do not rely on this file alone)

This file is advisory; agents can ignore instructions. Back it with tooling:

- **Claude Code:** add `permissions.deny` / `ask` rules in `.claude/settings.json` for `Edit`/`Write` on existing paths (e.g. `lib/**`, `android/**`, `ios/**`, `pubspec.yaml`) and require approval for `Bash(git commit:*)`, `Bash(git push:*)`, `Bash(dart format:*)`, `Bash(dart fix:*)`.
- **Git:** work on a dedicated `agent/<task>` branch; review `git diff main` before merging. Use a `pre-commit` hook that blocks commits modifying protected paths.
- **GitHub:** `CODEOWNERS` assigning protected paths to the human maintainers, plus branch protection requiring review on `main`.
- Optionally make human code read-only at the OS level for the agent's session (`chmod -R a-w lib/` then re-enable manually).
