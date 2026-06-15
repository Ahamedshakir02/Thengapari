import illustration from '../assets/illustration-kerala-landscape.svg';
import { hero } from '../data/content';
import { useSignup } from '../lib/signup';
import Reveal from './ui/Reveal';

export default function Hero() {
  const { selectType } = useSignup();
  const go = (type) => (e) => {
    e.preventDefault();
    selectType(type);
  };

  return (
    <section className="section hero">
      <div className="wrap hero-grid">
        <div className="hero-copy">
          <Reveal as="span" className="overline">{hero.overline}</Reveal>
          <Reveal as="h1" delayStep={1}>
            {hero.titleLead}
            <span className="hl">{hero.titleHighlight}</span>
          </Reveal>
          <Reveal as="p" className="hero-sub" delayStep={2}>{hero.sub}</Reveal>
          <Reveal className="hero-cta" delayStep={2}>
            <a href="#signup" className="btn btn-accent btn-lg" onClick={go('homeowner')}>
              Get started
              <svg className="ic" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M13 6l6 6-6 6" /></svg>
            </a>
            <a href="#signup" className="btn btn-outline btn-lg" onClick={go('business')}>For businesses</a>
          </Reveal>
          <Reveal className="hero-trust" delayStep={3}>
            {hero.trust.map((t) => (
              <span className="dot" key={t}>{t}</span>
            ))}
          </Reveal>
        </div>

        <Reveal className="hero-art" delayStep={2}>
          <div className="frame">
            <img src={illustration} alt="A Kerala homestead: coconut palm, mango tree and a tile-roof house among green hills" width="640" height="480" />
          </div>
          <div className="floaty f1">
            <span className="badge" style={{ background: 'var(--green-leaf-100)' }}>
              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="var(--green-forest-700)" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M20 6 9 17l-5-5" /></svg>
            </span>
            <span><small>Booked</small><b>Harvest scheduled</b></span>
          </div>
          <div className="floaty f2">
            <span className="badge" style={{ background: 'var(--amber-100)' }}>
              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="var(--amber-saffron-600)" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M12 1v22M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" /></svg>
            </span>
            <span><small>Paid to you</small><b>₹4,250 · same day</b></span>
          </div>
          <div className="floaty f3">
            <span className="badge" style={{ background: 'var(--teal-100)' }}>
              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="var(--teal-700)" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="9" /><path d="M12 7v5l3 2" /></svg>
            </span>
            <span><small>Today</small><b>312 coconuts</b></span>
          </div>
        </Reveal>
      </div>

      {/* hill divider into next band */}
      <svg className="hills" viewBox="0 0 1440 120" preserveAspectRatio="none" aria-hidden="true" style={{ marginTop: 'clamp(40px,6vw,80px)' }}>
        <path d="M0 64 Q 240 24 480 56 T 960 52 T 1440 44 L1440 120 L0 120 Z" fill="var(--green-leaf-100)" />
        <path d="M0 84 Q 280 52 560 78 T 1120 74 T 1440 70 L1440 120 L0 120 Z" fill="var(--surface-sunk)" />
      </svg>
    </section>
  );
}
