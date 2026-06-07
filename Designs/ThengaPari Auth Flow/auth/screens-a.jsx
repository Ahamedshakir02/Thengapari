// screens-a.jsx — ThengaPari auth: shell chrome, language toggle, onboarding, welcome
// Exports (to window): IndiaFlag, LangToggle, PhoneShell, NumPad, Onboarding, Welcome
const { useState, useRef, useEffect, useCallback } = React;

// ---------- India flag chip ----------
function IndiaFlag() {
  return (
    <svg className="tp-phone__flag" viewBox="0 0 24 17" xmlns="http://www.w3.org/2000/svg">
      <rect width="24" height="17" fill="#fff" />
      <rect width="24" height="5.67" fill="#FF9933" />
      <rect y="11.33" width="24" height="5.67" fill="#138808" />
      <circle cx="12" cy="8.5" r="2.4" fill="none" stroke="#0A2A6B" strokeWidth="0.8" />
      <circle cx="12" cy="8.5" r="0.5" fill="#0A2A6B" />
    </svg>
  );
}

// ---------- Language toggle (EN / മലയാളം) ----------
function LangToggle({ lang, setLang, onBleed = false }) {
  return (
    <div className={'tp-lang' + (onBleed ? ' tp-lang--onbleed' : '')} role="group" aria-label="Language">
      <button className={'tp-lang__opt' + (lang === 'en' ? ' is-on' : '')} onClick={() => setLang('en')}>EN</button>
      <button className={'tp-lang__opt tp-lang__opt--ml' + (lang === 'ml' ? ' is-on' : '')} onClick={() => setLang('ml')}>മല</button>
    </div>
  );
}

// ---------- Status bar + gesture nav shell ----------
function StatusBar({ onBrand }) {
  const c = onBrand ? ' tp-status--onbrand' : '';
  const col = onBrand ? 'rgba(255,255,255,.94)' : 'var(--fg1)';
  return (
    <div className={'tp-status' + c}>
      <span className="tp-status__time">9:30</span>
      <span className="tp-status__punch" />
      <span className="tp-status__icons" aria-hidden="true">
        <svg width="17" height="13" viewBox="0 0 17 13" fill="none"><path d="M1 6.5a10 10 0 0114.4 0" stroke={col} strokeWidth="1.6" strokeLinecap="round" opacity=".55"/><path d="M3.4 8.9a6.4 6.4 0 019.6 0" stroke={col} strokeWidth="1.6" strokeLinecap="round" opacity=".8"/><circle cx="8.2" cy="11.4" r="1.4" fill={col}/></svg>
        <svg width="18" height="13" viewBox="0 0 18 13" fill="none"><rect x="1" y="3" width="3" height="8" rx="1" fill={col} opacity=".45"/><rect x="5.5" y="1.5" width="3" height="9.5" rx="1" fill={col} opacity=".65"/><rect x="10" y="0" width="3" height="11" rx="1" fill={col} opacity=".85"/><rect x="14.5" y="-0.5" width="3" height="11.5" rx="1" fill={col}/></svg>
        <svg width="24" height="13" viewBox="0 0 24 13" fill="none"><rect x="1" y="1.5" width="19" height="10" rx="2.6" fill="none" stroke={col} strokeWidth="1.4" opacity=".5"/><rect x="2.8" y="3.3" width="13" height="6.4" rx="1.3" fill={col}/><rect x="21" y="4.5" width="1.8" height="4" rx="0.9" fill={col} opacity=".5"/></svg>
      </span>
    </div>
  );
}

function PhoneShell({ children, dark = false, onBrandStatus = false, navLight = false }) {
  return (
    <div className={'tp-shell' + (dark ? ' tp-shell--dark' : '')}>
      <StatusBar onBrand={onBrandStatus} />
      <div className="tp-screen">{children}</div>
      <div className="tp-nav"><span className={'tp-nav__pill' + (navLight ? ' tp-nav__pill--light' : '')} /></div>
    </div>
  );
}

// ---------- Numeric keypad ----------
function NumPad({ onKey, onDelete, accent }) {
  const keys = ['1','2','3','4','5','6','7','8','9'];
  return (
    <div className="tp-keypad">
      {keys.map(k => (
        <button key={k} className="tp-key" onClick={() => onKey(k)}>{k}</button>
      ))}
      <span className="tp-key tp-key--fn" aria-hidden="true" />
      <button className="tp-key" onClick={() => onKey('0')}>0</button>
      <button className="tp-key" onClick={onDelete} aria-label="Delete">
        <svg width="26" height="20" viewBox="0 0 26 20" fill="none"><path d="M8.5 3h13a2 2 0 012 2v10a2 2 0 01-2 2h-13L1 10l7.5-7z" stroke="currentColor" strokeWidth="1.7" strokeLinejoin="round"/><path d="M12 7.5l6 5M18 7.5l-6 5" stroke="currentColor" strokeWidth="1.7" strokeLinecap="round"/></svg>
      </button>
    </div>
  );
}

