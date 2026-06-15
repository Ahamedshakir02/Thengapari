import { useEffect, useState } from 'react';
import logoMark from '../assets/logo-mark.svg';
import { nav as navLinks } from '../data/content';
import { useSignup } from '../lib/signup';

export default function Nav() {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const { selectType } = useSignup();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener('scroll', onScroll, { passive: true });
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  useEffect(() => {
    const onKey = (e) => e.key === 'Escape' && setOpen(false);
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, []);

  const go = (type) => (e) => {
    e.preventDefault();
    setOpen(false);
    selectType(type);
  };

  const Brand = () => (
    <a className="brand" href="#top" aria-label="ThengaPari home">
      <img className="mark" src={logoMark} alt="" width="38" height="38" />
      <span className="name">
        <b>ThengaPari</b>
        <span>തേങ്ങാപ്പറി</span>
      </span>
    </a>
  );

  return (
    <>
      <header className={`nav${scrolled ? ' scrolled' : ''}`} id="nav">
        <div className="wrap nav-inner">
          <Brand />
          <nav className="nav-links" aria-label="Primary">
            {navLinks.map((l) => (
              <a key={l.href} href={l.href}>{l.label}</a>
            ))}
          </nav>
          <div className="nav-cta">
            <a href="#signup" className="btn btn-outline" onClick={go('business')}>For businesses</a>
            <a href="#signup" className="btn btn-accent" onClick={go('homeowner')}>Get started</a>
            <button
              className="nav-toggle"
              aria-label="Open menu"
              aria-expanded={open}
              onClick={() => setOpen((o) => !o)}
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round"><path d="M3 6h18M3 12h18M3 18h18" /></svg>
            </button>
          </div>
        </div>
      </header>
      <div className={`mobile-menu${open ? ' open' : ''}`}>
        {navLinks.map((l) => (
          <a key={l.href} href={l.href} onClick={() => setOpen(false)}>{l.label}</a>
        ))}
        <a href="#signup" className="btn btn-outline" onClick={go('business')}>For businesses</a>
        <a href="#signup" className="btn btn-accent" onClick={go('homeowner')}>Get started</a>
      </div>
    </>
  );
}
