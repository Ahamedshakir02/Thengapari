// screen4.jsx — Broadcast ping
const { useState: useState4, useEffect: useEffect4, useRef: useRef4 } = React;

const WORKERS = [
  { id: "w1", name: "Anil Kumar",    rating: 4.9, jobs: 212, dist: "0.8 km", eta: "6 min",  type: "Processor · copra" },
  { id: "w2", name: "Faisal Rahman", rating: 4.8, jobs: 156, dist: "1.4 km", eta: "9 min",  type: "Tender buyer" },
  { id: "w3", name: "Deepa Thomas",  rating: 4.7, jobs: 98,  dist: "2.1 km", eta: "12 min", type: "Processor · oil mill" },
  { id: "w4", name: "Manoj S",       rating: 4.6, jobs: 74,  dist: "2.6 km", eta: "15 min", type: "Husk / coir unit" },
];

function Stars({ r }) {
  return (
    <span style={{ display: "inline-flex", alignItems: "center", gap: 3 }}>
      <I.star size={14} style={{ color: "var(--accent)" }} />
      <span className="mono" style={{ font: "600 13px var(--font-mono)", color: "var(--fg1)" }}>{r.toFixed(1)}</span>
    </span>
  );
}

function ResponseCard({ w, assigned, anyAssigned, onAssign }) {
  return (
    <div className="card anim-in" style={{ padding: "var(--s-3) var(--s-4)",
      border: assigned ? "2px solid var(--green-600)" : "1px solid var(--border)",
      opacity: anyAssigned && !assigned ? .5 : 1 }}>
      <div style={{ display: "flex", alignItems: "center", gap: "var(--s-3)" }}>
        <div style={{ width: 46, height: 46, borderRadius: "50%", flexShrink: 0,
          background: "var(--green-leaf-100)", color: "var(--green-forest-700)",
          display: "flex", alignItems: "center", justifyContent: "center", font: "700 18px var(--font-display)" }}>
          {w.name.split(" ").map((x) => x[0]).join("").slice(0, 2)}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <span style={{ font: "var(--t-title)", fontSize: 16, color: "var(--fg1)" }}>{w.name}</span>
            <Stars r={w.rating} />
          </div>
          <div style={{ font: "var(--t-caption)", color: "var(--fg3)", marginTop: 1 }}>{w.type} · {w.jobs} jobs</div>
        </div>
      </div>
      <div style={{ display: "flex", alignItems: "center", gap: "var(--s-2)", marginTop: "var(--s-3)" }}>
        <span className="chip chip-line"><I.pin size={13} sw={2} /> {w.dist}</span>
        <span className="chip chip-line"><I.clock size={13} sw={2} /> {w.eta}</span>
        <div style={{ flex: 1 }} />
        {assigned ? (
          <span className="spill spill-done" style={{ minHeight: 36, padding: "0 14px" }}><I.check size={15} sw={2.4} /> Assigned</span>
        ) : (
          <button className="btn btn-brand" style={{ width: "auto", minHeight: 44, padding: "0 22px" }} onClick={() => onAssign(w.id)}>Assign</button>
        )}
      </div>
    </div>
  );
}

