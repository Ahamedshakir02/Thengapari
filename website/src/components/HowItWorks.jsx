import { how } from '../data/content';
import { useReveal } from '../lib/useReveal';
import SectionHead from './ui/SectionHead';
import { StepIcon } from './Icons';

export default function HowItWorks() {
  const [ref, shown] = useReveal({ threshold: 0.3 });

  return (
    <section className="section" id="how">
      <div className="wrap">
        <SectionHead center overline={how.overline} title={how.title} sub={how.sub} />

        <div className="steps" id="steps" ref={ref}>
          <div className="progress" style={{ width: shown ? '84%' : 0, transition: 'width 1.1s cubic-bezier(.22,.61,.36,1)' }} />
          {how.steps.map((s, i) => (
            <div className={`step${shown ? ' in' : ''}`} data-step={i + 1} key={s.title} style={{ transitionDelay: `${i * 160}ms` }}>
              <div className="num">
                <span className="chip">{i + 1}</span>
                <StepIcon name={s.icon} />
              </div>
              <h3>{s.title}</h3>
              <p>{s.body}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
