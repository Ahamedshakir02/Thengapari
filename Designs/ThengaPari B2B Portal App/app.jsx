// app.jsx — navigation, footers, tabs, tweaks

const SAVINGS = { amount: 2140, pctAvg: 13, orders: 18 };

const ACCENTS = {
  amber: { '--accent': 'var(--amber-500)', '--on-accent': 'var(--green-forest-900)' },
  blue:  { '--accent': 'var(--blue-700)',  '--on-accent': '#ffffff' },
  green: { '--accent': 'var(--green-600)',  '--on-accent': '#ffffff' },
};

const BAND_STYLES = {
  money:  'linear-gradient(135deg, #1F8A4D 0%, #146C3A 100%)',
  brand:  'linear-gradient(135deg, var(--blue-500) 0%, var(--blue-900) 100%)',
  saffron:'linear-gradient(135deg, var(--amber-500) 0%, var(--amber-saffron-600) 100%)',
};

const TAB_DEF = [
  { id: 'market', label: 'Market', icon: (a) => <svg width="22" height="22" viewBox="0 0 24 24"><path d="M4 9l1-4h14l1 4M4 9v10a1 1 0 001 1h14a1 1 0 001-1V9M4 9h16M9 9v3a3 3 0 006 0V9" stroke="currentColor" strokeWidth={a ? 2 : 1.6} fill="none" strokeLinejoin="round" /></svg> },
  { id: 'orders', label: 'Orders', icon: (a) => <svg width="22" height="22" viewBox="0 0 24 24"><rect x="5" y="3.5" width="14" height="17" rx="2.5" stroke="currentColor" strokeWidth={a ? 2 : 1.6} fill="none" /><path d="M9 8.5h6M9 12h6M9 15.5h3.5" stroke="currentColor" strokeWidth={a ? 2 : 1.6} strokeLinecap="round" /></svg> },
  { id: 'dashboard', label: 'Savings', icon: (a) => <svg width="22" height="22" viewBox="0 0 24 24"><path d="M4 20V10M9.5 20V5M15 20v-7M20.5 20V8" stroke="currentColor" strokeWidth={a ? 2.4 : 1.8} strokeLinecap="round" /></svg> },
];

function TabBar({ tab, onTab }) {
  return (
    <div className="tabbar">
      {TAB_DEF.map(t => (
        <button key={t.id} className={'tab' + (tab === t.id ? ' active' : '')} onClick={() => onTab(t.id)}>
          <span className="ico-wrap">{t.icon(tab === t.id)}</span>
          <span className="lbl">{t.label}</span>
        </button>
      ))}
    </div>
  );
}

