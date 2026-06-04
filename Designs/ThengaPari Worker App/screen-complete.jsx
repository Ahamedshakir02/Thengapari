// screen-complete.jsx — payout confirmation, job summary, site-manager rating

function Stars({ value, onChange }) {
  const [hover, setHover] = React.useState(0);
  return (
    <div style={{ display: 'flex', gap: 8, justifyContent: 'center' }}>
      {[1, 2, 3, 4, 5].map(n => {
        const on = n <= (hover || value);
        return (
          <button key={n} onMouseEnter={() => setHover(n)} onMouseLeave={() => setHover(0)} onClick={() => onChange(n)}
            style={{ border: 'none', background: 'transparent', padding: 4, lineHeight: 0, transition: 'transform .15s',
              transform: on ? 'scale(1.08)' : 'scale(1)' }}>
            <Icon name={on ? 'star' : 'star-o'} size={40} color={on ? 'var(--w-accent)' : 'var(--w-line-strong)'} sw={1.8} />
          </button>
        );
      })}
    </div>
  );
}

function SummaryRow({ icon, label, value }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '11px 0' }}>
      <Icon name={icon} size={18} color="var(--w-teal-300)" sw={2.1} />
      <span style={{ flex: 1, font: 'var(--t-body)', color: 'var(--w-fg2)' }}>{label}</span>
      <span className="mono" style={{ font: '600 15px/1 var(--font-mono)', color: '#fff' }}>{value}</span>
    </div>
  );
}

function CompleteScreen({ lang, onDone }) {
  const [rating, setRating] = React.useState(5);
  const ratingWords = { 1: 'Poor', 2: 'Unfair', 3: 'Okay', 4: 'Good', 5: 'Excellent' };
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0,
      background: 'radial-gradient(120% 60% at 50% 0%, var(--w-glow-top) 0%, var(--w-bg) 50%, var(--w-bg-deep) 100%)' }}>
      <div style={{ flex: 1, minHeight: 0, overflow: 'auto', padding: '26px 18px 16px' }}>
        {/* success */}
        <div style={{ textAlign: 'center', marginBottom: 20 }}>
          <div style={{ width: 84, height: 84, borderRadius: '50%', margin: '0 auto 14px', animation: 'pop-in .5s cubic-bezier(.34,1.56,.64,1) both',
            background: 'radial-gradient(circle at 50% 35%, var(--w-good), #2E8E5C)', display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '0 12px 30px rgba(87,201,139,.4)' }}>
            <Icon name="check" size={44} color="#fff" sw={3.4} />
          </div>
          <h1 className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ margin: 0, font: 'var(--t-h1)', color: '#fff' }}>{tx(lang, 'complete').primary}</h1>
          <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body)', color: 'var(--w-teal-300)', marginTop: 5 }}>{tx(lang, 'paid_via').primary}</div>
        </div>

        {/* payout card */}
        <div style={{ background: 'var(--paper-0)', borderRadius: 'var(--r-xl)', padding: '20px', boxShadow: 'var(--shadow-lg)', textAlign: 'center', animation: 'ping-in .5s .1s both' }}>
          <div style={{ font: 'var(--t-overline)', color: 'var(--ink-500)', textTransform: 'uppercase', letterSpacing: '.08em' }}>{tx(lang, 'payout').primary}</div>
          <div style={{ margin: '6px 0 2px' }}><Rupee value="380" size={56} weight={800} color="var(--green-forest-700)" /></div>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 7, marginTop: 8, background: 'var(--green-leaf-50)', padding: '8px 14px', borderRadius: 999 }}>
            <Icon name="check-c" size={16} color="var(--green-600)" />
            <span style={{ font: 'var(--t-body-sm)', color: 'var(--ink-700)' }}>{tx(lang, 'paid_to').primary} <b className="mono" style={{ color: 'var(--green-forest-800)' }}>ravi@okaxis</b></span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'center', gap: 16, marginTop: 14, font: 'var(--t-caption)', color: 'var(--ink-500)' }}>
            <span>UPI ref <b className="mono" style={{ color: 'var(--ink-700)' }}>4072 1183</b></span>
            <span>·</span>
            <span className="mono">9:54 AM</span>
          </div>
        </div>

        {/* summary */}
        <div style={{ background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '4px 16px 8px', marginTop: 14, boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
          <div style={{ font: 'var(--t-overline)', color: 'var(--w-fg3)', textTransform: 'uppercase', letterSpacing: '.08em', padding: '14px 0 4px' }}>{tx(lang, 'summary').primary}</div>
          <SummaryRow icon="coconut" label="Coconut husking" value="24 nuts" />
          <div style={{ height: 1, background: 'var(--w-line)' }} />
          <SummaryRow icon="clock" label="Time on site" value="1h 28m" />
          <div style={{ height: 1, background: 'var(--w-line)' }} />
          <SummaryRow icon="pin" label="Parambil Estate" value="Ollur" />
        </div>

        {/* rating */}
        <div style={{ background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '18px 16px 20px', marginTop: 14, boxShadow: 'inset 0 0 0 1px var(--w-line)', textAlign: 'center' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, justifyContent: 'center', marginBottom: 4 }}>
            <div style={{ width: 34, height: 34, borderRadius: '50%', background: 'var(--green-leaf-100)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span className="disp" style={{ fontSize: 15, fontWeight: 700, color: 'var(--green-forest-700)' }}>A</span>
            </div>
            <span className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ font: 'var(--t-title)', color: '#fff' }}>{tx(lang, 'rate_mgr').primary}</span>
          </div>
          <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg3)', marginBottom: 14 }}>{tx(lang, 'rate_sub').primary}</div>
          <Stars value={rating} onChange={setRating} />
          <div style={{ font: '600 14px/1 var(--font-text)', color: 'var(--w-accent-2)', marginTop: 12, height: 16 }}>{rating ? ratingWords[rating] : ''}</div>
        </div>
      </div>

      {/* footer */}
      <div style={{ flexShrink: 0, padding: '12px 18px 18px', background: 'linear-gradient(180deg, color-mix(in srgb, var(--w-bg-deep) 0%, transparent), var(--w-bg-deep) 30%)' }}>
        <button onClick={() => onDone(rating)} style={{ width: '100%', height: 60, borderRadius: 'var(--r-pill)', border: 'none',
          background: '#fff', color: 'var(--w-bg)', font: '700 18px/1 var(--font-text)', boxShadow: '0 8px 24px rgba(255,255,255,.16)' }}>
          {tx(lang, 'submit_home').primary}
        </button>
      </div>
    </div>
  );
}

Object.assign(window, { CompleteScreen, Stars });
