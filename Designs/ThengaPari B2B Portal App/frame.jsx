// frame.jsx — deep-blue Android device shell + small shared UI atoms

// ── Status bar (white icons on a deep-blue strip) ──
function StatusBar({ bg }) {
  const c = '#FFFFFF';
  return (
    <div style={{
      height: 34, flex: 'none', background: bg, color: c,
      display: 'flex', alignItems: 'center', justifyContent: 'space-between',
      padding: '0 18px', position: 'relative',
      fontFamily: 'Roboto, system-ui, sans-serif',
    }}>
      <span style={{ fontSize: 13, fontWeight: 600, letterSpacing: .2 }}>9:30</span>
      <div style={{
        position: 'absolute', left: '50%', top: 9, transform: 'translateX(-50%)',
        width: 9, height: 9, borderRadius: 100, background: 'rgba(0,0,0,.35)',
      }} />
      <div style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
        <svg width="15" height="15" viewBox="0 0 16 16"><path d="M1 11h2v3H1zM5 8h2v6H5zM9 5h2v9H9zM13 2h2v12h-2z" fill={c} /></svg>
        <svg width="15" height="15" viewBox="0 0 16 16"><path d="M8 13.3L.67 5.97a10.37 10.37 0 0114.66 0L8 13.3z" fill={c} /></svg>
        <svg width="16" height="15" viewBox="0 0 18 16"><rect x="1" y="4" width="13" height="8" rx="2" fill="none" stroke={c} strokeWidth="1.4" /><rect x="2.5" y="5.5" width="9" height="5" rx="1" fill={c} /><rect x="15" y="6.5" width="1.6" height="3" rx="0.8" fill={c} /></svg>
      </div>
    </div>
  );
}

// ── Gesture nav pill ──
function NavBar({ bg, pill }) {
  return (
    <div style={{ height: 22, flex: 'none', background: bg, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ width: 108, height: 4, borderRadius: 2, background: pill || 'rgba(43,42,36,.4)' }} />
    </div>
  );
}

// ── Device shell ──
function Phone({ children, footer, statusBg = 'var(--blue-900)', navBg = 'var(--paper-100)', navPill }) {
  return (
    <div className="phone">
      <StatusBar bg={statusBg} />
      <div className="phone-scroll">{children}</div>
      {footer}
      <NavBar bg={navBg} pill={navPill} />
    </div>
  );
}

// ── Shared atoms ──
function SaveBadge({ pct, size = 'md' }) {
  return (
    <span className={'save-badge ' + (size === 'sm' ? 'save-badge--sm' : '')}>
      <svg width="11" height="11" viewBox="0 0 12 12" aria-hidden="true"><path d="M6 10V3M6 10L2.5 6.5M6 10l3.5-3.5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" fill="none" /></svg>
      {pct}% vs market
    </span>
  );
}

function Money({ value, unit, className }) {
  return (
    <span className={className}>
      <span className="rupee">₹</span>{value}{unit ? <span className="per">/{unit}</span> : null}
    </span>
  );
}

// Mini sparkline-free bar used in several places
function Bar({ pct, color, track, h = 10, r = 6 }) {
  return (
    <div style={{ height: h, borderRadius: r, background: track || 'var(--mist-200)', overflow: 'hidden', flex: 1 }}>
      <div style={{ width: pct + '%', height: '100%', borderRadius: r, background: color }} />
    </div>
  );
}

Object.assign(window, { Phone, StatusBar, NavBar, SaveBadge, Money, Bar });
