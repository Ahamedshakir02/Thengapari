# ThengaPari

A hyperlocal agri-harvest marketplace for Kerala, built as a **Melos monorepo**:
one shared `core` package plus four standalone, independently-runnable Flutter
apps — **Homeowner**, **Worker**, **Site Manager**, and **B2B buyer**. Each app
*is* its role (chosen at install — no role-gate). All four share one Firebase
backend (Auth, Firestore, Storage, Messaging) with TypeScript Cloud Functions,
payments via Razorpay, and state managed with Riverpod.

## Layout

```
pubspec.yaml            workspace root (Dart pub workspace) + melos
melos.yaml
packages/
  core/                 shared code → import 'package:core/core.dart'
                        models · services · providers · theme · widgets ·
                        painters · shared auth screens · assets
apps/
  homeowner/            com.thengapari.homeowner
  worker/               com.thengapari.worker
  site_manager/         com.thengapari.site_manager
  b2b/                  com.thengapari.b2b
    lib/                main.dart · app.dart · router.dart · features/<role>/
    android/ ios/       per-app platform projects
functions/              TypeScript Cloud Functions (shared backend)
firestore.rules · firestore.indexes.json · firebase.json
docs/                   plans (00 = source of truth) + per-app specs
Designs/                design system (CSS tokens, JSX mockups, SVG assets)
```

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart `^3.12.1`)
- An Android emulator / device (Android-first)
- Network on first run — fonts (Baloo Chettan 2 / Noto Sans) fetch once via
  `google_fonts`, then cache

## Setup (workspace)

```bash
flutter pub get            # resolves the whole workspace against one lockfile
dart run melos list        # lists the 5 packages
```

## Running an app

Each app runs standalone. Its `main.dart` seeds demo data, so it renders the
full UI **without** live Firestore:

```bash
cd apps/homeowner   && flutter run
cd apps/worker      && flutter run
cd apps/site_manager && flutter run
cd apps/b2b         && flutter run
```

## Firebase setup (for a live build)

Each app needs its own Firebase config, all pointing at the **same** project:

```bash
cd apps/<role>
flutterfire configure      # select the shared Firebase project + this app's applicationId
flutter run
```

This registers the app and writes `google-services.json` / `firebase_options.dart`.
Until then the demo data renders (Firebase init is guarded). To exercise real
auth, enable **Authentication → Phone** in the Firebase console.

> **Cloud Functions** (`functions/`) require the **Blaze** plan to deploy.
> Razorpay key/secret live only in function secrets — never on the client.
> See `functions/README.md` for the deploy steps.

## Analysis & tests

```bash
flutter analyze apps packages  # analyze every app + the core package
```

> The `melos run analyze` script also works, but only if Melos is activated
> globally and on PATH (`dart pub global activate melos`). `dart run melos list`
> / `dart run melos bootstrap` work without that.

## License

Released under the [MIT License](LICENSE) © 2026 Ahamed Shakir.
