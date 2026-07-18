import { useState } from 'react';
import { signup, links } from '../data/content';
import { submitLead } from '../lib/firebase';
import { useSignup } from '../lib/signup';
import Reveal from './ui/Reveal';

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export default function SignupCTA() {
  const { type, setType } = useSignup();
  const [email, setEmail] = useState('');
  const [msg, setMsg] = useState({ kind: '', text: '' });
  const [busy, setBusy] = useState(false);

  const onSubmit = async (e) => {
    e.preventDefault();
    const val = email.trim();
    if (!val) return setMsg({ kind: 'err', text: signup.errEmpty });
    if (!EMAIL_RE.test(val)) return setMsg({ kind: 'err', text: signup.errInvalid });

    setBusy(true);
    setMsg({ kind: '', text: '' });
    try {
      await submitLead({ email: val, type });
      setMsg({ kind: 'ok', text: signup.success });
      setEmail('');
    } catch (_) {
      setMsg({ kind: 'err', text: signup.errFail });
    } finally {
      setBusy(false);
    }
  };

  return (
    <section className="section cta" id="signup">
      <div className="wrap cta-inner">
        <Reveal>
          <span className="overline">{signup.overline}</span>
          <h2>{signup.title}</h2>
          <p>{signup.sub}</p>
        </Reveal>

        <Reveal className="signup-card" delayStep={1}>
          <h3>{signup.cardTitle}</h3>
          <p className="sc-sub">{signup.cardSub}</p>

          {/* audience toggle — sets the lead `type` (homeowner | business | general) */}
          <div className="type-toggle" role="group" aria-label="I am a…">
            {signup.types.map((t) => (
              <button
                type="button"
                key={t.value}
                className={`type-opt${type === t.value ? ' active' : ''}`}
                aria-pressed={type === t.value}
                onClick={() => setType(t.value)}
              >
                {t.label}
              </button>
            ))}
          </div>

          <form onSubmit={onSubmit} noValidate>
            <div className="field">
              <input
                type="email"
                name="email"
                placeholder={signup.placeholder}
                autoComplete="email"
                aria-label="Email address"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              <button type="submit" className="btn btn-accent" disabled={busy}>
                {busy ? 'Sending…' : signup.submit}
              </button>
            </div>
            <div className={`field-msg${msg.kind ? ` ${msg.kind}` : ''}`} role="status" aria-live="polite">
              {msg.text}
            </div>
          </form>

          <div className="divider-or">or get the app</div>
          <div className="stores">
            <a className="store-badge" href={links.playStore} target="_blank" rel="noopener noreferrer" aria-label="Get it on Google Play">
              <svg className="si" viewBox="0 0 24 24" fill="none"><path d="M4 3.5 13.5 12 4 20.5z" fill="#4FD0A6" /><path d="M4 3.5 16 10.5 13.5 12z" fill="#FFC93C" /><path d="M4 20.5 16 13.5 13.5 12z" fill="#FF6B6B" /><path d="M16 10.5 20.5 13 16 15.5 13.5 12z" fill="#4F9BFF" /></svg>
              <span><small>Get it on</small><b>Google Play</b></span>
            </a>
            <button className="store-badge soon" type="button" aria-label="App Store — coming soon" disabled>
              <span className="soon-tag">Coming soon</span>
              <svg className="si" viewBox="0 0 24 24" fill="#fff"><path d="M16.3 12.6c0-2.3 1.9-3.4 2-3.5-1.1-1.6-2.8-1.8-3.4-1.8-1.4-.1-2.8.9-3.5.9s-1.8-.8-3-.8c-1.5 0-2.9.9-3.7 2.3-1.6 2.7-.4 6.8 1.1 9 .7 1.1 1.6 2.3 2.7 2.2 1.1 0 1.5-.7 2.8-.7s1.7.7 2.8.7 1.9-1.1 2.6-2.1c.8-1.2 1.2-2.3 1.2-2.4-.1 0-2.3-.9-2.3-3.5z" /><path d="M14.2 5.9c.6-.8 1-1.8.9-2.9-.9 0-2 .6-2.6 1.3-.6.7-1.1 1.7-.9 2.7 1 .1 2-.4 2.6-1.1z" /></svg>
              <span><small>Download on the</small><b>App Store</b></span>
            </button>
          </div>
        </Reveal>
      </div>
    </section>
  );
}
