# Project Work Log

> Running log of work done on the Thengapari agri-tech marketplace (Flutter, 4 role-based apps in one codebase).
> Newest entries first. Every work session appends/updates an entry here.

---

## 2026-07-18 — Session 11: Design-fidelity pass (audits by subagents, fixes applied)

**Goal:** Verify every screen matches its `Designs/` source and close every gap.

### Audits (5 parallel subagents, one per surface)
Full comparisons of screens vs `Designs/<App>/…jsx` + design CSS. Verdicts:
B2B and Homeowner near-faithful with targeted gaps; Site Manager faithful but
missing the design's monospace numeric face; Worker faithful in layout but on
the wrong palette variant and missing the bilingual mode; Auth flow had the
biggest gaps (login/OTP didn't match, Welcome screen missing entirely).

### Fixes applied (all committed; `flutter analyze` = 0 issues)
- **Core:** `AppText.mono` (Noto Sans Mono, tabular figures) for meter/scale
  numerics; `AppLang.both` + `trMl()` bilingual mode; banana `CropType`;
  crop-chip palette corrections + real WhatsApp glyph in `AppIcon`.
- **Auth (rebuilt):** new `WelcomeScreen` (Kerala landscape + wordmark) wired
  into all 4 routers between onboarding and login; login rebuilt (India-flag
  +91 field, design copy via `tr()`, reassurance line, top bar); OTP rebuilt
  (6 code boxes, auto-submit, resend countdown, success overlay); splash on
  `greenForest900`; role-gate marked legacy (unused in split apps).
- **Worker:** Emerald palette (the variant the design actually renders);
  mono numerics everywhere; Both-mode secondary Malayalam lines (toggle +
  section heads, default Both, language row cycles 3 ways); ping screen shows
  the site manager (name denormalised into ping docs by `pings.ts`);
  complete-screen summary per design; 18px titles; wallet glow; amber ring.
- **Homeowner:** crop colors, "+12% this season", In-progress pill, design
  stepper labels + "Live harvest", book/report/confirm copy, Verified-owner
  pill, weekday chart labels.
- **Site Manager:** mono meters (timer/weight/keypad/counters/stats), ticking
  "Live m:ss" spill, tender-coconuts headline, ping-count nav badge + house
  icon, brand logo in queue header, km distances, pulse CTAs, blinking
  weight caret, 128/20 donut.
- **B2B:** Orders tab per design (Upcoming, sage badges, green savings),
  freshness bar removed, straight spend chart with month-anchored labels,
  copy fixes.

---

## 2026-07-17 — Session 10: Apps go LIVE (demo → real Firebase, emulator-suite E2E)

**Goal:** Convert all four apps from seeded-demo shells to live Firebase apps
whose every button/service does the real thing, verifiable end-to-end TODAY
(no Blaze upgrade, no SMS quota) via the local Firebase Emulator Suite.

### Infrastructure
- Registered 4 Android apps in `thengapari-dev` (`com.thengapari.{homeowner,
  worker,site_manager,b2b}`) via the Firebase CLI; downloaded per-app
  `google-services.json` and wired the google-services gradle plugin.
- `firebase.json`: auth(9099)/firestore(8080)/functions(5001)/ui(4000)
  emulators. Emulators need JDK 21 → run with Android Studio's JBR
  (`JAVA_HOME="C:\Program Files\Android\Android Studio\jbr"`).
- `functions/scripts/seed-emulator.mjs` (`npm run seed:emulator`): 4 auth
  users (+9190000000{01..04} → fixed uids) + a full coherent Firestore
  dataset (users, trees, AMC, worker profile + week of earnings, SM profile,
  buyer profile, active + completed jobs with statusUpdates/yieldData,
  inventory ×3, market prices, delivered b2b order + tracking + savings,
  standing order, byproduct buyers). Hard-wired to emulator hosts — can
  never touch production.
- `functions/.secret.local` (gitignored) carries dummy Razorpay secrets so
  the functions emulator boots.

### Core live wiring (packages/core)
- New models: `JobPing` (reader for `/job_pings`, canonical writer is
  `pings.ts`), `EarningRecord` (`/workers/{uid}/earnings`).
- `WorkerService`: `watchPendingPing`, `acceptPing` (atomic callable),
  `declinePing`, `watchTodayAssignedJobs`, `watchJob`, `watchEarningsSince`,
  `syncLocation` (one-shot on go-online), `positionStream` +
  `writeTrackingPoint` (live breadcrumbs → `/jobs/{id}/tracking`).
- Worker providers now live: pending-ping stream, day stats + weekly chart
  from earnings, confirmed jobs from `/jobs` (replaced empty-stream stubs),
  `workerTrackingProvider` controller.
- `bootstrapFirebase()` (exported from core): Firebase init + optional
  emulator hookup via `--dart-define=USE_FIREBASE_EMULATORS=true`
  (host default 10.0.2.2, override `FIREBASE_EMULATOR_HOST`).
- `firestore.rules`: `/jobs/{id}/tracking` (parties read, assigned
  worker/SM create). `firestore.indexes.json`: composite indexes for
  job_pings(workerId,status,createdAt↓) and jobs(workerIds∋,scheduledAt).
- `pings.ts` broadcast now embeds `payout`/`place`/`requiredSkill` in each
  ping doc (rules deny job reads pre-acceptance).

### App entrypoints
- Each app's `main.dart` is now LIVE (real Firebase + phone auth, zero
  overrides); old seeded harness preserved as `main_demo.dart`.
