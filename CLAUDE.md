# ThengaPari — Project Context

## What this is
ThengaPari is a hyperlocal coconut/crop-harvesting marketplace for Kerala, India.
It is a **Melos monorepo**: a shared `packages/core` (models, services, providers,
theme, widgets, painters, auth screens) plus four standalone, independently
runnable apps — `apps/{homeowner,worker,site_manager,b2b}`. Role is chosen at
**install** (each app IS its role; there is no role-gate). All four apps share
one Firebase backend. Cloud Functions + Firestore rules live at the repo root
(`functions/`, `firestore.rules`, `firebase.json`).

Layout:
```
packages/core/   shared code (package:core)
apps/<role>/     lib/{main,app,router}.dart + features/<role>/ ; own android/ios
functions/       TypeScript Cloud Functions (root)
pubspec.yaml     workspace root (members declare `resolution: workspace`)
```

## Key references (read these, don't guess)
- Plans live in `docs/`. `docs/00_shared_architecture.md` is the SOURCE OF TRUTH
  for Firestore collection paths, data models, and the cross-app event flow.
- Per-app specs: `docs/01_homeowner_app_plan.md`, `docs/02_worker_app_plan.md`,
  `docs/03_site_manager_app_plan.md`, `docs/04_b2b_portal_plan.md`.
- Full widget/painter code + theme tokens: `docs/flutter_implementation_plan.md`.
- Designs (React/JSX + CSS) live in `Designs/<App Name>/` — screen1–4.jsx show
  the intended layout; `design-system.css` is the visual source of truth.

## Hard rules
- Match Firestore collection paths EXACTLY to docs/00_shared_architecture.md so
  all 4 apps stay compatible. Do not invent new paths.
- The theme in packages/core/lib/app/theme.dart (+ design_tokens.dart) is locked
  to design-system.css. Pull colors, spacing, radii, and fonts FROM THE THEME.
  Never hardcode hex values in widgets.
- Cross-app Firestore field names are centralized: write via
  HarvestJob.createData / JobStatusUpdate.writeData / YieldData.writeData /
  InventoryListing.toFirestore (in packages/core/lib/core/models). Don't
  hand-roll those maps in services.
- Razorpay secret keys NEVER reach the client — server-side Cloud Functions only.
- acceptPing and createB2BOrder MUST use Firestore transactions (atomic) so two
  users cannot grab the same job or over-order the same stock.
- State management: Riverpod (providers named exactly as in the plans).
- Routing: GoRouter, one slim router per app (its routes + shared core auth).
- Data models: freezed.
- Run an app:  cd apps/<role> && flutter run   (each app's main.dart seeds demo
  data so it runs without live Firestore). Workspace: `flutter pub get` at root;
  `dart run melos list` / `dart run melos run analyze`. A live build needs
  `flutterfire configure` inside each app (its own google-services.json).

## Workflow rules
- Build ONE app per session. Don't mix two apps in one session.
- Pause after each screen so I can hot-reload and visually verify against the
  design before continuing.
- Match each screen's look to the corresponding screenN.jsx in its Designs folder.
- After a working step, remind me to commit (git add -A; git commit).

## Environment
- Windows. JDK 17. Android Studio installed. Emulator: Pixel (Android).
- Firebase project: "thengapari-dev" (currently Spark / free plan).
- Cloud Functions require Blaze — NOT upgraded yet, so don't try to deploy
  functions until I say the project is on Blaze.
- Phone auth: enable the Phone provider in Firebase console for login to work.
  SHA-1 is optional (only needed for OTP auto-fill) — skip it for now.
