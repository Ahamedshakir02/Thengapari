// app-screens-report.jsx — Yield report: grade donut, byproduct routing,
// earnings breakdown, WhatsApp share.

function ReportScreen({ lang, subtitles, go }) {
  const segs = [
    { k: 'grade_a', value: 14, color: 'var(--brand)' },
    { k: 'grade_b', value: 7,  color: 'var(--green-sage-500)' },
    { k: 'tender',  value: 3,  color: 'var(--accent)' },
  ];
  const total = segs.reduce((s, x) => s + x.value, 0);
  const lines = [
    { k: 'harvest_value', icon: 'coconut', v: '₹4,180', sign: '' },
    { k: 'byproduct_credit', icon: 'recycle', v: '+₹440', sign: 'pos' },
    { k: 'service_fee', icon: 'wallet', v: '−₹340', sign: 'neg' },
  ];

  return (
    <>
      <TopBar title="yield_report" lang={lang} onBack={() => go('home', 'back')}
        right={<span className="pill-status st-complete" style={{ marginRight: 4 }}><Icon name="check" size={13} color="var(--status-complete-fg)" sw={2.4} />{t('completed', lang)}</span>} />
      <div className="scroll" style={{ paddingTop: 4 }}>
        <div className="pad stack">

          {/* donut */}
          <div className="card card-pad">
            <Lbl k="grade_breakdown" lang={lang} subtitles={subtitles} className="sh-title" tag="div" style={{ font: 'var(--t-title)', marginBottom: 6 }} />
            <div className="donutwrap" style={{ marginBottom: 10 }}>
              <Donut segs={segs} size={156} thick={24} />
              <div className="donut-center">
                <div className="dc-val">{total}</div>
                <div className="dc-lbl">{t('total_nuts', lang)}</div>
              </div>
            </div>
            <div className="legend">
              {segs.map((s) => (
                <div key={s.k} className="legend-row">
                  <span className="lg-dot" style={{ background: s.color }} />
                  <span className="lg-name">{t(s.k, lang)}</span>
                  <span className="lg-meta">{Math.round((s.value / total) * 100)}%</span>
                  <span className="lg-val">{s.value}</span>
                </div>
              ))}
            </div>
          </div>

          {/* byproduct routing */}
          <div className="byproduct">
            <span className="bp-icon"><Icon name="recycle" size={22} color="var(--green-forest-900)" /></span>
            <div>
              <div className="bp-title">{t('byproduct_title', lang)}</div>
              <div className="bp-sub">{t('byproduct_sub', lang)}</div>
            </div>
          </div>

          {/* earnings breakdown */}
          <div className="card card-pad">
            <Lbl k="earnings_break" lang={lang} subtitles={subtitles} className="sh-title" tag="div" style={{ font: 'var(--t-title)', marginBottom: 4 }} />
            {lines.map((l) => (
              <div key={l.k} className="breakdown-row">
                <span className="br-k"><Icon name={l.icon} size={18} color="var(--fg3)" /> {t(l.k, lang)}</span>
                <span className="br-v" style={{ color: l.sign === 'pos' ? 'var(--green-600)' : l.sign === 'neg' ? 'var(--status-error-fg)' : 'var(--fg1)' }}>{l.v}</span>
              </div>
            ))}
            <div className="breakdown-total">
              <div>
                <Lbl k="net_payout" lang={lang} subtitles={subtitles} className="bt-k" tag="div" />
                <div className="jc-meta" style={{ marginTop: 2 }}>{t('paid_to', lang)}rahul@okaxis</div>
              </div>
              <div className="bt-v">₹4,280</div>
            </div>
          </div>

        </div>
      </div>
      <div className="sticky-foot">
        <button className="btn whatsapp"><Icon name="whatsapp" size={22} color="#fff" /> {t('share_whatsapp', lang)}</button>
      </div>
    </>
  );
}

Object.assign(window, { ReportScreen });