function ScreenBroadcast({ onBack, onAssigned, state }) {
  const [phase, setPhase] = useState4(state.pingDone ? "live" : "ready");
  const [responses, setResponses] = useState4(state.pingDone ? WORKERS.slice(0, 3) : []);
  const [assigned, setAssigned] = useState4(null);
  const [secs, setSecs] = useState4(0);
  const timers = useRef4([]);

  const startBroadcast = () => {
    setPhase("live");
    [1400, 3200, 5200, 8000].forEach((ms, i) => {
      const t = setTimeout(() => setResponses((r) => (r.find((x) => x.id === WORKERS[i].id) ? r : [...r, WORKERS[i]])), ms);
      timers.current.push(t);
    });
  };
  useEffect4(() => {
    if (phase !== "live") return;
    const t = setInterval(() => setSecs((s) => s + 1), 1000);
    return () => clearInterval(t);
  }, [phase]);
  useEffect4(() => () => timers.current.forEach(clearTimeout), []);

  const assign = (id) => { setAssigned(id); onAssigned(); };
  const m = String(Math.floor(secs / 60)).padStart(2, "0");
  const s = String(secs % 60).padStart(2, "0");

  return (
    <div className="kera">
      <header className="hdr hdr--paper">
        <div className="hdr-row">
          <button className="hdr-back" onClick={onBack}><I.back size={22} /></button>
          <div style={{ flex: 1 }}>
            <div style={{ font: "var(--t-title)", color: "var(--fg1)" }}>Broadcast ping</div>
            <div style={{ font: "var(--t-caption)", color: "var(--fg3)" }}>Ravi Nair · 47.2 kg ready</div>
          </div>
          {phase === "live" && (
            <span className="spill" style={{ background: "var(--status-error-bg)", color: "var(--status-error-fg)" }}>
              <span className="live-dot" style={{ background: "var(--status-error-fg)", width: 6, height: 6 }} /> Live {m}:{s}
            </span>
          )}
        </div>
      </header>

      <div className="kera-body">
        <div className="pad stack" style={{ gap: "var(--s-4)" }}>

          {/* urgency banner */}
          <div style={{ background: "var(--amber-100)", borderRadius: "var(--r-lg)", padding: "var(--s-4)",
            border: "1px solid var(--amber-200)", display: "flex", gap: "var(--s-3)" }}>
            <div style={{ width: 40, height: 40, borderRadius: "var(--r-md)", background: "var(--accent)",
              color: "var(--green-forest-900)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
              <I.bolt size={22} />
            </div>
            <div>
              <div style={{ font: "var(--t-title)", fontSize: 16, color: "var(--status-inprogress-fg)" }}>Time-sensitive · tender coconuts</div>
              <div style={{ font: "var(--t-body-sm)", color: "var(--fg2)", marginTop: 2 }}>Fresh yield grades best within 4 hours. Broadcast to nearby processors now.</div>
            </div>
          </div>

          {phase === "ready" ? (
            <>
              {/* nearby count */}
              <div className="card" style={{ padding: "var(--s-5)", textAlign: "center" }}>
                <div style={{ display: "flex", justifyContent: "center", marginBottom: "var(--s-2)" }}>
                  {[0,1,2,3,4].map((i) => (
                    <div key={i} style={{ width: 36, height: 36, borderRadius: "50%", marginLeft: i ? -10 : 0,
                      background: ["var(--green-forest-700)","var(--green-sage-500)","var(--teal-500)","var(--amber-500)","var(--green-600)"][i],
                      border: "2.5px solid var(--surface)", display: "flex", alignItems: "center", justifyContent: "center",
                      color: "#fff", font: "700 13px var(--font-display)" }}>{["A","F","D","M","+"][i]}</div>
                  ))}
                </div>
                <div style={{ font: "var(--t-display)", fontSize: 44, color: "var(--brand-ink)" }}>18</div>
                <div style={{ font: "var(--t-body)", color: "var(--fg2)" }}>processors active within <b>3 km</b></div>
              </div>

              <button className="btn btn-accent btn-lg pulse" onClick={startBroadcast} style={{ minHeight: 66 }}>
                <I.radio size={26} sw={2.2} /> Broadcast to 18 processors
              </button>
              <div style={{ font: "var(--t-caption)", color: "var(--fg3)", textAlign: "center" }}>They get yield, grade &amp; location. You assign the best responder.</div>
            </>
          ) : (
            <>
              {/* live status strip */}
              <div style={{ display: "flex", gap: "var(--s-2)" }}>
                {[["Sent","18","var(--fg1)"],["Viewing","11","var(--accent)"],["Accepted",String(responses.length),"var(--green-600)"]].map(([l,n,c],i)=>(
                  <div key={i} className="card" style={{ flex: 1, padding: "var(--s-3)", textAlign: "center" }}>
                    <div className="mono" style={{ font: "700 24px var(--font-mono)", color: c }}>{n}</div>
                    <div className="over">{l}</div>
                  </div>
                ))}
              </div>

              <div>
                <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: "var(--s-3)" }}>
                  <span className="over">Incoming responses</span>
                  {!assigned && responses.length > 0 && <span className="live-dot" style={{ background: "var(--green-600)" }} />}
                </div>
                <div className="stack" style={{ gap: "var(--s-3)" }}>
                  {responses.length === 0 && (
                    <div className="card" style={{ padding: "var(--s-5)", textAlign: "center", font: "var(--t-body)", color: "var(--fg3)" }}>
                      <span className="live-dot" style={{ background: "var(--accent)", display: "inline-block", marginRight: 8 }} />
                      Waiting for processors to accept…
                    </div>
                  )}
                  {responses.map((w) => (
                    <ResponseCard key={w.id} w={w} assigned={assigned === w.id} anyAssigned={!!assigned} onAssign={assign} />
                  ))}
                </div>
              </div>
            </>
          )}
        </div>
      </div>

      {assigned && (
        <div style={{ flexShrink: 0, padding: "var(--s-3) var(--s-4)", background: "var(--surface)", borderTop: "1px solid var(--border)" }}>
          <button className="btn btn-brand btn-lg" onClick={onBack}>
            <I.check size={20} sw={2.4} /> Confirm pickup &amp; return to job
          </button>
        </div>
      )}
    </div>
  );
}

window.ScreenBroadcast = ScreenBroadcast;
