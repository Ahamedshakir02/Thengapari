/**
 * Tailwind theme is a thin mapping over the ThengaPari design system.
 * Every value points at a CSS variable defined in src/styles/tokens.css
 * (the locked source of truth shared with the apps) — so components reference
 * the theme and NEVER hardcode hex values.
 */
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        // semantic roles
        bg: 'var(--bg)',
        surface: 'var(--surface)',
        'surface-sunk': 'var(--surface-sunk)',
        fg1: 'var(--fg1)',
        fg2: 'var(--fg2)',
        fg3: 'var(--fg3)',
        border: 'var(--border)',
        'border-strong': 'var(--border-strong)',
        brand: 'var(--brand)',
        'brand-ink': 'var(--brand-ink)',
        accent: 'var(--accent)',
        'on-brand': 'var(--on-brand)',
        'on-accent': 'var(--on-accent)',
        // palette (for per-role tints / art)
        green: {
          forest900: 'var(--green-forest-900)',
          forest800: 'var(--green-forest-800)',
          forest700: 'var(--green-forest-700)',
          600: 'var(--green-600)',
          sage500: 'var(--green-sage-500)',
          sage400: 'var(--green-sage-400)',
          leaf300: 'var(--green-leaf-300)',
          leaf200: 'var(--green-leaf-200)',
          leaf100: 'var(--green-leaf-100)',
          leaf50: 'var(--green-leaf-50)',
        },
        amber: {
          saffron600: 'var(--amber-saffron-600)',
          500: 'var(--amber-500)',
          400: 'var(--amber-400)',
          200: 'var(--amber-200)',
          100: 'var(--amber-100)',
        },
        teal: {
          900: 'var(--teal-900)',
          700: 'var(--teal-700)',
          500: 'var(--teal-500)',
          300: 'var(--teal-300)',
          100: 'var(--teal-100)',
        },
        blue: {
          900: 'var(--blue-900)',
          700: 'var(--blue-700)',
          500: 'var(--blue-500)',
          300: 'var(--blue-300)',
          100: 'var(--blue-100)',
        },
        ink: {
          900: 'var(--ink-900)',
          700: 'var(--ink-700)',
          500: 'var(--ink-500)',
          400: 'var(--ink-400)',
        },
        mist: {
          300: 'var(--mist-300)',
          200: 'var(--mist-200)',
        },
        status: {
          'error-fg': 'var(--status-error-fg)',
          'error-bg': 'var(--status-error-bg)',
        },
      },
      fontFamily: {
        display: 'var(--font-display)',
        text: 'var(--font-text)',
        mono: 'var(--font-mono)',
      },
      borderRadius: {
        xs: 'var(--r-xs)',
        sm: 'var(--r-sm)',
        md: 'var(--r-md)',
        lg: 'var(--r-lg)',
        xl: 'var(--r-xl)',
        pill: 'var(--r-pill)',
      },
      boxShadow: {
        sm: 'var(--shadow-sm)',
        md: 'var(--shadow-md)',
        lg: 'var(--shadow-lg)',
        accent: 'var(--shadow-accent)',
      },
      maxWidth: {
        wrap: '1200px',
      },
    },
  },
  plugins: [],
};
