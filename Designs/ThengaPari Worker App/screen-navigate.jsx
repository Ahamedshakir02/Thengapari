// screen-navigate.jsx — live map, ETA banner, "I've arrived"

const ROUTE_D = "M170 612 C 142 566 198 528 150 478 C 110 436 120 388 196 348 C 268 310 300 250 246 196 C 224 174 232 158 250 150";

function MapBg() {
  // soft "plot" blocks
  const blocks = [
    { x: 16, y: 200, w: 96, h: 78 }, { x: 250, y: 250, w: 120, h: 90 },
    { x: 30, y: 360, w: 80, h: 70 }, { x: 210, y: 430, w: 150, h: 110 },
    { x: 40, y: 520, w: 90, h: 80 }, { x: 270, y: 110, w: 100, h: 70 },
    { x: 130, y: 250, w: 60, h: 60 },
  ];
  return (
    <svg viewBox="0 0 390 720" preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0, width: '100%', height: '100%' }}>
      <defs>
        <path id="route" d={ROUTE_D} />
        <filter id="glow"><feGaussianBlur stdDeviation="6" /></filter>
      </defs>
      <rect x="0" y="0" width="390" height="720" fill="#05231F" />
      {/* plots / groves */}
      {blocks.map((b, i) => (
        <g key={i}>
          <rect x={b.x} y={b.y} width={b.w} height={b.h} rx="12" fill={i % 2 ? '#0A3C36' : '#0B423B'} stroke="rgba(111,182,171,.10)" />
          <circle cx={b.x + 16} cy={b.y + 16} r="2.4" fill="rgba(111,182,171,.4)" />
          <circle cx={b.x + 30} cy={b.y + 22} r="2.4" fill="rgba(111,182,171,.3)" />
          <circle cx={b.x + 22} cy={b.y + 30} r="2.4" fill="rgba(111,182,171,.25)" />
        </g>
      ))}
      {/* roads */}
      <g stroke="#0E4A43" strokeWidth="14" strokeLinecap="round" fill="none">
        <path d="M-10 470 H400" /><path d="M120 730 V300" /><path d="M-10 150 H400" /><path d="M-10 610 L400 430" />
      </g>
      <g stroke="#0F564D" strokeWidth="3" strokeDasharray="2 10" strokeLinecap="round" fill="none" opacity=".6">
        <path d="M-10 470 H400" /><path d="M120 730 V300" /><path d="M-10 150 H400" />
      </g>

      {/* route glow + line */}
      <path d={ROUTE_D} stroke="rgba(244,165,42,.35)" strokeWidth="13" fill="none" strokeLinecap="round" filter="url(#glow)" />
      <path d={ROUTE_D} stroke="var(--w-accent)" strokeWidth="5.5" fill="none" strokeLinecap="round" />
      <path d={ROUTE_D} stroke="#fff" strokeWidth="2" strokeDasharray="2 14" fill="none" strokeLinecap="round" opacity=".85" />

      {/* destination pin */}
      <g transform="translate(250 150)">
        <path d="M0 6 C 16 6 24 -6 24 -16 A 24 24 0 1 0 -24 -16 C -24 -6 -16 6 0 6 Z" transform="translate(0 -22)" fill="var(--w-accent)" />
        <circle cx="0" cy="-38" r="11" fill="#5A3206" />
        <circle cx="-3.5" cy="-40" r="1.8" fill="#F4A52A" /><circle cx="3.5" cy="-40" r="1.8" fill="#F4A52A" /><circle cx="0" cy="-34" r="1.8" fill="#F4A52A" />
      </g>

      {/* moving worker marker along route */}
      <g>
        <circle r="9" fill="#fff" stroke="var(--w-teal-500)" strokeWidth="3">
          <animateMotion dur="6s" repeatCount="indefinite" rotate="auto" keyPoints="0;0.62" keyTimes="0;1" calcMode="linear">
            <mpath href="#route" />
          </animateMotion>
        </circle>
      </g>
    </svg>
  );
}

function NavigateScreen({ lang, onArrived, onBack }) {
  return (
    <div style={{ height: '100%', position: 'relative', overflow: 'hidden', background: '#05231F' }}>
      <MapBg />
      {/* top scrim */}
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, height: 160, background: 'linear-gradient(180deg, rgba(5,35,31,.85), rgba(5,35,31,0))', pointerEvents: 'none' }} />

      {/* back */}
      <button onClick={onBack} style={{ position: 'absolute', top: 14, left: 14, width: 42, height: 42, borderRadius: '50%',
        border: 'none', background: 'rgba(6,41,37,.7)', backdropFilter: 'blur(8px)', boxShadow: 'inset 0 0 0 1px var(--w-line)',
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name="chevron" size={22} color="#fff" style={{ transform: 'scaleX(-1)' }} />
      </button>

      {/* ETA banner */}
      <div className="ping-in" style={{ position: 'absolute', top: 14, left: 66, right: 14, borderRadius: 'var(--r-lg)',
        background: 'rgba(8,51,47,.86)', backdropFilter: 'blur(14px)', boxShadow: 'var(--shadow-lg), inset 0 0 0 1px rgba(111,182,171,.22)',
        padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 42, height: 42, borderRadius: 12, background: 'rgba(244,165,42,.16)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name="nav" size={20} color="var(--w-accent-2)" />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 8 }}>
            <span className="mono" style={{ font: '800 22px/1 var(--font-mono)', color: '#fff' }}>12<span style={{ fontSize: 14, fontWeight: 600, opacity: .8 }}> min</span></span>
            <span className="mono" style={{ font: '600 13px/1 var(--font-mono)', color: 'var(--w-teal-300)' }}>· 1.8 km</span>
          </div>
          <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 4 }}>
            {tx(lang, 'arrive_by').primary} <b style={{ color: 'var(--w-teal-100)' }}>9:42 AM</b>
          </div>
        </div>
        <button style={{ width: 44, height: 44, borderRadius: '50%', border: 'none', background: 'var(--w-teal-500)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name="phone" size={19} color="#fff" />
        </button>
      </div>

      {/* bottom sheet */}
      <div className="ping-in" style={{ position: 'absolute', left: 0, right: 0, bottom: 0, animationDelay: '.1s',
        background: 'linear-gradient(180deg, rgba(8,51,47,.6) 0%, #07302B 22%)', backdropFilter: 'blur(6px)',
        borderTopLeftRadius: 'var(--r-xl)', borderTopRightRadius: 'var(--r-xl)', padding: '14px 18px 20px', boxShadow: '0 -14px 36px rgba(0,0,0,.4)' }}>
        <div style={{ width: 44, height: 5, borderRadius: 999, background: 'var(--w-line-strong)', margin: '0 auto 14px' }} />
        <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 16 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: 'var(--w-surface)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Icon name="leaf" size={21} color="var(--w-teal-300)" />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ font: 'var(--t-title)', color: '#fff' }}>{tx(lang, 'head_to').primary}</div>
            <div style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg2)', marginTop: 2 }}>Parambil Estate · Ollur, Thrissur</div>
          </div>
        </div>
        <button onClick={onArrived} style={{ width: '100%', height: 62, borderRadius: 'var(--r-pill)', border: 'none',
          background: 'linear-gradient(135deg, var(--w-accent-2), var(--w-accent))', color: 'var(--green-forest-900)',
          font: '700 19px/1 var(--font-text)', boxShadow: '0 10px 28px rgba(244,165,42,.4)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 10 }}>
          <Icon name="pin" size={21} color="var(--green-forest-900)" sw={2.4} />
          {tx(lang, 'arrived').primary}
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { NavigateScreen, MapBg });
