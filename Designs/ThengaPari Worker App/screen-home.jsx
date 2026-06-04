// screen-home.jsx — Worker home: online toggle, stats, reliability, jobs, weekly chart, bottom nav

function BigToggle({ online, onToggle, lang }) {
  return (
    <button onClick={onToggle} style={{
      width: '100%', border: 'none', textAlign: 'left',
      borderRadius: 'var(--r-xl)', padding: '18px 20px',
      display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 14,
      background: online
        ? 'linear-gradient(135deg, var(--w-glow-top) 0%, var(--w-surface-2) 100%)'
        : 'var(--w-surface-2)',
      boxShadow: online ? '0 10px 30px rgba(21,120,107,.4), inset 0 0 0 1px rgba(111,182,171,.3)'
                        : 'inset 0 0 0 1px var(--w-line)',
      transition: 'all .35s cubic-bezier(.22,1,.36,1)',
    }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 14, minWidth: 0 }}>
        <div style={{ position: 'relative', width: 14, height: 14, flexShrink: 0 }}>
          <span style={{ position: 'absolute', inset: 0, borderRadius: '50%',
            background: online ? 'var(--w-good)' : 'var(--w-fg3)' }}/>
          {online && <span className="pulse-dot" style={{ position: 'absolute', inset: 0, borderRadius: '50%', background: 'var(--w-good)' }}/>}
        </div>
        <Bi lang={lang} k={online ? 'online' : 'offline'}
          primaryClass="disp"
          primaryStyle={{ font: 'var(--t-h3)', color: 'var(--w-fg1)' }}
          subStyle={{ font: 'var(--t-body-sm)', color: online ? 'var(--w-teal-300)' : 'var(--w-fg3)' }} />
      </div>
      {/* switch */}
      <div style={{ width: 70, height: 40, borderRadius: 999, flexShrink: 0, position: 'relative',
        background: online ? 'var(--w-accent)' : 'rgba(214,236,231,.18)',
        boxShadow: online ? '0 4px 16px rgba(244,165,42,.5)' : 'none',
        transition: 'background .3s' }}>
        <span style={{ position: 'absolute', top: 4, left: online ? 34 : 4, width: 32, height: 32, borderRadius: '50%',
          background: '#fff', boxShadow: '0 2px 6px rgba(0,0,0,.3)', transition: 'left .28s cubic-bezier(.22,1,.36,1)',
          display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          {online && <Icon name="bolt" size={16} color="var(--w-accent-press)" />}
        </span>
      </div>
    </button>
  );
}

function StatCard({ icon, label, sub, accent, children }) {
  return (
    <div style={{ flex: 1, background: accent ? 'linear-gradient(160deg, rgba(244,165,42,.16), rgba(244,165,42,.04))' : 'var(--w-surface)',
      borderRadius: 'var(--r-lg)', padding: '14px 16px 16px',
      boxShadow: accent ? 'inset 0 0 0 1px rgba(244,165,42,.28)' : 'inset 0 0 0 1px var(--w-line)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 7, marginBottom: 10 }}>
        <Icon name={icon} size={16} color={accent ? 'var(--w-accent-2)' : 'var(--w-teal-300)'} sw={2.2} />
        <span style={{ font: 'var(--t-caption)', color: 'var(--w-fg2)', fontWeight: 600 }}>{label}</span>
      </div>
      {children}
      {sub && <div style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 7 }}>{sub}</div>}
    </div>
  );
}

function JobCard({ job, lang, onOpen }) {
  const statusMap = {
    next: { fg: 'var(--w-accent-2)', bg: 'rgba(244,165,42,.16)', label: 'Up next' },
    scheduled: { fg: 'var(--w-teal-300)', bg: 'rgba(111,182,171,.14)', label: 'Scheduled' },
  };
  const s = statusMap[job.status] || statusMap.scheduled;
  return (
    <button onClick={() => onOpen(job)} style={{
      width: '100%', border: 'none', textAlign: 'left', display: 'flex', alignItems: 'center', gap: 14,
      background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '14px 14px 14px 16px',
      boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
      <div style={{ flexShrink: 0, width: 52, textAlign: 'center' }}>
        <div className="mono" style={{ fontSize: 17, fontWeight: 700, color: 'var(--w-fg1)', lineHeight: 1 }}>{job.time}</div>
        <div style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 3 }}>{job.ampm}</div>
      </div>
      <div style={{ width: 1, alignSelf: 'stretch', background: 'var(--w-line)' }}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-title)', color: 'var(--w-fg1)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {lang === 'ml' ? job.titleMl : job.title}
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginTop: 4 }}>
          <Icon name="pin" size={13} color="var(--w-fg3)" />
          <span style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg2)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{job.place} · {job.dist}</span>
        </div>
      </div>
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: 6, flexShrink: 0 }}>
        <Rupee value={job.payout} size={18} color="var(--w-fg1)" />
        <span style={{ font: 'var(--t-overline)', color: s.fg, background: s.bg, padding: '3px 8px', borderRadius: 999, fontSize: 10, textTransform: 'uppercase', letterSpacing: '.05em' }}>{s.label}</span>
      </div>
    </button>
  );
}

