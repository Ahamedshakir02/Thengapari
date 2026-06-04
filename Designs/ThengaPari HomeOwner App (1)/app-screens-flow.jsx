// app-screens-flow.jsx — Book a harvest, Confirm overlay, Live tracker, Yield report

function buildDays(lang) {
  const dows = lang === 'ml' ? ['ഞാ','തി','ചൊ','ബു','വ്യ','വെ','ശ'] : ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  const out = [];
  const now = new Date(2026, 5, 3); // fixed for the mock
  for (let i = 0; i < 7; i++) {
    const d = new Date(now); d.setDate(now.getDate() + i);
    out.push({ dow: i === 0 ? t('today', lang) : i === 1 ? t('tomorrow', lang) : dows[d.getDay()],
      day: d.getDate(), ripe: i <= 2 });
  }
  return out;
}

// ── Book ────────────────────────────────────────────────────────────────────
function BookScreen({ lang, subtitles, go, booking, setBooking, onConfirm }) {
  const days = React.useMemo(() => buildDays(lang), [lang]);
  const crop = cropById(booking.cropId);
  const baseCount = booking.ripe ? (crop.ready || crop.count) : crop.count;
  const earning = Math.round(baseCount * crop.rate);
  const yieldStr = crop.id === 'coconut' ? baseCount + ' ' + t('nuts', lang)
    : crop.unit === 'kg' ? baseCount + ' kg'
    : baseCount + ' ' + crop.unit;

  return (
    <>
      <TopBar title="book_harvest" lang={lang} onBack={() => go('home', 'back')} />
      <div className="scroll" style={{ paddingTop: 4 }}>
        <div className="pad">
          {/* crop grid */}
          <Lbl k="pick_crop" lang={lang} subtitles={subtitles} className="tp-h3" tag="h2" style={{ marginBottom: 12 }} />
          <div className="cropgrid">
            {CROPS.map((c) => {
              const sel = c.id === booking.cropId;
              return (
                <button key={c.id} className={'cropcell' + (sel ? ' sel' : '')} onClick={() => setBooking((b) => ({ ...b, cropId: c.id }))}>
                  <span className="cell-emoji" style={{ background: c.tint }}><Icon name={c.icon} size={24} color={c.fg} /></span>
                  <div className="cell-name">{c.name[lang === 'ml' ? 'ml' : 'en']}</div>
                  <div className="cell-sub">{c.ready > 0 ? c.ready + ' ' + t('ready_to_pick', lang) : (lang === 'ml' ? 'ഉടൻ പാകമാകും' : 'ripening soon')}</div>
                  <span className="cell-check">{sel && <Icon name="check-bold" size={15} color="#fff" />}</span>
                </button>
              );
            })}
          </div>

          {/* date */}
          <Lbl k="when" lang={lang} subtitles={subtitles} className="tp-h3" tag="h2" style={{ margin: '22px 0 12px' }} />
          <div className="daystrip">
            {days.map((d, i) => (
              <button key={i} className={'daycell' + (i === booking.dayIdx ? ' sel' : '')} onClick={() => setBooking((b) => ({ ...b, dayIdx: i }))}>
                <div className="dc-dow">{d.dow}</div>
                <div className="dc-day">{d.day}</div>
                {d.ripe && <span className="dc-tag">● {lang === 'ml' ? 'പാകം' : 'ripe'}</span>}
              </button>
            ))}
          </div>

          {/* ripe/all toggle */}
          <div className="segment" style={{ marginTop: 20 }}>
            <button className={booking.ripe ? 'on' : ''} onClick={() => setBooking((b) => ({ ...b, ripe: true }))}>
              <Icon name="check" size={16} sw={2.2} color={booking.ripe ? 'var(--brand)' : 'var(--fg3)'} /> {t('ripe_only', lang)}
            </button>
            <button className={!booking.ripe ? 'on' : ''} onClick={() => setBooking((b) => ({ ...b, ripe: false }))}>
              {t('all', lang)}
            </button>
          </div>

          {/* preview */}
          <div className="previewcard" style={{ marginTop: 18 }}>
            <div className="pv-glow" />
            <div className="pv-row">
              <div className="pv-block">
                <div className="pv-k"><Icon name="coconut" size={15} color="var(--green-leaf-200)" /> {t('est_yield', lang)}</div>
                <div className="pv-v">{baseCount}<small> {crop.id === 'coconut' ? t('nuts', lang) : (crop.unit === 'kg' ? 'kg' : crop.unit)}</small></div>
              </div>
              <div className="pv-block" style={{ textAlign: 'right' }}>
                <div className="pv-k" style={{ justifyContent: 'flex-end' }}><Icon name="rupee" size={15} color="var(--green-leaf-200)" /> {t('est_earning', lang)}</div>
                <div className="pv-v" style={{ color: 'var(--amber-400)' }}>₹{earning.toLocaleString('en-IN')}</div>
              </div>
            </div>
            <div className="pv-divider" />
            <div className="pv-note"><Icon name="shield" size={15} color="rgba(255,255,255,.7)" /> {t('preview_note', lang)}</div>
          </div>
        </div>
      </div>
      <div className="sticky-foot">
        <button className="btn btn-accent" onClick={onConfirm}>
          {t('confirm_booking', lang)} · ₹{earning.toLocaleString('en-IN')}
        </button>
      </div>
    </>
  );
}

