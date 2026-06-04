// screen-ping.jsx — full-screen dark teal job ping: radar, detail card, live countdown

function Radar({ style = 'sweep', dist = '1.8 km' }) {
  const rings = [250, 188, 126, 66];
  // job dot position (≈ -40° from center, between ring 2 and 3)
  const cx = 130, cy = 130, jx = cx + 54, jy = cy - 46;
  return (
    <div style={{ position: 'relative', height: 196, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
      <div style={{ position: 'relative', width: 260, height: 260, transform: 'scale(.78)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        {rings.map((d, i) => (
          <div key={i} style={{ position: 'absolute', width: d, height: d, borderRadius: '50%',
            border: `1px solid rgba(111,182,171,${0.34 - i * 0.06})` }} />
        ))}
        {/* axes */}
        <div style={{ position: 'absolute', width: 250, height: 1, background: 'rgba(111,182,171,.12)' }} />
        <div style={{ position: 'absolute', width: 1, height: 250, background: 'rgba(111,182,171,.12)' }} />

        {style === 'sweep' && (
          <div style={{ position: 'absolute', width: 250, height: 250, borderRadius: '50%',
            background: 'conic-gradient(from 0deg, rgba(244,165,42,0) 0deg, rgba(244,165,42,0) 296deg, rgba(244,165,42,.10) 330deg, rgba(244,165,42,.42) 360deg)',
            animation: 'radar-spin 3.6s linear infinite',
            WebkitMaskImage: 'radial-gradient(circle, #000 26%, transparent 72%)',
            maskImage: 'radial-gradient(circle, #000 26%, transparent 72%)' }} />
        )}
        {style === 'sonar' && [0, 1, 2].map(i => (
          <div key={i} style={{ position: 'absolute', width: 250, height: 250, borderRadius: '50%',
            border: '2px solid rgba(244,165,42,.45)', animation: 'sonar 3s ease-out infinite', animationDelay: `${i}s` }} />
        ))}

        {/* worker (center) */}
        <div style={{ position: 'absolute', left: cx, top: cy, transform: 'translate(-50%,-50%)', zIndex: 4 }}>
          <div style={{ width: 16, height: 16, borderRadius: '50%', background: '#fff', boxShadow: '0 0 0 5px rgba(255,255,255,.14)' }} />
        </div>

        {/* job (amber pulsing dot) */}
        <div style={{ position: 'absolute', left: jx, top: jy, transform: 'translate(-50%,-50%)', zIndex: 5 }}>
          <div style={{ position: 'absolute', left: '50%', top: '50%', width: 34, height: 34, transform: 'translate(-50%,-50%)',
            borderRadius: '50%', border: '2px solid var(--w-accent)', animation: 'job-ring 2s ease-out infinite' }} />
          <div style={{ width: 20, height: 20, borderRadius: '50%', background: 'var(--w-accent)',
            boxShadow: '0 0 16px 4px rgba(244,165,42,.7)', animation: 'job-pulse 1.4s ease-in-out infinite',
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Icon name="coconut" size={12} color="#5A3206" />
          </div>
        </div>
        {/* dist chip */}
        <div className="mono" style={{ position: 'absolute', left: jx + 16, top: jy - 30, zIndex: 6,
          font: '700 12px/1 var(--font-mono)', color: 'var(--w-accent-2)', background: 'rgba(8,51,47,.85)',
          padding: '4px 8px', borderRadius: 999, boxShadow: 'inset 0 0 0 1px rgba(244,165,42,.4)', whiteSpace: 'nowrap' }}>{dist}</div>
      </div>
    </div>
  );
}

function Fact({ icon, value, label }) {
  return (
    <div style={{ flex: 1, textAlign: 'center' }}>
      <Icon name={icon} size={18} color="var(--brand)" sw={2.1} style={{ margin: '0 auto 6px', display: 'block' }} />
      <div style={{ font: '700 16px/1.1 var(--font-text)', color: 'var(--ink-900)' }}>{value}</div>
      <div style={{ font: 'var(--t-caption)', color: 'var(--ink-500)', marginTop: 3 }}>{label}</div>
    </div>
  );
}

function PingScreen({ lang, duration = 38, radarStyle = 'sweep', onAccept, onDecline, onExpire }) {
  const [left, setLeft] = React.useState(duration);
  React.useEffect(() => {
    if (left <= 0) { onExpire && onExpire(); return; }
    const id = setTimeout(() => setLeft(l => l - 1), 1000);
    return () => clearTimeout(id);
  }, [left]);

  const ratio = left / duration;
  const urgent = left <= 10;
  const cdColor = ratio > 0.5 ? 'var(--w-good)' : ratio > 0.26 ? 'var(--w-accent-2)' : 'var(--w-bad)';

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0,
      background: 'radial-gradient(120% 70% at 50% 0%, var(--w-glow-top) 0%, var(--w-bg) 52%, var(--w-bg-deep) 100%)' }}>
      <div style={{ flex: 1, minHeight: 0, overflow: 'auto', display: 'flex', flexDirection: 'column', padding: '14px 18px 0' }}>
        {/* header */}
        <div className="ping-in" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9, marginBottom: 2 }}>
          <span style={{ position: 'relative', width: 9, height: 9 }}>
            <span style={{ position: 'absolute', inset: 0, borderRadius: '50%', background: 'var(--w-accent)' }} />
            <span className="pulse-dot" style={{ position: 'absolute', inset: 0, borderRadius: '50%', background: 'var(--w-accent)' }} />
          </span>
          <span style={{ font: 'var(--t-overline)', color: 'var(--w-accent-2)', textTransform: 'uppercase', letterSpacing: '.14em', fontSize: 12.5 }}>
            {tx(lang, 'newping').primary} · 1.8 km away
          </span>
        </div>

        <div className="ping-in" style={{ animationDelay: '.05s' }}><Radar style={radarStyle} /></div>

        {/* title */}
        <div className="ping-in" style={{ textAlign: 'center', animationDelay: '.1s', marginBottom: 16, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
          <h1 className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ margin: 0, font: '700 26px/32px var(--font-display)', color: '#fff', letterSpacing: '-.01em', whiteSpace: 'nowrap' }}>
            {tx(lang, 'husking').primary}
          </h1>
          {lang !== 'en' && <div className={lang === 'ml' ? '' : 'ml'} style={{ font: '500 15px/1.5 var(--font-text)', color: 'var(--w-teal-300)' }}>{lang === 'ml' ? STR.husking.en : STR.husking.ml}</div>}
        </div>

        {/* white detail card */}
        <div className="ping-in" style={{ animationDelay: '.15s', background: 'var(--paper-0)', borderRadius: 'var(--r-xl)', padding: '18px 18px 16px', boxShadow: 'var(--shadow-lg)' }}>
          <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between' }}>
            <div>
              <div style={{ font: 'var(--t-overline)', color: 'var(--ink-500)', textTransform: 'uppercase', letterSpacing: '.08em' }}>{tx(lang, 'payout').primary}</div>
              <div style={{ display: 'flex', alignItems: 'baseline', gap: 1, marginTop: 2 }}>
                <Rupee value="380" size={42} weight={800} color="var(--amber-saffron-600)" />
              </div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <span style={{ font: '600 12px/1.4 var(--font-text)', color: 'var(--green-600)', background: 'var(--status-complete-bg)', padding: '5px 10px', borderRadius: 999 }}>≈ ₹16 / coconut</span>
            </div>
          </div>

          <div style={{ height: 1, background: 'var(--mist-200)', margin: '15px -2px' }} />

          <div style={{ display: 'flex', gap: 4 }}>
            <Fact icon="clock" value="~1.5 h" label={tx(lang, 'duration').primary} />
            <div style={{ width: 1, background: 'var(--mist-200)' }} />
            <Fact icon="nav-o" value="1.8 km" label={tx(lang, 'distance').primary} />
            <div style={{ width: 1, background: 'var(--mist-200)' }} />
            <Fact icon="coconut" value="24" label={tx(lang, 'crop').primary} />
          </div>

          <div style={{ height: 1, background: 'var(--mist-200)', margin: '15px -2px' }} />

          {/* manager */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 42, height: 42, borderRadius: '50%', background: 'var(--green-leaf-100)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <span className="disp" style={{ fontSize: 18, fontWeight: 700, color: 'var(--green-forest-700)' }}>A</span>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <div style={{ font: 'var(--t-title)', color: 'var(--ink-900)' }}>Arjun K.</div>
              <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 1 }}>
                <Icon name="star" size={13} color="var(--amber-500)" />
                <span className="mono" style={{ font: '600 13px/1 var(--font-mono)', color: 'var(--ink-700)' }}>4.9</span>
                <span style={{ font: 'var(--t-caption)', color: 'var(--ink-500)' }}>· {tx(lang, 'manager').primary}</span>
              </div>
            </div>
            <div style={{ width: 42, height: 42, borderRadius: '50%', background: 'var(--green-leaf-50)', boxShadow: 'inset 0 0 0 1px var(--mist-200)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
              <Icon name="phone" size={18} color="var(--green-forest-700)" />
            </div>
          </div>
        </div>

        {/* countdown */}
        <div className="ping-in" style={{ animationDelay: '.2s', display: 'flex', alignItems: 'center', gap: 14, padding: '16px 4px 10px' }}>
          <div style={{ flex: 1 }}>
            <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', textTransform: 'uppercase', letterSpacing: '.08em', marginBottom: 8 }}>{tx(lang, 'respond_in').primary}</div>
            <div style={{ height: 8, borderRadius: 999, background: 'rgba(214,236,231,.14)', overflow: 'hidden' }}>
              <div style={{ height: '100%', width: `${Math.max(0, ratio * 100)}%`, background: cdColor, borderRadius: 999, transition: 'width 1s linear, background .4s' }} />
            </div>
          </div>
          <div className="mono" style={{ font: '800 38px/1 var(--font-mono)', color: cdColor, minWidth: 64, textAlign: 'right',
            transition: 'color .4s', animation: urgent ? 'job-pulse 1s ease-in-out infinite' : 'none' }}>
            {left}<span style={{ fontSize: 18, fontWeight: 600, opacity: .7 }}>s</span>
          </div>
        </div>
      </div>

      {/* buttons */}
      <div style={{ flexShrink: 0, display: 'grid', gridTemplateColumns: '1fr 1.5fr', gap: 12, padding: '12px 18px 18px',
        background: 'linear-gradient(180deg, color-mix(in srgb, var(--w-bg-deep) 0%, transparent) 0%, var(--w-bg-deep) 28%)' }}>
        <button onClick={onDecline} style={{ height: 60, borderRadius: 'var(--r-pill)', border: '1.5px solid var(--w-line-strong)',
          background: 'transparent', color: 'var(--w-fg2)', font: '600 17px/1 var(--font-text)' }}>
          {tx(lang, 'decline').primary}
        </button>
        <button onClick={onAccept} style={{ height: 60, borderRadius: 'var(--r-pill)', border: 'none',
          background: '#fff', color: 'var(--w-bg)', font: '700 18px/1 var(--font-text)', boxShadow: '0 8px 24px rgba(255,255,255,.18)',
          display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9 }}>
          <Icon name="check" size={20} color="var(--w-teal-500)" sw={3} />
          {tx(lang, 'accept').primary}
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { PingScreen, Radar });
