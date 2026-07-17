# ThengaPari — Landing Page

The public marketing site for **ThengaPari**, a hyperlocal coconut & crop-harvesting
marketplace in Kerala. Mobile-first, fast-loading, and static except for one dynamic
piece: a waitlist form that writes to Firestore.

- **Stack:** React + Vite + Tailwind CSS
- **Design system:** colors, type, spacing pulled from `src/styles/tokens.css`
  (the same tokens the apps use) — components never hardcode hex values.
- **Backend:** none. The waitlist form writes directly to Firestore `/leads/{id}`.

## Run locally

```bash
cd website
npm install
npm run dev        # http://localhost:5173
npm run build      # production bundle -> dist/
npm run preview    # preview the production build
```

The page works out of the box. Until Firebase is configured (below), waitlist
submissions are stored in `localStorage` instead of Firestore — the form still
succeeds and a console note explains why.

## Configure Firebase (waitlist → Firestore)

1. Firebase console → project **thengapari-dev** → *Project settings* → *General*
   → *Your apps* → add/select a **Web app** → copy the SDK config.
2. `cp .env.example .env.local` and paste the values (`VITE_FB_*`). Restart `npm run dev`.
3. Deploy the security rule that allows public, validated lead creation
   (already added to the repo-root `firestore.rules`):

   ```bash
   # from the repo root
   firebase deploy --only firestore:rules
   ```

   Leads are written as:

   ```js
   /leads/{id} = { email, type: 'homeowner' | 'business' | 'general', createdAt }
   ```

   The `type` comes from the audience toggle in the form (and is pre-selected when
   a "For businesses" / role CTA is clicked).

## Deploy

Static output is `dist/` — deploy it anywhere. Three turnkey options:

| Target | How |
| --- | --- |
| **Netlify** | Connect the repo, set **Base directory** to `website`. `netlify.toml` sets build = `npm run build`, publish = `dist`. |
| **Vercel** | Import the repo, set **Root Directory** to `website`. `vercel.json` configures Vite + SPA rewrite. |
| **Firebase Hosting** | From repo root: `firebase deploy --only hosting` (config in root `firebase.json`, publishes `website/dist`, same `thengapari-dev` project). |

Set the same `VITE_FB_*` and `VITE_PLAY_STORE_URL` as environment variables in
your host's dashboard for production builds.

## Placeholders to replace

- **Firebase web config** — paste real values into `.env.local` / host env vars.
- **Play Store URL** — `VITE_PLAY_STORE_URL` (App Store badge stays "coming soon"
  until `VITE_APP_STORE_URL` is set).
- **OG image** — `public/og-cover.svg` is provided; for best social previews,
  export a 1200×630 **PNG** and point the `og:image` / `twitter:image` meta in
  `index.html` at it.
- **Partner logos** — `Traction` shows the design's dashed placeholders.
- **Domain** — canonical/OG URLs in `index.html` and `public/sitemap.xml` assume
  `https://thengapari.in/`; update if different.

## Malayalam (future)

All copy lives in `src/data/content.js` as English strings, each marked with a
`// ML:` note where a Malayalam translation slots in. Existing Malayalam accents
(`തേങ്ങാപ്പറി`, `നന്ദി`) are kept. To localize: add a parallel `ml` map + a `lang`
toggle — Noto Sans Malayalam is already loaded.

## Structure

```
src/
  components/   section components + ui/ primitives + Icons.jsx
  data/         content.js — all copy
  lib/          firebase.js (lead capture), useReveal.js (hooks), signup.jsx (CTA intent)
  styles/       tokens.css (design system) + landing.css (bespoke visuals)
  App.jsx       composes sections (below-fold lazy-loaded)
public/         favicon, og-cover, manifest, robots, sitemap
```