// ── Confirm overlay ──────────────────────────────────────────────────────────
function ConfirmOverlay({ booking, lang, subtitles, onClose, onTrack }) {
  const crop = cropById(booking.cropId);
  const days = buildDays(lang);
  const d = days[booking.dayIdx] || days[0];
  const baseCount = booking.ripe ? (crop.ready || crop.count) : crop.count;
  const earning = Math.round(baseCount * crop.rate);
  return (
    <div className="confirm-overlay" onClick={onClose}>
      <div className="confirm-sheet" onClick={(e) => e.stopPropagation()}>
        <div className="cs-badge"><Icon name="check-bold" size={36} color="var(--status-complete-fg)" /></div>
        <Lbl k="booked_title" lang={lang} subtitles={subtitles} className="cs-title" tag="div" />
        <div className="cs-sub">{t('booked_sub', lang)}</div>
        <div className="cs-detail">
          <div className="cd-row"><span>{t('crop_label', lang)}</span><b>{crop.name[lang === 'ml' ? 'ml' : 'en']} · {baseCount} {crop.id === 'coconut' ? t('nuts', lang) : crop.unit}</b></div>
          <div className="cd-row"><span>{t('date_label', lang)}</span><b>{d.dow}, {d.day}</b></div>
          <div className="cd-row"><span>{t('est_label', lang)}</span><b style={{ color: 'var(--brand-ink)' }}>₹{earning.toLocaleString('en-IN')}</b></div>
        </div>
        <button className="btn btn-primary" onClick={onTrack}>{t('view_tracker', lang)} <Icon name="arrow-right" size={18} sw={2.2} /></button>
        <button className="btn btn-ghost" style={{ marginTop: 10, border: 'none', boxShadow: 'none', height: 44 }} onClick={onClose}>{t('back', lang)}</button>
      </div>
    </div>
  );
}

