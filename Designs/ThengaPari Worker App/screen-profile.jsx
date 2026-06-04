// screen-profile.jsx — Profile: identity, stats, skills, KYC documents, settings

const SKILLS = [
  { k: 'skill_climb', icon: 'route', lvl: 'lvl_expert', jobs: 182, pct: 100 },
  { k: 'skill_tender', icon: 'coconut', lvl: 'lvl_expert', jobs: 96, pct: 92 },
  { k: 'skill_husk', icon: 'coconut', lvl: 'lvl_skilled', jobs: 64, pct: 70 },
  { k: 'skill_trim', icon: 'leaf', lvl: 'lvl_learning', jobs: 18, pct: 34 },
];

const DOCS = [
  { k: 'aadhaar', icon: 'badge', meta: 'XXXX XXXX 4471', ok: true },
  { k: 'bank_acc', icon: 'bank', meta: 'Federal Bank ••8820', ok: true },
  { k: 'police_v', icon: 'shield', meta: 'Thrissur Rural · 2025', ok: true },
  { k: 'insurance', icon: 'shield', meta: 'ThengaSuraksha · active', ok: true, active: true },
];

const lvlStyle = {
  lvl_expert:   { fg: 'var(--w-accent-2)', bg: 'rgba(244,165,42,.16)' },
  lvl_skilled:  { fg: 'var(--w-teal-300)', bg: 'rgba(111,182,171,.16)' },
  lvl_learning: { fg: 'var(--w-fg2)', bg: 'var(--w-surface-2)' },
};

function ProfileStat({ value, label, icon, accent }) {
  return (
    <div style={{ flex: 1, textAlign: 'center', padding: '4px 2px' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5 }}>
        {icon && <Icon name={icon} size={15} color={accent ? 'var(--w-accent)' : 'var(--w-teal-300)'} />}
        <span className="mono" style={{ font: '800 22px/1 var(--font-mono)', color: 'var(--w-fg1)' }}>{value}</span>
      </div>
      <div className="ml-cap" style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 6 }}>{label}</div>
    </div>
  );
}

function SkillRow({ s, lang }) {
  const l = lvlStyle[s.lvl];
  return (
    <div style={{ padding: '13px 0' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 38, height: 38, borderRadius: 11, background: 'var(--w-surface-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
          <Icon name={s.icon} size={19} color="var(--w-teal-300)" sw={2.1} />
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body)', fontWeight: 600, color: 'var(--w-fg1)' }}>{tx(lang, s.k).primary}</div>
          <div style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 2 }}><span className="mono">{s.jobs}</span> {lang === 'ml' ? 'ജോലികൾ' : 'jobs'}</div>
        </div>
        <span className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-overline)', fontWeight: 700, color: l.fg, background: l.bg, padding: '4px 10px', borderRadius: 999, fontSize: 11, flexShrink: 0 }}>{tx(lang, s.lvl).primary}</span>
      </div>
      <div style={{ height: 6, borderRadius: 999, background: 'var(--w-surface-2)', marginTop: 11, overflow: 'hidden' }}>
        <div style={{ height: '100%', width: `${s.pct}%`, borderRadius: 999,
          background: s.lvl === 'lvl_expert' ? 'linear-gradient(90deg, var(--w-accent), var(--w-accent-2))' : 'var(--w-teal-500)' }} />
      </div>
    </div>
  );
}

function DocRow({ d, lang }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 0' }}>
      <div style={{ width: 40, height: 40, borderRadius: 11, background: 'var(--w-surface-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
        <Icon name={d.icon} size={19} color="var(--w-teal-300)" sw={2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body)', fontWeight: 600, color: 'var(--w-fg1)' }}>{tx(lang, d.k).primary}</div>
        <div className="mono" style={{ font: '500 12px/1.3 var(--font-mono)', color: 'var(--w-fg3)', marginTop: 2 }}>{d.meta}</div>
      </div>
      <div style={{ display: 'flex', alignItems: 'center', gap: 5, flexShrink: 0, color: 'var(--w-good)' }}>
        <Icon name="check-c" size={16} color="var(--w-good)" />
        <span className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-caption)', fontWeight: 700, color: 'var(--w-good)' }}>{tx(lang, d.active ? 'active_s' : 'verified_s').primary}</span>
      </div>
    </div>
  );
}

function SettingRow({ icon, label, lang, value, danger, last }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '15px 0', borderBottom: last ? 'none' : '1px solid var(--w-line)' }}>
      <Icon name={icon} size={20} color={danger ? 'var(--w-bad)' : 'var(--w-teal-300)'} sw={2} />
      <span className={lang === 'ml' ? 'ml' : ''} style={{ flex: 1, font: 'var(--t-body)', fontWeight: 500, color: danger ? 'var(--w-bad)' : 'var(--w-fg1)' }}>{label}</span>
      {value && <span style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg3)' }}>{value}</span>}
      {!danger && <Icon name="chevron" size={18} color="var(--w-fg3)" />}
    </div>
  );
}

function ProfileCard({ lang, k, sub, icon, children }) {
  return (
    <div style={{ marginTop: 14, background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '16px 16px 8px', boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
        <Icon name={icon} size={17} color="var(--w-accent-2)" />
        <h3 className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ margin: 0, font: 'var(--t-title)', color: 'var(--w-fg1)' }}>{tx(lang, k).primary}</h3>
      </div>
      {children}
    </div>
  );
}

