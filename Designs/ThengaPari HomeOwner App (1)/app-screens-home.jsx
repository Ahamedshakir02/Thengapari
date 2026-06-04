// app-screens-home.jsx — Home dashboard + Schedule + Profile

function CropChip({ crop, lang, onClick }) {
  return (
    <button className="cropchip" onClick={onClick}>
      <span className="cc-emoji" style={{ background: crop.tint }}>
        <Icon name={crop.icon} size={22} color={crop.fg} />
      </span>
      <span style={{ textAlign: 'left' }}>
        <span className="cc-name" style={{ display: 'block' }}>{crop.name[lang === 'ml' ? 'ml' : 'en']}</span>
        <span className="cc-count">
          {crop.id === 'pepper' ? '~2 kg' : '×' + crop.count}{crop.ready > 0 ? ' · ' + crop.ready + ' ' + t('ready_to_pick', lang) : ''}
        </span>
      </span>
    </button>
  );
}

function HomeScreen({ lang, setLang, subtitles, tweaks, go, setBooking }) {
  const name = tweaks.greetName || 'Rahul';
  const greetKey = 'greet_' + (tweaks.greeting || 'morning');
  const openBook = (cropId) => { if (cropId) setBooking((b) => ({ ...b, cropId })); go('book', 'push'); };

  return (
    <div className="scroll" style={{ paddingBottom: 12 }}>
      {/* hero */}
      <div className="hero">
        <img src="assets/illustration-kerala-landscape.svg" alt="Kerala grove at sunrise" />
        <div className="hero-scrim" />
        <div className="hero-top">
          <div className="brandchip">
            <img src="assets/logo-mark.svg" alt="" />
            <span className="bc-name">ThengaPari</span>
          </div>
          <div className="langtoggle">
            <button className={lang === 'en' ? 'on' : ''} onClick={() => setLang('en')}>EN</button>
            <button className={lang === 'ml' ? 'on' : ''} onClick={() => setLang('ml')}>മല</button>
          </div>
        </div>
        <div className="hero-greet rise">
          <div className="g-small">{t(greetKey, lang)},</div>
          <div className="g-name">{name}</div>
          <div className="g-sub"><Icon name="leaf" size={15} color="rgba(255,255,255,.92)" sw={1.8} />{t('greet_sub', lang)}</div>
        </div>
      </div>

      {/* crop chips */}
      <div style={{ marginTop: 16 }}>
        <div className="pad sec-head" style={{ marginBottom: 10 }}>
          <Lbl k="your_crops" lang={lang} subtitles={subtitles} className="sh-title" />
        </div>
        <div className="chips-scroll">
          {CROPS.map((c) => <CropChip key={c.id} crop={c} lang={lang} onClick={() => openBook(c.id)} />)}
        </div>
      </div>

      {/* stat cards */}
      <div className="pad statgrid" style={{ marginTop: 16 }}>
        <div className="card statcard">
          <span className="sc-icon" style={{ background: 'var(--green-leaf-100)' }}><Icon name="rupee" size={20} color="var(--brand)" /></span>
          <div className="sc-val">₹4,280</div>
          <Lbl k="yield_earned" lang={lang} subtitles={subtitles} className="sc-label" />
          <span className="sc-trend" style={{ background: 'var(--status-complete-bg)', color: 'var(--status-complete-fg)' }}>
            <Icon name="trend-up" size={12} sw={2.4} /> +12% {t('this_season', lang)}
          </span>
        </div>
        <div className="card statcard">
          <span className="sc-icon" style={{ background: 'var(--amber-100)' }}><Icon name="feather" size={20} color="var(--status-inprogress-fg)" /></span>
          <div className="sc-val">0.8 kg</div>
          <Lbl k="weight_saved" lang={lang} subtitles={subtitles} className="sc-label" />
          <span className="sc-trend" style={{ background: 'var(--amber-100)', color: 'var(--status-inprogress-fg)' }}>
            <Icon name="scale" size={12} sw={2.2} /> {t('vs_market', lang)}
          </span>
        </div>
      </div>

      {/* weekly earnings */}
      <div className="pad" style={{ marginTop: 14 }}>
        <div className="card barchart-card">
          <div className="sec-head">
            <Lbl k="weekly_earnings" lang={lang} subtitles={subtitles} className="sh-title" style={{ font: 'var(--t-title)' }} />
            <span className="lg-meta" style={{ fontWeight: 700, color: 'var(--brand-ink)' }}>₹4,850</span>
          </div>
          <BarChart data={WEEK} lang={lang} style={tweaks.chart || 'leaf'} />
        </div>
      </div>

      {/* active job */}
      <div className="pad" style={{ marginTop: 14 }}>
        <div className="sec-head" style={{ marginBottom: 8 }}>
          <Lbl k="active_job" lang={lang} subtitles={subtitles} className="sh-title" style={{ font: 'var(--t-title)' }} />
          <span className="pill-status st-inprogress"><span className="dot" style={{ background: 'var(--status-inprogress-fg)' }} />{t('in_progress', lang)}</span>
        </div>
        <div className="card jobcard">
          <div className="jc-head">
            <span className="jc-thumb" style={{ background: 'var(--green-leaf-100)' }}><Icon name="coconut" size={26} color="var(--brand)" /></span>
            <div style={{ flex: 1 }}>
              <div className="jc-title">{lang === 'ml' ? 'തേങ്ങ വിളവെടുപ്പ്' : 'Coconut harvest'}</div>
              <div className="jc-meta">{lang === 'ml' ? '24-ൽ 14 മരങ്ങൾ' : '14 of 24 trees · East grove'}</div>
            </div>
          </div>
          <div className="jc-body">
            <div className="progress"><div className="fill" style={{ width: '60%' }} /></div>
            <div className="jc-foot">
              <div className="jc-eta">
                <span className="worker-avatar">SM</span>
                <span>{lang === 'ml' ? 'സൈറ്റ് മാനേജർ · 2.1 കി.മീ ' : 'Site Manager · 2.1 km '}{t('away', lang)}</span>
              </div>
              <button className="btn btn-accent btn-sm" onClick={() => go('tracker', 'push')}>
                {t('track', lang)} <Icon name="arrow-right" size={16} sw={2.2} />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* book CTA */}
      <div className="pad" style={{ marginTop: 16 }}>
        <button className="btn btn-primary" onClick={() => openBook(null)}>
          <Icon name="plus" size={20} sw={2.2} /> {t('book_harvest', lang)}
        </button>
      </div>
    </div>
  );
}

