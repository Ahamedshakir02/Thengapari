# agri_platform

A Flutter app for an agri-marketplace, with separate experiences for homeowners,
workers, B2B buyers, and site managers. Backed by Firebase (Auth, Firestore,
Storage, Messaging, Crashlytics, Analytics) and state-managed with Riverpod.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.11.5`)
- An Android emulator / device, or iOS simulator / device
- Firebase config files in place (see [Firebase setup](#firebase-setup))

Verify your toolchain:

```bash
flutter doctor
```

## Setup

Install dependencies:

```bash
flutter pub get
```

This project uses code generation (`freezed`, `json_serializable`,
`riverpod_annotation`). Generate the `*.g.dart` / `*.freezed.dart` files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

While actively developing, you can keep the generator running and regenerate on
save instead:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Firebase setup

The app boots Firebase per environment (flavor). Each flavor reads its own
config from `android/app/src/<flavor>/google-services.json`. Replace the
placeholder JSON files with real ones from the Firebase console before running
on a device:

| Flavor    | Firebase project           | Android config location                       |
| --------- | -------------------------- | --------------------------------------------- |
| `dev`     | `agri-marketplace-dev`     | `android/app/src/dev/google-services.json`     |
| `staging` | `agri-marketplace-staging` | `android/app/src/staging/google-services.json` |
| `prod`    | `agri-marketplace-prod`    | `android/app/src/prod/google-services.json`    |

## Running the app

The project has three build flavors, each with its own entrypoint. Each flavor
needs both the `--flavor` and the matching `-t` (target) flag:

```bash
# Development
flutter run --flavor dev     -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod    -t lib/main_prod.dart
```

For a quick run during development you can also use the default entrypoint,
which boots the `dev` flavor:

```bash
flutter run -t lib/main_dev.dart   # or simply: flutter run
```

> **Note:** `lib/main.dart` calls `bootstrap(Flavor.dev)` so a plain
> `flutter run` works, but on Android you should still pass `--flavor dev` so
> the correct `google-services.json` is bundled.

## Building release artifacts

```bash
# Android APK (e.g. staging)
flutter build apk --flavor staging -t lib/main_staging.dart

# Android App Bundle (prod)
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

## Testing & analysis

```bash
flutter test       # unit & widget tests
flutter analyze    # static analysis (see analysis_options.yaml)
```

## Project structure

```
lib/
  app/         App shell, router, theme, flavor config
  bootstrap.dart   Shared startup (Firebase init + ProviderScope)
  core/        Models, providers, services (auth, etc.)
  features/    Feature modules: auth, homeowner, worker, b2b, site_manager
  main.dart            Default entrypoint (dev flavor)
  main_dev.dart        Dev flavor entrypoint
  main_staging.dart    Staging flavor entrypoint
  main_prod.dart       Prod flavor entrypoint
```

## Learn more

- [Flutter documentation](https://docs.flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [FlutterFire (Firebase for Flutter)](https://firebase.flutter.dev/)
