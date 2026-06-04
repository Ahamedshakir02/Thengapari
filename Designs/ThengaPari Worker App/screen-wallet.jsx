// screen-wallet.jsx — Wallet: balance, withdraw to UPI (sheet flow), weekly chart, payouts

const TXNS = [
  { id: 1, title: 'Coconut husking', titleMl: 'തേങ്ങ പൊതിക്കൽ', place: 'Parambil Estate', amt: '380', time: 'Today · 9:54 AM', ref: '4072 1183' },
  { id: 2, title: 'Palm trimming', titleMl: 'പന വെട്ടൽ', place: 'Vadakke Padam', amt: '300', time: 'Yesterday · 5:12 PM', ref: '3981 7720' },
  { id: 3, title: 'Withdrawal to UPI', titleMl: 'UPI പിൻവലിക്കൽ', place: 'ravi@okaxis', amt: '1500', time: 'Yesterday · 8:00 PM', ref: '2261 0049', out: true },
  { id: 4, title: 'Tender coconut climb', titleMl: 'കരിക്ക് കയറ്റം', place: 'Maple Grove', amt: '420', time: 'Mon · 11:40 AM', ref: '1180 5532' },
  { id: 5, title: 'Coconut climbing', titleMl: 'തെങ്ങുകയറ്റം', place: 'Cheruvath Farm', amt: '460', time: 'Sun · 10:20 AM', ref: '8841 2093' },
];

const WALLET_WEEK = [
  { d: 'M', v: 980 }, { d: 'T', v: 1240 }, { d: 'W', v: 760 }, { d: 'T', v: 1500 },
  { d: 'F', v: 1100 }, { d: 'S', v: 1240 }, { d: 'S', v: 0 },
];

function TxnRow({ txn, lang }) {
  const out = txn.out;
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 13, padding: '13px 4px' }}>
      <div style={{ width: 40, height: 40, borderRadius: 12, flexShrink: 0,
        background: out ? 'var(--w-surface-2)' : 'rgba(95,200,150,.14)',
        display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Icon name={out ? 'arrow-ur' : 'coconut'} size={out ? 19 : 18} color={out ? 'var(--w-teal-300)' : 'var(--w-good)'} sw={2.2} />
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body)', fontWeight: 600, color: 'var(--w-fg1)', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
          {lang === 'ml' ? txn.titleMl : txn.title}
        </div>
        <div style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 2 }}>{txn.time}</div>
      </div>
      <div style={{ flexShrink: 0, textAlign: 'right' }}>
        <span className="mono" style={{ font: '700 16px/1 var(--font-mono)', color: out ? 'var(--w-fg2)' : 'var(--w-good)' }}>
          {out ? '−' : '+'}₹{txn.amt}
        </span>
        <div className="mono" style={{ font: '500 10px/1 var(--font-mono)', color: 'var(--w-fg3)', marginTop: 5 }}>ref {txn.ref}</div>
      </div>
    </div>
  );
}

