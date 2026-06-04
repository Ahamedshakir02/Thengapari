// app.jsx — worker app shell: routing, demo orchestration, theme tweaks, phone frame

const TWEAK_DEFAULTS = /*EDITMODE-BEGIN*/{
  "online": true,
  "radar": "Sweep",
  "accent": "Balanced",
  "palette": "Emerald",
  "reliability": 94,
  "countdown": 38,
  "language": "Both"
}/*EDITMODE-END*/;

const LANG = { English: 'en', Both: 'both', Malayalam: 'ml' };
const LANG_CYCLE = ['English', 'Both', 'Malayalam'];
const RADAR = { Sweep: 'sweep', Rings: 'rings', Sonar: 'sonar' };
const ACCENT = {
  Soft:     { a: '#E7B45E', a2: '#F4CE8C', glow: '.16' },
  Balanced: { a: '#F4A52A', a2: '#FBBA4D', glow: '.30' },
  Bold:     { a: '#FF9E0F', a2: '#FFB733', glow: '.52' },
};

// Palette = whole canvas + teal ramp hue family (amber accent stays)
const PALETTES = {
  Emerald: {
    bg: '#07332A', bg2: '#0A3E32', bgDeep: '#052A22', glowTop: '#0F6B52',
    surface: '#0C4A3B', surface2: '#0A4034', teal500: '#12876B', teal300: '#5FC6A2', teal100: '#CFEFE0',
    line: 'rgba(207,239,224,.13)', lineStrong: 'rgba(207,239,224,.26)', fg2: '#BCE0D0', fg3: '#74B7A0', good: '#5FCF95',
  },
  Teal: {
    bg: '#08332F', bg2: '#0A3C36', bgDeep: '#062925', glowTop: '#0F5C52',
    surface: '#0E5249', surface2: '#0C463F', teal500: '#15786B', teal300: '#6FB6AB', teal100: '#D6ECE7',
    line: 'rgba(214,236,231,.13)', lineStrong: 'rgba(214,236,231,.26)', fg2: '#BDDDD5', fg3: '#7FB4AB', good: '#57C98B',
  },
  Indigo: {
    bg: '#0A2A3D', bg2: '#0E3349', bgDeep: '#07202F', glowTop: '#135E7E',
    surface: '#123F57', surface2: '#0F3850', teal500: '#1E6E92', teal300: '#6FB0CE', teal100: '#D6E9F2',
    line: 'rgba(214,231,242,.13)', lineStrong: 'rgba(214,231,242,.26)', fg2: '#BDD4E0', fg3: '#7FA8BC', good: '#4FC2C9',
  },
};

const JOBS = [
  { id: 1, time: '11:00', ampm: 'AM', title: 'Tender coconut climb', titleMl: 'കരിക്ക് കയറ്റം', payout: '420', place: 'Maple Grove', dist: '2.4 km', status: 'next' },
  { id: 2, time: '1:30', ampm: 'PM', title: 'Coconut husking', titleMl: 'തേങ്ങ പൊതിക്കൽ', payout: '380', place: 'Parambil Estate', dist: '1.8 km', status: 'scheduled' },
  { id: 3, time: '4:00', ampm: 'PM', title: 'Palm trimming', titleMl: 'പന വെട്ടൽ', payout: '300', place: 'Vadakke Padam', dist: '3.1 km', status: 'scheduled' },
];
const WEEK = [
  { d: 'M', v: 980 }, { d: 'T', v: 1240 }, { d: 'W', v: 760 }, { d: 'T', v: 1500 },
  { d: 'F', v: 1100 }, { d: 'S', v: 1240 }, { d: 'S', v: 0 },
];

