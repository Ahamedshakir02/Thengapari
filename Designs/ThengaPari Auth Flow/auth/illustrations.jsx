// illustrations.jsx — ThengaPari onboarding illustrations
// Flat-geometric (matches the design-system Kerala landscape) with an
// optional `painterly` treatment: a gentle edge-wobble displacement filter +
// gradient fills + soft shadow, so the same geometry reads looser/hand-painted.
// Exports (to window): IlloIncome, IlloFlow, IlloReport, IlloDefs
const { useId } = React;

// Shared palette (from design tokens)
const C = {
  sky0: '#FDF3DD', sky1: '#F1F6E9',
  hill1: '#BCD6A3', hill2: '#94B97F', grass: '#6E9E5E', grassHi: '#7FAE6A',
  forest: '#1E4D2B', forest2: '#2E6B3E', forest3: '#357A47', deep: '#15331F', sage: '#256038',
  trunk: '#8B6239', trunkHi: '#A9794C', trunkDk: '#6E4326',
  sun: '#F4A52A', sun2: '#FBDFA6', saffron: '#E89318', amber: '#FBBA4D', amberPale: '#FCEBCB',
  roof: '#C8603A', roof2: '#A94F2E', wall: '#FEFCF6',
  ink: '#2B2A24', ink2: '#4A4840', mist: '#C9C5B6',
  paper: '#FFFFFF', paper2: '#FBF8F1', leaf: '#E6EFD9', leaf2: '#CFE0BC',
};

// Per-instance defs: sky gradient + painterly filter. Unique ids via prefix.
function IlloDefs({ p, painterly }) {
  return (
    <defs>
      <linearGradient id={`${p}-sky`} x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stopColor={C.sky0} />
        <stop offset="1" stopColor={C.sky1} />
      </linearGradient>
      <radialGradient id={`${p}-sun`} cx="0.5" cy="0.5" r="0.5">
        <stop offset="0" stopColor="#FFD37A" />
        <stop offset="1" stopColor={C.sun} />
      </radialGradient>
      <linearGradient id={`${p}-leaf`} x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stopColor={C.forest3} />
        <stop offset="1" stopColor={C.forest} />
      </linearGradient>
      <filter id={`${p}-paint`} x="-6%" y="-6%" width="112%" height="112%">
        <feTurbulence type="fractalNoise" baseFrequency="0.013 0.018" numOctaves="2" seed="7" result="n" />
        <feDisplacementMap in="SourceGraphic" in2="n" scale={painterly ? 6 : 0} xChannelSelector="R" yChannelSelector="G" />
      </filter>
      <filter id={`${p}-soft`} x="-20%" y="-20%" width="140%" height="140%">
        <feDropShadow dx="0" dy="6" stdDeviation="7" floodColor="#1E4D2B" floodOpacity={painterly ? 0.16 : 0} />
      </filter>
    </defs>
  );
}

function Frame({ p, painterly, children, vb = '0 0 340 300' }) {
  return (
    <svg viewBox={vb} fill="none" xmlns="http://www.w3.org/2000/svg" role="img">
      <IlloDefs p={p} painterly={painterly} />
      <g filter={`url(#${p}-soft)`}>
        <g filter={`url(#${p}-paint)`}>{children}</g>
      </g>
    </svg>
  );
}

const skyFill = (p, painterly) => (painterly ? `url(#${p}-sky)` : C.sky1);
const leafFill = (p, painterly, solid) => (painterly ? `url(#${p}-leaf)` : solid);

