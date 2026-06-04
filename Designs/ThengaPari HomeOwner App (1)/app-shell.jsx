// app-shell.jsx — phone chrome (status bar, gesture nav, bottom nav, top bar),
// the Lbl bilingual label helper, and the PhoneApp state container.

// Language label: renders the active language only. The EN/മല toggle switches
// the whole UI — no inline dual-language subtitles.
function Lbl({ k, lang, className, style, tag = 'span' }) {
  const Tag = tag;
  return <Tag className={className} style={style}>{t(k, lang)}</Tag>;
}

function StatusBar({ dark }) {
  return (
    <div className={'statusbar ' + (dark ? 'on-dark' : 'on-light')}>
      <span className="sb-time">9:41</span>
      <span className="punch" />
      <span className="sb-icons">
        <svg width="17" height="12" viewBox="0 0 17 12" fill="none" aria-hidden="true">
          <path d="M1 7.5 8.5 1 16 7.5" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round" opacity=".9"/>
          <path d="M4 9.2 8.5 5l4.5 4.2" stroke="currentColor" strokeWidth="1.4" strokeLinecap="round"/>
        </svg>
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none" aria-hidden="true">
          <rect x="1" y="6" width="2.6" height="5" rx=".6" fill="currentColor" opacity=".5"/>
          <rect x="5" y="4" width="2.6" height="7" rx=".6" fill="currentColor" opacity=".7"/>
          <rect x="9" y="2" width="2.6" height="9" rx=".6" fill="currentColor" opacity=".85"/>
          <rect x="13" y="0" width="2.6" height="11" rx=".6" fill="currentColor"/>
        </svg>
        <svg width="24" height="12" viewBox="0 0 24 12" fill="none" aria-hidden="true">
          <rect x="1" y="1.5" width="19" height="9" rx="2.4" stroke="currentColor" strokeWidth="1.2" opacity=".55"/>
          <rect x="2.6" y="3" width="14" height="6" rx="1.3" fill="currentColor"/>
          <rect x="21" y="4" width="1.8" height="4" rx=".9" fill="currentColor" opacity=".55"/>
        </svg>
      </span>
    </div>
  );
}

function GestureNav({ dark }) {
  return <div className={'gesturenav ' + (dark ? 'on-dark' : 'on-light')}><span className="pill" /></div>;
}

function TopBar({ title, onBack, lang, right }) {
  return (
    <div className="topbar">
      <button className="iconbtn" onClick={onBack} aria-label="Back"><Icon name="chevron-left" size={20} /></button>
      <span className="tb-title">{t(title, lang)}</span>
      {right}
    </div>
  );
}

const NAV = [
  { id: 'home', icon: 'home', k: 'nav_home' },
  { id: 'schedule', icon: 'calendar', k: 'nav_schedule' },
  { id: 'reports', icon: 'report', k: 'nav_reports' },
  { id: 'profile', icon: 'profile', k: 'nav_profile' },
];

function BottomNav({ active, onNav, lang }) {
  return (
    <nav className="bottomnav">
      {NAV.map((n) => {
        const on = active === n.id || (active === 'report' && n.id === 'reports')
          || (active === 'book' && n.id === 'home') || (active === 'tracker' && n.id === 'home');
        return (
          <button key={n.id} className={'navitem' + (on ? ' on' : '')} onClick={() => onNav(n.id)}>
            <span className="ni-bubble"><Icon name={n.icon} size={22} sw={on ? 2.2 : 1.9} /></span>
            <span className="ni-label">{t(n.k, lang)}</span>
          </button>
        );
      })}
    </nav>
  );
}

// ── PhoneApp ──────────────────────────────────────────────────────────────
function PhoneApp({ initial = 'home', tweaks, lang, setLang }) {
  const [screen, setScreen] = React.useState(initial);
  const [anim, setAnim] = React.useState('enter-tab');
  const [booking, setBooking] = React.useState({ cropId: 'coconut', dayIdx: 1, ripe: true });
  const [confirm, setConfirm] = React.useState(false);

  const go = (next, mode = 'push') => {
    setAnim(mode === 'back' ? 'enter-back' : mode === 'tab' ? 'enter-tab' : 'enter-push');
    setScreen(next);
  };
  const onNav = (id) => {
    const target = id === 'reports' ? 'report' : id;
    go(target, 'tab');
  };

  const common = { lang, setLang, tweaks, go, booking, setBooking, screen };
  const dark = screen === 'home'; // hero is dark at the top → light status icons

  let body = null;
  if (screen === 'home') body = <HomeScreen {...common} />;
  else if (screen === 'book') body = <BookScreen {...common} onConfirm={() => setConfirm(true)} />;
  else if (screen === 'tracker') body = <TrackerScreen {...common} />;
  else if (screen === 'report') body = <ReportScreen {...common} />;
  else if (screen === 'schedule') body = <ScheduleScreen {...common} />;
  else if (screen === 'profile') body = <ProfileScreen {...common} />;

  const showNav = ['home', 'schedule', 'report', 'profile'].includes(screen);
  const gut = tweaks.density === 'comfy' ? '22px' : '16px';
  const gap = tweaks.density === 'comfy' ? '16px' : '13px';

  return (
    <div className="phone">
      <div className="phone-screen">
        <div className="app-root" style={{ '--gut': gut, '--card-gap': gap }}>
          <StatusBar dark={dark} />
          <div className="viewport">
            <div key={screen} className={'screen ' + anim}>
              {body}
            </div>
            {confirm && (
              <ConfirmOverlay booking={booking} lang={lang}
                onClose={() => setConfirm(false)}
                onTrack={() => { setConfirm(false); go('tracker', 'push'); }} />
            )}
          </div>
          {showNav && <BottomNav active={screen} onNav={onNav} lang={lang} />}
          <GestureNav dark={false} />
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { Lbl, StatusBar, GestureNav, TopBar, BottomNav, PhoneApp });
