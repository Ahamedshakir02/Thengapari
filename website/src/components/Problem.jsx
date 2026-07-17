import { problem } from '../data/content';
import SectionHead from './ui/SectionHead';
import Reveal from './ui/Reveal';
import { ProblemIcon } from './Icons';

export default function Problem() {
  return (
    <section className="section band-leaf" id="problem">
      <div className="wrap">
        <SectionHead overline={problem.overline} title={problem.title} sub={problem.sub} />
        <div className="prob-grid">
          {problem.cards.map((c, i) => (
            <Reveal as="article" className="pcard" delayStep={i} key={c.title}>
              <span className="picon"><ProblemIcon name={c.icon} /></span>
              <h3>{c.title}</h3>
              <p>{c.body}</p>
              <span className="tag">{c.tag}</span>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