// ── Schedule ────────────────────────────────────────────────────────────────
function ScheduleScreen({ lang, subtitles, go, setBooking }) {
  const upcoming = [
    { crop: 'coconut', date: lang === 'ml' ? 'നാളെ, 7:00 AM' : 'Tomorrow, 7:00 AM', note: lang === 'ml' ? 'കിഴക്കൻ തോട്ടം · 24 മരം' : 'East grove · 24 trees', st: 'scheduled' },
    { crop: 'banana', date: lang === 'ml' ? 'വെള്ളി, 8:30 AM' : 'Fri, 8:30 AM', note: lang === 'ml' ? '2 കുല' : '2 bunches ready', st: 'scheduled' },
  ];
  const past = [
    { crop: 'mango', date: lang === 'ml' ? 'കഴിഞ്ഞ ചൊവ്വ' : 'Last Tue', note: '₹760', st: 'complete' },
    { crop: 'areca', date: lang === 'ml' ? 'മെയ് 21' : 'May 21', note: '₹2,140', st: 'complete' },
    { crop: 'coconut', date: lang === 'ml' ? 'മെയ് 14' : 'May 14', note: '₹3,480', st: 'complete' },
  ];
  const Row = ({ item }) => {
    const c = cropById(item.crop);
    return (
      <div className="card card-pad row" style={{ gap: 13 }}>
        <span className="jc-thumb" style={{ width: 44, height: 44, background: c.tint }}><Icon name={c.icon} size={24} color={c.fg} /></span>
        <div style={{ flex: 1 }}>
          <div style={{ font: 'var(--t-title)', fontSize: 15.5, color: 'var(--fg1)' }}>{c.name[lang === 'ml' ? 'ml' : 'en']}</div>
          <div className="jc-meta">{item.note}</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ font: '600 13px/1.2 var(--font-text)', color: 'var(--fg1)' }}>{item.date}</div>
          <span className={'pill-status st-' + (item.st === 'complete' ? 'complete' : 'scheduled')} style={{ marginTop: 5, fontSize: 11, padding: '4px 9px' }}>
            <span className="dot" style={{ background: item.st === 'complete' ? 'var(--status-complete-fg)' : 'var(--status-scheduled-fg)' }} />
            {t(item.st === 'complete' ? 'completed' : 'scheduled', lang)}
          </span>
        </div>
      </div>
    );
  };
  return (
    <div className="scroll">
      <div className="pad" style={{ paddingTop: 8, paddingBottom: 14 }}>
        <Lbl k="nav_schedule" lang={lang} subtitles={subtitles} className="tp-h2" tag="h1" style={{ marginBottom: 18 }} />
        <Lbl k="upcoming" lang={lang} subtitles={subtitles} className="eyebrow" style={{ display: 'block', marginBottom: 10 }} />
        <div className="stack">{upcoming.map((it, i) => <Row key={i} item={it} />)}</div>
        <Lbl k="past_harvests" lang={lang} subtitles={subtitles} className="eyebrow" style={{ display: 'block', margin: '22px 0 10px' }} />
        <div className="stack">{past.map((it, i) => <Row key={i} item={it} />)}</div>
      </div>
    </div>
  );
}

