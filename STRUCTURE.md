# ThengaPari — Full Project Structure

ThengaPari is a hyperlocal coconut/crop-harvesting marketplace for Kerala, India.
This document maps the **entire repository**: the Flutter monorepo (shared core +
four role apps), the Cloud Functions + Firestore backend, the design exports, the
docs, and the marketing website.

> Source of truth for collection paths, data models, and the cross-app event flow
> is [`docs/00_shared_architecture.md`](docs/00_shared_architecture.md).
> Project conventions and hard rules live in [`CLAUDE.md`](CLAUDE.md).

---

## 1. Top-level layout

```
Thengapari/
├── packages/core/      Shared Flutter code (package:core) — models, services,
│                       providers, theme, widgets, painters, auth screens
├── apps/               Four standalone, independently runnable role apps
│   ├── homeowner/      Books harvests, tracks jobs, gets yield reports
│   ├── worker/         Climbers/processors — job pings, navigation, wallet
│   ├── site_manager/   Students who run harvests — queue, weigh, report
│   └── b2b/            Businesses — live inventory, orders, standing orders
├── functions/          TypeScript Cloud Functions (Firebase backend logic)
├── website/            Marketing landing page (React + Vite) — see its own
│                       website/STRUCTURE.md
├── Designs/            Claude Design exports (React/JSX + CSS) per app + website
├── docs/               Architecture, per-app plans, implementation plan, work log
├── .claude/            Local Claude Code config (project-scoped)
│
├── pubspec.yaml        Dart pub WORKSPACE root (core + 4 apps, one lockfile)
├── pubspec.lock        Shared resolved dependency lockfile
├── melos.yaml          Melos monorepo scripts (analyze, etc.)
├── analysis_options.yaml  Shared lint rules
├── firebase.json       Firestore + Functions + Hosting (website) deploy config
├── firestore.rules     Security rules for ALL collections (incl. /leads)
├── firestore.indexes.json  Composite index definitions
├── CLAUDE.md           Project context + hard rules for contributors/agents
└── README.md           Repo overview
```

**Architecture model:** a Melos/Dart-workspace monorepo. Role is chosen at
**install** — each app *is* its role; there is no in-app role gate. All four apps
share one Firebase backend. The four apps + the website all read/write the same
Firestore collections, so field names and paths must match exactly.

---

## 2. `packages/core/` — shared Flutter package (`package:core`)

The dependency hub every app imports. Re-exported through `lib/core.dart`.

```
packages/core/lib/
├── core.dart                       Barrel file — public API of the package
│
├── app/                            App-wide foundations
│   ├── theme.dart                  ThemeData locked to design-system.css
│   ├── design_tokens.dart          Color/spacing/radii/type tokens
│   └── flavor_config.dart          Flavor enum (dev/staging/prod) + project IDs
│
├── core/
│   ├── i18n/
│   │   └── app_strings.dart        Bilingual (English/Malayalam) strings
│   │
│   ├── models/                     freezed data models + Firestore (de)serializers
│   │   ├── app_user.dart           Shared user profile
│   │   ├── harvest_job.dart        Central job document (HarvestJob.createData)
│   │   ├── job_status_update.dart  Checklist events (JobStatusUpdate.writeData)
│   │   ├── job_step.dart           Steps within a job
│   │   ├── yield_data.dart         Harvest weights/grades (YieldData.writeData)
│   │   ├── yield_estimate.dart     Pre-harvest estimate
│   │   ├── tree_inventory.dart     Homeowner's trees
│   │   ├── crop_listing.dart       / crop_summary.dart
│   │   ├── inventory_listing.dart  B2B live stock (InventoryListing.toFirestore)
│   │   ├── b2b_order.dart          / standing_order.dart / b2b_buyer_profile.dart
│   │   ├── b2b_savings.dart        Buyer savings ledger
│   │   ├── worker_profile.dart     / site_manager_profile.dart
│   │   ├── processor_response.dart Ping accept/decline payload
│   │   ├── byproduct.dart          Zero-waste routing
│   │   └── amc_contract.dart       Annual maintenance contracts
│   │
│   ├── providers/                  Riverpod providers (state management)
│   │   ├── auth_provider.dart      Auth state + dev login override
│   │   ├── locale_provider.dart    Language toggle
│   │   ├── onboarding_provider.dart
│   │   ├── homeowner_providers.dart
│   │   ├── worker_providers.dart
│   │   ├── site_manager_providers.dart
│   │   └── b2b_providers.dart
│   │
│   ├── services/                   Firestore/Firebase access layer
│   │   ├── auth_service.dart
│   │   ├── onboarding_service.dart
│   │   ├── homeowner_service.dart
│   │   ├── worker_service.dart
│   │   ├── site_manager_service.dart
│   │   └── b2b_service.dart
│   │
│   └── widgets/                    Shared UI atoms + composite widgets
│       ├── app_button.dart, app_icon.dart, app_text_field.dart
│       ├── job_status_badge.dart, job_status_card.dart, stat_card.dart
│       ├── crop_inventory_row.dart, live_inventory_tile.dart
│       ├── countdown_timer_widget.dart, worker_availability_toggle.dart
│       ├── role_nav_bars.dart, user_avatar_widget.dart, shimmer_job_card.dart
│       ├── hero_landscape_widget.dart, savings_band_widget.dart
│       └── painters/               CustomPainters (no images, all drawn)
│           ├── kerala_landscape_painter.dart
│           ├── radar_map_painter.dart        (worker job-ping radar)
│           ├── yield_donut_painter.dart
│           ├── savings_bar_chart_painter.dart
│           └── weekly_earnings_chart_painter.dart
│
└── features/auth/                  Shared auth flow (used by all 4 apps)
    ├── screens/                    splash, onboarding, login, otp_verify, role_gate
    └── widgets/                    auth_widgets, onboarding_illustrations
```

