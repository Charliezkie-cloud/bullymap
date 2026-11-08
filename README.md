# Bully Map

Navigation app for iOS and Android where the voice guidance bullies you in English, Tagalog, and Cebuano.

## Table of Contents

- [About](#about)
- [Features](#features)
- [Voice Languages](#voice-languages)
- [Supported Platforms](#supported-platforms)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Content Notice](#content-notice)
- [Project Status](#project-status)
- [License](#license)
- [Contact](#contact)

## About

Bully Map is a mobile navigation app built with Flutter and the Mapbox SDK. It runs on iOS and Android from a single codebase.

Normal navigation apps give polite, neutral directions. Bully Map does not. The voice guidance bullies the user while guiding them to their destination. Users can choose to be bullied in English, Tagalog, or Cebuano.

The map and routing are powered by Mapbox. The voices are custom and are the main feature of the app.

This project is client work. The source code is closed.

## Features

- Map navigation powered by the Mapbox SDK
- Custom navigation voices that bully the user while giving directions
- Voice guidance in three languages: English, Tagalog, and Cebuano
- Single Flutter codebase for iOS and Android

## Voice Languages

| Language | Bully Voice |
|---|---|
| English | Yes |
| Tagalog | Yes |
| Cebuano | Yes |

## Supported Platforms

| Platform | Supported |
|---|---|
| Android | Yes |
| iOS | Yes |

Minimum versions: TODO (Android API level, iOS version).

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| Maps and Navigation | Mapbox SDK |
| Target Platforms | iOS, Android |

Voice delivery method (pre-recorded audio or text-to-speech), additional libraries, and backend services: TODO.

## Project Structure

```
TODO: add the real folder layout, for example:
lib/
android/
ios/
assets/
pubspec.yaml
```

## Getting Started

Access to this repository is restricted to the client and authorized developers.

### Prerequisites

- Flutter SDK (version: TODO)
- Android Studio with the Android SDK, for Android builds
- Xcode, for iOS builds (macOS only)
- A Mapbox account with a valid access token

### Setup

1. Clone the repository.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Add your Mapbox tokens (see [Configuration](#configuration)).
4. Run the app:
   ```bash
   flutter run
   ```

## Configuration

The app needs Mapbox access tokens to load maps and run navigation. Do not commit tokens to the repository.

Token setup method: TODO (local env file or platform config). Keep that file in `.gitignore`.

## Content Notice

The navigation voices are intentionally rude and are meant as humor. The app is not meant to insult or harm anyone for real. Content rating and language: TODO (confirm with the client, for example if the voices use profanity).

## Project Status

Status: TODO (in development, in testing, or released).

## License

Proprietary. This is client work and the source code is closed. All rights reserved. Copying, distribution, or use without written permission from the owner is not allowed.