// A reusable coconut palm (origin at trunk base x,y; scale s)
function Palm({ p, painterly, x, y, s = 1, climber = false }) {
  return (
    <g transform={`translate(${x} ${y}) scale(${s})`}>
      {/* curved trunk */}
      <path d="M-7 0 C-12 -40 -10 -78 4 -110 L16 -106 C2 -76 0 -40 7 0 Z" fill={C.trunk} />
      <path d="M-3 -8 C-6 -40 -5 -72 6 -100" stroke={C.trunkDk} strokeWidth="2.4" fill="none" opacity=".5" />
      {/* coconuts */}
      <circle cx="2" cy="-112" r="7" fill={C.trunkDk} />
      <circle cx="16" cy="-110" r="7" fill={C.trunkDk} />
      <circle cx="9" cy="-120" r="6.5" fill="#7A4A2B" />
      {/* fronds */}
      <g fill={leafFill(p, painterly, C.forest)}>
        <path d="M9 -118 C-34 -132 -74 -120 -100 -92 C-62 -100 -22 -110 9 -116 Z" />
        <path d="M9 -118 C52 -132 92 -120 118 -92 C80 -100 40 -110 9 -116 Z" />
      </g>
      <g fill={leafFill(p, painterly, C.forest2)}>
        <path d="M9 -120 C-22 -156 -52 -180 -54 -214 C-30 -186 0 -154 12 -122 Z" />
        <path d="M9 -120 C40 -156 70 -180 72 -214 C48 -186 18 -154 6 -122 Z" />
        <path d="M9 -120 C-12 -150 -42 -168 -72 -170 C-44 -150 -14 -132 10 -124 Z" />
        <path d="M9 -120 C30 -150 60 -168 90 -170 C62 -150 32 -132 8 -124 Z" />
      </g>
      {climber && (
        <g transform="translate(-2 -58)">
          {/* simple climber figure hugging the trunk */}
          <circle cx="0" cy="-8" r="6.5" fill={C.ink2} />
          <path d="M-5 -2 q5 -3 10 0 l-1 18 q-4 3 -8 0 Z" fill={C.forest2} />
          <path d="M5 2 q10 -6 14 -18 M-5 2 q-9 -5 -12 -16" stroke={C.ink2} strokeWidth="3" strokeLinecap="round" />
          <path d="M3 16 q9 6 11 18 M-3 16 q-8 6 -10 18" stroke={C.ink2} strokeWidth="3" strokeLinecap="round" />
        </g>
      )}
    </g>
  );
}

function Ground({ p, painterly, y = 250 }) {
  return (
    <g>
      <path d={`M-10 ${y} Q120 ${y-26} 250 ${y-8} T360 ${y-12} L360 300 L-10 300 Z`} fill={C.hill1} />
      <path d={`M-10 ${y+18} Q160 ${y-6} 320 ${y+14} T360 ${y+8} L360 300 L-10 300 Z`} fill={C.hill2} />
      <rect x="-10" y={y+34} width="360" height={300-(y+34)} fill={C.grass} />
    </g>
  );
}

// Coin with rupee mark
function Coin({ x, y, r = 15, rot = 0 }) {
  return (
    <g transform={`translate(${x} ${y}) rotate(${rot})`}>
      <circle r={r} fill={C.sun} />
      <circle r={r} fill="none" stroke={C.saffron} strokeWidth="2.4" />
      <circle r={r-5} fill="none" stroke={C.saffron} strokeWidth="1.4" opacity=".7" />
      <path d={`M${-r*0.32} ${-r*0.42} h${r*0.62} M${-r*0.32} ${-r*0.08} h${r*0.62} M${-r*0.16} ${-r*0.42} c${r*0.5} 0 ${r*0.5} ${r*0.46} 0 ${r*0.46} h${-r*0.16} l${r*0.5} ${r*0.5}`}
        stroke={C.roof2} strokeWidth="2.2" fill="none" strokeLinecap="round" strokeLinejoin="round" />
    </g>
  );
}

