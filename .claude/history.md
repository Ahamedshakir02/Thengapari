# Project History

Newest-first change log. Read the INDEX first, then only the entries you need.

## Index

| Date | Session | Summary | Files |
|------|---------|---------|-------|
| 2026-07-18 | design-fidelity | 5 subagent audits vs Designs/; applied all fixes (auth rebuild + welcome, worker Emerald/mono/Both, HO/SM/B2B gaps); analyze clean | `packages/core/**`, `apps/*/**`, `functions/src/pings.ts` |
| 2026-07-17 | apps-go-live | Demo→live: per-app google-services, emulator suite+seed, worker ping pipeline (acceptPing/tracking/earnings), live mains (demo kept as main_demo) | `packages/core/**`, `apps/*/lib/**`, `firebase.json`, `firestore.{rules,indexes}`, `functions/**` |
| 2026-07-17 | apps-status-check | Verified toolchain-side: analyze 0 issues, functions tsc clean; NO tests exist; apps demo-only (no live wiring/google-services.json) | none (assessment only) |
| 2026-07-17 | website-finish | Verified + committed finished landing site; lazy Firebase, /leads rules, hosting config | `website/*`, `firestore.rules`, `firebase.json`, `docs/PROJECT_LOG.md` |

## Entries

### 2026-07-17 — apps-status-check
- **Files:** none changed (assessment session).
- **Summary:** Ran the Session-8 pending verification on Windows: `flutter pub get` OK, `flutter analyze apps packages` → 0 issues, `functions` `npm ci && tsc` → clean. Found: NO test files exist in any app or core (audit checklist assumed routing tests that were never written). No `google-services.json` in any app (flutterfire configure never run). Worker "Accept job" (`job_ping_screen.dart:_accept`) only navigates — `WorkerService` has no `acceptPing` method at all (only saveWorkerSetup/watchWorker/setOnline). All 4 apps override service providers with in-memory `_Demo*Service` in main.dart.
- **Why:** User asked whether the apps are finished and every button/service works.
- **Decisions:** Verdict: apps compile clean and work in DEMO mode; not live-functional. Blockers to live: per-app Firebase config, Blaze upgrade + functions deploy, phone auth enablement, live wiring (acceptPing + location streaming + FCM), and a real (non-demo) entrypoint path.
- **TODOs:** Wire live flows one app per session (worker first: add `acceptPing` to WorkerService + call from `_accept`); run `flutterfire configure` per app; write routing/widget tests; emulator walk of every screen per Designs/.

### 2026-07-17 — website-finish
- **Files:** committed all pending `website/` work (components, styles, lib, public assets, deploy configs), `firestore.rules` (/leads create-only rule), `firebase.json` (hosting), `apps/{b2b,site_manager}/lib/router.dart` (extra-cast hardening from Session 8 audit), `STRUCTURE.md`, `docs/PROJECT_LOG.md` (Session 9 entry).
- **Summary:** Finished the Vite+React marketing site on branch `website`. Verified end-to-end: clean production build (Firestore SDK lazy-loaded on first submit, below-fold sections code-split), full page walk in Chrome, waitlist submit with type toggle → success message + localStorage fallback, zero site console errors.
- **Why:** Site was feature-complete but unverified and uncommitted; user asked to finish and commit everything.
- **Decisions:** Firebase SDK dynamic-import on submit (fast first paint); `/leads` rule validates keys/email-size/type whitelist/`createdAt == request.time`; commit messages carry NO AI attribution (user rule, 2026-07-17).
- **TODOs:** Fill `website/.env.local` from Firebase console web-app config; deploy firestore.rules; choose host (Firebase/Netlify/Vercel configs all present); replace placeholder partner logos + traction numbers.
