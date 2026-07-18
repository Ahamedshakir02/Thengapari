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
website/                marketing site (Vite + Tailwind) — npm run dev / build
```

`STRUCTURE.md` has a fuller tour of the tree.

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

Each app runs standalone and has two entrypoints:

- **`main.dart` (default)** — LIVE: real Firebase (Android configs for the
  shared project are checked in), real phone-OTP auth, every screen backed by
  Firestore.
- **`main_demo.dart`** — the seeded offline demo harness: renders the full UI
  with in-memory demo data, no Firebase needed.

```bash
cd apps/homeowner    && flutter run                          # live
cd apps/worker       && flutter run -t lib/main_demo.dart    # offline demo
cd apps/site_manager && flutter run
cd apps/b2b          && flutter run
```

## Firebase

All four apps point at the **same** Firebase project; each has its own
`applicationId` and `google-services.json` (already committed for Android —
run `flutterfire configure` inside an app only when re-registering or adding
iOS).

### Live-local via the Emulator Suite (no Blaze plan, no SMS quota)

```bash
cd functions && npm run emulators     # auth + firestore + functions, one terminal
npm run seed:emulator                 # once, to load demo data
cd apps/<role>
flutter run --dart-define=USE_FIREBASE_EMULATORS=true
```

The emulator host defaults to `10.0.2.2` (right for the Android emulator);
for a physical phone put the emulators on the LAN and pass
`--dart-define=FIREBASE_EMULATOR_HOST=<PC Wi-Fi IP>` — see the caveat in
`packages/core/lib/app/firebase_bootstrap.dart` (`adb reverse` does **not**
work for the FlutterFire plugins).

To exercise real auth against production, enable **Authentication → Phone**
in the Firebase console.

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