// ============ Slide 1 — Turn backyard trees into income ============
function IlloIncome({ painterly = false }) {
  const p = useId().replace(/:/g, '');
  return (
    <Frame p={p} painterly={painterly}>
      <rect x="-10" y="-10" width="360" height="320" fill="none" />
      {/* sun + birds */}
      <circle cx="285" cy="62" r="30" fill={C.sun2} />
      <circle cx="285" cy="62" r="20" fill={painterly ? `url(#${p}-sun)` : C.sun} />
      <path d="M52 64 q7 -7 14 0 q7 -7 14 0" stroke={C.ink2} strokeWidth="2.6" strokeLinecap="round" fill="none" />
      <path d="M92 50 q5 -5 10 0 q5 -5 10 0" stroke={C.ink2} strokeWidth="2.6" strokeLinecap="round" fill="none" />

      <Ground p={p} painterly={painterly} y={246} />

      {/* mango tree (right) */}
      <g transform="translate(244 248)">
        <rect x="-7" y="-66" width="14" height="70" rx="6" fill={C.trunk} />
        <path d="M0 -30 l-20 -14 M0 -46 l22 -14" stroke={C.trunk} strokeWidth="7" strokeLinecap="round" />
        <circle cx="0" cy="-92" r="46" fill={C.forest2} />
        <circle cx="-34" cy="-70" r="32" fill={C.forest3} />
        <circle cx="34" cy="-72" r="33" fill={C.sage} />
        <circle cx="0" cy="-96" r="34" fill={C.forest3} />
        {/* mangoes */}
        <ellipse cx="-26" cy="-66" rx="7" ry="9.5" fill={C.sun} />
        <ellipse cx="28" cy="-58" rx="7" ry="9.5" fill={C.amber} />
        <ellipse cx="2" cy="-50" rx="7" ry="9.5" fill={C.saffron} />
        <ellipse cx="-4" cy="-104" rx="6.5" ry="9" fill={C.amber} />
      </g>

      {/* coconut palm (left) */}
      <Palm p={p} painterly={painterly} x={92} y={248} s={1.04} />

      {/* small basket of coconuts at base */}
      <g transform="translate(150 258)">
        <path d="M-26 -2 L26 -2 L20 22 L-20 22 Z" fill={C.trunkHi} />
        <path d="M-26 -2 L26 -2 L24 6 L-24 6 Z" fill={C.trunk} />
        <circle cx="-9" cy="-7" r="9" fill="#7A4A2B" />
        <circle cx="9" cy="-8" r="9" fill={C.trunkDk} />
        <circle cx="0" cy="-13" r="8.5" fill="#85542F" />
      </g>

      {/* floating coins → income */}
      <Coin x={206} y={150} r={17} rot={-8} />
      <Coin x={238} y={186} r={13} rot={10} />
      <Coin x={186} y={118} r={11} rot={6} />
    </Frame>
  );
}

// ============ Slide 2 — Same-day harvest, zero coordination ============
function IlloFlow({ painterly = false }) {
  const p = useId().replace(/:/g, '');
  const dash = painterly ? '1 11' : '2 10';
  return (
    <Frame p={p} painterly={painterly}>
      {/* dotted connector path book → crew → done */}
      <path d="M70 120 C110 88 150 88 170 150 C190 212 230 212 270 176"
        stroke={C.sage} strokeWidth="3.4" strokeLinecap="round" strokeDasharray={dash} fill="none" opacity=".75" />

      {/* STATION 1 — book (phone + calendar) */}
      <g transform="translate(70 120)">
        <circle r="46" fill={C.leaf} />
        <rect x="-20" y="-30" width="40" height="60" rx="8" fill={C.paper} stroke={C.forest2} strokeWidth="2.5" />
        <rect x="-20" y="-30" width="40" height="15" rx="8" fill={C.forest2} />
        <rect x="-20" y="-22" width="40" height="7" fill={C.forest2} />
        {/* calendar grid */}
        <g fill={C.sage}>
          <rect x="-13" y="-7" width="7" height="7" rx="1.5" /><rect x="-3.5" y="-7" width="7" height="7" rx="1.5" /><rect x="6" y="-7" width="7" height="7" rx="1.5" />
          <rect x="-13" y="3" width="7" height="7" rx="1.5" />
          <rect x="-3.5" y="3" width="7" height="7" rx="1.5" fill={C.sun} />
          <rect x="6" y="3" width="7" height="7" rx="1.5" />
          <rect x="-13" y="13" width="7" height="7" rx="1.5" /><rect x="-3.5" y="13" width="7" height="7" rx="1.5" />
        </g>
        <circle cx="26" cy="-26" r="13" fill={C.sun} />
        <path d="M21 -26 l3.5 3.5 L31 -30" stroke="#fff" strokeWidth="2.6" fill="none" strokeLinecap="round" strokeLinejoin="round" />
      </g>

      {/* STATION 2 — crew arrives (palm + climber + auto) */}
      <g transform="translate(170 150)">
        <circle r="52" fill={C.leaf2} />
        <g transform="translate(-2 30) scale(0.62)">
          <Palm p={p} painterly={painterly} x={0} y={0} s={1} climber />
        </g>
        {/* tiny three-wheeler auto */}
        <g transform="translate(20 24)">
          <path d="M-22 0 q2 -16 16 -16 l8 0 q9 0 11 8 l3 8 Z" fill={C.sun} />
          <path d="M-22 0 l38 0 0 6 -38 0 Z" fill={C.saffron} />
          <rect x="-13" y="-13" width="11" height="9" rx="2" fill={C.leaf} />
          <circle cx="-12" cy="8" r="6" fill={C.ink2} /><circle cx="-12" cy="8" r="2.4" fill={C.mist} />
          <circle cx="12" cy="8" r="6" fill={C.ink2} /><circle cx="12" cy="8" r="2.4" fill={C.mist} />
        </g>
      </g>

      {/* STATION 3 — done (check badge + coconut) */}
      <g transform="translate(270 176)">
        <circle r="44" fill={C.leaf} />
        <circle r="30" fill={C.forest2} />
        <circle r="30" fill="none" stroke={C.forest} strokeWidth="2" opacity=".5" />
        <path d="M-13 1 l9 10 L16 -11" stroke="#fff" strokeWidth="5.5" fill="none" strokeLinecap="round" strokeLinejoin="round" />
        {/* sparkle */}
        <path d="M30 -30 l2 7 7 2 -7 2 -2 7 -2 -7 -7 -2 7 -2 Z" fill={C.sun} />
      </g>
    </Frame>
  );
}

