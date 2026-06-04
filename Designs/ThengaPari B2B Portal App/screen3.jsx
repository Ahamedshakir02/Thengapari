// screen3.jsx — Pre-book (order summary, date, payment) + success

function buildDates() {
  const dow = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  const mon = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const base = new Date(2026, 5, 5); // delivery starts tomorrow (Jun 5)
  return [...Array(7)].map((_, i) => {
    const d = new Date(base); d.setDate(base.getDate() + i);
    return { dow: dow[d.getDay()], dnum: d.getDate(), mon: mon[d.getMonth()], label: i === 0 ? 'Tomorrow' : null };
  });
}

function PrebookScreen({ l, qty, onBack, onConfirm }) {
  const DATES = React.useMemo(buildDates, []);
  const [dateIdx, setDateIdx] = React.useState(0);
  const [pay, setPay] = React.useState('delivery');
  const subtotal = qty * l.price;
  const saved = Math.round(qty * (l.market - l.price));
  const delivery = 0;
  const total = subtotal + delivery;
  return (
    <React.Fragment>
      <div className="backbar">
        <button onClick={onBack}>
          <svg width="20" height="20" viewBox="0 0 20 20"><path d="M12.5 4L6.5 10l6 6" stroke="currentColor" strokeWidth="1.9" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>
          Back
        </button>
        <span className="title">Pre-book</span>
        <span style={{ width: 34 }} />
      </div>

      {/* summary */}
      <div className="card summary-card">
        <div className="summary-top">
          <div className="summary-glyph" style={{ background: CROP_TINT[l.type] }}><CropGlyph type={l.type} size={34} /></div>
          <div style={{ flex: 1 }}>
            <div className="inv-name"><span className="nm" style={{ font: 'var(--t-title)' }}>{l.name}</span><span className="grade-tag">{l.grade}</span></div>
            <div className="tp-body-sm" style={{ color: 'var(--ink-500)', marginTop: 2 }}>{l.farm.name} · {l.ward}</div>
          </div>
        </div>
        <div className="summary-div" />
        <div className="summary-line"><span className="k">Quantity</span><span className="v">{qty} {l.unit}</span></div>
        <div className="summary-line"><span className="k">Unit price (locked)</span><span className="v">₹{l.price}/{l.unit}</span></div>
        <div className="summary-line muted"><span className="k">Wholesale equivalent</span><span className="v" style={{ textDecoration: 'line-through' }}>₹{(qty * l.market).toLocaleString('en-IN')}</span></div>
        <div className="summary-line"><span className="k">Delivery</span><span className="v" style={{ color: 'var(--green-600)' }}>Free</span></div>
        <div className="summary-div" />
        <div className="summary-line"><span className="k" style={{ font: 'var(--t-title)' }}>Total</span><span className="v" style={{ font: '700 20px/1 var(--font-display)' }}>₹{total.toLocaleString('en-IN')}</span></div>
        <div className="summary-save">
          <span className="k"><svg width="16" height="16" viewBox="0 0 14 14"><path d="M7 11V3M7 3L3.5 6.5M7 3l3.5 3.5" stroke="#B6F0C9" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round" fill="none" /></svg>You're saving vs wholesale</span>
          <span className="v">₹{saved.toLocaleString('en-IN')}</span>
        </div>
      </div>

      {/* delivery date */}
      <div className="section-head" style={{ marginLeft: 18 }}><span className="t">Delivery date</span></div>
      <div className="dates">
        {DATES.map((d, i) => (
          <button key={i} className={'date-cell' + (i === dateIdx ? ' active' : '')} onClick={() => setDateIdx(i)}>
            <div className="dow">{d.dow}</div>
            <div className="dnum">{d.dnum}</div>
            <div className="mon">{d.label || d.mon}</div>
          </button>
        ))}
      </div>

      {/* payment */}
      <div className="section-head" style={{ marginLeft: 18 }}><span className="t">Payment</span></div>
      <div className="paytoggle">
        <button className={'pay-opt' + (pay === 'delivery' ? ' active' : '')} onClick={() => setPay('delivery')}>
          <span className="radio" />
          <div>
            <div className="t">Pay on delivery</div>
            <div className="s">Cash or UPI when produce arrives</div>
          </div>
          <span className="tag">No risk</span>
        </button>
        <button className={'pay-opt' + (pay === 'now' ? ' active' : '')} onClick={() => setPay('now')}>
          <span className="radio" />
          <div>
            <div className="t">Pay now · UPI</div>
            <div className="s">Lock the lot instantly</div>
          </div>
          <span className="tag" style={{ color: 'var(--blue-700)', background: 'var(--blue-100)' }}>+1% off</span>
        </button>
      </div>

      <div className="spacer-24" />
    </React.Fragment>
  );
}

function PrebookFooter({ l, qty, onConfirm }) {
  const total = qty * l.price;
  return (
    <div className="sticky-cta">
      <button className="btn-primary" onClick={onConfirm}>
        Confirm pre-book · ₹{total.toLocaleString('en-IN')}
        <svg width="18" height="18" viewBox="0 0 20 20"><path d="M4 10h11M11 5l5 5-5 5" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>
      </button>
    </div>
  );
}

function SuccessScreen({ l, qty, onDone }) {
  const saved = Math.round(qty * (l.market - l.price));
  return (
    <div className="success">
      <div className="ring">
        <div className="core">
          <svg width="32" height="32" viewBox="0 0 32 32"><path d="M9 16.5l4.5 4.5L23 11" stroke="#fff" strokeWidth="3" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>
        </div>
      </div>
      <h2>Pre-book confirmed</h2>
      <p>{qty} {l.unit} of {l.name} reserved from {l.farm.name}. Arrives tomorrow, 7–10 AM.</p>
      <div className="saved-chip">
        <div className="k">You saved on this order</div>
        <div className="v">₹{saved.toLocaleString('en-IN')}</div>
      </div>
      <button className="btn-primary" onClick={onDone} style={{ maxWidth: 280 }}>View my savings dashboard</button>
      <button className="btn-ghost" onClick={onDone} style={{ maxWidth: 280, marginTop: 12, border: 0, color: 'var(--ink-500)' }}>Back to market</button>
    </div>
  );
}

Object.assign(window, { PrebookScreen, PrebookFooter, SuccessScreen });