- Worker flow wired for real: home listens for pings → full-screen
  takeover with live countdown to `expiresAt` → Accept via `acceptPing`
  (loser gets a graceful "already taken") / Decline writes status →
  Navigate shows real ETA/place + streams location → Complete shows the
  real payout + worker's UPI. Demo ping trigger is debug-only.

### How to run live-local
1. `cd functions && npm run emulators` (JDK 21 via Android Studio JBR)
2. `npm run seed:emulator` (fresh each emulator start — data is in-memory)
3. `cd apps/<role> && flutter run --dart-define=USE_FIREBASE_EMULATORS=true`
4. Log in with a seeded number (e.g. worker +91 90000 00002); OTP codes:
   `curl http://127.0.0.1:9099/emulator/v1/projects/thengapari-dev/verificationCodes`

### Remaining for production (user actions)
- Upgrade thengapari-dev to Blaze → `firebase deploy --only functions`.
- Enable the Phone provider in Firebase console (+ India SMS region).
- `firebase deploy --only firestore:rules,firestore:indexes` (works on Spark).
- Real Razorpay test keys as function secrets when payments go live.

---

## 2026-07-17 — Session 9: Marketing website finished + verified (branch `website`)

**Goal:** Finish the ThengaPari landing site (`website/`, Vite + React) and verify
it end-to-end in a real browser.

### State at session start (uncommitted work from prior website sessions)
- All sections built as components: Nav, Hero, Problem, HowItWorks, WhoItsFor,
  ZeroWaste, Traction, SignupCTA, Footer (+ ui/Button, Reveal, SectionHead;
  data/content.js; styles/tokens.css + landing.css matching
  `Designs/ThengaPari Website/`).
- `src/lib/firebase.js` — Firebase SDK now **dynamically imported on first form
  submit** (keeps initial bundle lean); localStorage fallback when `VITE_FB_*`
  env vars are absent.
- `src/lib/signup.jsx` — SignupProvider + waitlist form with an audience
  **type toggle** (homeowner / business / general → Firestore `type` field).
- `firestore.rules` — added `/leads/{leadId}`: create-only, keys restricted to
  `email|type|createdAt`, email length 4–199, `type` whitelisted,
  `createdAt == request.time`. No public read/update/delete.
