# ThengaPari

A hyperlocal agri-harvest marketplace for Kerala, built as a **single Flutter
codebase** serving four role-based apps: **Homeowner**, **Worker**, **Site
Manager**, and **B2B buyer**. The role is assigned at first login and GoRouter
serves the matching app. Backed by Firebase (Auth, Firestore, Storage,
Messaging, Crashlytics, Analytics), payments via Razorpay, and state managed
with Riverpod.

> The Android `applicationId` / iOS bundle id stay `com.agrimarketplace.agri_platform`
> because the Firebase `google-services.json` is registered to it. The
> user-facing name everywhere is **ThengaPari**.

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.11.5`)
- An Android emulator / device (the app is Android-first)
- Per-flavor Firebase config in place (see [Firebase setup](#firebase-setup))
- Network access on first run — fonts (Baloo Chettan 2 / Noto Sans) are fetched
  once via `google_fonts`, then cached

Verify your toolchain:

```bash
flutter doctor
```

## Setup

```bash
flutter pub get
```

> Models are currently hand-written, so **no code generation is required** to
> run the app. (`freezed` / `json_serializable` are present for later use.)

## Firebase setup

The app boots Firebase per environment (flavor). Each flavor reads its own
`android/app/src/<flavor>/google-services.json`:

| Flavor    | Android config location                          | Status         |
| --------- | ------------------------------------------------- | -------------- |
| `dev`     | `android/app/src/dev/google-services.json`        | real config    |
| `staging` | `android/app/src/staging/google-services.json`    | placeholder    |
| `prod`    | `android/app/src/prod/google-services.json`       | placeholder    |

To exercise real auth / Firestore writes in `dev`, enable in the Firebase
console: **Authentication → Phone** (+ India SMS region) and, for the dev
harness, **Authentication → Anonymous**.

## Running

The project has three flavors, each with its own entrypoint:

```bash
flutter run --flavor dev     -t lib/main_dev.dart      # development
flutter run --flavor staging -t lib/main_staging.dart  # staging
flutter run --flavor prod    -t lib/main_prod.dart     # production
```

> **Dev harness:** `lib/main_dev.dart` currently launches a developer harness —
> a menu that jumps straight to each Homeowner screen with seeded sample data
> (no phone-OTP needed), so screens can be hot-reloaded and reviewed in
> isolation. The real role-routed app shell is `bootstrap(Flavor.dev)`
> (`lib/bootstrap.dart`); `main_staging.dart` / `main_prod.dart` use it.

## Building release artifacts

```bash
flutter build apk       --flavor prod -t lib/main_prod.dart
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

## Testing & analysis

```bash
flutter test       # routing/widget tests
flutter analyze    # static analysis (see analysis_options.yaml)
```

## Project structure

```
lib/
  app/            theme.dart · design_tokens.dart · router.dart · app.dart · flavor_config.dart
  core/
    models/       app_user, tree_inventory, harvest_job, crop_*, yield_estimate, job_status_update
    services/     auth_service, homeowner_service
    providers/    auth_provider, homeowner_providers
    widgets/      shared widgets + painters/ (Kerala landscape, radar, donut, charts) + app_icon
  features/
    auth/         splash · login · otp_verify · role_gate
    homeowner/    screens/ (profile setup, tree setup, home, book harvest, live tracker) + widgets/
    worker/ site_manager/ b2b/   (home stubs — built in later phases)
    dev/          widget_gallery_screen.dart
  main.dart · main_dev.dart · main_staging.dart · main_prod.dart · bootstrap.dart

assets/images/    illustration-kerala-landscape.svg · logo-mark.svg · logo-mark-light.svg
docs/             plans + PROJECT_LOG.md (running work log)
Designs/          source design system (CSS tokens, JSX mockups, SVG assets)
```

The Flutter UI follows the design system in `Designs/` (warm-paper background,
forest-green brand, amber accent, Baloo Chettan 2 / Noto Sans) ported into
`lib/app/design_tokens.dart`.

## Learn more

- [Flutter documentation](https://docs.flutter.dev/)
- [Riverpod](https://riverpod.dev/)
- [FlutterFire (Firebase for Flutter)](https://firebase.flutter.dev/)

## License

Released under the [MIT License](LICENSE) © 2026 Ahamed Shakir.
