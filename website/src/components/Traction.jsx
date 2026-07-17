import { traction } from '../data/content';
import { useReveal, useCountUp } from '../lib/useReveal';
import SectionHead from './ui/SectionHead';
import Reveal from './ui/Reveal';

function Stat({ stat, delayStep }) {
  const [ref, shown] = useReveal({ threshold: 0.4 });
  const number = useCountUp(stat.count, { active: shown });
  // 'k' and '%' get the accent-coloured .suf treatment; '+' stays inline.
  const fancy = stat.suffix === 'k' || stat.suffix === '%';
  return (
    <Reveal className="stat" delayStep={delayStep}>
      <div className="n" ref={ref}>
        {number}
        {fancy ? <span className="suf">{stat.suffix}</span> : stat.suffix}
      </div>
      <div className="lbl">{stat.label}</div>
      <div className="sub">{stat.sub}</div>
    </Reveal>
  );
}

export default function Traction() {
  return (
    <section className="section" id="traction">
      <div className="wrap">
        <SectionHead center tag={traction.tag} title={traction.title} sub={traction.sub} />

        <div className="stats">
          {traction.stats.map((s, i) => (
            <Stat stat={s} delayStep={i} key={s.label} />
          ))}
        </div>

        <Reveal className="logos">
          <p className="ltitle">{traction.logosTitle}</p>
          <div className="logo-row">
            {traction.logos.map((l) => (
              <div className="logo-slot" key={l}><span className="dotmark" />{l}</div>
            ))}
          </div>
        </Reveal>
      </div>
    </section>
  );
}