- `firebase.json` — added Hosting config (`website/dist`, SPA rewrite, predeploy
  build). Netlify + Vercel configs also present (`netlify.toml`, `vercel.json`).

### Verified this session (Windows, real browser)
- `npm run build` — clean. Chunks: initial JS 178 kB (57 kB gz); Firestore SDK
  split into lazy chunks (434 kB) loaded only on submit; ZeroWaste/Traction/
  Footer code-split below the fold.
- Served `vite preview` on :4173 and walked the whole page in Chrome: hero,
  problem cards, who-it's-for, zero-waste band, traction stats, signup card,
  footer all render with reveal animations and match the design HTML.
- Waitlist flow: selected "Business" toggle, submitted an email → success
  message ("നന്ദി! You're on the list…"), lead persisted to localStorage as
  `{email, type: "business", createdAt}` with the expected not-configured
  console warning. No site console errors.

### Still open (deploy-time, not code)
- Create the Firebase **web app** in thengapari-dev console and copy its config
  into `website/.env.local` (see `.env.example`) so leads go to Firestore.
- Deploy `firestore.rules` (`firebase deploy --only firestore:rules` — works on
  Spark) before going live, so `/leads` create is allowed in production.
- Pick a host (Firebase Hosting / Netlify / Vercel — configs for all three are
  in place) and point the domain; swap placeholder partner logos and traction
  numbers when real ones exist.



**Goal:** Sweep the whole repo for structural problems, contract drift, and bugs;
fix what's safe; confirm everything is consistent with
`docs/00_shared_architecture.md` and the design system.

> **Constraint:** this pass was a *static* review — the audit environment had no
> Flutter/Dart toolchain, so `flutter pub get`, `flutter analyze`, `flutter test`
> and app builds were **not** run here. Findings are from reading the source, not
> compiling it. A Windows-side build/analyze is still required to certify "green"
> (checklist at the end).

### What was audited
- `docs/00_shared_architecture.md` (source of truth) + `STRUCTURE.md`.
- `packages/core`: all 21 models, 6 services, 7 provider files, theme/design
  tokens, barrel exports, `pubspec.yaml`.
- All 4 apps' entry wiring: `router.dart` ×4 (+ route constants, redirects).
- `functions/` TypeScript: `index.ts`, `pings.ts`, `b2b.ts` (transactional paths).
- `firestore.rules` vs. every collection the apps actually read/write.

### Findings — healthy
- **Firestore paths match the architecture doc exactly** across all services
  (`users`, `jobs`, `jobs/{id}/statusUpdates|yieldData`, `job_pings`, `inventory`,
  `b2b_orders`, `standing_orders`, `byproduct_routes`, `amc_contracts`,
  `market_prices`, role-profile collections). No invented paths.
- **Cross-app writes go through the centralized model helpers** (`HarvestJob.
  createData`, `JobStatusUpdate.writeData`, `YieldData.writeData`,
  `InventoryListing.toFirestore`) — no hand-rolled maps in services.
- **Atomicity hard rule honored:** `acceptPing` and `createB2BOrder` (and
  `confirmDelivery`) each run their read-check-write inside `db.runTransaction`,
  so no double-grab / over-order is possible.
- **Razorpay secrets are server-side only** (bound via `secrets:[...]` in
  `b2b.ts`/`payments.ts`); no key reaches the client.
- **Cloud Function wiring is complete:** all 16 functions in the architecture doc
  are exported from `index.ts`, and all 8 `httpsCallable(...)` names used by the
  Dart services resolve to a real exported function.
- **`firestore.rules` covers every collection** in use (incl. subcollection rules
  for `statusUpdates`, `yieldData`, `tracking`, `earnings`, `savings`) plus the
  website `/leads` create-only rule.
- **Theme is centralized and consistent.** `design_tokens.dart` (AppColors / AppText
  / AppRadii / AppSpace / AppShadows) and the worker `WColors` palette define every
  token the screens reference — spot-checked the token-heavy `job_ping_screen` and
  all worker-theme widgets; no undefined-getter references found.
