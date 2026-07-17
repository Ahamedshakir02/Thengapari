import { who } from '../data/content';
import { useSignup } from '../lib/signup';
import SectionHead from './ui/SectionHead';
import Reveal from './ui/Reveal';
import { TileArt } from './Icons';

export default function WhoItsFor() {
  const { selectType } = useSignup();

  return (
    <section className="section band-leaf" id="who">
      <div className="wrap">
        <SectionHead center overline={who.overline} title={who.title} sub={who.sub} />
        <div className="tiles">
          {who.tiles.map((t, i) => (
            <Reveal as="article" className={`tile ${t.variant}`} delayStep={i} key={t.role}>
              <span className="tband" />
              <span className="tart"><TileArt name={t.art} /></span>
              <span className="role">{t.role}</span>
              <h3>{t.title}</h3>
              <p>{t.body}</p>
              <a
                href="#signup"
                className="more"
                onClick={(e) => { e.preventDefault(); selectType(t.intent); }}
              >
                {t.cta} <span className="arr">→</span>
              </a>
            </Reveal>
          ))}
        </div>
      </div>
    </section>
  );
}