// ============ Slide 3 — Get paid, get a clear report ============
function IlloReport({ painterly = false }) {
  const p = useId().replace(/:/g, '');
  return (
    <Frame p={p} painterly={painterly}>
      {/* soft halo */}
      <circle cx="170" cy="138" r="116" fill={C.leaf} opacity=".6" />

      {/* report card (tilted) */}
      <g transform="translate(120 56) rotate(-5)">
        <rect x="0" y="0" width="150" height="178" rx="14" fill={C.paper} stroke={C.mist} strokeWidth="1.5" />
        {/* header band */}
        <path d="M0 14 a14 14 0 0 1 14 -14 h122 a14 14 0 0 1 14 14 v22 h-150 Z" fill={C.forest2} />
        <circle cx="22" cy="18" r="9" fill={C.sun} />
        <path d="M18 18 l3 3 5 -6" stroke="#fff" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" />
        <rect x="38" y="13" width="64" height="6" rx="3" fill="#fff" opacity=".95" />
        <rect x="38" y="24" width="40" height="5" rx="2.5" fill="#fff" opacity=".55" />
        {/* line items */}
        <g>
          <rect x="16" y="52" width="58" height="6" rx="3" fill={C.ink2} opacity=".7" />
          <rect x="104" y="52" width="30" height="6" rx="3" fill={C.mist} />
          <rect x="16" y="70" width="48" height="6" rx="3" fill={C.mist} />
          <rect x="104" y="70" width="30" height="6" rx="3" fill={C.mist} />
          <rect x="16" y="88" width="54" height="6" rx="3" fill={C.mist} />
          <rect x="104" y="88" width="30" height="6" rx="3" fill={C.mist} />
        </g>
        {/* weight chip */}
        <g transform="translate(16 108)">
          <rect width="62" height="24" rx="12" fill={C.leaf} />
          <text x="31" y="16" textAnchor="middle" fontFamily="Noto Sans, sans-serif" fontWeight="700" fontSize="12" fill={C.forest}>148 kg</text>
        </g>
        {/* total */}
        <line x1="16" y1="146" x2="134" y2="146" stroke={C.mist} strokeWidth="1.5" strokeDasharray="3 4" />
        <text x="16" y="168" fontFamily="Noto Sans, sans-serif" fontWeight="600" fontSize="11" fill={C.ink2}>Total paid</text>
        <text x="134" y="170" textAnchor="end" fontFamily="Baloo Chettan 2, Noto Sans, sans-serif" fontWeight="800" fontSize="20" fill={C.forest}>₹4,260</text>
      </g>

      {/* UPI / paid badge overlapping */}
      <g transform="translate(232 178)">
        <circle r="38" fill={C.sun} />
        <circle r="38" fill="none" stroke={C.saffron} strokeWidth="2.5" opacity=".6" />
        <path d="M-15 2 l10 11 L18 -13" stroke="#fff" strokeWidth="6" fill="none" strokeLinecap="round" strokeLinejoin="round" />
        <text x="0" y="30" textAnchor="middle" fontFamily="Noto Sans, sans-serif" fontWeight="800" fontSize="11" fill={C.roof2}>PAID</text>
      </g>

      {/* coins stack bottom-left */}
      <Coin x={86} y={236} r={18} rot={-6} />
      <Coin x={116} y={250} r={14} rot={8} />
    </Frame>
  );
}

Object.assign(window, { IlloIncome, IlloFlow, IlloReport, IlloDefs });
