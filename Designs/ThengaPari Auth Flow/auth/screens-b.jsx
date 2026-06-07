// screens-b.jsx — ThengaPari auth: phone entry, OTP verify, success
// Exports (to window): TopBar, PhoneEntry, OtpVerify, SuccessScreen
const { useState: useStateB, useEffect: useEffectB, useRef: useRefB } = React;

function fmtPhone(d) {
  // d = up to 10 raw digits → "98765 43210"
  if (d.length <= 5) return d;
  return d.slice(0, 5) + ' ' + d.slice(5);
}

function TopBar({ onBack, lang, setLang }) {
  return (
    <div className="tp-form__bar">
      <button className="tp-back" onClick={onBack} aria-label="Back">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none"><path d="M15 5l-7 7 7 7" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"/></svg>
      </button>
      <div style={{ flex: 1 }} />
      <LangToggle lang={lang} setLang={setLang} />
    </div>
  );
}

// ---------- Phone entry ----------
function PhoneEntry({ t, lang, setLang, onBack, onSubmit, ctaStyle, initialDigits = '' }) {
  const [digits, setDigits] = useStateB(initialDigits);
  const ready = digits.length === 10;
  const push = (k) => setDigits(d => (d.length < 10 ? d + k : d));
  const del = () => setDigits(d => d.slice(0, -1));

  return (
    <div className={'tp-form' + (lang === 'ml' ? ' tp-ml' : '')}>
      <TopBar onBack={onBack} lang={lang} setLang={setLang} />
      <div className="tp-form__body">
        <h1 className="tp-form__head">{t.phoneHead}</h1>
        <p className="tp-form__lead">{t.phoneLead}</p>

        <div className="tp-field">
          <label className="tp-field__label">{t.phoneLabel}</label>
          <div className={'tp-phone is-focus'}>
            <span className="tp-phone__cc"><IndiaFlag /> +91</span>
            <span className="tp-phone__num" style={{ display: 'flex', alignItems: 'center' }}>
              {digits.length ? fmtPhone(digits) : <span style={{ color: 'var(--ink-400)', fontWeight: 500 }}>00000 00000</span>}
            </span>
          </div>
        </div>
        <p className="tp-reassure">
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M8 1.5l5.5 2.2v3.3c0 3.2-2.2 5.7-5.5 6.8-3.3-1.1-5.5-3.6-5.5-6.8V3.7L8 1.5z" stroke="var(--green-sage-500)" strokeWidth="1.4" strokeLinejoin="round"/><path d="M5.6 8.1l1.7 1.7 3.1-3.5" stroke="var(--green-sage-500)" strokeWidth="1.4" strokeLinecap="round" strokeLinejoin="round"/></svg>
          {t.reassure}
        </p>

        <div style={{ flex: 1 }} />
      </div>

      <div className="tp-form__foot">
        <button className={'tp-btn tp-btn--' + (ready ? ctaStyle : 'disabled')} disabled={!ready}
          onClick={() => ready && onSubmit('+91 ' + fmtPhone(digits))}>
          {t.sendOtp}
        </button>
      </div>
      <NumPad onKey={push} onDelete={del} />
    </div>
  );
}