function ProfileScreen({ lang, langLabel, onSetLang, reliability = 94, onNav }) {
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0, background: 'var(--w-bg)' }}>
      <div style={{ flex: 1, minHeight: 0, overflow: 'auto', padding: '16px 16px 22px' }}>
        <ScreenHeader lang={lang} k="profile_title" right={<HeaderIconBtn icon="edit" />} />

        {/* identity */}
        <div style={{ background: 'linear-gradient(150deg, var(--w-glow-top) 0%, var(--w-surface) 60%)', borderRadius: 'var(--r-xl)', padding: '20px 18px 18px',
          boxShadow: '0 12px 30px rgba(0,0,0,.26), inset 0 0 0 1px var(--w-line-strong)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 15 }}>
            <div style={{ position: 'relative', width: 66, height: 66, borderRadius: '50%', flexShrink: 0,
              background: 'linear-gradient(145deg, var(--w-teal-500), var(--w-bg-2))', boxShadow: 'inset 0 0 0 1.5px var(--w-line-strong)',
              display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <span className="disp" style={{ fontSize: 27, fontWeight: 700, color: '#fff' }}>R</span>
              <span style={{ position: 'absolute', right: -2, bottom: -2, width: 22, height: 22, borderRadius: '50%', background: 'var(--w-good)', boxShadow: '0 0 0 3px var(--w-surface)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="check" size={12} color="#fff" sw={3.4} />
              </span>
            </div>
            <div style={{ flex: 1, minWidth: 0 }}>
              <h2 className="disp" style={{ margin: 0, font: '700 22px/26px var(--font-display)', color: '#fff' }}>Ravi Krishnan</h2>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginTop: 5 }}>
                <Icon name="badge" size={15} color="var(--w-accent-2)" />
                <span className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body-sm)', color: 'var(--w-teal-100)', fontWeight: 600 }}>{tx(lang, 'verified_climber').primary}</span>
              </div>
            </div>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', marginTop: 18, paddingTop: 16, borderTop: '1px solid var(--w-line)' }}>
            <ProfileStat value="4.9" label={tx(lang, 'avg_rating').primary} icon="star" accent />
            <div style={{ width: 1, height: 30, background: 'var(--w-line)' }} />
            <ProfileStat value="360" label={tx(lang, 'total_jobs').primary} icon="check-c" />
            <div style={{ width: 1, height: 30, background: 'var(--w-line)' }} />
            <ProfileStat value={reliability + '%'} label={tx(lang, 'reliability').primary} icon="shield" />
          </div>
        </div>

        {/* lifetime earnings */}
        <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 14, background: 'linear-gradient(160deg, rgba(244,165,42,.16), rgba(244,165,42,.04))',
          borderRadius: 'var(--r-lg)', padding: '16px 18px', boxShadow: 'inset 0 0 0 1px rgba(244,165,42,.28)' }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: 'rgba(244,165,42,.18)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Icon name="wallet" size={22} color="var(--w-accent-2)" />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-caption)', color: 'var(--w-fg2)', fontWeight: 600 }}>{tx(lang, 'lifetime').primary}</div>
            <Rupee value="1,42,800" size={26} weight={800} color="var(--w-fg1)" />
          </div>
          <div style={{ textAlign: 'right', flexShrink: 0 }}>
            <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)' }}>{tx(lang, 'member_since').primary}</div>
            <div className="mono" style={{ font: '700 14px/1.3 var(--font-mono)', color: 'var(--w-teal-100)', marginTop: 2 }}>Mar 2023</div>
          </div>
        </div>

        {/* skills */}
        <ProfileCard lang={lang} k="skills" icon="route">
          {SKILLS.map((s, i) => (
            <React.Fragment key={s.k}>
              {i > 0 && <div style={{ height: 1, background: 'var(--w-line)' }} />}
              <SkillRow s={s} lang={lang} />
            </React.Fragment>
          ))}
        </ProfileCard>

        {/* documents / KYC */}
        <ProfileCard lang={lang} k="documents" icon="doc">
          {DOCS.map((d, i) => (
            <React.Fragment key={d.k}>
              {i > 0 && <div style={{ height: 1, background: 'var(--w-line)' }} />}
              <DocRow d={d} lang={lang} />
            </React.Fragment>
          ))}
        </ProfileCard>

        {/* settings */}
        <ProfileCard lang={lang} k="settings" icon="gear">
          <button onClick={onSetLang} style={{ width: '100%', border: 'none', background: 'transparent', textAlign: 'left', padding: 0 }}>
            <SettingRow icon="leaf" label={tx(lang, 'set_language').primary} lang={lang} value={langLabel} />
          </button>
          <SettingRow icon="bell" label={tx(lang, 'set_notif').primary} lang={lang} value={lang === 'ml' ? 'ഓൺ' : 'On'} />
          <SettingRow icon="help" label={tx(lang, 'set_help').primary} lang={lang} />
          <SettingRow icon="logout" label={tx(lang, 'set_logout').primary} lang={lang} danger last />
        </ProfileCard>

        <div style={{ textAlign: 'center', marginTop: 18, font: 'var(--t-caption)', color: 'var(--w-fg3)' }}>ThengaPari Worker · v2.4.0</div>
      </div>

      <BottomNav lang={lang} active="you" onNav={onNav} />
    </div>
  );
}

Object.assign(window, { ProfileScreen, SkillRow, DocRow, SettingRow });
