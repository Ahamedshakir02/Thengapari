# Project Work Log

> Running log of work done on the Thengapari agri-tech marketplace (Flutter, 4 role-based apps in one codebase).
> Newest entries first. Every work session appends/updates an entry here.

---

## 2026-06-04 — Session 1: Foundation setup

**Goal:** Stand up the project foundation only — no feature screens, no painters.

### Done

**1. Flutter project**
- Initialised `agri_platform` (Flutter 3.41.7 / Dart 3.11.5, null-safe), org `com.agrimarketplace`, platforms Android + iOS.

**2. Folder structure** (per `00_shared_architecture.md`)
```
lib/app/                   theme.dart · router.dart · app.dart · flavor_config.dart
lib/core/models/           app_user.dart  (AppUser + UserRole)
lib/core/services/         auth_service.dart  (Firebase phone OTP)
lib/core/providers/        auth_provider.dart  (authServiceProvider, authStateProvider)
lib/core/widgets/          (empty — .gitkeep)
lib/core/widgets/painters/ (empty — .gitkeep, NOT built yet)
lib/features/auth/screens/        splash · login · otp_verify · role_gate
lib/features/homeowner/screens/   home_screen.dart  (stub)
lib/features/worker/screens/      home_screen.dart  (stub)
lib/features/site_manager/screens/home_screen.dart  (stub)
lib/features/b2b/screens/         home_screen.dart  (stub)
functions/                 README placeholder
lib/main.dart + main_dev/staging/prod.dart + bootstrap.dart
```

**3. Dependencies**
- Added the full package list from the plan via `flutter pub add` (versions auto-resolved to ones compatible with Dart 3.11.5 — see "Deviations" below).

**4. Firebase + flavors**
- Android product flavors `dev` / `staging` / `prod` in `android/app/build.gradle.kts` (appId suffixes `.dev` / `.staging`, none for prod).
- `com.google.gms.google-services` plugin wired in `settings.gradle.kts` + `app/build.gradle.kts`.
- Per-flavor config at `android/app/src/<flavor>/google-services.json`.
  - **dev**: REAL config added (project `thengapari-dev`).
  - **staging / prod**: still PLACEHOLDERS — replace before running those flavors.
- `minSdk` bumped to 23 (required by Firebase Auth 6.x).

**5. Theme** — `AgriColors` (all tokens verbatim) + `buildAgriTheme()` seeded from `green400`. Poppins declared but not yet bundled (falls back to system font).

**6. Routing** — `GoRouter` (`lib/app/router.dart`), stable instance refreshed by the auth stream. Redirect rules:
- loading → `/splash`
- signed-out → `/login` (or `/otp`)
- signed-in, no role → `/select-role`
- signed-in, with role → `/homeowner|worker|manager|b2b/home`

**7. Auth flow** — `SplashScreen`, `LoginScreen` (+91 phone → `verifyPhoneNumber`), `OtpVerifyScreen` (6-digit → `signInWithCredential`). `AuthService.authStateChanges` joins FirebaseUser with `/users/{uid}` so role changes drive routing reactively. `authStateProvider` = `StreamProvider<AppUser?>`.

**8. Stub home screens** — 4 role homes, each a Scaffold showing the role name + a sign-out action.

### Verification
- `flutter analyze` → No issues found.
- `flutter test` → 6/6 routing tests pass (`test/widget_test.dart`): signed-out→login, no-role→role gate, and each of the 4 roles → correct home.

### Deviations from the plan (and why)
1. **Package versions bumped.** Plan pins (e.g. `firebase_core ^2.27`, `go_router ^13`) predate Dart 3.11 and can't resolve. Same package *list*, newer versions (Firebase 4/6.x, go_router 17, Riverpod 3.x).
2. **`riverpod_generator` dropped.** It pins `analyzer ^9` which conflicts with `json_serializable`'s `analyzer >=10`. It's only codegen sugar; providers are written by hand (as the plan already does). `freezed` / `json_serializable` kept for later models. `json_annotation` pinned to `^4.9.0` for the same compatibility reason.
3. **Added `/select-role` stub** (`role_gate_screen.dart`) so an authenticated-but-role-less user doesn't dead-end. Full role-selection/profile UI is a later phase.
4. **Riverpod 3.x note:** use `AsyncValue.value` (nullable), not `valueOrNull`.

### Not done (intentionally out of scope this session)
- CustomPainters (Kerala landscape, radar, donut, charts).
- All feature screens beyond stubs.
- Cloud Functions implementation.
- Firestore security rules deployment, FCM, Razorpay, maps wiring.

### Next up
- Replace staging/prod `google-services.json` with real config.
- Build the shared widget library + painters, then the Homeowner app.

---

<!-- Template for new entries:

## YYYY-MM-DD — Session N: <title>

**Goal:**

### Done
-

### Verification
-

### Notes / deviations
-

### Next up
-
-->
