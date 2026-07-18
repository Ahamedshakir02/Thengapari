/* Inline SVG art reproduced from the design (Designs/ThengaPari Website).
   Grouped by usage so section components stay readable. */

// ── Problem cards (amber line icons) ──
export function ProblemIcon({ name }) {
  switch (name) {
    case 'monkey':
      return (
        <svg width="26" height="26" viewBox="0 0 32 32" fill="none">
          <circle cx="16" cy="11" r="6.5" fill="#8B6239" />
          <circle cx="13.5" cy="9" r="1.3" fill="#3a2a18" /><circle cx="18" cy="9" r="1.3" fill="#3a2a18" /><circle cx="16" cy="12.5" r="1.3" fill="#3a2a18" />
          <path d="M6 27 h20" stroke="#B86A06" strokeWidth="2.4" strokeLinecap="round" />
          <path d="M24 6 l3 -2 M25 11 l3 0" stroke="#DD8413" strokeWidth="2.2" strokeLinecap="round" />
        </svg>
      );
    case 'calendar':
      return (
        <svg width="26" height="26" viewBox="0 0 32 32" fill="none" stroke="#B86A06" strokeWidth="2.3" strokeLinecap="round" strokeLinejoin="round">
          <rect x="5" y="7" width="22" height="20" rx="3" />
          <path d="M5 12h22M11 4v5M21 4v5" />
          <path d="M13 18l3 3 4-5" />
        </svg>
      );
    case 'scale':
      return (
        <svg width="26" height="26" viewBox="0 0 32 32" fill="none" stroke="#B86A06" strokeWidth="2.3" strokeLinecap="round" strokeLinejoin="round">
          <path d="M16 5v22" /><path d="M8 9h16" />
          <path d="M8 9l-4 8a4 4 0 0 0 8 0z" />
          <path d="M24 9l-4 8a4 4 0 0 0 8 0z" />
          <path d="M11 27h10" />
        </svg>
      );
    case 'chart':
    default:
      return (
        <svg width="26" height="26" viewBox="0 0 32 32" fill="none">
          <path d="M5 22 l5 -6 4 4 6 -9 7 7" stroke="#B86A06" strokeWidth="2.3" strokeLinecap="round" strokeLinejoin="round" fill="none" />
          <circle cx="5" cy="22" r="2" fill="#DD8413" /><circle cx="27" cy="18" r="2" fill="#DD8413" />
          <path d="M5 27h22" stroke="#B86A06" strokeWidth="2.3" strokeLinecap="round" />
        </svg>
      );
  }
}

// ── How-it-works step glyphs ──
export function StepIcon({ name }) {
  switch (name) {
    case 'book':
      return (
        <svg className="si" viewBox="0 0 40 40" fill="none">
          <rect x="9" y="5" width="22" height="30" rx="4" fill="var(--green-leaf-100)" stroke="var(--green-forest-700)" strokeWidth="2" />
          <rect x="14" y="10" width="12" height="2.6" rx="1.3" fill="var(--green-forest-700)" />
          <circle cx="20" cy="24" r="6" fill="var(--amber-500)" />
          <path d="M17.4 24l1.8 1.8 3.4-3.6" stroke="#fff" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      );
    case 'manager':
      return (
        <svg className="si" viewBox="0 0 40 40" fill="none">
          <rect x="8" y="7" width="24" height="26" rx="3" fill="var(--green-leaf-100)" stroke="var(--green-forest-700)" strokeWidth="2" />
          <rect x="15" y="4" width="10" height="6" rx="2" fill="var(--amber-500)" />
          <circle cx="20" cy="19" r="3.4" fill="var(--green-forest-700)" />
          <path d="M14 28c0-3.3 2.7-5 6-5s6 1.7 6 5" stroke="var(--green-forest-700)" strokeWidth="2" strokeLinecap="round" />
        </svg>
      );
    case 'tree':
      return (
        <svg className="si" viewBox="0 0 40 40" fill="none">
          <rect x="18.5" y="20" width="3" height="15" rx="1.5" fill="#8B6239" />
          <circle cx="20" cy="15" r="8" fill="var(--green-600)" />
          <circle cx="13" cy="18" r="5.5" fill="var(--green-sage-500)" />
          <circle cx="27" cy="18" r="5.5" fill="var(--green-forest-700)" />
          <circle cx="16" cy="15" r="2.2" fill="var(--amber-500)" /><circle cx="24" cy="16" r="2.2" fill="var(--amber-400)" />
        </svg>
      );
    case 'rupee':
    default:
      return (
        <svg className="si" viewBox="0 0 40 40" fill="none">
          <rect x="9" y="6" width="22" height="28" rx="3" fill="var(--green-leaf-100)" stroke="var(--green-forest-700)" strokeWidth="2" />
          <path d="M20 12v13M16.5 15.5H22a2.6 2.6 0 0 1 0 5.2H17.5a2.6 2.6 0 0 0 0 5.2H23" stroke="var(--amber-saffron-600)" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      );
  }
}