- **Models need no codegen** — they're hand-written `fromFirestore`/`createData`
  (no `@freezed`/`part` directives), so a missing `build_runner` run can't break
  the build. (`freezed`/`json_serializable` remain in dev_deps but unused.)
- **Declared `google_fonts` dependency present** and `assets/images/` (3 SVGs)
  exists, matching the `pubspec.yaml` asset declaration.
- No `TODO`/`FIXME`/`UnimplementedError`, no stray `print(`/`debugPrint(`, and no
  Riverpod-2 `valueOrNull` left in any app or in core.
- All 4 routers share an identical, correct auth+onboarding redirect shape and
  reference real screen classes and core providers.

### Findings — worth attention
1. **Hardcoded hex in some shared widgets.** `crop_inventory_row`, `live_inventory_tile`,
   `job_status_card`, `job_status_badge`, `countdown_timer_widget`, `role_nav_bars`
   use literal `Color(0xFF…)` instead of `AppColors.*`. They render correctly and
   match the design, but this deviates from the "never hardcode hex in widgets"
   rule. (CustomPainters legitimately use literal colors for illustration.) A
   token-mapping cleanup is safe but should be done with `flutter analyze` running.
2. **Demo screens aren't wired to live data yet (by design).** e.g. the worker
   `job_ping_screen` "Accept" just navigates; it doesn't call the `acceptPing`
   callable. This matches the seed-demo-data approach, but the live wiring
   (worker accept → `acceptPing`, location streaming, FCM ping receipt) is still
   pending and is the main functional gap before integration testing.

### Changed this session
- **`apps/site_manager/lib/router.dart`** + **`apps/b2b/lib/router.dart`** —
  hardened the detail-route `state.extra` casts. Changed each non-null
  `state.extra as X` to a nullable `as X?` with a fallback to the app's home
  screen (already imported) when `extra` is missing. Prevents a runtime crash on
  hot-restart / deep-link onto `managerWeigh|Broadcast|Byproduct|Report` and
  `b2bListing|Prebook|Tracking|Invoice`. Self-contained, no screen-constructor or
  type changes — but still confirm with `flutter analyze` on Windows.
- **`docs/PROJECT_LOG.md`** — this entry. No other source files were modified: the
  rest of the review found no certain compile-breaking bug, and editing a clean,
  currently-building codebase without a compiler to verify would risk regressions.

### Windows-side verification checklist (run to certify "working")
1. `flutter pub get` at repo root (bootstraps the workspace).
2. `flutter analyze apps packages` — expect clean; triage any new lints.
3. `cd apps/<role> && flutter test` for each of the 4 apps (routing tests).
4. `cd apps/<role> && flutter run` for each app on the Pixel emulator; walk every
   screen against the matching `Designs/<App>/screenN.jsx`.
5. `cd functions && npm ci && npm run build` (tsc) to confirm the TS compiles.
6. Enable the Phone auth provider in Firebase console before testing login.

### Next up
- Address finding #2 (live data wiring: worker accept → `acceptPing`, location
  streaming, FCM ping receipt), one app per session per the CLAUDE.md workflow,
  verifying each screen on device.
- Optional: token-map the hardcoded-hex widgets in finding #1.

---

## 2026-06-16 — Session 7: Public marketing landing page (React + Vite)

**Goal:** Ship the Claude Design landing-page export (`Designs/ThengaPari Website/`)
as a real, deployable marketing site with Firestore-backed waitlist capture.

### Done

**New `website/` package — React + Vite + Tailwind** (separate from the Flutter
monorepo; static-only).
- Design tokens (`Designs/.../colors_and_type.css`) kept verbatim as
  `src/styles/tokens.css` and mapped into the Tailwind theme via CSS variables
  (`tailwind.config.js`) so components reference the theme, never hardcoded hex.
  Bespoke design CSS ported to `src/styles/landing.css`.
