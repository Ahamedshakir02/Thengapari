# ThengaPari — Project Context

## What this is
ThengaPari is a hyperlocal coconut/crop-harvesting marketplace for Kerala, India.
A single Flutter codebase serves 4 role-based apps (homeowner, worker,
site_manager, b2b), routed by GoRouter based on the user's role after login.

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
- The theme in lib/app/theme.dart is locked to design-system.css. Pull colors,
  spacing, radii, and fonts FROM THE THEME. Never hardcode hex values in widgets.
- Razorpay secret keys NEVER reach the client — server-side Cloud Functions only.
- acceptPing and createB2BOrder MUST use Firestore transactions (atomic) so two
  users cannot grab the same job or over-order the same stock.
- State management: Riverpod (providers named exactly as in the plans).
- Routing: GoRouter, role-based.
- Data models: freezed.
- Build is flavor-based:  flutter run --flavor dev -t lib/main_dev.dart

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
