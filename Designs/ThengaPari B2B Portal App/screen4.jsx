// screen4.jsx — Business savings dashboard

function LineChart({ data, labels }) {
  const W = 330, H = 130, pad = 8, base = H - 22;
  const max = Math.max(...data) * 1.15, min = Math.min(...data) * 0.85;
  const x = i => pad + i * ((W - pad * 2) / (data.length - 1));
  const y = v => 14 + (base - 14) * (1 - (v - min) / (max - min));
  const pts = data.map((v, i) => [x(i), y(v)]);
  const path = pts.map((p, i) => (i ? 'L' : 'M') + p[0].toFixed(1) + ' ' + p[1].toFixed(1)).join(' ');
  const area = path + ` L${x(data.length - 1).toFixed(1)} ${base} L${x(0).toFixed(1)} ${base} Z`;
  const [grow, setGrow] = React.useState(false);
  React.useEffect(() => { const t = setTimeout(() => setGrow(true), 150); return () => clearTimeout(t); }, []);
  return (
    <svg viewBox={`0 0 ${W} ${H}`} style={{ width: '100%', height: 'auto', display: 'block' }}>
      <defs>
        <linearGradient id="lc" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#2A5F8F" stopOpacity=".22" />
          <stop offset="1" stopColor="#2A5F8F" stopOpacity="0" />
        </linearGradient>
      </defs>
      {[0, 1, 2].map(g => <line key={g} x1={pad} x2={W - pad} y1={14 + g * ((base - 14) / 2)} y2={14 + g * ((base - 14) / 2)} stroke="var(--border)" strokeWidth="1" strokeDasharray="3 4" />)}
      <path d={area} fill="url(#lc)" style={{ opacity: grow ? 1 : 0, transition: 'opacity .9s' }} />
      <path d={path} fill="none" stroke="var(--blue-500)" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"
        style={{ strokeDasharray: 700, strokeDashoffset: grow ? 0 : 700, transition: 'stroke-dashoffset 1.1s ease' }} />
      {pts.map((p, i) => (
        <g key={i} style={{ opacity: grow ? 1 : 0, transition: 'opacity .5s ' + (i * 0.08 + 0.4) + 's' }}>
          <circle cx={p[0]} cy={p[1]} r={i === pts.length - 1 ? 5 : 3.2} fill={i === pts.length - 1 ? 'var(--blue-700)' : '#fff'} stroke="var(--blue-500)" strokeWidth="2" />
        </g>
      ))}
      {labels.map((lb, i) => <text key={i} x={x(i)} y={H - 4} textAnchor="middle" fontSize="10" fontWeight="600" fill="var(--ink-400)" fontFamily="var(--font-text)">{lb}</text>)}
    </svg>
  );
}

const MONTH_SAVINGS = [
  { type: 'coconut', name: 'Coconut', amt: 720, pct: 14 },
  { type: 'mango', name: 'Mango', amt: 560, pct: 10 },
  { type: 'jackfruit', name: 'Jackfruit', amt: 480, pct: 20 },
  { type: 'banana', name: 'Banana', amt: 240, pct: 9 },
  { type: 'pepper', name: 'Pepper', amt: 140, pct: 8 },
];

const STANDING = [
  { type: 'coconut', name: 'Coconut · Grade A', qty: '150 pc / week', freq: 'Weekly', next: 'Next: Jun 8' },
  { type: 'banana', name: 'Nendran Banana', qty: '60 kg / week', freq: 'Weekly', next: 'Next: Jun 7' },
  { type: 'mango', name: 'Alphonso Mango', qty: '40 kg / fortnight', freq: 'Biweekly', next: 'Next: Jun 15' },
];