- Sections componentized: `Nav, Hero, Problem, HowItWorks, WhoItsFor, ZeroWaste,
  Traction, SignupCTA, Footer` + `ui/` primitives (`Reveal, Button, SectionHead`)
  and a shared `Icons.jsx`. All copy centralized in `src/data/content.js` with
  `// ML:` Malayalam-translation markers.
- Interactions re-implemented as React hooks (`useReveal`, `useCountUp`): scroll
  reveals, step progress, count-up stats, sticky-nav shadow, mobile menu — all
  honoring `prefers-reduced-motion`. Below-the-fold sections `React.lazy`-loaded.

**Waitlist → Firestore** (`src/lib/firebase.js`)
- `submitLead({email,type})` writes `/leads/{id} = { email, type, createdAt }`
  (type = `homeowner|business|general`), set via an audience toggle + CTA intent
  (`src/lib/signup.jsx`). Falls back to `localStorage` when Firebase env is unset
  so the page works before config is pasted in.
- Added a validated, create-only public `/leads` rule to `firestore.rules`.

**SEO / deploy**
- `index.html`: title, meta description, Open Graph + Twitter cards, JSON-LD
  Organization, favicon, manifest, font preconnect. `public/`: favicon,
  `og-cover.svg`, `site.webmanifest`, `robots.txt`, `sitemap.xml`.
- Turnkey deploy configs: `netlify.toml`, `vercel.json`, and a `hosting` block in
  the repo-root `firebase.json` (publishes `website/dist`, same `thengapari-dev`).

### Verification
- `npm run build` in `website/` produces a clean production bundle; `npm run dev`
  renders all sections matching `Designs/ThengaPari Website/screens/*.png`.
- Form submits with no env → success UI + `localStorage`; with env + deployed
  rule → doc in Firestore `/leads`.

### Notes / deviations
- Real Firebase web config, Play Store URL, and a PNG OG image are placeholders
  (documented in `website/README.md`). Partner logos remain design placeholders.
- Dropped the Claude Design "Tweaks panel" React island (a design-tool artifact).

### Next up
- Paste real `thengapari-dev` web config + deploy `firestore:rules` and hosting.
- Optional: Malayalam `ml` copy map + language toggle; PNG OG export.

---

## 2026-06-07 — Session 6: Worker app — remaining screens + dev login bypass

**Goal:** Finish the Worker app (only home was done): build the Jobs/Wallet/Profile tabs and the Ping → Navigate → Complete active-job flow, matching the worker designs. Also add a dev login bypass so the full app is testable.

### Done

**Shared worker styling** (`features/worker/theme/worker_theme.dart`)
- Public `WColors` (dark-teal `--w-*` tokens) + reusable atoms: `WScreenHeader`, `WHeaderIconBtn`, `WMiniStat`, `WSectionHead`, `WTag`, `WRupee`, `WWeeklyChart`, and `inrGroup()` Indian-digit formatter. Refactored `home_screen.dart` to use `WColors` and wired its bottom-nav tabs to the real screens + a "Demo · trigger a job ping" button.

