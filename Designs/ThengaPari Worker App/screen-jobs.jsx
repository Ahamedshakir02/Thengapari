// screen-jobs.jsx — Jobs: upcoming (grouped by day) + history with ratings

const UPCOMING = {
  jobs_today: [
    { id: 1, time: '11:00', ampm: 'AM', title: 'Tender coconut climb', titleMl: 'കരിക്ക് കയറ്റം', payout: '420', place: 'Maple Grove', dist: '2.4 km', status: 'next' },
    { id: 2, time: '1:30', ampm: 'PM', title: 'Coconut husking', titleMl: 'തേങ്ങ പൊതിക്കൽ', payout: '380', place: 'Parambil Estate', dist: '1.8 km', status: 'scheduled' },
    { id: 3, time: '4:00', ampm: 'PM', title: 'Palm trimming', titleMl: 'പന വെട്ടൽ', payout: '300', place: 'Vadakke Padam', dist: '3.1 km', status: 'scheduled' },
  ],
  jobs_tomorrow: [
    { id: 4, time: '8:30', ampm: 'AM', title: 'Coconut climbing', titleMl: 'തെങ്ങുകയറ്റം', payout: '460', place: 'Cheruvath Farm', dist: '4.2 km', status: 'scheduled' },
    { id: 5, time: '2:00', ampm: 'PM', title: 'Coconut husking', titleMl: 'തേങ്ങ പൊതിക്കൽ', payout: '350', place: 'Kunnath Grove', dist: '2.0 km', status: 'scheduled' },
  ],
};

const HISTORY = [
  { id: 11, date: 'Yesterday', title: 'Coconut husking', titleMl: 'തേങ്ങ പൊതിക്കൽ', payout: '380', place: 'Parambil Estate', count: '24 nuts', rating: 5 },
  { id: 12, date: 'Yesterday', title: 'Palm trimming', titleMl: 'പന വെട്ടൽ', payout: '300', place: 'Vadakke Padam', count: '6 palms', rating: 4 },
  { id: 13, date: 'Mon 2 Jun', title: 'Tender coconut climb', titleMl: 'കരിക്ക് കയറ്റം', payout: '420', place: 'Maple Grove', count: '32 nuts', rating: 5 },
  { id: 14, date: 'Sun 1 Jun', title: 'Coconut climbing', titleMl: 'തെങ്ങുകയറ്റം', payout: '460', place: 'Cheruvath Farm', count: '5 trees', rating: 5 },
  { id: 15, date: 'Sat 31 May', title: 'Coconut husking', titleMl: 'തേങ്ങ പൊതിക്കൽ', payout: '340', place: 'Kunnath Grove', count: '22 nuts', rating: 4 },
];

function SegTabs({ tabs, value, onChange }) {
  return (
    <div style={{ display: 'flex', gap: 4, padding: 4, background: 'var(--w-surface-2)', borderRadius: 'var(--r-pill)',
      boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
      {tabs.map(t => {
        const on = t.id === value;
        return (
          <button key={t.id} onClick={() => onChange(t.id)} style={{ flex: 1, border: 'none', borderRadius: 'var(--r-pill)',
            padding: '9px 10px', background: on ? 'var(--w-accent)' : 'transparent',
            color: on ? 'var(--w-accent-press)' : 'var(--w-fg2)', font: '700 14px/1 var(--font-text)',
            boxShadow: on ? '0 4px 14px rgba(244,165,42,.35)' : 'none', transition: 'color .2s, background .2s' }}>
            {t.label}
          </button>
        );
      })}
    </div>
  );
}

function MiniStat({ icon, label, children }) {
  return (
    <div style={{ flex: 1, background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '13px 15px 14px',
      boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 8 }}>
        <Icon name={icon} size={15} color="var(--w-teal-300)" sw={2.2} />
        <span style={{ font: 'var(--t-caption)', color: 'var(--w-fg2)', fontWeight: 600 }}>{label}</span>
      </div>
      {children}
    </div>
  );
}

function HistoryRow({ job, lang }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 14, background: 'var(--w-surface)',
      borderRadius: 'var(--r-lg)', padding: '14px 16px', boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
      <div style={{ width: 40, height: 40, borderRadius: 12, flexShrink: 0, background: 'var(--w-surface-2)',
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name="check-c" size={20} color="var(--w-good)" sw={2.2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-title)', color: 'var(--w-fg1)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {lang === 'ml' ? job.titleMl : job.title}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginTop: 4 }}>
          <span style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)' }}>{job.place}</span>
          <span style={{ width: 3, height: 3, borderRadius: '50%', background: 'var(--w-fg3)' }} />
          <span style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)' }}>{job.count}</span>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 6, flexShrink: 0 }}>
        <Rupee value={job.payout} size={17} color="var(--w-fg1)" />
        <div style={{ display: 'flex', alignItems: 'center', gap: 3 }}>
          <Icon name="star" size={12} color="var(--w-accent)" />
          <span className="mono" style={{ font: '600 12px/1 var(--font-mono)', color: 'var(--w-fg2)' }}>{job.rating}.0</span>
        </div>
      </div>
    </div>
  );
}