function App() {
  const [t, setTweak] = useTweaks(TWEAK_DEFAULTS);
  const lang = LANG[t.language] || 'both';
  const acc = ACCENT[t.accent] || ACCENT.Balanced;
  const pal = PALETTES[t.palette] || PALETTES.Emerald;

  const [online, setOnline] = React.useState(!!t.online);
  const [screen, setScreen] = React.useState('home');
  const [pingNonce, setPingNonce] = React.useState(0);
  const [earnings, setEarnings] = React.useState(1240);
  const [jobsDone, setJobsDone] = React.useState(4);
  const pingTimer = React.useRef(null);

  // keep online in sync if the tweak default changes
  React.useEffect(() => { setOnline(!!t.online); }, [t.online]);

  const goPing = React.useCallback(() => {
    clearTimeout(pingTimer.current);
    setPingNonce(n => n + 1);
    setScreen('ping');
  }, []);

  const onToggleOnline = () => {
    setOnline(prev => {
      const next = !prev;
      clearTimeout(pingTimer.current);
      if (next && screen === 'home') {
        pingTimer.current = setTimeout(goPing, 1700);
      }
      return next;
    });
  };

  const completeJob = (rating) => {
    setEarnings(e => e + 380);
    setJobsDone(j => j + 1);
    setScreen('home');
  };

  React.useEffect(() => () => clearTimeout(pingTimer.current), []);

  // bottom-nav routing
  const NAV_SCREEN = { home: 'home', jobs: 'jobs', earn: 'wallet', you: 'profile' };
  const onNav = (id) => setScreen(NAV_SCREEN[id] || 'home');
  const cycleLang = () => {
    const i = LANG_CYCLE.indexOf(t.language);
    setTweak('language', LANG_CYCLE[(i + 1) % LANG_CYCLE.length]);
  };

  const themeVars = {
    '--w-bg': pal.bg, '--w-bg-2': pal.bg2, '--w-bg-deep': pal.bgDeep, '--w-glow-top': pal.glowTop,
    '--w-surface': pal.surface, '--w-surface-2': pal.surface2,
    '--w-teal-500': pal.teal500, '--w-teal-300': pal.teal300, '--w-teal-100': pal.teal100,
    '--w-line': pal.line, '--w-line-strong': pal.lineStrong,
    '--w-fg2': pal.fg2, '--w-fg3': pal.fg3, '--w-good': pal.good,
    '--w-accent': acc.a, '--w-accent-2': acc.a2, '--w-accent-glow': acc.glow,
    width: '100%', height: '100%',
  };

  let body;
  if (screen === 'ping') {
    body = <PingScreen key={pingNonce} lang={lang} duration={t.countdown} radarStyle={RADAR[t.radar] || 'sweep'}
      onAccept={() => setScreen('navigate')} onDecline={() => setScreen('home')} onExpire={() => setScreen('home')} />;
  } else if (screen === 'navigate') {
    body = <NavigateScreen lang={lang} onArrived={() => setScreen('complete')} onBack={() => setScreen('home')} />;
  } else if (screen === 'complete') {
    body = <CompleteScreen lang={lang} onDone={completeJob} />;
  } else if (screen === 'jobs') {
    body = <JobsScreen lang={lang} onOpenJob={() => setScreen('navigate')} onNav={onNav} />;
  } else if (screen === 'wallet') {
    body = <WalletScreen lang={lang} balance={2380} onNav={onNav} />;
  } else if (screen === 'profile') {
    body = <ProfileScreen lang={lang} langLabel={t.language} onSetLang={cycleLang} reliability={t.reliability} onNav={onNav} />;
  } else {
    body = <HomeScreen lang={lang} online={online} onToggleOnline={onToggleOnline}
      earnings={earnings} jobsDone={jobsDone} reliability={t.reliability} jobs={JOBS} weekData={WEEK}
      onOpenJob={() => setScreen('navigate')} onSimulatePing={goPing} onNav={onNav} />;
  }

  return (
    <React.Fragment>
      <AndroidDevice width={406} height={858} dark bg={pal.bg}>
        <div className="worker" style={themeVars}>{body}</div>
      </AndroidDevice>

      <TweaksPanel>
        <TweakSection label="Availability" />
        <TweakToggle label="Start online" value={t.online} onChange={v => setTweak('online', v)} />
        <TweakButton label="Trigger a job ping" onClick={goPing} />

        <TweakSection label="Navigate" />
        <TweakRadio label="Go to screen" value={screen === 'wallet' ? 'Wallet' : screen === 'jobs' ? 'Jobs' : screen === 'profile' ? 'Profile' : 'Home'}
          options={['Home', 'Jobs', 'Wallet', 'Profile']}
          onChange={v => setScreen({ Home: 'home', Jobs: 'jobs', Wallet: 'wallet', Profile: 'profile' }[v])} />

        <TweakSection label="Job ping" />
        <TweakRadio label="Radar style" value={t.radar} options={['Sweep', 'Rings', 'Sonar']} onChange={v => setTweak('radar', v)} />
        <TweakSlider label="Respond window" value={t.countdown} min={15} max={60} step={1} unit="s" onChange={v => setTweak('countdown', v)} />

        <TweakSection label="Worker" />
        <TweakSlider label="Reliability score" value={t.reliability} min={80} max={100} step={1} unit="%" onChange={v => setTweak('reliability', v)} />

        <TweakSection label="Theme" />
        <TweakRadio label="Palette" value={t.palette} options={['Emerald', 'Teal', 'Indigo']} onChange={v => setTweak('palette', v)} />
        <TweakRadio label="Accent intensity" value={t.accent} options={['Soft', 'Balanced', 'Bold']} onChange={v => setTweak('accent', v)} />

        <TweakSection label="Language" />
        <TweakRadio label="Labels" value={t.language} options={['English', 'Both', 'Malayalam']} onChange={v => setTweak('language', v)} />
      </TweaksPanel>
    </React.Fragment>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