// ---------- OTP verify ----------
function OtpVerify({ t, lang, setLang, onBack, onVerify, phone, code, otpStyle, ctaStyle, forceError, initialDigits, initialError = false }) {
  const [digits, setDigits] = useStateB(initialDigits || ['','','','','','']);
  const [error, setError] = useStateB(initialError);
  const [seconds, setSeconds] = useStateB(45);
  const [toast, setToast] = useStateB('');
  const filled = digits.filter(Boolean).length;
  const active = Math.min(filled, 5);
  const complete = filled === 6;

  // countdown
  useEffectB(() => {
    if (seconds <= 0) return;
    const id = setTimeout(() => setSeconds(s => s - 1), 1000);
    return () => clearTimeout(id);
  }, [seconds]);

  const doVerify = (arr) => {
    const entered = (arr || digits).join('');
    if (!forceError && entered === code) { onVerify(); return; }
    setError(true);
    setTimeout(() => { setDigits(['','','','','','']); }, 650);
  };

  const push = (k) => {
    if (complete) return;
    setError(false);
    setDigits(d => {
      const n = [...d]; const i = n.findIndex(x => !x);
      if (i === -1) return n; n[i] = k;
      if (i === 5) setTimeout(() => doVerify(n), 320); // auto-verify
      return n;
    });
  };
  const del = () => { setError(false); setDigits(d => { const n = [...d]; const i = n.map(Boolean).lastIndexOf(true); if (i >= 0) n[i] = ''; return n; }); };

  const resend = () => {
    if (seconds > 0) return;
    setSeconds(45); setDigits(['','','','','','']); setError(false);
    setToast(t.otpResent); setTimeout(() => setToast(''), 2600);
  };

  const mm = Math.floor(seconds / 60), ss = String(seconds % 60).padStart(2, '0');

  return (
    <div className={'tp-form' + (lang === 'ml' ? ' tp-ml' : '')}>
      <TopBar onBack={onBack} lang={lang} setLang={setLang} />
      <div className="tp-form__body">
        <h1 className="tp-form__head">{t.otpHead}</h1>
        <div className="tp-otp__sent">
          <span className="tp-otp__num">{t.otpSentTo} {phone}</span>
          <button className="tp-otp__edit" onClick={onBack}>{t.otpEdit}</button>
        </div>

        <div className={'tp-otp' + (error ? ' tp-otp--error' : '')}>
          <div className={'tp-otp__boxes' + (otpStyle === 'underline' ? ' tp-otp__boxes--underline' : '')}>
            {digits.map((d, i) => (
              <div key={i} className={'tp-otp__box' + (d ? ' is-filled has-digit' : '') + (!error && i === active ? ' is-active' : '')}>{d}</div>
            ))}
          </div>
          {error && (
            <div className="tp-otp__msg">
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="6.6" stroke="currentColor" strokeWidth="1.4"/><path d="M8 5v3.4M8 10.7v.2" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/></svg>
              {t.otpError}
            </div>
          )}
        </div>

        <p className="tp-otp__resend">
          {seconds > 0
            ? <span>{t.resendIn} <b>{mm}:{ss}</b></span>
            : <button className="tp-otp__resend-btn" onClick={resend}>{t.resend}</button>}
        </p>
        {toast && <p className="tp-otp__resend" style={{ color: 'var(--green-600)', fontWeight: 600 }}>{toast}</p>}

        {/* demo hint */}
        <div style={{ flex: 1, display: 'flex', alignItems: 'flex-end', justifyContent: 'center', paddingBottom: 6 }}>
          <span style={{ font: 'var(--t-caption)', color: 'var(--ink-400)', background: 'var(--surface-sunk)', padding: '6px 12px', borderRadius: 'var(--r-pill)', letterSpacing: '.02em' }}>
            Demo code: <b style={{ color: 'var(--ink-500)', letterSpacing: '.12em' }}>{code}</b>
          </span>
        </div>
      </div>

      <div className="tp-form__foot">
        <button className={'tp-btn tp-btn--' + (complete ? ctaStyle : 'disabled')} disabled={!complete} onClick={() => doVerify()}>
          {t.verify}
        </button>
      </div>
      <NumPad onKey={push} onDelete={del} />
    </div>
  );
}

// ---------- Success ----------
function SuccessScreen({ t, onRestart, ctaStyle }) {
  return (
    <div className="tp-wel tp-wel--heroup" style={{ alignItems: 'center', justifyContent: 'center' }}>
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '0 36px', gap: 22 }}>
        <div style={{ position: 'relative', width: 132, height: 132 }}>
          <div style={{ position: 'absolute', inset: 0, borderRadius: '50%', background: 'var(--green-leaf-100)' }} />
          <div style={{ position: 'absolute', inset: 18, borderRadius: '50%', background: 'var(--brand)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-md)' }}>
            <svg width="52" height="52" viewBox="0 0 52 52" fill="none"><path d="M15 27l8 8 16-18" stroke="#fff" strokeWidth="5.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
          </div>
          <span style={{ position: 'absolute', top: -2, right: 6, fontSize: 22 }}>✦</span>
        </div>
        <div>
          <h1 className="tp-form__head" style={{ marginBottom: 8 }}>You're all set!</h1>
          <p className="tp-wel__tagline">Welcome to ThengaPari. Let's get your trees working for you.</p>
        </div>
      </div>
      <div className="tp-wel__foot">
        <button className={'tp-btn tp-btn--' + ctaStyle} onClick={onRestart}>Restart the flow</button>
      </div>
    </div>
  );
}

Object.assign(window, { TopBar, PhoneEntry, OtpVerify, SuccessScreen, fmtPhone });
