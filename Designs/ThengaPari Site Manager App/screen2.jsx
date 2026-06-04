// screen2.jsx — On-site operations (main screen)
const GRADE_META = {
  A:      { label: "Grade A", color: "var(--green-forest-700)", price: 24 },
  B:      { label: "Grade B", color: "var(--green-sage-500)",   price: 15 },
  Tender: { label: "Tender",  color: "var(--accent)",           price: 32 },
};

function gradeSegs(grades) {
  return [
    { key: "A",      v: grades.A,      color: GRADE_META.A.color },
    { key: "B",      v: grades.B,      color: GRADE_META.B.color },
    { key: "Tender", v: grades.Tender, color: GRADE_META.Tender.color },
  ];
}
function estValue(grades) {
  return Object.entries(grades).reduce((s, [k, v]) => s + v * GRADE_META[k].price, 0);
}

/* ---- checklist step ---- */
function Step({ step, last, onTap }) {
  const { status } = step;
  const ring = {
    done:    { bg: "var(--status-complete-bg)", bd: "var(--green-600)", ico: <I.check size={20} style={{ color: "var(--green-600)" }} /> },
    active:  { bg: "var(--amber-100)",          bd: "var(--accent)",    ico: <span className="mono" style={{ font: "700 14px var(--font-mono)", color: "var(--status-inprogress-fg)" }}>•</span> },
    pending: { bg: "var(--surface-sunk)",       bd: "var(--border-strong)", ico: <span style={{ width: 8, height: 8, borderRadius: 4, background: "var(--ink-400)" }} /> },
  }[status];
  const tappable = status === "active";
  return (
    <div style={{ display: "flex", gap: "var(--s-3)", cursor: tappable ? "pointer" : "default" }} onClick={tappable ? onTap : undefined}>
      {/* rail */}
      <div style={{ display: "flex", flexDirection: "column", alignItems: "center", flexShrink: 0 }}>
        <div className={status === "active" ? "pulse" : ""} style={{
          width: 38, height: 38, borderRadius: "50%", background: ring.bg,
          border: `2.5px solid ${ring.bd}`, display: "flex", alignItems: "center", justifyContent: "center" }}>
          {ring.ico}
        </div>
        {!last && <div style={{ flex: 1, width: 2.5, background: status === "done" ? "var(--green-sage-400)" : "var(--border)", margin: "2px 0", minHeight: 18 }} />}
      </div>
      {/* body */}
      <div style={{ flex: 1, paddingBottom: last ? 0 : "var(--s-4)" }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8 }}>
          <div style={{ font: "var(--t-title)", fontSize: 16,
            color: status === "pending" ? "var(--fg3)" : "var(--fg1)",
            textDecoration: status === "done" ? "none" : "none" }}>{step.label}</div>
          {step.time && <span className="mono" style={{ font: "600 13px var(--font-mono)", color: status === "done" ? "var(--green-600)" : "var(--fg3)" }}>{step.time}</span>}
        </div>
        {step.sub && <div style={{ font: "var(--t-body-sm)", color: "var(--fg3)", marginTop: 1 }}>{step.sub}</div>}
        {status === "active" && (
          <button className="btn btn-accent" style={{ marginTop: "var(--s-3)", minHeight: 46 }} onClick={onTap}>
            {step.cta} <I.chevR size={19} sw={2.4} />
          </button>
        )}
      </div>
    </div>
  );
}

function ScreenOnsite({ state, steps, onStep, onPing, startMs }) {
  const elapsed = useElapsed(startMs);
  const { grades } = state;
  const total = grades.A + grades.B + grades.Tender;
  const segs = gradeSegs(grades);
  const pingStep = steps.find((s) => s.k === "ping");
  const pingActive = pingStep.status === "active";

  return (
    <div className="kera">
      {/* header */}
      <header className="hdr">
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span className="spill" style={{ background: "rgba(244,165,42,.16)", color: "var(--accent)" }}>
            <span className="live-dot" style={{ background: "var(--accent)" }} /> On site
          </span>
          <span style={{ font: "var(--t-caption)", color: "var(--green-sage-400)" }}>Job #KH-2261</span>
        </div>
        <div style={{ display: "flex", alignItems: "flex-end", justifyContent: "space-between", marginTop: "var(--s-3)", gap: 12 }}>
          <div style={{ minWidth: 0 }}>
            <div style={{ font: "var(--t-h2)", color: "#fff" }}>Ravi Nair</div>
            <div style={{ font: "var(--t-body-sm)", color: "var(--green-leaf-200)", marginTop: 1 }}>Coconut harvest · started 9:16 AM</div>
          </div>
          <div style={{ textAlign: "right", flexShrink: 0 }}>
            <div className="over" style={{ color: "var(--green-sage-400)" }}>Elapsed</div>
            <div className="mono" style={{ font: "700 26px var(--font-mono)", color: "var(--accent)", lineHeight: 1.1 }}>{elapsed}</div>
          </div>
        </div>
      </header>

      <div className="kera-body">
        <div className="pad stack" style={{ gap: "var(--s-4)" }}>

          {/* yield widget */}
          <div className="card" style={{ padding: "var(--s-4)" }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: "var(--s-3)" }}>
              <span className="over">Yield logged</span>
              <span className="chip chip-leaf"><I.check size={13} sw={2.4} /> Grading</span>
            </div>
            <div style={{ display: "flex", alignItems: "center", gap: "var(--s-4)" }}>
              <Donut segs={segs} size={128} thick={20} center={
                <>
                  <div className="mono" style={{ font: "700 28px var(--font-mono)", color: "var(--fg1)", lineHeight: 1 }}>{state.weight.toFixed(1)}</div>
                  <div className="over" style={{ marginTop: 2 }}>KG TOTAL</div>
                </>
              } />
              <div style={{ flex: 1 }}>
                {segs.map((s) => (
                  <div key={s.key} style={{ display: "flex", alignItems: "center", gap: 8, padding: "5px 0" }}>
                    <span style={{ width: 11, height: 11, borderRadius: 3, background: s.color, flexShrink: 0 }} />
                    <span style={{ font: "var(--t-body-sm)", color: "var(--fg2)", flex: 1 }}>{GRADE_META[s.key].label}</span>
                    <span className="mono" style={{ font: "600 15px var(--font-mono)", color: "var(--fg1)" }}>{s.v}</span>
                  </div>
                ))}
                <div className="hr" style={{ margin: "6px 0" }} />
                <div style={{ display: "flex", justifyContent: "space-between" }}>
                  <span style={{ font: "var(--t-body-sm)", color: "var(--fg3)" }}>{total} nuts · est.</span>
                  <span style={{ font: "var(--t-title)", fontSize: 16, color: "var(--green-600)" }}>₹{estValue(grades).toLocaleString("en-IN")}</span>
                </div>
              </div>
            </div>
          </div>

          {/* ping CTA */}
          <button className={"btn btn-accent btn-lg" + (pingActive || state.pingDone ? " pulse" : "")} onClick={onPing}>
            <I.radio size={24} sw={2.2} /> {state.pingDone ? "View broadcast · live" : "Ping processors now"}
          </button>

          {/* checklist */}
          <div className="card" style={{ padding: "var(--s-4)" }}>
            <div className="over" style={{ marginBottom: "var(--s-4)" }}>Site checklist</div>
            {steps.map((s, i) => (
              <Step key={s.k} step={s} last={i === steps.length - 1} onTap={() => onStep(s)} />
            ))}
          </div>

        </div>
      </div>
    </div>
  );
}

Object.assign(window, { ScreenOnsite, GRADE_META, gradeSegs, estValue });
