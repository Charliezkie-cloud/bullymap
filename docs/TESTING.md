[← Docs index](README.md)

# Testing

- **Unit tests:** controllers, repositories, mappers (mock the network and location service).
- **Widget tests:** each screen's key states (loading, success, error, permission denied).
- **Integration tests:** Intro → permission → map → search → navigation happy path.
- Map rendering itself is not unit-testable; where logic needs testing without the SDK, isolate the Mapbox calls behind a small wrapper. Do not add the wrapper by default ([§0.7](HUMAN_CODE_PROTECTION.md), Rule 1).
- Bug fix = add a regression test when feasible.