function DashSavingsChart() {
  const max = Math.max(...MONTH_SAVINGS.map(c => c.amt));
  const [shown, setShown] = React.useState(false);
  React.useEffect(() => { const t = setTimeout(() => setShown(true), 120); return () => clearTimeout(t); }, []);
  return (
    <div className="card savechart" style={{ paddingBottom: 10 }}>
      {MONTH_SAVINGS.map(c => (
        <div className="row" key={c.type}>
          <div className="glyph" style={{ background: CROP_TINT[c.type] }}><CropGlyph type={c.type} size={22} /></div>
          <div className="nm">{c.name}</div>
          <div className="track"><div className="fill" style={{ width: shown ? (c.amt / max * 100) + '%' : 0 }} /></div>
          <div className="pct" style={{ width: 52, color: 'var(--green-600)' }}>₹{c.amt}</div>
        </div>
      ))}
    </div>
  );
}

function DashboardScreen({ savings }) {
  const spend = [4200, 3600, 5100, 4400, 3900, 5300];
  const weeks = ['Apr W2', 'W3', 'W4', 'May W1', 'W2', 'W3'];
  return (
    <React.Fragment>
      <div className="dash-hero">
        <div className="appbar-row" style={{ marginBottom: 10 }}>
          <div style={{ flex: 1 }}>
            <div className="lbl">Saravana Juice Stall · this month</div>
          </div>
          <button className="icon-btn" aria-label="Settings"><svg width="18" height="18" viewBox="0 0 20 20"><circle cx="10" cy="10" r="3" stroke="currentColor" strokeWidth="1.7" fill="none" /><path d="M10 2v2M10 16v2M2 10h2M16 10h2M4.2 4.2l1.4 1.4M14.4 14.4l1.4 1.4M15.8 4.2l-1.4 1.4M5.6 14.4l-1.4 1.4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" /></svg></button>
        </div>
        <div className="lbl">Total saved vs wholesale</div>
        <div className="big"><span className="rupee">₹</span>{savings.amount.toLocaleString('en-IN')}</div>
        <span className="delta">
          <svg width="13" height="13" viewBox="0 0 14 14"><path d="M7 11V3M7 3L3.5 6.5M7 3l3.5 3.5" stroke="#B6F0C9" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" fill="none" /></svg>
          ₹480 more than last month
        </span>
      </div>

      <div className="dash-stats">
        <div className="dash-stat"><div className="v">{savings.orders}</div><div className="k">Pre-books</div></div>
        <div className="dash-stat"><div className="v">{savings.pctAvg}%</div><div className="k">Avg savings</div></div>
        <div className="dash-stat"><div className="v">₹26.4k</div><div className="k">Total spend</div></div>
      </div>

      <div className="section-head"><span className="t">Savings by crop · this month</span></div>
      <div className="section"><DashSavingsChart /></div>

      <div className="section-head"><span className="t">Weekly spend trend</span><span className="a" style={{ color: 'var(--green-600)' }}>↓ 8% vs Apr</span></div>
      <div className="section">
        <div className="card" style={{ padding: '14px 10px 6px' }}>
          <LineChart data={spend} labels={weeks} />
        </div>
      </div>

      <div className="section-head"><span className="t">Standing orders</span><span className="a">Manage</span></div>
      <div className="section">
        <div className="card">
          {STANDING.map((s, i) => (
            <div className="standing" key={i}>
              <div className="glyph" style={{ background: CROP_TINT[s.type] }}><CropGlyph type={s.type} size={26} /></div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div className="nm">{s.name}</div>
                <div className="meta">{s.qty}</div>
              </div>
              <div className="freq">
                <span className="f">{s.freq}</span>
                <div className="nx">{s.next}</div>
              </div>
            </div>
          ))}
          <div className="standing" style={{ justifyContent: 'center', color: 'var(--blue-700)', fontWeight: 700, cursor: 'pointer' }}>
            <svg width="18" height="18" viewBox="0 0 20 20"><path d="M10 4v12M4 10h12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" /></svg>
            New standing order
          </div>
        </div>
      </div>
      <div className="spacer-24" />
    </React.Fragment>
  );
}

Object.assign(window, { DashboardScreen });