function OrdersScreen({ onTab }) {
  return (
    <React.Fragment>
      <div className="appbar"><div className="appbar-row"><div style={{ flex: 1 }}><div className="eyebrow">Upcoming</div><h1>My pre-books</h1></div></div></div>
      <div className="section" style={{ marginTop: 16 }}>
        <div className="card">
          {LISTINGS.slice(0, 3).map((l, i) => {
            const qty = l.unit === 'kg' ? 40 : 150;
            return (
              <div className="standing" key={l.id}>
                <div className="glyph" style={{ background: CROP_TINT[l.type] }}><CropGlyph type={l.type} size={26} /></div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div className="nm" style={{ font: 'var(--t-title)' }}>{l.name}</div>
                  <div className="meta">{qty} {l.unit} · {l.farm.name}</div>
                </div>
                <div className="freq">
                  <span className="f" style={{ background: 'var(--status-scheduled-bg)', color: 'var(--status-scheduled-fg)' }}>{i === 0 ? 'Tomorrow' : 'Booked'}</span>
                  <div className="nx" style={{ color: 'var(--green-600)', fontWeight: 700 }}>saved ₹{Math.round(qty * (l.market - l.price))}</div>
                </div>
              </div>
            );
          })}
        </div>
      </div>
      <div className="spacer-24" />
    </React.Fragment>
  );
}

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const [tab, setTab] = React.useState('market');
  const [detailId, setDetailId] = React.useState(null);
  const [prebookId, setPrebookId] = React.useState(null);
  const [success, setSuccess] = React.useState(false);
  const [qty, setQty] = React.useState(150);

  const listing = LISTINGS.find(l => l.id === (prebookId || detailId)) || LISTINGS[0];

  const openDetail = (id) => {
    const l = LISTINGS.find(x => x.id === id);
    setQty(l.unit === 'kg' ? 40 : 150);
    setDetailId(id);
    document.querySelector('.phone-scroll')?.scrollTo(0, 0);
  };
  const goPrebook = () => { setPrebookId(detailId); scrollTop(); };
  const confirm = () => { setSuccess(true); };
  const finish = (dest) => { setSuccess(false); setPrebookId(null); setDetailId(null); setTab(dest); };
  const backFromDetail = () => { setDetailId(null); };
  const backFromPrebook = () => { setPrebookId(null); scrollTop(); };
  function scrollTop() { setTimeout(() => document.querySelector('.phone-scroll')?.scrollTo(0, 0), 0); }

  // resolve current view + footer
  let view, footer, navBg = 'var(--paper-100)';
  if (success) {
    view = <SuccessScreen l={listing} qty={qty} onDone={() => finish('dashboard')} />;
    navBg = 'var(--paper-0)';
  } else if (prebookId) {
    view = <PrebookScreen l={listing} qty={qty} onBack={backFromPrebook} />;
    footer = <PrebookFooter l={listing} qty={qty} onConfirm={confirm} />;
    navBg = 'var(--paper-0)';
  } else if (detailId) {
    view = <DetailScreen l={listing} qty={qty} setQty={setQty} onBack={backFromDetail} onPrebook={goPrebook} />;
    footer = (
      <div className="sticky-cta">
        <div className="cta-row">
          <div>
            <div className="total-lbl">Total · {qty} {listing.unit}</div>
            <div className="total-val">₹{(qty * listing.price).toLocaleString('en-IN')}</div>
          </div>
          <button className="btn-primary" onClick={goPrebook}>Pre-book this lot</button>
        </div>
      </div>
    );
    navBg = 'var(--paper-0)';
  } else if (tab === 'dashboard') {
    view = <DashboardScreen savings={SAVINGS} />;
    footer = <TabBar tab={tab} onTab={setTab} />;
    navBg = 'var(--paper-0)';
  } else if (tab === 'orders') {
    view = <OrdersScreen onTab={setTab} />;
    footer = <TabBar tab={tab} onTab={setTab} />;
    navBg = 'var(--paper-0)';
  } else {
    view = <MarketScreen savings={SAVINGS} onOpen={openDetail} showChart={t.showChart} />;
    footer = <TabBar tab={tab} onTab={setTab} />;
    navBg = 'var(--paper-0)';
  }

  // apply tweaks: accent + band color via CSS vars on the wrapper
  const styleVars = { ...ACCENTS[t.accent], '--band-grad': BAND_STYLES[t.band] };

  return (
    <div className="stage" style={styleVars}>
      <div className="stage-head">
        <img src="assets/logo-mark.svg" alt="ThengaPari" />
        <div>
          <div className="t">ThengaPari · B2B Buyer Portal</div>
          <div className="s">Deep-blue theme · 390px · Android · tap to navigate the full flow</div>
        </div>
      </div>

      <Phone footer={footer} navBg={navBg}>{view}</Phone>

      <TweaksPanel>
        <TweakSection label="Brand accent (CTAs)" />
        <TweakColor label="Accent" value={t.accent === 'amber' ? '#F4A52A' : t.accent === 'blue' ? '#1C3D5E' : '#2E6B3E'}
          options={['#F4A52A', '#1C3D5E', '#2E6B3E']}
          onChange={(v) => setTweak('accent', v === '#F4A52A' ? 'amber' : v === '#1C3D5E' ? 'blue' : 'green')} />
        <TweakSection label="Savings band" />
        <TweakRadio label="Color" value={t.band} options={['money', 'brand', 'saffron']} onChange={(v) => setTweak('band', v)} />
        <TweakToggle label="Savings-by-crop chart" value={t.showChart} onChange={(v) => setTweak('showChart', v)} />
      </TweaksPanel>
    </div>
  );
}

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "accent": "amber",
  "band": "money",
  "showChart": true
}/*EDITMODE-END*/;

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