**Hard rules enforced here:** cross-app Firestore writes go through the model
`*.writeData` / `*.createData` / `*.toFirestore` helpers (never hand-rolled maps);
colors/spacing come from `theme.dart` + `design_tokens.dart` (never hardcoded).

---

## 3. `apps/<role>/` — the four role apps

Each app is a standalone Flutter app with the same shape, depending on
`package:core`. Role is fixed at install.

```
apps/<role>/
├── lib/
│   ├── main.dart                   Entrypoint — sets flavor, seeds demo data, runs app
│   ├── app.dart                    Root widget (MaterialApp.router + theme)
│   ├── router.dart                 Slim GoRouter: this app's routes + shared core auth
│   └── features/<role>/
│       ├── screens/                The role's screens (see per-app list below)
│       ├── widgets/                Role-specific widgets (e.g. home_widgets.dart)
│       └── theme/                  Role-specific theme overrides (worker only)
├── android/                        Android project (app/src/{main,debug,profile})
│   └── app/build.gradle.kts        minSdk, applicationId, product flavors
├── ios/                            iOS project (Runner.xcodeproj/.xcworkspace)
└── test/                           Widget/routing tests
```

### Screens by app

| App | Screens (`features/<role>/screens/`) |
| --- | --- |
| **homeowner** | home, homeowner_shell, book_harvest, live_job_tracker, yield_report, tree_inventory_setup, profile_setup, payment, amc |
| **worker** | home, jobs, wallet, profile, worker_setup, **job_ping** (radar), **navigate** (map), **job_complete** |
| **site_manager** | home, daily_queue, broadcast_ping, navigation_to_site, on_site, yield_weigh, harvest_report, byproduct_routing, training, college_verification, sm_profile_setup |
| **b2b** | home, dashboard, inventory, listing_detail, prebook, orders, order_tracking, standing_order, invoice_view, business_profile_setup, gst_verification |

**Run an app:** `cd apps/<role> && flutter run` (each `main.dart` seeds demo data,
so it runs without live Firestore). Workspace bootstrap: `flutter pub get` at root.
Analyze everything: `flutter analyze apps packages`.

---

## 4. `functions/` — Cloud Functions (TypeScript)

Server-side logic and the only place Razorpay secret keys live. Atomic operations
(`acceptPing`, `createB2BOrder`) use Firestore transactions.