// ---------- Onboarding (3 swipeable slides) ----------
function Onboarding({ t, lang, setLang, onDone, onSkip, ctaStyle, painterly, Illos, initialIdx = 0 }) {
  const [idx, setIdx] = useState(initialIdx);
  const [drag, setDrag] = useState(null); // {startX, dx}
  const trackRef = useRef(null);
  const N = 3;

  const go = useCallback((n) => setIdx(Math.max(0, Math.min(N - 1, n))), []);

  // pointer / touch swipe
  const onDown = (e) => {
    const x = e.touches ? e.touches[0].clientX : e.clientX;
    setDrag({ startX: x, dx: 0 });
  };
  const onMove = (e) => {
    if (!drag) return;
    const x = e.touches ? e.touches[0].clientX : e.clientX;
    let dx = x - drag.startX;
    if ((idx === 0 && dx > 0) || (idx === N - 1 && dx < 0)) dx *= 0.32; // rubber-band
    setDrag(d => ({ ...d, dx }));
  };
  const onUp = () => {
    if (!drag) return;
    const w = trackRef.current ? trackRef.current.offsetWidth / N : 330;
    if (drag.dx < -w * 0.22) go(idx + 1);
    else if (drag.dx > w * 0.22) go(idx - 1);
    setDrag(null);
  };

  const slideW = 100 / N;
  const dragPct = drag && trackRef.current ? (drag.dx / trackRef.current.offsetWidth) * 100 : 0;
  const tx = -(idx * slideW) + dragPct;
  const last = idx === N - 1;
  const IlloComps = [Illos.IlloIncome, Illos.IlloFlow, Illos.IlloReport];

  return (
    <div className={'tp-ob' + (lang === 'ml' ? ' tp-ml' : '')}>
      <div className="tp-ob__top">
        <span className="tp-ob__brand"><img src="auth/assets/logo-mark.svg" alt="" /><b>{t.brand}</b></span>
        <LangToggle lang={lang} setLang={setLang} />
      </div>

      <div className="tp-ob__stage"
        onMouseDown={onDown} onMouseMove={onMove} onMouseUp={onUp} onMouseLeave={onUp}
        onTouchStart={onDown} onTouchMove={onMove} onTouchEnd={onUp}>
        <div ref={trackRef}
          className={'tp-ob__track' + (drag ? ' is-dragging' : '')}
          style={{ transform: `translateX(${tx}%)` }}>
          {t.slides.map((s, i) => {
            const Illo = IlloComps[i];
            return (
              <div className="tp-ob__slide" key={i}>
                <div className="tp-ob__art"><Illo painterly={painterly} /></div>
                <div className="tp-ob__copy">
                  <h1 className="tp-ob__headline">{s.h}</h1>
                  <p className="tp-ob__sub">{s.s}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      <div className="tp-ob__foot">
        <div className="tp-dots" role="tablist">
          {[0,1,2].map(i => (
            <button key={i} className={'tp-dot' + (i === idx ? ' tp-dot--active' : '')}
              onClick={() => go(i)} aria-label={`Slide ${i+1}`} aria-selected={i === idx} />
          ))}
        </div>
        <div className="tp-ob__row">
          {!last && <button className="tp-link" onClick={onSkip}>{t.skip}</button>}
          <button className={'tp-btn tp-btn--' + ctaStyle} onClick={() => last ? onDone() : go(idx + 1)}>
            {last ? t.getStarted : t.next}
            <span className="tp-btn__arrow">→</span>
          </button>
        </div>
      </div>
    </div>
  );
}

// ---------- Welcome ----------
function Welcome({ t, lang, setLang, onStart, ctaStyle, layout }) {
  const fullbleed = layout === 'fullbleed';
  const Logo = (
    <div className="tp-wel__logo">
      <img src="auth/assets/logo-mark.svg" alt="ThengaPari" />
      <div className="tp-wel__wordmark">Thenga<span>Pari</span></div>
    </div>
  );
  const Tagline = (
    <div>
      <p className="tp-wel__tagline">{t.welcomeTagline}</p>
      {lang !== 'ml' && <p className="tp-wel__ml">{t.welcomeMl}</p>}
    </div>
  );
  const Terms = (
    <p className="tp-wel__terms">{t.terms}</p>
  );

  if (fullbleed) {
    return (
      <div className="tp-wel tp-wel--fullbleed">
        <div className="tp-wel__bleed"><img src="auth/assets/illustration-kerala-landscape.svg" alt="Kerala landscape" /></div>
        <div className="tp-wel__scrim" />
        <div className="tp-ob__top" style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 3, justifyContent: 'flex-end' }}>
          <LangToggle lang={lang} setLang={setLang} onBleed />
        </div>
        <div className="tp-wel__content">
          {Logo}
          {Tagline}
          <button className={'tp-btn tp-btn--' + ctaStyle} style={{ marginTop: 4 }} onClick={onStart}>{t.getStarted}</button>
          {Terms}
        </div>
      </div>
    );
  }

  return (
    <div className="tp-wel tp-wel--heroup">
      <div className="tp-ob__top" style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 3, justifyContent: 'flex-end' }}>
        <LangToggle lang={lang} setLang={setLang} />
      </div>
      <div className="tp-wel__hero"><img src="auth/assets/illustration-kerala-landscape.svg" alt="Kerala landscape" /></div>
      <div className="tp-wel__body">
        {Logo}
        {Tagline}
      </div>
      <div className="tp-wel__foot">
        <button className={'tp-btn tp-btn--' + ctaStyle} onClick={onStart}>{t.getStarted}</button>
        {Terms}
      </div>
    </div>
  );
}

Object.assign(window, { IndiaFlag, LangToggle, PhoneShell, NumPad, StatusBar, Onboarding, Welcome });
