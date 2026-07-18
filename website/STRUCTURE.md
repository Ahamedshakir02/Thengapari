# ThengaPari Website — Structure

Reference for how the landing-page codebase is organized: every file, what it
does, and how the pieces fit together. For run/deploy instructions see
[`README.md`](./README.md).

- **Stack:** React 18 + Vite 5 + Tailwind CSS 3
- **Type:** Static marketing site. No backend — the only dynamic piece is the
  waitlist form, which writes directly to Firestore `/leads/{id}`.
- **Design source:** `Designs/ThengaPari Website/` (Claude Design export). Colors,
  type, spacing come from the shared ThengaPari design tokens, so the site is
  visually identical to the apps.

---

## Directory tree

```
website/
├── index.html                  # HTML entry: SEO/OG meta, fonts, #root mount
├── package.json                # deps + scripts (dev / build / preview)
├── vite.config.js              # Vite + React plugin config
├── tailwind.config.js          # design tokens → Tailwind theme (via CSS vars)
├── postcss.config.js           # Tailwind + Autoprefixer pipeline
├── .env.example                # template for VITE_FB_* + store URLs
├── .gitignore                  # node_modules, dist, .env.local, …
├── README.md                   # run / configure Firebase / deploy
├── STRUCTURE.md                # this file
├── netlify.toml                # Netlify build + SPA redirect
├── vercel.json                 # Vercel build + SPA rewrite
│
├── public/                     # served verbatim at site root (not bundled)
│   ├── favicon.svg             # logo mark (also the manifest/JSON-LD icon)
│   ├── og-cover.svg            # 1200×630 social share image
│   ├── site.webmanifest        # PWA manifest (name, theme-color, icon)
│   ├── robots.txt              # crawl rules + sitemap pointer
│   └── sitemap.xml             # single-URL sitemap
│
├── src/
│   ├── main.jsx                # React root; imports CSS (tokens+Tailwind, then landing)
│   ├── App.jsx                 # composes sections; lazy-loads below-the-fold
│   ├── index.css               # @import tokens + @tailwind base/components/utilities
│   │
│   ├── assets/                 # imported by components → hashed + bundled by Vite
│   │   ├── logo-mark.svg
│   │   ├── logo-mark-light.svg
│   │   └── illustration-kerala-landscape.svg
│   │
│   ├── styles/
│   │   ├── tokens.css          # design system (colors/type/spacing/shadows) — source of truth
│   │   └── landing.css         # bespoke component styles ported from the design
│   │
│   ├── data/
│   │   └── content.js          # ALL copy (English) + // ML: translation markers + links
│   │
│   ├── lib/
│   │   ├── firebase.js         # submitLead() → Firestore (SDK lazy-imported); localStorage fallback
│   │   ├── useReveal.js        # useReveal() + useCountUp() hooks (IntersectionObserver)
│   │   └── signup.jsx          # SignupProvider/useSignup — shares CTA "intent" across the page
│   │
│   └── components/
│       ├── Nav.jsx             # sticky nav, scroll shadow, mobile menu, CTAs
│       ├── Hero.jsx            # headline, CTAs, illustration + floating badges, hill divider
│       ├── Problem.jsx         # 4 problem cards
│       ├── HowItWorks.jsx      # 4-step flow with animated progress rail
│       ├── WhoItsFor.jsx       # 4 role tiles (homeowner/worker/manager/business)
│       ├── ZeroWaste.jsx       # byproduct flow diagrams (lazy)
│       ├── Traction.jsx        # count-up stat strip + partner logos (lazy)
│       ├── SignupCTA.jsx       # waitlist form: type toggle + email → submitLead()
│       ├── Footer.jsx          # brand, contact, link columns (lazy)
│       ├── Icons.jsx           # inline SVG art (ProblemIcon/StepIcon/TileArt/FlowIcon)
│       └── ui/
│           ├── Reveal.jsx      # wraps children with reveal-on-scroll (+ stagger)
│           ├── SectionHead.jsx # overline + title + sub used by most sections
│           └── Button.jsx      # thin <a>/<button> over the .btn design classes
│
└── dist/                       # build output (gitignored) — what you deploy
```

---

## How it fits together