function ScreenHeader({ lang, k, sub, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between', gap: 12, marginBottom: 18 }}>
      <div style={{ minWidth: 0 }}>
        <h1 className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ margin: 0, font: '700 26px/32px var(--font-display)', color: 'var(--w-fg1)', letterSpacing: '-.01em' }}>{tx(lang, k).primary}</h1>
        {sub && <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg3)', marginTop: 3 }}>{tx(lang, sub).primary}</div>}
      </div>
      {right}
    </div>
  );
}

function HeaderIconBtn({ icon }) {
  return (
    <div style={{ width: 44, height: 44, borderRadius: 14, flexShrink: 0, background: 'var(--w-surface)',
      boxShadow: 'inset 0 0 0 1px var(--w-line)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      <Icon name={icon} size={21} color="var(--w-teal-300)" />
    </div>
  );
}

function DayGroup({ lang, k, count, children }) {
  return (
    <div style={{ marginBottom: 18 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 11 }}>
        <span className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ font: 'var(--t-overline)', color: 'var(--w-fg2)', textTransform: 'uppercase', letterSpacing: '.1em' }}>{tx(lang, k).primary}</span>
        <span className="mono" style={{ font: '600 11px/1 var(--font-mono)', color: 'var(--w-accent-2)', background: 'rgba(244,165,42,.14)', padding: '3px 7px', borderRadius: 999 }}>{count}</span>
        <div style={{ flex: 1, height: 1, background: 'var(--w-line)' }} />
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>{children}</div>
    </div>
  );
}

function JobsScreen({ lang, onOpenJob, onNav }) {
  const [tab, setTab] = React.useState('upcoming');
  const weekEarned = HISTORY.reduce((a, b) => a + (+b.payout), 0) + 1100;
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0, background: 'var(--w-bg)' }}>
      <div style={{ flex: 1, minHeight: 0, overflow: 'auto', padding: '16px 16px 22px' }}>
        <ScreenHeader lang={lang} k="jobs_title" sub="jobs_sub" right={<HeaderIconBtn icon="calendar" />} />

        <div style={{ display: 'flex', gap: 12, marginBottom: 16 }}>
          <MiniStat icon="wallet" label={tx(lang, 'earned_week').primary}>
            <Rupee value={weekEarned.toLocaleString('en-IN')} size={24} color="var(--w-fg1)" />
          </MiniStat>
          <MiniStat icon="check-c" label={tx(lang, 'done_week').primary}>
            <span className="mono" style={{ fontSize: 24, fontWeight: 700, color: 'var(--w-fg1)', lineHeight: 1 }}>9</span>
          </MiniStat>
        </div>

        <div style={{ display: 'flex', gap: 4, padding: 4, marginBottom: 18, background: 'var(--w-surface-2)', borderRadius: 'var(--r-pill)', boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
          {[{ id: 'upcoming', label: tx(lang, 'tab_upcoming').primary }, { id: 'history', label: tx(lang, 'tab_history').primary }].map(tb => {
            const on = tb.id === tab;
            return (
              <button key={tb.id} onClick={() => setTab(tb.id)} style={{ flex: 1, border: 'none', borderRadius: 'var(--r-pill)',
                padding: '9px 10px', background: on ? 'var(--w-accent)' : 'transparent',
                color: on ? 'var(--w-accent-press)' : 'var(--w-fg2)', font: '700 14px/1 var(--font-text)',
                boxShadow: on ? '0 4px 14px rgba(244,165,42,.35)' : 'none', transition: 'color .2s, background .2s' }}>
                {tb.label}
              </button>
            );
          })}
        </div>

        {tab === 'upcoming' ? (
          <React.Fragment>
            <DayGroup lang={lang} k="jobs_today" count={UPCOMING.jobs_today.length}>
              {UPCOMING.jobs_today.map(j => <JobCard key={j.id} job={j} lang={lang} onOpen={onOpenJob} />)}
            </DayGroup>
            <DayGroup lang={lang} k="jobs_tomorrow" count={UPCOMING.jobs_tomorrow.length}>
              {UPCOMING.jobs_tomorrow.map(j => <JobCard key={j.id} job={j} lang={lang} onOpen={onOpenJob} />)}
            </DayGroup>
          </React.Fragment>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {HISTORY.map(j => <HistoryRow key={j.id} job={j} lang={lang} />)}
            <div style={{ textAlign: 'center', padding: '14px 0 2px', font: 'var(--t-caption)', color: 'var(--w-fg3)' }}>
              {lang === 'ml' ? 'കഴിഞ്ഞ 7 ദിവസം' : 'Showing last 7 days'}
            </div>
          </div>
        )}
      </div>

      <BottomNav lang={lang} active="jobs" onNav={onNav} />
    </div>
  );
}

Object.assign(window, { JobsScreen, SegTabs, ScreenHeader, HeaderIconBtn, MiniStat });
