[← Docs index](README.md)

# Git & Workflow

- Branches: `main` (releasable), `feat/<name>`, `fix/<name>`, `chore/<name>`.
- Commits: Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `test:`, `refactor:`).
- Small, focused PRs. One concern per PR. Describe what changed, why, and how it was tested (platform + device).
- Do not force-push `main`. Do not rewrite shared history.
- A real Git repository is mandatory for this project: full history, tags per release.
- Version in `pubspec.yaml` follows `MAJOR.MINOR.PATCH+BUILD`; bump per store release and tag it.