### Rendering & composition
- `index.html` loads fonts + meta and mounts `#root`; `src/main.jsx` renders
  `<App>` and pulls in the stylesheets **in order**: `index.css` (tokens +
  Tailwind) first, then `styles/landing.css` so the bespoke component rules win
  over Tailwind's preflight.
- `App.jsx` wraps everything in `SignupProvider` and lays out the sections in
  order. `ZeroWaste`, `Traction`, and `Footer` are `React.lazy()` + `Suspense`
  so they're code-split out of the initial bundle (faster first paint).

### Styling — tokens are the source of truth
- `styles/tokens.css` defines every design variable (`--green-forest-700`,
  `--accent`, `--r-lg`, `--s-6`, `--shadow-md`, fonts, the full type scale…).
- `tailwind.config.js` maps those CSS variables into named utilities
  (`bg-brand`, `text-accent`, `rounded-xl`, `shadow-md`, `font-display`, …).
  **Result: components reference the theme; no hex is ever hardcoded.**
- `styles/landing.css` holds the larger bespoke visuals (nav, hero floaties +
  hill divider, problem/step/tile cards, zero-waste flows, signup card + the
  audience toggle) — already token-driven, so it's kept rather than re-derived.

### Content & copy
- `data/content.js` is the single place all user-facing text lives, grouped by
  section (`hero`, `problem`, `how`, `who`, `zero`, `traction`, `signup`,
  `footer`). Each string carries a `// ML:` note marking where a Malayalam
  translation slots in later. It also exports `links` (Play/App Store URLs from
  env, with fallbacks).

### Interactions (hooks, not imperative JS)
- `lib/useReveal.js`
  - `useReveal()` → `[ref, shown]`; flips `shown` true when the element scrolls
    into view (IntersectionObserver). Honors `prefers-reduced-motion`.
  - `useCountUp(target, {active})` → animated, en-IN-formatted number string.
- `ui/Reveal.jsx` wraps any element and applies the `.reveal`/`.in` classes with
  an optional stagger (`delayStep`).
- `Nav.jsx` owns sticky-shadow-on-scroll and mobile-menu state locally.

### Signup flow (the one dynamic path)
1. A CTA anywhere (nav "For businesses", hero buttons, role-tile links) calls
   `selectType(type)` from `lib/signup.jsx`, which sets the shared lead `type`
   and smooth-scrolls to `#signup`.
2. `SignupCTA.jsx` shows a **Homeowner / Business / Other** toggle (pre-selected
   by that intent) + an email field, validates client-side, then calls…
3. `lib/firebase.js` → `submitLead({ email, type })`:
   - **Configured** (`VITE_FB_*` present): dynamically imports the Firebase SDK
     (kept out of the initial bundle) and writes
     `/leads/{id} = { email, type, createdAt: serverTimestamp() }`.
   - **Not configured:** stores to `localStorage` (`tp_waitlist`) so the form
     still succeeds, with a console note.

### Backend touchpoints (outside this folder, in the repo root)
- `firestore.rules` — a validated, create-only public rule for `/leads`
  (type ∈ homeowner|business|general; `createdAt == request.time`).
- `firebase.json` — a `hosting` block publishing `website/dist` to the same
  `thengapari-dev` project.

---

## Data flow at a glance

```
CTA click ──selectType(type)──▶ SignupProvider (shared `type`) ──▶ SignupCTA toggle
                                                                        │
email + type ──submitLead()──▶ lib/firebase.js ──┬─ configured ─▶ Firestore /leads/{id}
                                                  └─ not set ────▶ localStorage (fallback)
```

```
scroll ──IntersectionObserver (useReveal) ──▶ .reveal.in (fade/translate)
                                          └──▶ useCountUp drives stat numbers
```

---

## Build outputs (typical)

`npm run build` → `dist/`:
- `index.html` + `assets/index-*.css` (~28 kB)
- `assets/index-*.js` — app entry (~178 kB / ~57 kB gzip)
- `assets/ZeroWaste-*.js`, `Traction-*.js`, `Footer-*.js` — lazy section chunks
- `assets/*firebase*` (~434 kB) — **only fetched on first form submit**
- `public/` files copied to the root verbatim