function WithdrawSheet({ lang, balance, upi, onClose }) {
  const [stage, setStage] = React.useState('form'); // form | done
  const [amount, setAmount] = React.useState(balance);
  const quick = [500, 1000, balance];
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(3,20,17,.62)', backdropFilter: 'blur(2px)', animation: 'fade-in .25s ease both' }} />
      <div className="ping-in" style={{ position: 'relative', background: 'var(--w-bg-2)', borderTopLeftRadius: 'var(--r-xl)', borderTopRightRadius: 'var(--r-xl)',
        boxShadow: '0 -16px 40px rgba(0,0,0,.45), inset 0 0 0 1px var(--w-line)', padding: '14px 18px 22px' }}>
        <div style={{ width: 44, height: 5, borderRadius: 999, background: 'var(--w-line-strong)', margin: '0 auto 16px' }} />

        {stage === 'form' ? (
          <React.Fragment>
            <h2 className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ margin: '0 0 4px', font: 'var(--t-h3)', color: 'var(--w-fg1)' }}>{tx(lang, 'withdraw').primary}</h2>
            <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg3)', marginBottom: 18 }}>{tx(lang, 'no_fee').primary}</div>

            <div style={{ font: 'var(--t-overline)', color: 'var(--w-fg3)', textTransform: 'uppercase', letterSpacing: '.08em', marginBottom: 8 }}>{tx(lang, 'withdraw_amt').primary}</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 6, paddingBottom: 12, borderBottom: '2px solid var(--w-line-strong)', marginBottom: 14 }}>
              <span className="mono" style={{ font: '700 34px/1 var(--font-mono)', color: 'var(--w-accent-2)' }}>₹</span>
              <span className="mono" style={{ font: '800 40px/1 var(--font-mono)', color: 'var(--w-fg1)' }}>{amount.toLocaleString('en-IN')}</span>
            </div>

            <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
              {quick.map((q, i) => {
                const on = q === amount;
                return (
                  <button key={i} onClick={() => setAmount(q)} style={{ flex: 1, border: 'none', borderRadius: 'var(--r-pill)', padding: '9px 6px',
                    background: on ? 'rgba(244,165,42,.16)' : 'var(--w-surface)', boxShadow: on ? 'inset 0 0 0 1px rgba(244,165,42,.4)' : 'inset 0 0 0 1px var(--w-line)',
                    color: on ? 'var(--w-accent-2)' : 'var(--w-fg2)', font: '700 13px/1 var(--font-mono)' }}>
                    {i === 2 ? (lang === 'ml' ? 'എല്ലാം' : 'All ') : ''}₹{q.toLocaleString('en-IN')}
                  </button>
                );
              })}
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 12, background: 'var(--w-surface)', borderRadius: 'var(--r-md)', padding: '13px 15px', marginBottom: 18, boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
              <div style={{ width: 38, height: 38, borderRadius: 10, background: 'var(--w-surface-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Icon name="bank" size={19} color="var(--w-teal-300)" />
              </div>
              <div style={{ flex: 1, minWidth: 0 }}>
                <div style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)' }}>{tx(lang, 'send_to').primary}</div>
                <div className="mono" style={{ font: '600 15px/1.2 var(--font-mono)', color: 'var(--w-fg1)', marginTop: 2 }}>{upi}</div>
              </div>
              <Icon name="chevron" size={18} color="var(--w-fg3)" />
            </div>

            <button onClick={() => setStage('done')} style={{ width: '100%', height: 58, borderRadius: 'var(--r-pill)', border: 'none',
              background: 'linear-gradient(135deg, var(--w-accent-2), var(--w-accent))', color: 'var(--w-accent-press)',
              font: '800 18px/1 var(--font-text)', boxShadow: '0 10px 26px rgba(244,165,42,.4)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 9 }}>
              <Icon name="download" size={20} color="var(--w-accent-press)" sw={2.6} />
              {tx(lang, 'confirm_wd').primary} ₹{amount.toLocaleString('en-IN')}
            </button>
          </React.Fragment>
        ) : (
          <div style={{ textAlign: 'center', padding: '6px 0 4px' }}>
            <div style={{ width: 76, height: 76, borderRadius: '50%', margin: '0 auto 16px', animation: 'pop-in .5s cubic-bezier(.34,1.56,.64,1) both',
              background: 'radial-gradient(circle at 50% 35%, var(--w-good), #2E8E5C)', display: 'flex', alignItems: 'center', justifyContent: 'center',
              boxShadow: '0 12px 30px rgba(87,201,139,.4)' }}>
              <Icon name="check" size={40} color="#fff" sw={3.4} />
            </div>
            <h2 className={lang === 'ml' ? 'disp ml' : 'disp'} style={{ margin: '0 0 6px', font: 'var(--t-h2)', color: 'var(--w-fg1)' }}>{tx(lang, 'wd_done').primary}</h2>
            <div className="mono" style={{ font: '800 30px/1 var(--font-mono)', color: 'var(--w-good)', margin: '4px 0 8px' }}>₹{amount.toLocaleString('en-IN')}</div>
            <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-body-sm)', color: 'var(--w-fg3)', marginBottom: 20 }}>{tx(lang, 'wd_done_sub').primary} · <span className="mono">{upi}</span></div>
            <button onClick={onClose} style={{ width: '100%', height: 56, borderRadius: 'var(--r-pill)', border: 'none', background: '#fff', color: 'var(--w-bg)', font: '700 17px/1 var(--font-text)' }}>
              {tx(lang, 'done_btn').primary}
            </button>
          </div>
        )}
      </div>
    </div>
  );
}

