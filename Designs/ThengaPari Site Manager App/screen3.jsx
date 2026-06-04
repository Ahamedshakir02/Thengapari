// screen3.jsx — Yield weighing
const { useState: useState3 } = React;

function Counter({ meta, value, onDelta }) {
  return (
    <div style={{ display: "flex", alignItems: "center", gap: "var(--s-3)", padding: "var(--s-2) 0" }}>
      <span style={{ width: 13, height: 13, borderRadius: 4, background: meta.color, flexShrink: 0 }} />
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ font: "var(--t-title)", fontSize: 16, color: "var(--fg1)" }}>{meta.label}</div>
        <div style={{ font: "var(--t-caption)", color: "var(--fg3)" }}>₹{meta.price}/nut</div>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: 4 }}>
        <button className="cbtn" onClick={() => onDelta(-1)} aria-label="minus"><I.minus size={22} /></button>
        <div className="mono" style={{ width: 48, textAlign: "center", font: "700 24px var(--font-mono)", color: "var(--fg1)" }}>{value}</div>
        <button className="cbtn cbtn-plus" onClick={() => onDelta(1)} aria-label="plus"><I.plus size={22} /></button>
      </div>
    </div>
  );
}

function Keypad({ onKey }) {
  const keys = ["1","2","3","4","5","6","7","8","9",".","0","del"];
  return (
    <div style={{ display: "grid", gridTemplateColumns: "repeat(3,1fr)", gap: "var(--s-2)" }}>
      {keys.map((k) => (
        <button key={k} className="kp" onClick={() => onKey(k)}>
          {k === "del" ? <I.back size={24} sw={2.2} /> : k}
        </button>
      ))}
    </div>
  );
}

function ScreenWeigh({ state, onSave, onBack }) {
  const [w, setW] = useState3(String(state.weight));
  const [g, setG] = useState3({ ...state.grades });
  const [photo, setPhoto] = useState3(false);

  const weightNum = parseFloat(w) || 0;
  const total = g.A + g.B + g.Tender;
  const segs = gradeSegs(g);
  const val = estValue(g);

  const pressKey = (k) => {
    setW((cur) => {
      if (k === "del") return cur.length <= 1 ? "0" : cur.slice(0, -1);
      if (k === ".") return cur.includes(".") ? cur : cur + ".";
      let next = cur === "0" ? k : cur + k;
      if (next.includes(".") && next.split(".")[1].length > 1) return cur;
      if (next.replace(".", "").length > 5) return cur;
      return next;
    });
  };
  const delta = (key, d) => setG((cur) => ({ ...cur, [key]: Math.max(0, cur[key] + d) }));
  const grabScale = () => { setPhoto(true); setW("47.2"); };

  return (
    <div className="kera">
      <style>{`
        .cbtn{width:48px;height:48px;border-radius:var(--r-md);border:1.5px solid var(--border-strong);
          background:var(--surface);color:var(--fg1);display:flex;align-items:center;justify-content:center;cursor:pointer}
        .cbtn:active{background:var(--surface-sunk)}
        .cbtn-plus{background:var(--green-leaf-100);border-color:var(--green-leaf-300);color:var(--green-forest-800)}
        .kp{height:54px;border:none;border-radius:var(--r-md);background:var(--surface);box-shadow:var(--shadow-sm);
          font:600 24px var(--font-mono);color:var(--fg1);cursor:pointer;display:flex;align-items:center;justify-content:center}
        .kp:active{background:var(--surface-sunk)}
      `}</style>

      <header className="hdr hdr--paper">
        <div className="hdr-row">
          <button className="hdr-back" onClick={onBack}><I.back size={22} /></button>
          <div style={{ flex: 1 }}>
            <div style={{ font: "var(--t-title)", color: "var(--fg1)" }}>Weigh &amp; grade</div>
            <div style={{ font: "var(--t-caption)", color: "var(--fg3)" }}>Ravi Nair · Coconut harvest</div>
          </div>
          <span className="spill spill-prog">Step 3</span>
        </div>
      </header>

      <div className="kera-body">
        <div className="pad stack" style={{ gap: "var(--s-3)" }}>

          {/* weight display */}
          <div className="card" style={{ padding: "var(--s-4)", background: "var(--brand-ink)", border: "none" }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
              <span className="over" style={{ color: "var(--green-sage-400)" }}>Total weight</span>
              <button className="chip" onClick={grabScale}
                style={{ background: photo ? "var(--green-600)" : "rgba(255,255,255,.14)", color: "#fff", border: "none", cursor: "pointer", padding: "7px 12px" }}>
                <I.camera size={16} sw={2} /> {photo ? "Scale read ✓" : "Scale photo"}
              </button>
            </div>
            <div style={{ display: "flex", alignItems: "baseline", gap: 8, marginTop: 6 }}>
              <span className="mono" style={{ font: "700 52px var(--font-mono)", color: "#fff", letterSpacing: "-.02em" }}>{w}</span>
              <span style={{ font: "var(--t-h3)", color: "var(--green-sage-400)" }}>kg</span>
              <span style={{ marginLeft: "auto", width: 2, height: 38, background: "var(--accent)", animation: "blink 1.1s steps(1) infinite" }} />
            </div>
          </div>

          {/* keypad */}
          <Keypad onKey={pressKey} />

          {/* counters + preview */}
          <div className="card" style={{ padding: "var(--s-4)" }}>
            <div className="over" style={{ marginBottom: "var(--s-2)" }}>Count by grade</div>
            <Counter meta={GRADE_META.A} value={g.A} onDelta={(d) => delta("A", d)} />
            <div className="hr" />
            <Counter meta={GRADE_META.B} value={g.B} onDelta={(d) => delta("B", d)} />
            <div className="hr" />
            <Counter meta={GRADE_META.Tender} value={g.Tender} onDelta={(d) => delta("Tender", d)} />

            <div className="hr" style={{ margin: "var(--s-3) 0" }} />
            <div style={{ display: "flex", alignItems: "center", gap: "var(--s-4)" }}>
              <Donut segs={segs} size={96} thick={16} center={
                <>
                  <div className="mono" style={{ font: "700 22px var(--font-mono)", color: "var(--fg1)", lineHeight: 1 }}>{total}</div>
                  <div className="over" style={{ fontSize: 10 }}>NUTS</div>
                </>
              } />
              <div style={{ flex: 1 }}>
                <div className="over">Estimated value</div>
                <div style={{ font: "var(--t-h1)", fontSize: 30, color: "var(--green-600)" }}>₹{val.toLocaleString("en-IN")}</div>
                <div style={{ font: "var(--t-caption)", color: "var(--fg3)" }}>{weightNum.toFixed(1)} kg · {total} nuts graded</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* save bar */}
      <div style={{ flexShrink: 0, padding: "var(--s-3) var(--s-4)", background: "var(--surface)", borderTop: "1px solid var(--border)" }}>
        <button className="btn btn-brand btn-lg" onClick={() => onSave({ weight: weightNum, grades: g })}>
          Save yield &amp; continue <I.chevR size={20} sw={2.4} />
        </button>
      </div>
    </div>
  );
}

window.ScreenWeigh = ScreenWeigh;