```
functions/
├── src/
│   ├── index.ts        Exports / registers all functions
│   ├── lib.ts          Shared helpers (admin init, utils)
│   ├── jobs.ts         Harvest job lifecycle
│   ├── pings.ts        Job pings — acceptPing (transactional, anti-double-grab)
│   ├── inventory.ts    updateInventoryOnHarvest (live B2B stock)
│   ├── b2b.ts          createB2BOrder (transactional, anti-over-order)
│   ├── payments.ts     Razorpay (server-side keys only)
│   ├── reports.ts      Yield/harvest report generation
│   ├── crons.ts        Scheduled jobs
│   └── misc.ts         Misc triggers
├── package.json        Build/deploy scripts + deps
├── tsconfig.json
└── README.md
```

> **Deploy gate:** Functions require the Firebase **Blaze** plan. The project is
> currently on **Spark** — do not deploy functions until upgraded (per CLAUDE.md).

---

## 5. Firebase / Firestore (repo root)

```
firebase.json          Config for: firestore (rules+indexes), functions, hosting (website/dist)
firestore.rules        Security rules for every collection — users, jobs, job_pings,
                       inventory, b2b_orders, standing_orders, byproduct_*, payouts,
                       and /leads (public website waitlist, validated create-only)
firestore.indexes.json Composite indexes
```

Collections are defined/validated in `firestore.rules` and documented in
`docs/00_shared_architecture.md`. The website's waitlist writes to `/leads/{id}`.

---

## 6. `website/` — marketing landing page (React + Vite)

Static site, separate from the Flutter workspace. Pulls the same design tokens so
it matches the apps. Only dynamic piece: the waitlist form → Firestore `/leads`.
Full breakdown in **[`website/STRUCTURE.md`](website/STRUCTURE.md)**.

```
website/
├── index.html, vite.config.js, tailwind.config.js, postcss.config.js
├── src/{main.jsx, App.jsx, index.css, components/, data/, lib/, styles/, assets/}
├── public/{favicon.svg, og-cover.svg, site.webmanifest, robots.txt, sitemap.xml}
├── netlify.toml, vercel.json, .env.example, README.md, STRUCTURE.md
└── dist/  (build output — deployed)
```

---

## 7. `Designs/` — design source (Claude Design exports)

React/JSX + CSS exports that are the **visual source of truth**. `design-system.css`
(and per-export tokens) drive the Flutter theme and the website tokens.

```
Designs/
├── ThengaPari Auth Flow/          Shared auth screens
├── ThengaPari HomeOwner App (1)/
├── ThengaPari Worker App/         screen-*.jsx (home, jobs, wallet, ping, …) + assets
├── ThengaPari Site Manager App/
├── ThengaPari B2B Portal App/
└── ThengaPari Website/            landing.css/js + colors_and_type.css + assets/screens
```

Each app export contains `screenN.jsx` (intended layouts), an `assets/` folder
(real icons/illustrations), and `design-system.css` / `colors_and_type.css`.

---

## 8. `docs/` — plans & log

```
docs/
├── 00_shared_architecture.md   SOURCE OF TRUTH: collection paths, models, event flow
├── 01_homeowner_app_plan.md
├── 02_worker_app_plan.md
├── 03_site_manager_app_plan.md
├── 04_b2b_portal_plan.md
├── flutter_implementation_plan.md   Full widget/painter code + theme tokens
└── PROJECT_LOG.md              Running work log (newest first; one entry per session)
```

---

## 9. Tech stack & conventions (quick reference)

| Concern | Choice |
| --- | --- |
| Apps | Flutter (Dart workspace, Melos monorepo) |
| State | Riverpod (providers named per the plans) |
| Routing | GoRouter — one slim router per app + shared core auth |
| Models | freezed; Firestore maps via model helper methods only |
| Backend | Firebase: Firestore + Cloud Functions (TypeScript) |
| Payments | Razorpay — secret keys server-side (Functions) only |
| Website | React 18 + Vite 5 + Tailwind 3 (static; Firestore for /leads) |
| Design | Tokens locked to design-system.css; never hardcode hex |
| Environments | Flavors: dev / staging / prod (`flavor_config.dart`) |

**Golden rule:** all four apps + the website share one Firestore. Keep collection
paths and cross-app field names identical to `docs/00_shared_architecture.md`.
```
