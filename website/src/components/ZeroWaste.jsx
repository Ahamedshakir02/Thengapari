import { zero } from '../data/content';
import SectionHead from './ui/SectionHead';
import Reveal from './ui/Reveal';
import { FlowIcon, ArrowRight } from './Icons';

export default function ZeroWaste() {
  return (
    <section className="section zero" id="zerowaste">
      <span className="leafdot" style={{ width: 220, height: 220, background: 'var(--green-600)', top: -60, right: -40 }} />
      <span className="leafdot" style={{ width: 160, height: 160, background: 'var(--green-sage-500)', bottom: -50, left: -30, opacity: 0.3 }} />
      <div className="wrap">
        <SectionHead overline={zero.overline} title={zero.title} sub={zero.sub} maxWidth={760} />

        <div className="flows">
          {zero.flows.map((f, i) => (
            <Reveal className="flow" delayStep={i} key={f.fromLabel}>
              <div className="fline">
                <div className="node">
                  <span className="bubble from"><FlowIcon name={f.from} /></span>
                  <b>{f.fromLabel}</b>
                </div>
                <span className="arr"><ArrowRight /></span>
                <div className="node">
                  <span className="bubble to"><FlowIcon name={f.to} /></span>
                  <b>{f.toLabel}</b>
                </div>
              </div>
              <p className="cap">{f.cap}</p>
            </Reveal>
          ))}
        </div>

        <Reveal className="zero-note">
          <span className="pill">{zero.note.pill}</span>
          <span>{zero.note.text}</span>
        </Reveal>
      </div>
    </section>
  );
}