function BottomNav({ lang, active = 'home', onNav }) {
  const items = [
    { k: 'nav_home', icon: 'home', id: 'home' },
    { k: 'nav_jobs', icon: 'jobs', id: 'jobs' },
    { k: 'nav_earn', icon: 'wallet', id: 'earn' },
    { k: 'nav_you',  icon: 'user', id: 'you' },
  ];
  return (
    <div style={{ flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'space-around',
      padding: '8px 6px 6px', background: 'color-mix(in srgb, var(--w-bg-deep) 86%, transparent)', backdropFilter: 'blur(12px)',
      borderTop: '1px solid var(--w-line)' }}>
      {items.map(it => {
        const on = it.id === active;
        const { primary } = tx(lang, it.k);
        return (
          <button key={it.id} onClick={() => onNav && onNav(it.id)} style={{ border: 'none', background: 'transparent',
            display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3,
            minWidth: 56, padding: '6px 4px', color: on ? 'var(--w-accent-2)' : 'var(--w-fg3)', transition: 'color .2s' }}>
            <Icon name={it.icon} size={23} color="currentColor" sw={on ? 2.4 : 2} />
            <span className={lang === 'ml' ? 'ml' : ''} style={{ fontSize: 10.5, fontWeight: on ? 700 : 500, color: 'currentColor' }}>{primary}</span>
          </button>
        );
      })}
    </div>
  );
}

