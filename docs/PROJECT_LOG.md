# Project Work Log

> Running log of work done on the Thengapari agri-tech marketplace (Flutter, 4 role-based apps in one codebase).
> Newest entries first. Every work session appends/updates an entry here.

---

## 2026-06-05 — Session 3: Design-system alignment + rename to ThengaPari

**Goal:** Make the homeowner screens match the `Designs/` folder exactly (real assets, colors, fonts, components), and rename the app to ThengaPari.

### Done

**1. Design foundation**
- Bundled real SVG assets into `assets/images/` (`illustration-kerala-landscape.svg`, `logo-mark.svg`, `logo-mark-light.svg`); registered in `pubspec.yaml`; rendered via `flutter_svg`.
- Added `google_fonts`; theme now uses **Baloo Chettan 2** (display) + **Noto Sans** (text).
- New `lib/app/design_tokens.dart` — faithful port of `colors_and_type.css` / `design-system.css`: `AppColors` (forest green `#1E4D2B`, amber `#F4A52A`, warm paper `#FBF8F1`, warm-ink neutrals, status colors), `AppRadii`, `AppSpace`, `AppShadows`, `AppText`.
- Rewrote `buildAgriTheme()` to build from the design tokens (paper bg, forest-green brand, amber accent, pill buttons, md-radius inputs).
- `lib/core/widgets/app_icon.dart` — `AppIcon` (stroke UI icons) + `CropGlyph` (filled crop motifs) ported from `app-icons.jsx` as real SVG, plus `CropPalette` (per-crop tint/fg).

**2. Reskinned screens to match `app.css`**
- `lib/features/homeowner/widgets/home_widgets.dart` — bespoke `HomeHero` (real landscape SVG + scrim + brand chip + EN/മല toggle + greeting), `HomeCropChip`, `HomeStatCard` (icon + value + trend pill), `WeeklyBarChart` (amber peak), `ActiveJobCard` (crop thumb + gradient progress + worker avatar + Track btn), `HomeBottomNav` (bubble style), `SectionHead`.
- Rewrote `HomeownerHomeScreen` using these (live providers unchanged).
- Restyled `ProfileSetupScreen` + `TreeInventorySetupScreen` to design tokens; tree setup now uses `CropGlyph`.
- Migrated shared `AppButton` (pill, forest green) + `AppTextField` to design tokens.

**3. Renamed app → ThengaPari**
- `pubspec.yaml` package name `agri_platform` → `thengapari` (updated `test/widget_test.dart` imports).
- Launcher label: `AndroidManifest.xml` now `@string/app_name`; flavor `app_name` resValues → `ThengaPari Dev` / `ThengaPari Staging` / `ThengaPari`.
- `MaterialApp` titles + splash label → ThengaPari.
- **Left `applicationId`/namespace `com.agrimarketplace.agri_platform` unchanged** (tied to Firebase `google-services.json`).

### Verification
- `flutter analyze lib test` → No issues found.
- `flutter build apk --debug --flavor dev` → built OK (fonts/SVGs/assets bundle correctly).
- `flutter test` → 6/6 pass (homeowner routing test updated: incomplete-profile homeowner → profile setup).
- Not yet screenshotted on device — Pixel 7 wireless link dropped mid-session; pending visual confirmation on next run.

### Next up
- Visually confirm the redesigned Home/setup on device.
- Continue Homeowner steps 3–7 (Book, Tracker, Report, Payment, AMC) on the new design foundation.

---

## 2026-06-05 — Session 2: Shared widget library + Homeowner steps 1–2

**Goal:** Build the shared widget/painter library, then start the Homeowner app screen-by-screen (pausing after each for hot-reload testing).

### Done

**1. Custom painters** (`lib/core/widgets/painters/`)
- `KeralaLandscapePainter`, `WeeklyEarningsChartPainter`, `RadarMapPainter` (animated via `pingAnimValue`), `YieldDonutPainter`, `SavingsBarChartPainter` — built from the implementation-plan specs.

