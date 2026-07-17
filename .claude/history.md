# Project History

Newest-first change log. Read the INDEX first, then only the entries you need.

## Index

| Date | Session | Summary | Files |
|------|---------|---------|-------|
| 2026-07-17 | website-finish | Verified + committed finished landing site; lazy Firebase, /leads rules, hosting config | `website/*`, `firestore.rules`, `firebase.json`, `docs/PROJECT_LOG.md` |

## Entries

### 2026-07-17 — website-finish
- **Files:** committed all pending `website/` work (components, styles, lib, public assets, deploy configs), `firestore.rules` (/leads create-only rule), `firebase.json` (hosting), `apps/{b2b,site_manager}/lib/router.dart` (extra-cast hardening from Session 8 audit), `STRUCTURE.md`, `docs/PROJECT_LOG.md` (Session 9 entry).
- **Summary:** Finished the Vite+React marketing site on branch `website`. Verified end-to-end: clean production build (Firestore SDK lazy-loaded on first submit, below-fold sections code-split), full page walk in Chrome, waitlist submit with type toggle → success message + localStorage fallback, zero site console errors.
- **Why:** Site was feature-complete but unverified and uncommitted; user asked to finish and commit everything.
- **Decisions:** Firebase SDK dynamic-import on submit (fast first paint); `/leads` rule validates keys/email-size/type whitelist/`createdAt == request.time`; commit messages carry NO AI attribution (user rule, 2026-07-17).
- **TODOs:** Fill `website/.env.local` from Firebase console web-app config; deploy firestore.rules; choose host (Firebase/Netlify/Vercel configs all present); replace placeholder partner logos + traction numbers.
