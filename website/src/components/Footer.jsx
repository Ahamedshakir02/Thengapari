import logoMark from '../assets/logo-mark.svg';
import { brand, footer } from '../data/content';

export default function Footer() {
  return (
    <footer className="footer">
      <div className="wrap">
        <div className="foot-grid">
          <div className="foot-brand">
            <a className="brand" href="#top" aria-label="ThengaPari home">
              <img className="mark" src={logoMark} alt="" width="38" height="38" />
              <span className="name"><b>ThengaPari</b><span>തേങ്ങാപ്പറി</span></span>
            </a>
            <p>{footer.blurb}</p>
            <div className="foot-contact">
              <a href={`mailto:${brand.email}`}><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3 7 9 6 9-6" /></svg>{brand.email}</a>
              <a href="tel:+914840000000"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M5 4h4l2 5-3 2a12 12 0 0 0 5 5l2-3 5 2v4a2 2 0 0 1-2 2A16 16 0 0 1 3 6a2 2 0 0 1 2-2" /></svg>{brand.phone}</a>
              <a href="#"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z" /><circle cx="12" cy="10" r="2.5" /></svg>{brand.location}</a>
            </div>
            <div className="socials">
              <a href="#" aria-label="Instagram"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="3" width="18" height="18" rx="5" /><circle cx="12" cy="12" r="4" /><circle cx="17.5" cy="6.5" r="1" fill="currentColor" stroke="none" /></svg></a>
              <a href="#" aria-label="YouTube"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="6" width="18" height="12" rx="4" /><path d="M11 9.5v5l4-2.5z" fill="currentColor" stroke="none" /></svg></a>
              <a href="#" aria-label="LinkedIn"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><rect x="3" y="3" width="18" height="18" rx="4" /><path d="M8 11v5M8 8v.01M12 16v-3a2 2 0 0 1 4 0v3" strokeLinecap="round" /></svg></a>
            </div>
          </div>

          {footer.cols.map((col) => (
            <div className="foot-col" key={col.h}>
              <h4>{col.h}</h4>
              {col.links.map((l) => (
                <a href={l.href} key={l.label}>
                  {l.label}
                  {l.ext && <span className="badge-new">↗</span>}
                </a>
              ))}
            </div>
          ))}
        </div>

        <div className="foot-bottom">
          <span>{footer.copyright}</span>
          <span className="made">{footer.made} <b>· {footer.madeMl}</b></span>
        </div>
      </div>
    </footer>
  );
}