**2. Shared widget library** (`lib/core/widgets/`)
- Primitives: `StatCard`, `JobStatusBadge` (+ `JobStatus` enum), `WorkerJobDetailRow`, `CountdownTimerWidget`, `SavingsBandWidget`, `WorkerAvailabilityToggle`.
- Composites: `HeroLandscapeWidget` (now takes `topInset` for edge-to-edge under the status bar), `CropInventoryRow`, `JobStatusCard`, `LiveInventoryTile`.
- Shared UI: `AppButton` (primary/secondary/ghost + icon/loading/disabled), `AppTextField`, `UserAvatarWidget`, `ShimmerJobCard` (+ `ShimmerText`).
- `role_nav_bars.dart`: `HomeownerBottomNav`, `WorkerBottomNav` (dark teal), `SiteManagerBottomNav`, `B2BBottomNav`.
- View-model classes: `CropSummary`, `CropListing` (hand-written, matching plan field signatures).
- **Widget gallery** (`lib/features/dev/widget_gallery_screen.dart`) renders every widget + painter on one scrollable page. Verified rendering on a Pixel 7.

**3. Homeowner — Step 1: Profile + Tree inventory setup**
- Models: `TreeInventory` (+ `CropType` enum). `AppUser` gained `isProfileComplete`.
- `HomeownerService` — Firestore writes to `/users/{uid}`, `/homeowners/{uid}`, `/homeowners/{uid}/trees` (paths per `00_shared_architecture.md`).
- `homeowner_providers.dart` — `homeownerServiceProvider`, `treeInventoryProvider(uid)`.
- Screens: `ProfileSetupScreen` (name, 14-district dropdown, address) and `TreeInventorySetupScreen` (per-crop count/age steppers, batch write).
- `RoleGateScreen` upgraded to a real 4-role selector that writes the chosen role.
- Router: added `/homeowner/profile-setup` + `/homeowner/tree-setup` routes and an onboarding redirect (homeowner with incomplete profile → profile setup).

**4. Homeowner — Step 2: HomeScreen**
- Model: `HarvestJob` (central `/jobs` doc, with `badgeStatus`/`progress`/`isActive` helpers).
- Providers: `activeJobProvider(uid)` (real-time stream), `homeownerJobsProvider`, `monthlyEarningsProvider`, `weeklyEarningsProvider` — all filter/aggregate client-side to avoid composite indexes.
- `HomeownerHomeScreen` — hero greeting, live crop chips (`treeInventoryProvider`), stat cards, weekly-earnings chart, real-time active-job card (`activeJobProvider`), Book CTA, bottom nav. Matches `app-screens-home.jsx` layout.

**5. Dev harness** (`lib/main_dev.dart`)
- Boots Firebase, signs in anonymously (falls back to a placeholder uid), overrides `authStateProvider` with a dev user, and seeds the homeowner data providers with sample data so screens render without live Firestore. Menu jumps to each built screen. (The real app uses `bootstrap(Flavor.dev)` with the live providers.)

### Verification
- `flutter analyze lib` → No issues found.
- Ran on Pixel 7: gallery, dev menu, Profile setup, and HomeScreen all render correctly.

### Notes / deviations
- **Anonymous auth is disabled** in the dev Firebase project, so real Firestore writes are rejected by security rules until it's enabled (Authentication → Anonymous). The harness seeds sample data so UI is still testable.
- **Wireless `flutter run` is flaky** on the VM-service handshake (build/install succeed; hot-reload attach sometimes drops). USB is more reliable for hot reload.
- Used the existing `AgriColors` theme for colors (consistency with the verified gallery), matching the designs' **layout/spacing**.

### Design-fidelity requirement (raised 2026-06-05) — TO DO
User wants the apps to match the **Designs/** folder exactly (real assets, colors, fonts, components), not theme approximations. Concretely:
- **Real assets** to bundle: `Designs/ThengaPari HomeOwner App (1)/assets/illustration-kerala-landscape.svg`, `logo-mark.svg`, `logo-mark-light.svg` (use `flutter_svg`).
- **Design tokens** from `colors_and_type.css` / `design-system.css`: warm paper bg `#FBF8F1`, forest green brand `#1E4D2B`, amber accent `#F4A52A`, warm ink neutrals — differ from the current `AgriColors`.
- **Fonts**: Baloo Chettan 2 (display) + Noto Sans / Noto Sans Malayalam (text).
- **Components** to match exactly (`app.css` + `app-icons.jsx`): brand chip + EN/മല language toggle, richer `CropChip` (tinted glyph + ready count), stat cards with icon + trend pill, job card with crop thumb + worker avatar + Track button, day-based weekly bar chart.

### Next up
- Align Flutter to the design folder: bundle SVGs/logos, port design tokens + fonts, rework Homeowner screens (and shared widgets) to match `app.css` exactly.
- Then continue Homeowner steps 3–7 (Book harvest, Live tracker, Yield report, Payment, AMC).

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