**Tabs (live inside the home shell's bottom nav)**
- `jobs_screen.dart` — `WorkerJobsTab`: week mini-stats, Upcoming/History segmented tabs, day groups (Today/Tomorrow), job cards + history rows with star ratings.
- `wallet_screen.dart` — `WorkerWalletTab`: balance hero, **withdraw-to-UPI bottom sheet** (amount + quick chips → success stage), secondary stats, weekly chart, linked UPI, payouts list.
- `profile_screen.dart` — `WorkerProfileTab`: identity card (name/reliability from auth+profile), lifetime earnings, skills with progress bars, KYC docs, settings (language toggle via `localeProvider`, **sign-out** clears `devAuthOverride` + Firebase).

**Active-job flow (full-screen routes)**
- `job_ping_screen.dart` — `JobPingScreen`: animated **radar `CustomPainter`** (rings, rotating sweep, pulsing job dot), white detail card, 45s countdown that auto-declines on expiry; Accept → Navigate.
- `navigate_screen.dart` — `NavigateScreen`: painted dark map (plots, roads, amber route, pin, worker marker), ETA banner, "I've arrived" → Complete.
- `job_complete_screen.dart` — `JobCompleteScreen`: success animation, payout card, job summary, interactive star rating, "Submit & go home".

**Routing & dev login bypass**
- Added `workerPing` / `workerNavigate` / `workerComplete` routes to `router.dart` + the worker harness, with menu entries for each.
- `auth_provider.dart`: `devAuthOverrideProvider` (`Notifier<AppUser?>`) — when set, `authStateProvider` emits it instead of the Firebase stream. `LoginScreen` now has a `kDebugMode`-gated **DEV BYPASS** row (Homeowner/Worker/Site Manager/B2B) and is wrapped in a scroll view. Production untouched.
- Cleaned stale unused worker imports from the homeowner harness.

### Verification
- `flutter analyze` on the worker feature + harnesses → No issues found.
- Full app built + ran on Pixel 7 (dev flavor). Phone OTP needs SHA-1 added in Firebase (server-side done; `google-services.json` not yet re-downloaded — not required for phone auth). Worker screens reviewable via dev bypass or `main_worker_dev.dart`.

### Notes / deviations
- Tab/flow content is demo/static (mirrors the design's hardcoded data); wiring to live Firestore (`/jobs`, `/job_pings`, `/workers/{uid}/earnings`) + FCM ping + Razorpay payout is a later step.
- Maps are painted approximations (no Google Maps key needed for review). Worker screens are English-only for now (no per-screen EN/മല toggle yet, except the profile language setting).

### Next up
- Wire worker screens to live data + the real ping/accept/complete Cloud Functions (needs Blaze).
- Optional: bilingual labels across worker screens.

---

## 2026-06-07 — Session 5: Worker app start (setup + home dashboard)

**Goal:** Begin the Worker app (dark-teal theme). Build first-time setup, then the home dashboard, on a dedicated worker dev harness. One screen at a time, pausing for on-device hot-reload.

### Done

**Worker data layer**
- `worker_profile.dart` — `WorkerProfile` (`/workers/{uid}`) + `WorkerSkill` enum (climber/husker/pepper picker/jackfruit processor/general labour) with stable `firestoreValue` snake_case, labels, and icons.
- `worker_service.dart` — `WorkerService`: `saveWorkerSetup` (batched `/users/{uid}` role:worker + `/workers/{uid}` with skills, UPI VPA, FCM token, starting stats), `watchWorker` stream, `setOnline` toggle.
- `worker_providers.dart` — `workerServiceProvider`, `workerProfileProvider(uid)`, `workerAvailabilityProvider` (Riverpod 3 `Notifier<bool>`, optimistic, seeds from profile), plus `workerDayStatsProvider`, `workerConfirmedJobsProvider`, `workerWeeklyEarningsProvider` (+ `WorkerDayStats` / `WorkerConfirmedJob` view models). Names per `02_worker_app_plan.md`.

**Screen 1 — WorkerSetupScreen** (`worker_setup_screen.dart`)
- Single-flow setup: full name, 14-district dropdown, multi-select skill chips, validated UPI VPA. Dark-teal palette, amber CTA. Writes via `saveWorkerSetup` → `/worker/home`. Wired into router with a worker onboarding redirect (incomplete profile → `/worker/setup`).

**Screen 2 — WorkerHomeScreen** (`home_screen.dart`)
- Rebuilt from the stub to match `Designs/ThengaPari Worker App/screen-home.jsx`: time-aware greeting header + avatar with live online dot; animated online/offline **BigToggle** (pulsing dot, sliding switch) writing `isOnline`; two stat cards (today's earnings amber-accent + jobs completed); **reliability card** with a `CustomPaint` score ring (green/amber/red banded); "Today's confirmed jobs" list (time · place·distance · payout · Up next/Scheduled tags + empty state); **weekly earnings bar chart** (Mon–Sun, today highlighted); worker bottom nav (Home·Jobs·Wallet·You — last three are themed "Coming next" placeholders).

**Worker dev harness** (`main_worker_dev.dart`, new)
- `main_dev.dart` is homeowner-only, so added a parallel worker harness: boots Firebase, anon sign-in, overrides `authStateProvider` with a worker user, seeds the worker providers with sample data, and a `_DemoWorkerService` so setup + toggle writes no-op without live Firestore. Menu jumps to Setup + Home. Run: `flutter run --flavor dev -t lib/main_worker_dev.dart`.

### Verification
- `flutter analyze` on the worker files → No issues found.
- Not yet run on device — pending hot-reload visual check against `screen-home.jsx`.

### Notes / deviations
- Static strings carried over from the design (not yet provider-driven): "47/50 on time", "Top 8% of climbers", "+₹380 last job", "2 climbs · 2 husks". Worker home has no bilingual (EN/മല) toggle yet.
- Reliability ring + weekly chart drawn inline in `home_screen.dart` (not the shared `painters/` library) to keep the worker palette self-contained.

### Next up
- Wire the static stat sub-labels to real provider data + bilingual toggle (optional polish).
- Screen 3 — **JobPingScreen** (full-screen ping takeover, radar painter, 45s countdown, accept/decline) — the most critical screen.

---

## 2026-06-06 — Session 4: Homeowner steps 3–4 + design fixes + name propagation

**Goal:** Build BookHarvest + LiveJobTracker on the design foundation; fix UI issues found on device; finish propagating the ThengaPari name; update docs.

### Done

**Step 3 — BookHarvestScreen** (`book_harvest_screen.dart`)
- Crop grid (multi-select cells with glyphs + check), date strip, ripe/all segment, gradient estimate preview, sticky amber confirm bar, success bottom sheet.
- `cloud_functions` added; `HomeownerService.calculateYieldEstimate` (Cloud Function + local fallback) and `createJob` (writes `/jobs/{id}`, status `pending`). Crop economics (`kgPerTree`, `ratePerKg`) on `CropType`; `YieldEstimate` model.

**Step 4 — LiveJobTrackerScreen** (`live_job_tracker_screen.dart`)
- Progress stepper (derived from job status), stylised grove map (`CustomPainter` + SM pin + badge — no Google Maps key needed), contact row (tap-to-call via `url_launcher`), live-weight dial, site photos.
- `JobStatusUpdate` model + `statusUpdatesProvider` (`/jobs/{id}/statusUpdates`). Wired into router + dev harness. Verified on Pixel 7.

**Design fixes (from on-device review)**
- Home hero: darker top scrim + dark translucent backgrounds on the brand chip + EN/മല toggle so the white text is legible over the light sky.
- Book screen: fixed crop-cell + date-cell vertical overflow (taller extents, non-wrapping day label).

**Name propagation (ThengaPari)**
- iOS `Info.plist`: `CFBundleDisplayName` → ThengaPari, `CFBundleName` → thengapari.
- README rewritten for ThengaPari (corrected: no code-gen required; documented the dev harness + first-run font fetch).
- `flutter_implementation_plan.md` structure diagram → `thengapari/`.
- **Intentionally unchanged:** Android `applicationId`/namespace + iOS bundle id `com.agrimarketplace.agri_platform*` and `google-services.json` (Firebase-bound).

### Verification
- `flutter analyze lib` → No issues found; `flutter build apk --debug --flavor dev` → builds.
- On Pixel 7: Home (redesign + contrast fix), Book, and Tracker all verified.

### Notes
- An automated PR workflow commits/merges branches into `master`; uncommitted edits made between cycles were lost twice this session (home-contrast fix, README, iOS name). Re-applied and committed on a branch to persist.

### Next up
- Homeowner steps 5–7 (Yield report, Payment, AMC).

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