function WalletScreen({ lang, balance = 2380, onNav }) {
  const [sheet, setSheet] = React.useState(false);
  const upi = 'ravi@okaxis';
  const weekTotal = WALLET_WEEK.reduce((a, b) => a + b.v, 0);
  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', minHeight: 0, background: 'var(--w-bg)', position: 'relative' }}>
      <div style={{ flex: 1, minHeight: 0, overflow: 'auto', padding: '16px 16px 22px' }}>
        <ScreenHeader lang={lang} k="wallet_title" right={<HeaderIconBtn icon="history" />} />

        {/* balance hero card */}
        <div style={{ borderRadius: 'var(--r-xl)', padding: '20px 20px 18px',
          background: 'linear-gradient(150deg, var(--w-glow-top) 0%, var(--w-surface) 55%, var(--w-surface-2) 100%)',
          boxShadow: '0 14px 34px rgba(0,0,0,.3), inset 0 0 0 1px var(--w-line-strong)', position: 'relative', overflow: 'hidden' }}>
          <div style={{ position: 'absolute', right: -30, top: -30, width: 150, height: 150, borderRadius: '50%', background: 'radial-gradient(circle, rgba(244,165,42,.18), transparent 70%)' }} />
          <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-caption)', color: 'var(--w-teal-100)', textTransform: 'uppercase', letterSpacing: '.1em', opacity: .9 }}>{tx(lang, 'balance').primary}</div>
          <div style={{ display: 'flex', alignItems: 'baseline', gap: 2, margin: '8px 0 16px' }}>
            <Rupee value={balance.toLocaleString('en-IN')} size={48} weight={800} color="#fff" />
          </div>
          <div style={{ display: 'flex', gap: 10 }}>
            <button onClick={() => setSheet(true)} style={{ flex: 1, height: 52, borderRadius: 'var(--r-pill)', border: 'none',
              background: 'linear-gradient(135deg, var(--w-accent-2), var(--w-accent))', color: 'var(--w-accent-press)',
              font: '800 16px/1 var(--font-text)', boxShadow: '0 8px 22px rgba(244,165,42,.4)',
              display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8 }}>
              <Icon name="download" size={19} color="var(--w-accent-press)" sw={2.6} />
              {tx(lang, 'withdraw').primary}
            </button>
          </div>
        </div>

        {/* secondary stats */}
        <div style={{ display: 'flex', gap: 12, marginTop: 14 }}>
          <MiniStat icon="clock" label={tx(lang, 'pending_pay').primary}>
            <Rupee value="0" size={22} color="var(--w-fg1)" />
            <div className={lang === 'ml' ? 'ml' : ''} style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)', marginTop: 6 }}>{tx(lang, 'add_money_note').primary}</div>
          </MiniStat>
          <MiniStat icon="wallet" label={tx(lang, 'in_week').primary}>
            <Rupee value={weekTotal.toLocaleString('en-IN')} size={22} color="var(--w-fg1)" />
            <div style={{ font: 'var(--t-caption)', color: 'var(--w-good)', marginTop: 6, fontWeight: 600 }}>▲ 12% vs last</div>
          </MiniStat>
        </div>

        {/* weekly chart */}
        <div style={{ marginTop: 14, background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '16px 16px 14px', boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
          <SectionHead lang={lang} k="weekly" right={<Rupee value={(weekTotal/1000).toFixed(1) + 'k'} size={17} color="var(--w-teal-100)" />} />
          <WeeklyChart data={WALLET_WEEK} today={5} />
        </div>

        {/* linked upi */}
        <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 13, background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '14px 16px', boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
          <div style={{ width: 40, height: 40, borderRadius: 12, background: 'var(--w-surface-2)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
            <Icon name="bank" size={20} color="var(--w-teal-300)" />
          </div>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ font: 'var(--t-caption)', color: 'var(--w-fg3)' }}>{tx(lang, 'linked_upi').primary}</div>
            <div className="mono" style={{ font: '600 15px/1.2 var(--font-mono)', color: 'var(--w-fg1)', marginTop: 2 }}>{upi}</div>
          </div>
          <Icon name="badge" size={20} color="var(--w-good)" />
        </div>

        {/* payouts */}
        <div style={{ marginTop: 22 }}>
          <SectionHead lang={lang} k="payouts" />
          <div style={{ background: 'var(--w-surface)', borderRadius: 'var(--r-lg)', padding: '2px 16px', boxShadow: 'inset 0 0 0 1px var(--w-line)' }}>
            {TXNS.map((t, i) => (
              <React.Fragment key={t.id}>
                {i > 0 && <div style={{ height: 1, background: 'var(--w-line)' }} />}
                <TxnRow txn={t} lang={lang} />
              </React.Fragment>
            ))}
          </div>
        </div>
      </div>

      <BottomNav lang={lang} active="earn" onNav={onNav} />

      {sheet && <WithdrawSheet lang={lang} balance={balance} upi={upi} onClose={() => setSheet(false)} />}
    </div>
  );
}

Object.assign(window, { WalletScreen, WithdrawSheet, TxnRow });
