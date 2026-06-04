// screen1.jsx — Live produce inventory (market)

function SavingsBand({ amount = 2140, pctAvg = 13, orders = 18 }) {
  return (
    <div className="savings-band">
      <svg className="leaf" width="120" height="120" viewBox="0 0 120 120" aria-hidden="true">
        <path d="M60 110C40 90 30 60 60 20c30 40 20 70 0 90Z" fill="#fff" />
        <path d="M60 102V40" stroke="#146C3A" strokeWidth="3" />
      </svg>
      <div className="lbl">Your savings vs wholesale · this month</div>
      <div className="amt"><span className="rupee">₹</span>{amount.toLocaleString('en-IN')}<span style={{ font: '600 15px/1 var(--font-text)', opacity: .85, alignSelf: 'center' }}>saved</span></div>
      <div className="delta">
        <svg width="14" height="14" viewBox="0 0 14 14"><path d="M7 11V3M7 3L3.5 6.5M7 3l3.5 3.5" stroke="#B6F0C9" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round" fill="none" /></svg>
        Avg {pctAvg}% below market across {orders} pre-books
      </div>
      <div className="foot">
        <span className="k">Best deal today</span>
        <span className="v">Jackfruit · 20% off</span>
      </div>
    </div>
  );
}

function SavingsChart() {
  const max = Math.max(...SAVINGS_BY_CROP.map(c => c.pct));
  const [shown, setShown] = React.useState(false);
  React.useEffect(() => { const t = setTimeout(() => setShown(true), 120); return () => clearTimeout(t); }, []);
  return (
    <div className="card savechart">
      {SAVINGS_BY_CROP.map(c => (
        <div className="row" key={c.type}>
          <div className="glyph" style={{ background: CROP_TINT[c.type] }}><CropGlyph type={c.type} size={22} /></div>
          <div className="nm">{c.name}</div>
          <div className="track"><div className="fill" style={{ width: shown ? (c.pct / max * 100) + '%' : 0 }} /></div>
          <div className="pct">{c.pct}%</div>
        </div>
      ))}
    </div>
  );
}

const FILTERS = {
  crop: ['All crops', 'Coconut', 'Mango', 'Pepper', 'Jackfruit'],
  grade: ['Any grade', 'Grade A', 'Grade B'],
  dist: ['Any distance', '< 5 km', '< 10 km'],
};

function FilterChips() {
  const [crop, setCrop] = React.useState(0);
  const [grade, setGrade] = React.useState(0);
  const [dist, setDist] = React.useState(0);
  const cyc = (v, set, arr) => set((v + 1) % arr.length);
  const Chip = ({ icon, val, active, onClick }) => (
    <button className={'chip' + (active ? ' active' : '')} onClick={onClick}>
      {icon}{val}
      <svg width="12" height="12" viewBox="0 0 12 12"><path d="M3 4.5L6 7.5L9 4.5" stroke="currentColor" strokeWidth="1.5" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>
    </button>
  );
  return (
    <div className="chips">
      <Chip val={FILTERS.crop[crop]} active={crop !== 0} onClick={() => cyc(crop, setCrop, FILTERS.crop)}
        icon={<svg width="14" height="14" viewBox="0 0 14 14"><circle cx="7" cy="7" r="5" stroke="currentColor" strokeWidth="1.4" fill="none" /></svg>} />
      <Chip val={FILTERS.grade[grade]} active={grade !== 0} onClick={() => cyc(grade, setGrade, FILTERS.grade)}
        icon={<svg width="14" height="14" viewBox="0 0 14 14"><path d="M7 1.5l1.6 3.3 3.6.5-2.6 2.5.6 3.6L7 9.7 3.8 11.4l.6-3.6L1.8 5.3l3.6-.5z" stroke="currentColor" strokeWidth="1.2" fill="none" strokeLinejoin="round" /></svg>} />
      <Chip val={FILTERS.dist[dist]} active={dist !== 0} onClick={() => cyc(dist, setDist, FILTERS.dist)}
        icon={<svg width="14" height="14" viewBox="0 0 14 14"><path d="M7 1.5c2.5 0 4.5 2 4.5 4.4C11.5 9 7 12.5 7 12.5S2.5 9 2.5 5.9C2.5 3.5 4.5 1.5 7 1.5z" stroke="currentColor" strokeWidth="1.3" fill="none" /><circle cx="7" cy="5.9" r="1.5" fill="currentColor" /></svg>} />
    </div>
  );
}

function InventoryRow({ l, onOpen }) {
  return (
    <div className="inv-row" onClick={onOpen}>
      <div className="inv-glyph" style={{ background: CROP_TINT[l.type] }}><CropGlyph type={l.type} size={32} /></div>
      <div className="inv-main">
        <div className="inv-name">
          <span className="nm">{l.name}</span>
          <span className="grade-tag">{l.grade}</span>
        </div>
        <div className="inv-meta">
          <span>{l.harvest}</span><span className="dot" />
          <span>{l.ward}</span>
        </div>
        <div className="inv-meta" style={{ marginTop: 5 }}>
          <SaveBadge pct={l.save} size="sm" />
          <span style={{ color: 'var(--ink-400)' }}>· {l.qty}</span>
        </div>
      </div>
      <div className="inv-right">
        <div style={{ textAlign: 'right' }}>
          <Money value={l.price} unit={l.unit} className="price-lg" />
          <div className="mkt-strike">₹{l.market}/{l.unit}</div>
        </div>
        <button className="btn-prebook" onClick={(e) => { e.stopPropagation(); onOpen(); }}>Pre-book</button>
      </div>
    </div>
  );
}

function MarketScreen({ onOpen, savings, showChart = true }) {
  return (
    <React.Fragment>
      <div className="appbar">
        <div className="appbar-row">
          <div style={{ flex: 1 }}>
            <div className="eyebrow"><span className="live-dot" />Live produce inventory</div>
            <h1>Today's harvest</h1>
            <div className="sub">Manjaly &amp; nearby wards · updated 2 min ago</div>
          </div>
          <button className="icon-btn" aria-label="Search">
            <svg width="19" height="19" viewBox="0 0 20 20"><circle cx="9" cy="9" r="6" stroke="currentColor" strokeWidth="1.7" fill="none" /><path d="M13.5 13.5L17 17" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" /></svg>
          </button>
        </div>
      </div>

      <SavingsBand amount={savings.amount} pctAvg={savings.pctAvg} orders={savings.orders} />

      {showChart && (
        <React.Fragment>
          <div className="section-head"><span className="t">Savings by crop</span><span className="a">This week</span></div>
          <div className="section"><SavingsChart /></div>
        </React.Fragment>
      )}

      <div style={{ height: 14 }} />
      <FilterChips />

      <div className="section-head"><span className="t">Available now · {LISTINGS.length} lots</span><span className="a">Sort: Best savings</span></div>
      <div className="section">
        <div className="card">
          {LISTINGS.map(l => <InventoryRow key={l.id} l={l} onOpen={() => onOpen(l.id)} />)}
        </div>
      </div>
      <div className="spacer-24" />
    </React.Fragment>
  );
}

Object.assign(window, { MarketScreen });