// ── Profile ───────────────────────────────────────────────────────────────
function ProfileScreen({ lang, setLang, subtitles, tweaks }) {
  const name = tweaks.greetName || 'Rahul';
  const items = [
    { icon: 'tree', k: 'my_grove', meta: '52 ' + t('trees_registered', lang) },
    { icon: 'wallet', k: 'payouts', meta: 'UPI · rahul@okaxis' },
    { icon: 'globe', k: 'language_set', meta: lang === 'ml' ? 'മലയാളം' : 'English' },
    { icon: 'shield', k: 'help', meta: '' },
  ];
  return (
    <div className="scroll">
      <div className="pad" style={{ paddingTop: 8 }}>
        <Lbl k="nav_profile" lang={lang} subtitles={subtitles} className="tp-h2" tag="h1" style={{ marginBottom: 18 }} />
        <div className="card card-pad prof-head">
          <span className="prof-avatar">{name[0]}</span>
          <div>
            <div style={{ font: 'var(--t-h3)', color: 'var(--fg1)' }}>{name} {lang === 'ml' ? '' : 'Menon'}</div>
            <div className="jc-meta">{lang === 'ml' ? 'തൃശൂർ · 52 മരം' : 'Thrissur · 52 trees'}</div>
            <span className="pill-status st-complete" style={{ marginTop: 8, fontSize: 11, padding: '4px 9px' }}>
              <Icon name="shield" size={12} color="var(--status-complete-fg)" sw={2} /> {lang === 'ml' ? 'പരിശോധിച്ചു' : 'Verified owner'}
            </span>
          </div>
        </div>

        <div className="card card-pad prof-list" style={{ marginTop: 14 }}>
          {items.map((it) => (
            <div key={it.k} className="prof-item">
              <span className="pi-icon"><Icon name={it.icon} size={20} color="var(--brand)" /></span>
              <Lbl k={it.k} lang={lang} subtitles={subtitles} className="pi-label" />
              {it.meta && <span className="jc-meta" style={{ marginRight: 6 }}>{it.meta}</span>}
              <Icon name="chevron-right" size={18} color="var(--fg3)" />
            </div>
          ))}
        </div>

        <div className="card card-pad" style={{ marginTop: 14 }}>
          <Lbl k="language_set" lang={lang} subtitles={subtitles} className="eyebrow" style={{ display: 'block', marginBottom: 10 }} />
          <div className="langtoggle dark-ctx" style={{ width: '100%' }}>
            <button className={lang === 'en' ? 'on' : ''} style={{ flex: 1 }} onClick={() => setLang('en')}>English</button>
            <button className={lang === 'ml' ? 'on' : ''} style={{ flex: 1 }} onClick={() => setLang('ml')}>മലയാളം</button>
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { HomeScreen, ScheduleScreen, ProfileScreen, CropChip });
