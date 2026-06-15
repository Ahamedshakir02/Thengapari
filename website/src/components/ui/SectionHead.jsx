import Reveal from './Reveal';

/** Overline + title + sub used at the top of most sections. */
export default function SectionHead({ overline, title, sub, center = false, tag, maxWidth }) {
  return (
    <Reveal className={`section-head${center ? ' center' : ''}`} style={maxWidth ? { maxWidth } : undefined}>
      {tag ? <span className="pilot-tag">{tag}</span> : <span className="overline">{overline}</span>}
      <h2 className="section-title">{title}</h2>
      {sub && <p className="section-sub">{sub}</p>}
    </Reveal>
  );
}