// ── Role tile art ──
export function TileArt({ name }) {
  switch (name) {
    case 'house':
      return (
        <svg width="46" height="46" viewBox="0 0 48 48" fill="none">
          <path d="M8 24 L24 11 L40 24" stroke="var(--green-forest-700)" strokeWidth="2.6" strokeLinecap="round" strokeLinejoin="round" />
          <path d="M11 22v16h26V22" fill="#fff" stroke="var(--green-forest-700)" strokeWidth="2.6" strokeLinejoin="round" />
          <rect x="21" y="29" width="6" height="9" rx="1" fill="var(--green-forest-700)" />
          <path d="M24 11 L24 5" stroke="var(--green-600)" strokeWidth="2.4" strokeLinecap="round" />
          <circle cx="24" cy="4" r="3" fill="var(--green-600)" />
        </svg>
      );
    case 'worker':
      return (
        <svg width="46" height="46" viewBox="0 0 48 48" fill="none">
          <path d="M12 24a12 12 0 0 1 24 0z" fill="var(--teal-700)" />
          <rect x="10" y="24" width="28" height="4" rx="2" fill="var(--teal-500)" />
          <path d="M24 12v-4" stroke="var(--teal-700)" strokeWidth="2.4" strokeLinecap="round" />
          <circle cx="24" cy="34" r="4.5" fill="none" stroke="var(--teal-700)" strokeWidth="2.4" />
          <path d="M24 38v3M20 36l-3 2M28 36l3 2" stroke="var(--teal-700)" strokeWidth="2.4" strokeLinecap="round" />
        </svg>
      );
    case 'manager':
      return (
        <svg width="46" height="46" viewBox="0 0 48 48" fill="none">
          <path d="M24 9 L40 16 L24 23 L8 16 Z" fill="var(--amber-saffron-600)" />
          <path d="M14 19v7c0 3 5 5 10 5s10-2 10-5v-7" stroke="var(--amber-saffron-600)" strokeWidth="2.6" fill="none" strokeLinecap="round" strokeLinejoin="round" />
          <path d="M40 16v8" stroke="var(--amber-saffron-600)" strokeWidth="2.6" strokeLinecap="round" />
        </svg>
      );
    case 'business':
    default:
      return (
        <svg width="46" height="46" viewBox="0 0 48 48" fill="none">
          <path d="M10 18 L13 11 H35 L38 18 Z" fill="var(--blue-500)" />
          <path d="M10 18c0 2.5 2 4 4 4s4-1.5 4-4c0 2.5 2 4 4 4s4-1.5 4-4c0 2.5 2 4 4 4s4-1.5 4-4" stroke="var(--blue-700)" strokeWidth="2.2" fill="none" />
          <path d="M12 22v15h24V22" stroke="var(--blue-700)" strokeWidth="2.4" fill="#fff" strokeLinejoin="round" />
          <rect x="20" y="28" width="8" height="9" rx="1" fill="var(--blue-500)" />
        </svg>
      );
  }
}

// ── Zero-waste flow bubbles ──
export function FlowIcon({ name }) {
  switch (name) {
    case 'husk':
      return (
        <svg width="30" height="30" viewBox="0 0 32 32" fill="none"><path d="M16 4C9 8 6 16 9 24c4 4 10 4 14 0 3-8 0-16-7-20z" fill="#A9794C" /><path d="M16 7c-3 5-3 12 0 18M11 12c2 4 2 9 0 13M21 12c-2 4-2 9 0 13" stroke="#6E4326" strokeWidth="1.4" /></svg>
      );
    case 'coir':
      return (
        <svg width="30" height="30" viewBox="0 0 32 32" fill="none"><rect x="7" y="11" width="18" height="10" rx="5" fill="#6E4326" /><path d="M7 13c4 2 14 2 18 0M7 16c4 2 14 2 18 0M7 19c4 2 14 2 18 0" stroke="#FBDFA6" strokeWidth="1.4" /><path d="M11 11V9M21 11V9" stroke="#3a2a18" strokeWidth="2" strokeLinecap="round" /></svg>
      );
    case 'jackfruit':
      return (
        <svg width="30" height="30" viewBox="0 0 32 32" fill="none"><path d="M16 5c7 0 11 6 11 13s-5 9-11 9-11-2-11-9S9 5 16 5z" fill="var(--green-600)" /><g fill="var(--green-forest-900)"><circle cx="13" cy="13" r="1.1" /><circle cx="18" cy="12" r="1.1" /><circle cx="15" cy="17" r="1.1" /><circle cx="20" cy="17" r="1.1" /><circle cx="13" cy="21" r="1.1" /><circle cx="18" cy="22" r="1.1" /></g></svg>
      );
    case 'feed':
      return (
        <svg width="30" height="30" viewBox="0 0 32 32" fill="none"><path d="M11 7h10l-1 4 1 13c0 1.5-1.5 2-5 2s-5-.5-5-2l1-13z" fill="#fff" stroke="#6E4326" strokeWidth="1.6" strokeLinejoin="round" /><path d="M11 14h10" stroke="#6E4326" strokeWidth="1.4" /><rect x="13" y="4" width="6" height="3" rx="1" fill="#6E4326" /></svg>
      );
    case 'shell':
      return (
        <svg width="30" height="30" viewBox="0 0 32 32" fill="none"><path d="M16 6c6 0 10 5 10 11s-4 9-10 9-10-3-10-9S10 6 16 6z" fill="#6E4326" /><path d="M11 14a6 4 0 0 1 10 0z" fill="#3a2a18" /></svg>
      );
    case 'charcoal':
    default:
      return (
        <svg width="30" height="30" viewBox="0 0 32 32" fill="none"><rect x="9" y="13" width="14" height="11" rx="2" fill="#2B2A24" /><path d="M12 13l2-4h4l2 4" stroke="#3a2a18" strokeWidth="1.6" fill="none" /><path d="M14 9c0-2 1-3 2-3M18 9c0-2-1-3-2-3" stroke="var(--amber-400)" strokeWidth="1.6" strokeLinecap="round" /></svg>
      );
  }
}

export const ArrowRight = (props) => (
  <svg width="26" height="20" viewBox="0 0 26 20" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" {...props}><path d="M2 10h20M16 4l6 6-6 6" /></svg>
);
