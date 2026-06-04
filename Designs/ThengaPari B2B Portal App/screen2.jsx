// screen2.jsx — Listing detail

function PriceCompare({ l }) {
  const [shown, setShown] = React.useState(false);
  React.useEffect(() => { const t = setTimeout(() => setShown(true), 150); return () => clearTimeout(t); }, [l.id]);
  const maxv = l.market;
  const platW = shown ? (l.price / maxv * 100) : 0;
  const mktW = shown ? 100 : 0;
  const savePer = (l.market - l.price).toFixed(1);
  return (
    <div className="cmp">
      <div className="bar-row">
        <div className="bar-top">
          <span className="bar-lbl"><span className="swatch" style={{ background: 'var(--green-600)' }} />ThengaPari price</span>
          <span className="bar-val" style={{ color: 'var(--green-600)' }}>₹{l.price}/{l.unit}</span>
        </div>
        <div className="bar-track"><div className="bar-fill" style={{ width: platW + '%', background: 'linear-gradient(90deg,var(--green-sage-500),var(--green-600))' }} /></div>
      </div>
      <div className="bar-row">
        <div className="bar-top">
          <span className="bar-lbl"><span className="swatch" style={{ background: 'var(--ink-400)' }} />Wholesale market</span>
          <span className="bar-val" style={{ color: 'var(--ink-700)' }}>₹{l.market}/{l.unit}</span>
        </div>
        <div className="bar-track"><div className="bar-fill" style={{ width: mktW + '%', background: 'var(--ink-400)' }} /></div>
      </div>
      <div className="save-callout">
        <span className="k">You save ₹{savePer} on every {l.unit}</span>
        <span className="v">{l.save}% off</span>
      </div>
    </div>
  );
}

function DetailScreen({ l, onBack, onPrebook, qty, setQty }) {
  const step = l.unit === 'kg' ? 5 : 10;
  return (
    <React.Fragment>
      <div className="backbar">
        <button onClick={onBack}>
          <svg width="20" height="20" viewBox="0 0 20 20"><path d="M12.5 4L6.5 10l6 6" stroke="currentColor" strokeWidth="1.9" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>
          Back
        </button>
        <span className="title">Listing</span>
        <button aria-label="Save"><svg width="20" height="20" viewBox="0 0 20 20"><path d="M5 3h10v14l-5-3.2L5 17z" stroke="currentColor" strokeWidth="1.7" fill="none" strokeLinejoin="round" /></svg></button>
      </div>

      {/* hero */}
      <div className="hero" style={{ background: 'radial-gradient(circle at 50% 40%, ' + CROP_TINT[l.type] + ', var(--paper-50))' }}>
        <div className="glyph-xl"><CropGlyph type={l.type} size={120} /></div>
        <div className="fresh-pill"><span className="leaf-dot" />Harvested {l.hours}h ago · peak freshness</div>
      </div>

      <div className="detail-body">
        <div className="detail-title">
          <div>
            <h2>{l.name}</h2>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginTop: 5 }}>
              <span className="grade-tag">{l.grade}</span>
              <span className="tp-body-sm" style={{ color: 'var(--ink-500)' }}>{l.variety}</span>
            </div>
          </div>
          <SaveBadge pct={l.save} />
        </div>

        <div style={{ height: 16 }} />
        <div className="info-grid">
          <div className="cell"><div className="k">Available</div><div className="v">{l.qty}</div></div>
          <div className="cell"><div className="k">Distance</div><div className="v">{l.dist} km · {l.ward}</div></div>
          <div className="cell"><div className="k">Condition</div><div className="v">{l.moisture}</div></div>
          <div className="cell"><div className="k">Harvest</div><div className="v">{l.harvest}</div></div>
        </div>
      </div>

      <div className="section-head" style={{ marginLeft: 18 }}><span className="t">Price comparison</span></div>
      <div className="section"><div className="card"><PriceCompare l={l} /></div></div>

      <div className="section-head" style={{ marginLeft: 18 }}><span className="t">Farm source</span><span className="a">View profile</span></div>
      <div className="section">
        <div className="card">
          <div className="farm">
            <div className="ava">{l.farm.name.split(' ').map(w => w[0]).join('').slice(0, 2)}</div>
            <div style={{ flex: 1 }}>
              <div className="nm">{l.farm.name}</div>
              <div className="meta">{l.farm.plot} · farming since {l.farm.since}</div>
            </div>
            <div style={{ textAlign: 'right' }}>
              <div className="star"><svg width="14" height="14" viewBox="0 0 14 14"><path d="M7 1.5l1.6 3.3 3.6.5-2.6 2.5.6 3.6L7 9.7 3.8 11.4l.6-3.6L1.8 5.3l3.6-.5z" fill="currentColor" /></svg>{l.farm.rating}</div>
              <div className="tp-caption" style={{ marginTop: 3 }}>{l.farm.harvests} harvests</div>
            </div>
          </div>
        </div>
      </div>

      <div className="section-head" style={{ marginLeft: 18 }}><span className="t">Quantity</span></div>
      <div className="section">
        <div className="card" style={{ padding: '16px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div className="qty">
            <button onClick={() => setQty(Math.max(step, qty - step))}>−</button>
            <div>
              <div className="val">{qty}</div>
              <div className="un" style={{ textAlign: 'center' }}>{l.unit === 'kg' ? 'kilograms' : 'pieces'}</div>
            </div>
            <button onClick={() => setQty(qty + step)}>+</button>
          </div>
          <div style={{ textAlign: 'right' }}>
            <div className="tp-caption">Subtotal</div>
            <div className="price-lg" style={{ fontSize: 22 }}><span className="rupee">₹</span>{(qty * l.price).toLocaleString('en-IN')}</div>
            <div className="tp-caption" style={{ color: 'var(--green-600)', fontWeight: 700 }}>save ₹{Math.round(qty * (l.market - l.price)).toLocaleString('en-IN')}</div>
          </div>
        </div>
      </div>

      {/* price lock banner */}
      <div className="lock">
        <div className="ico"><svg width="18" height="18" viewBox="0 0 20 20"><rect x="4" y="9" width="12" height="8" rx="2" fill="currentColor" /><path d="M6.5 9V7a3.5 3.5 0 0 1 7 0v2" stroke="currentColor" strokeWidth="1.8" fill="none" /></svg></div>
        <div className="t">This <b>₹{l.price}/{l.unit}</b> price is locked for <b>24 hours</b> when you pre-book — no surge, no broker markup.</div>
      </div>

      <div className="spacer-24" />
    </React.Fragment>
  );
}

Object.assign(window, { DetailScreen });