function HomeScreen({ lang, online, onToggleOnline, earnings, jobsDone, reliability, jobs, weekData, onOpenJob, onSimulatePing, onNav }) {
  const { primary: relSub } = tx(lang, 'reliability_sub');
  const weekTotal = weekData.reduce((a, b) => a + b.v, 0);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0, background: 'var(--w-bg)' }}>
      <div style={{ flex: 1, minHeight: 0, overflow: 'auto', padding: '14px 16px 22px' }}>
        {/* header */}
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 18, gap: 12 }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <Bi lang={lang} k="greeting" primaryClass="disp"
              primaryStyle={{ font: '700 22px/28px var(--font-display)', color: 'var(--w-fg1)', letterSpacing: '-.01em', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis', display: 'block' }}
              subStyle={{ display: 'none' }} />
            <div style={{ display: 'flex', alignItems: 'center', gap: 5, marginTop: 4 }}>
              <Icon name="pin" size={14} color="var(--w-teal-300)" />
              <span className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg2)' }}>{tx(lang, 'location').primary}</span>
            </div>
          </div>
          <div style={{ position: 'relative', width: 48, height: 48, borderRadius: '50%', flexShrink: 0,
            background: 'linear-gradient(145deg,var(--w-glow-top),var(--w-bg-2))', boxShadow: 'inset 0 0 0 1px var(--w-line-strong)',
            display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span className="disp" style={{ fontSize: 19, fontWeight: 700, color: 'var(--w-teal-100)' }}>R</span>
            <span style={{ position: 'absolute', right: -1, bottom: -1, width: 14, height: 14, borderRadius: '50%',
              background: online ? 'var(--w-good)' : 'var(--w-fg3)', boxShadow: '0 0 0 3px var(--w-bg)' }}/>
          </div>
        </div>

        {/* online toggle */}
        <BigToggle online={online} onToggle={onToggleOnline} lang={lang} />

        {/* stats */}
        <div style={{ display: 'flex', gap: 12, marginTop: 14 }}>
          <StatCard icon="wallet" label={tx(lang, 'earnings_today').primary} accent sub="+₹380 last job">
            <Rupee value={earnings.toLocaleString('en-IN')} size={30} color="var(--w-fg1)" />
          </StatCard>
          <StatCard icon="check-c" label={tx(lang, 'jobs_done').primary} sub="2 climbs · 2 husks">
            <span className="mono" style={{ fontSize: 30, fontWeight: 700, color: 'var(--w-fg1)', lineHeight: 1 }}>{jobsDone}</span>
          </StatCard>
        </div>

        {/* reliability */}
        <div style={{ marginTop: 14, background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: 16,
          boxShadow: 'inset 0 0 0 1px var(--w-line)', display: 'flex', alignItems: 'center', gap: 18 }}>
          <Ring value={reliability} size={88} stroke={9}>
            <span className="mono" style={{ fontSize: 24, fontWeight: 700, color: 'var(--w-fg1)', lineHeight: 1 }}>{reliability}</span>
            <span style={{ fontSize: 12, color: 'var(--w-fg3)', fontWeight: 600 }}>%</span>
          </Ring>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
              <Icon name="shield" size={17} color="var(--w-accent-2)" />
              <span className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ font: 'var(--t-title)', color: 'var(--w-fg1)' }}>{tx(lang, 'reliability').primary}</span>
            </div>
            <p className={lang === 'ml' ? 'ml' : ''} style={{ margin: '6px 0 0', font: 'var(--t-body-sm)', color: 'var(--w-fg2)' }}>{relSub}</p>
            <div style={{ display: 'flex', gap: 14, marginTop: 10 }}>
              <span style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)' }}><b className="mono" style={{ color: 'var(--w-teal-100)', fontSize: 13 }}>47/50</b> on time</span>
              <span style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)' }}><b className="mono" style={{ color: 'var(--w-teal-100)', fontSize: 13 }}>0</b> no-shows</span>
            </div>
          </div>
        </div>

        {/* today's jobs */}
        <div style={{ marginTop: 22 }}>
          <SectionHead lang={lang} k="today_jobs" right={
            <span style={{ font: 'var(--t-caption)', color: 'var(--w-accent-2)', fontWeight: 700, background: 'rgba(244,165,42,.14)', padding: '3px 9px', borderRadius: 999 }}>{jobs.length}</span>
          } />
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {jobs.map(j => <JobCard key={j.id} job={j} lang={lang} onOpen={onOpenJob} />)}
          </div>
        </div>

        {/* weekly chart */}
        <div style={{ marginTop: 22, background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '16px 16px 14px', boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
          <SectionHead lang={lang} k="weekly" right={<Rupee value={(weekTotal/1000).toFixed(1) + 'k'} size={17} color="var(--w-teal-100)" />} />
          <WeeklyChart data={weekData} today={5} />
        </div>

        {/* demo control */}
        <button onClick={onSimulatePing} style={{ width: '100%', marginTop: 20, padding: '12px', borderRadius: 999,
          background: 'transparent', border: '1px dashed var(--w-line-strong)', color: 'var(--w-fg3)',
          font: 'var(--t-body-sm)', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
          <Icon name="bolt" size={15} color="var(--w-accent-2)" /> Demo · trigger a job ping
        </button>
      </div>

      <BottomNav lang={lang} active="home" onNav={onNav} />
    </div>
  );
}

Object.assign(window, { HomeScreen, BottomNav, JobCard, StatCard });
