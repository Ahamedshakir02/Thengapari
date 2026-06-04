// ui.jsx — shared icons + atoms for the worker app (dark teal theme)

function Icon({ name, size = 24, color = 'currentColor', sw = 2, style }) {
  const p = { width: size, height: size, viewBox: '0 0 24 24', fill: 'none',
    stroke: color, strokeWidth: sw, strokeLinecap: 'round', strokeLinejoin: 'round', style };
  switch (name) {
    case 'home': return (<svg {...p}><path d="M3 10.5 12 3l9 7.5"/><path d="M5 9.5V20h14V9.5"/><path d="M9.5 20v-6h5v6"/></svg>);
    case 'jobs': return (<svg {...p}><rect x="3" y="7" width="18" height="13" rx="2.5"/><path d="M8.5 7V5.5A1.5 1.5 0 0 1 10 4h4a1.5 1.5 0 0 1 1.5 1.5V7"/><path d="M3 12.5h18"/></svg>);
    case 'wallet': return (<svg {...p}><rect x="3" y="6" width="18" height="13" rx="3"/><path d="M3 9.5h18"/><circle cx="16.5" cy="13.5" r="1.4" fill={color} stroke="none"/></svg>);
    case 'user': return (<svg {...p}><circle cx="12" cy="8" r="3.6"/><path d="M5 20c.7-3.6 3.3-5.5 7-5.5s6.3 1.9 7 5.5"/></svg>);
    case 'pin': return (<svg {...p}><path d="M12 21s7-5.7 7-11a7 7 0 1 0-14 0c0 5.3 7 11 7 11Z"/><circle cx="12" cy="10" r="2.6"/></svg>);
    case 'clock': return (<svg {...p}><circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 1.8"/></svg>);
    case 'ruler': return (<svg {...p}><path d="M4 14 14 4l6 6L10 20 4 14Z"/><path d="M8 10l1.5 1.5M11 7l1.5 1.5M14 10l1.5 1.5"/></svg>);
    case 'coconut': return (<svg {...p} stroke="none"><circle cx="12" cy="13" r="8" fill={color}/><circle cx="9.4" cy="12" r="1.3" fill="rgba(0,0,0,.35)"/><circle cx="14.6" cy="12" r="1.3" fill="rgba(0,0,0,.35)"/><circle cx="12" cy="15.6" r="1.3" fill="rgba(0,0,0,.35)"/></svg>);
    case 'star': return (<svg {...p} fill={color} stroke="none"><path d="M12 3.5l2.55 5.17 5.7.83-4.13 4.02.98 5.68L12 16.9 6.9 19.2l.98-5.68L3.75 9.5l5.7-.83L12 3.5Z"/></svg>);
    case 'star-o': return (<svg {...p}><path d="M12 3.8l2.5 5.06 5.58.81-4.04 3.94.95 5.56L12 16.5l-4.99 2.68.95-5.56L3.92 9.67l5.58-.81L12 3.8Z"/></svg>);
    case 'phone': return (<svg {...p}><path d="M6.5 4h2.2l1.3 4-1.8 1.2a11 11 0 0 0 4.6 4.6l1.2-1.8 4 1.3v2.2a2 2 0 0 1-2.2 2A15.5 15.5 0 0 1 4.5 6.2 2 2 0 0 1 6.5 4Z"/></svg>);
    case 'nav': return (<svg {...p} fill={color} stroke="none"><path d="M12 3 21 20l-9-4-9 4 9-17Z"/></svg>);
    case 'nav-o': return (<svg {...p}><path d="M12 4.5 19.5 19l-7.5-3.3L4.5 19 12 4.5Z"/></svg>);
    case 'check': return (<svg {...p}><path d="M5 12.5l4.5 4.5L19 7.5"/></svg>);
    case 'check-c': return (<svg {...p}><circle cx="12" cy="12" r="8.5"/><path d="M8.3 12.3l2.5 2.5 4.9-5"/></svg>);
    case 'bolt': return (<svg {...p} fill={color} stroke="none"><path d="M13 2 4 14h6l-1 8 9-12h-6l1-8Z"/></svg>);
    case 'chevron': return (<svg {...p}><path d="M9 5l7 7-7 7"/></svg>);
    case 'shield': return (<svg {...p}><path d="M12 3l7 2.5V11c0 4.5-3 8-7 9.5C8 19 5 15.5 5 11V5.5L12 3Z"/><path d="M9 12l2 2 4-4"/></svg>);
    case 'route': return (<svg {...p}><circle cx="6" cy="18" r="2.2"/><circle cx="18" cy="6" r="2.2"/><path d="M8 17.5c5-.5 8-2 8-6.5"/></svg>);
    case 'leaf': return (<svg {...p}><path d="M5 19C5 11 11 5 19 5c0 8-6 14-14 14Z"/><path d="M5 19c3-5 6-8 11-10"/></svg>);
    case 'download': return (<svg {...p}><path d="M12 3.5v11"/><path d="M7.5 10.5 12 15l4.5-4.5"/><path d="M5 19.5h14"/></svg>);
    case 'calendar': return (<svg {...p}><rect x="3.5" y="5" width="17" height="15.5" rx="2.5"/><path d="M3.5 9.5h17"/><path d="M8 3.2v3.6M16 3.2v3.6"/></svg>);
    case 'doc': return (<svg {...p}><path d="M7 3.5h7l4 4v13a0 0 0 0 1 0 0H7a1.5 1.5 0 0 1-1.5-1.5V5A1.5 1.5 0 0 1 7 3.5Z"/><path d="M13.5 3.6V8h4.3"/></svg>);
    case 'gear': return (<svg {...p}><circle cx="12" cy="12" r="3.2"/><path d="M12 2.5v3M12 18.5v3M2.5 12h3M18.5 12h3M5.2 5.2l2.1 2.1M16.7 16.7l2.1 2.1M18.8 5.2l-2.1 2.1M7.3 16.7l-2.1 2.1"/></svg>);
    case 'bell': return (<svg {...p}><path d="M6 9a6 6 0 0 1 12 0c0 5 2 6 2 6H4s2-1 2-6Z"/><path d="M10 19a2 2 0 0 0 4 0"/></svg>);
    case 'help': return (<svg {...p}><circle cx="12" cy="12" r="8.5"/><path d="M9.6 9.4a2.5 2.5 0 0 1 4.6 1.3c0 1.7-2.2 2-2.2 3.3"/><circle cx="12" cy="17" r="0.6" fill={color} stroke={color}/></svg>);
    case 'logout': return (<svg {...p}><path d="M14 5.5H6.5A1.5 1.5 0 0 0 5 7v10a1.5 1.5 0 0 0 1.5 1.5H14"/><path d="M11 12h9M16.5 8.5 20 12l-3.5 3.5"/></svg>);
    case 'badge': return (<svg {...p}><path d="M12 3 19 6v5c0 4.4-2.9 7.9-7 9.4-4.1-1.5-7-5-7-9.4V6l7-3Z"/><path d="M9 11.8l2.1 2.1L15 10"/></svg>);
    case 'bank': return (<svg {...p}><path d="M4 9.5 12 4l8 5.5"/><path d="M5 9.5h14"/><path d="M6.5 10v7M10.5 10v7M13.5 10v7M17.5 10v7"/><path d="M4 20h16"/></svg>);
    case 'plus': return (<svg {...p}><path d="M12 5v14M5 12h14"/></svg>);
    case 'history': return (<svg {...p}><path d="M4 12a8 8 0 1 1 2.5 5.8"/><path d="M4 12v-4M4 12h4"/><path d="M12 8v4.2l2.8 1.6"/></svg>);
    case 'arrow-ur': return (<svg {...p}><path d="M7 17 17 7M9 7h8v8"/></svg>);
    case 'chevron-d': return (<svg {...p}><path d="M5 9l7 7 7-7"/></svg>);
    case 'edit': return (<svg {...p}><path d="M5 19h14"/><path d="M14.5 5.5l3 3M16 4l3 3-9.5 9.5-4 1 1-4L16 4Z"/></svg>);
    default: return null;
  }
}

// Rupee amount with mono numerals
function Rupee({ value, size = 28, weight = 700, color = 'var(--w-fg1)', sign = true }) {
  return (
    <span className="mono" style={{ fontSize: size, fontWeight: weight, color, letterSpacing: '-.01em', lineHeight: 1 }}>
      {sign && <span style={{ fontWeight: 600, opacity: .92 }}>₹</span>}{value}
    </span>
  );
}

// Circular reliability ring
function Ring({ value = 94, size = 92, stroke = 9, color = 'var(--w-accent)', track = 'rgba(214,236,231,0.14)', children }) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const off = c * (1 - value / 100);
  return (
    <div style={{ position: 'relative', width: size, height: size, flexShrink: 0 }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        <circle cx={size/2} cy={size/2} r={r} stroke={track} strokeWidth={stroke} fill="none"/>
        <circle cx={size/2} cy={size/2} r={r} stroke={color} strokeWidth={stroke} fill="none"
          strokeLinecap="round" strokeDasharray={c} strokeDashoffset={off}
          style={{ transition: 'stroke-dashoffset .9s cubic-bezier(.22,1,.36,1)' }}/>
      </svg>
      <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center', gap: 0 }}>
        {children}
      </div>
    </div>
  );
}

// Weekly earnings bar chart
function WeeklyChart({ data, today = 5, accent = 'var(--w-accent)', muted = 'var(--w-teal-500)' }) {
  const max = Math.max(...data.map(d => d.v), 1);
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', gap: 8, height: 116, paddingTop: 6 }}>
      {data.map((d, i) => {
        const h = Math.max(8, Math.round((d.v / max) * 96));
        const isToday = i === today;
        return (
          <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 7 }}>
            <span className="mono" style={{ fontSize: 10, color: isToday ? 'var(--w-accent-2)' : 'var(--w-fg3)', fontWeight: 600, opacity: d.v ? 1 : .4 }}>
              {d.v ? (d.v >= 1000 ? (d.v/1000).toFixed(1) + 'k' : d.v) : '—'}
            </span>
            <div style={{ width: '100%', height: h, borderRadius: 7,
              background: isToday
                ? `linear-gradient(180deg, var(--w-accent-2), ${accent})`
                : `linear-gradient(180deg, var(--w-teal-500), var(--w-glow-top))`,
              boxShadow: isToday ? '0 4px 14px rgba(244,165,42,.35)' : 'none',
              transition: 'height .6s cubic-bezier(.22,1,.36,1)' }}/>
            <span style={{ fontSize: 11, color: isToday ? 'var(--w-fg1)' : 'var(--w-fg3)', fontWeight: isToday ? 700 : 500 }}>{d.d}</span>
          </div>
        );
      })}
    </div>
  );
}

// Section heading row
function SectionHead({ lang, k, right }) {
  const { primary, secondary } = tx(lang, k);
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 14 }}>
      <div style={{ minWidth: 0 }}>
        <h3 className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ margin: 0, font: 'var(--t-h3)', color: 'var(--w-fg1)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{primary}</h3>
        {secondary && <span className={lang === 'ml' ? '' : 'ml'} style={{ display: 'block', font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 2 }}>{secondary}</span>}
      </div>
      {right && <div style={{ flexShrink: 0, paddingTop: 2 }}>{right}</div>}
    </div>
  );
}

Object.assign(window, { Icon, Rupee, Ring, WeeklyChart, SectionHead });
