// app-charts.jsx — lightweight SVG/CSS charts: weekly bars (3 styles),
// grade donut, live-weight dial. All driven by design-system tokens.

// Weekly earnings bar chart. style: 'leaf' | 'forest' | 'line'
function BarChart({ data, lang, style = 'leaf', animate = true }) {
  const max = Math.max(...data.map((d) => d.v));
  const [shown, setShown] = React.useState(!animate);
  // Use setTimeout (not rAF): rAF never fires in throttled/non-painting
  // contexts (offscreen iframe, screenshot, PDF/PPTX export), which would
  // freeze every bar at the 4% pre-animation height. setTimeout still fires,
  // so the resting state always reaches full height.
  React.useEffect(() => { const id = setTimeout(() => setShown(true), 60); return () => clearTimeout(id); }, []);

  if (style === 'line') {
    const W = 320, H = 116, pad = 14;
    const xs = (i) => pad + (i * (W - pad * 2)) / (data.length - 1);
    const ys = (v) => H - 18 - (v / max) * (H - 34);
    const pts = data.map((d, i) => [xs(i), ys(d.v)]);
    const path = pts.map((p, i) => (i ? 'L' : 'M') + p[0] + ' ' + p[1]).join(' ');
    const area = path + ` L${xs(data.length - 1)} ${H - 14} L${xs(0)} ${H - 14} Z`;
    const peak = pts[data.length - 1];
    return (
      <div className="linechart">
        <svg viewBox={`0 0 ${W} ${H}`} width="100%" height="116" preserveAspectRatio="none">
          <defs><linearGradient id="lcfill" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor="var(--green-sage-500)" stopOpacity=".22"/>
            <stop offset="1" stopColor="var(--green-sage-500)" stopOpacity="0"/>
          </linearGradient></defs>
          <path d={area} fill="url(#lcfill)" style={{ opacity: shown ? 1 : 0, transition: 'opacity .6s' }}/>
          <path d={path} fill="none" stroke="var(--brand)" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"
            style={{ strokeDasharray: 600, strokeDashoffset: shown ? 0 : 600, transition: 'stroke-dashoffset 1s ease' }}/>
          {pts.map((pt, i) => (
            <circle key={i} cx={pt[0]} cy={pt[1]} r={i === data.length - 1 ? 5 : 3}
              fill={i === data.length - 1 ? 'var(--accent)' : 'var(--surface)'}
              stroke={i === data.length - 1 ? 'var(--accent)' : 'var(--brand)'} strokeWidth="2"
              style={{ opacity: shown ? 1 : 0, transition: `opacity .4s ${0.3 + i * 0.06}s` }}/>
          ))}
          <text x={peak[0]} y={peak[1] - 11} textAnchor="middle" fontSize="11" fontWeight="700" fill="var(--brand-ink)"
            style={{ fontFamily: 'var(--font-text)', opacity: shown ? 1 : 0, transition: 'opacity .5s .8s' }}>₹{data[data.length-1].v}</text>
        </svg>
        <div className="row" style={{ justifyContent: 'space-between', padding: '6px 12px 0' }}>
          {data.map((d, i) => <span key={i} className="bar-label">{d.d[lang === 'ml' ? 'ml' : 'en']}</span>)}
        </div>
      </div>
    );
  }

  const barColor = style === 'forest' ? 'var(--brand)' : 'var(--green-leaf-300)';
  return (
    <div className="bars">
      {data.map((d, i) => {
        const h = shown ? Math.max(8, (d.v / max) * 100) : 4;
        return (
          <div key={i} className={'bar-col' + (d.peak ? ' is-peak' : '')}>
            <div className="bar-track">
              <div className="bar" style={{ height: h + '%', background: d.peak ? 'var(--accent)' : barColor,
                transitionDelay: (i * 0.06) + 's' }}>
                {d.peak && <span className="bar-val">₹{d.v}</span>}
              </div>
            </div>
            <span className="bar-label">{d.d[lang === 'ml' ? 'ml' : 'en']}</span>
          </div>
        );
      })}
    </div>
  );
}

// Donut chart for grade breakdown. segs: [{label, value, color}]
function Donut({ segs, size = 150, thick = 22, animate = true }) {
  const total = segs.reduce((s, x) => s + x.value, 0);
  const r = (size - thick) / 2;
  const c = 2 * Math.PI * r;
  const [shown, setShown] = React.useState(!animate);
  React.useEffect(() => { const id = setTimeout(() => setShown(true), 60); return () => clearTimeout(id); }, []);
  let acc = 0;
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} aria-hidden="true"
      style={{ transform: 'rotate(-90deg)' }}>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="var(--mist-200)" strokeWidth={thick}/>
      {segs.map((s, i) => {
        const frac = s.value / total;
        const len = shown ? frac * c : 0;
        const off = -acc * c;
        acc += frac;
        return (
          <circle key={i} cx={size/2} cy={size/2} r={r} fill="none"
            stroke={s.color} strokeWidth={thick} strokeLinecap="round"
            strokeDasharray={`${len} ${c}`} strokeDashoffset={off}
            style={{ transition: `stroke-dasharray 1s cubic-bezier(.22,.61,.36,1) ${i * 0.18}s` }}/>
        );
      })}
    </svg>
  );
}

// Live-weight circular dial (0..1 fill)
function WeightDial({ pct, size = 76 }) {
  const thick = 8, r = (size - thick) / 2, c = 2 * Math.PI * r;
  const [shown, setShown] = React.useState(false);
  React.useEffect(() => { const id = setTimeout(() => setShown(true), 80); return () => clearTimeout(id); }, []);
  return (
    <svg width={size} height={size} viewBox={`0 0 ${size} ${size}`} style={{ transform: 'rotate(-90deg)' }} aria-hidden="true">
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="var(--green-leaf-100)" strokeWidth={thick}/>
      <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="var(--accent)" strokeWidth={thick} strokeLinecap="round"
        strokeDasharray={`${(shown ? pct : 0) * c} ${c}`}
        style={{ transition: 'stroke-dasharray 1.1s cubic-bezier(.22,.61,.36,1)' }}/>
    </svg>
  );
}

Object.assign(window, { BarChart, Donut, WeightDial });