// ── Tracker ──────────────────────────────────────────────────────────────────
function TrackerScreen({ lang, subtitles, go }) {
  const steps = [
    { k: 'step_assigned', state: 'done' },
    { k: 'step_arrived', state: 'done' },
    { k: 'step_harvest', state: 'active' },
    { k: 'step_weighing', state: '' },
    { k: 'step_done', state: '' },
  ];
  return (
    <>
      <TopBar title="live_job" lang={lang} onBack={() => go('home', 'back')}
        right={<span className="pill-status st-inprogress" style={{ marginRight: 4 }}><span className="live-dot" />{t('live', lang)}</span>} />
      <div className="scroll" style={{ paddingTop: 4 }}>
        {/* stepper */}
        <div className="pad">
          <div className="stepper">
            {steps.map((s, i) => (
              <div key={i} className={'step ' + (s.state)}>
                <div className={'st-line ' + (s.state === 'done' || s.state === 'active' ? 'fill' : '')} />
                <div className="st-node">
                  {s.state === 'done' ? <Icon name="check" size={16} color="#fff" sw={2.4} />
                    : <span style={{ font: '700 12px/1 var(--font-text)' }}>{i + 1}</span>}
                </div>
                <span className="st-label">{t(s.k, lang)}</span>
              </div>
            ))}
          </div>
        </div>

        {/* map */}
        <div className="pad" style={{ marginTop: 18 }}>
          <GroveMap lang={lang} />
        </div>

        {/* worker row */}
        <div className="pad" style={{ marginTop: 14 }}>
          <div className="card card-pad row" style={{ gap: 12 }}>
            <span className="prof-avatar" style={{ width: 46, height: 46, fontSize: 17 }}>SM</span>
            <div style={{ flex: 1 }}>
              <div style={{ font: 'var(--t-title)', fontSize: 15.5, color: 'var(--fg1)' }}>{lang === 'ml' ? 'സുരേഷ് കുമാർ' : 'Suresh Kumar'}</div>
              <div className="jc-meta">{t('worker_enroute', lang)} · 2.1 km</div>
            </div>
            <button className="iconbtn" style={{ background: 'var(--green-leaf-100)', borderColor: 'transparent' }}><Icon name="phone" size={19} color="var(--brand)" /></button>
            <button className="iconbtn" style={{ background: 'var(--green-leaf-100)', borderColor: 'transparent' }}><Icon name="chat" size={19} color="var(--brand)" /></button>
          </div>
        </div>

        {/* live weight */}
        <div className="pad" style={{ marginTop: 14 }}>
          <div className="sec-head" style={{ marginBottom: 8 }}>
            <Lbl k="live_weight" lang={lang} subtitles={subtitles} className="sh-title" style={{ font: 'var(--t-title)' }} />
            <span className="pill-status st-inprogress" style={{ fontSize: 11, padding: '4px 9px' }}><span className="live-dot" />{t('live', lang)}</span>
          </div>
          <div className="card weightcard">
            <div className="wt-dial"><WeightDial pct={0.62} />
              <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="scale" size={26} color="var(--accent)" /></div>
            </div>
            <div style={{ flex: 1 }}>
              <div className="wt-val">14.2<small> / 23 kg</small></div>
              <div className="wt-label">{t('weighed_now', lang)} · {lang === 'ml' ? '14 മരം' : 'across 14 trees'}</div>
            </div>
          </div>
        </div>

        {/* site photos */}
        <div style={{ marginTop: 16, paddingBottom: 14 }}>
          <div className="pad sec-head" style={{ marginBottom: 10 }}>
            <Lbl k="site_photos" lang={lang} subtitles={subtitles} className="sh-title" style={{ font: 'var(--t-title)' }} />
            <span className="sh-action">{t('see_all', lang)}</span>
          </div>
          <div className="photos">
            {[
              { g: 'linear-gradient(150deg,#357A47,#1E4D2B)', ic: 'tree', tm: '8:02' },
              { g: 'linear-gradient(150deg,#94B97F,#2E6B3E)', ic: 'coconut', tm: '8:14' },
              { g: 'linear-gradient(150deg,#FBBA4D,#DD8413)', ic: 'scale', tm: '8:31' },
              { g: 'linear-gradient(150deg,#6E9E5E,#357A47)', ic: 'leaf', tm: '8:40' },
            ].map((ph, i) => (
              <div key={i} className="photo" style={{ background: ph.g, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={ph.ic} size={30} color="rgba(255,255,255,.85)" sw={1.6} />
                <span className="ph-time">{ph.tm}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}

// stylized grove map
function GroveMap({ lang }) {
  return (
    <div className="mapwrap">
      <svg viewBox="0 0 360 220" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
        <rect width="360" height="220" fill="#EAF0E0" />
        {/* plots */}
        <rect x="-10" y="120" width="180" height="120" fill="#D6E5C2" />
        <rect x="180" y="-10" width="200" height="110" fill="#DDEAC9" />
        <path d="M0 60 Q120 40 200 90 T360 70" fill="none" stroke="#CFE0BC" strokeWidth="40" opacity=".6"/>
        {/* tree dots grid */}
        {Array.from({ length: 5 }).map((_, r) => Array.from({ length: 8 }).map((__, c) => (
          <circle key={r + '-' + c} cx={28 + c * 42} cy={40 + r * 40} r="6" fill={(r + c) % 3 === 0 ? '#2E6B3E' : '#6E9E5E'} opacity=".8" />
        )))}
        {/* path */}
        <path d="M40 210 C120 160 130 120 220 96" fill="none" stroke="#F1F6E9" strokeWidth="9" strokeLinecap="round" strokeDasharray="2 12" opacity=".9"/>
        {/* home */}
        <g transform="translate(34,196)">
          <rect x="-8" y="-6" width="20" height="14" rx="2" fill="#C8603A" />
          <path d="M-11 -6 L2 -16 L15 -6 Z" fill="#A94F2E" />
        </g>
      </svg>
      {/* worker pin */}
      <div className="map-pin pulse" style={{ left: '61%', top: '46%' }}>
        <svg width="34" height="44" viewBox="0 0 34 44" fill="none" aria-hidden="true">
          <path d="M17 43c8-10 13-17 13-25A13 13 0 1 0 4 18c0 8 5 15 13 25Z" fill="var(--accent)" />
          <circle cx="17" cy="17" r="9" fill="#fff" />
          <text x="17" y="21" textAnchor="middle" fontSize="10" fontWeight="700" fill="var(--amber-saffron-600)" fontFamily="var(--font-text)">SM</text>
        </svg>
      </div>
      <div className="map-badge">
        <span className="worker-avatar" style={{ width: 26, height: 26, fontSize: 11 }}>SM</span>
        2.1 km · {lang === 'ml' ? '6 മിനിറ്റ്' : '6 min away'}
      </div>
    </div>
  );
}

Object.assign(window, { BookScreen, ConfirmOverlay, TrackerScreen, GroveMap });
