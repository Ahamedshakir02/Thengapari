// screen1.jsx — Daily job queue
const { useState: useState1 } = React;

const QUEUE = [
  { id: "j1", time: "9:00", ampm: "AM", name: "Ravi Nair", area: "Vaduthala",
    crops: ["Coconut", "Tender"], dist: "0.0 km", status: "active",
    note: "On site now", trees: 14 },
  { id: "j2", time: "11:30", ampm: "AM", name: "Lakshmi Menon", area: "Edappally",
    crops: ["Coconut"], dist: "3.2 km", status: "next", trees: 9 },
  { id: "j3", time: "2:15", ampm: "PM", name: "Suresh Pillai", area: "Palarivattom",
    crops: ["Coconut", "Arecanut"], dist: "5.8 km", status: "scheduled", trees: 22 },
];

function CropChip({ name }) {
  const tender = name === "Tender";
  return (
    <span className={"chip " + (tender ? "chip-amber" : "chip-leaf")}>
      <I.leaf size={13} sw={2} /> {name}
    </span>
  );
}

function JobCard({ job, onOpen }) {
  const active = job.status === "active";
  return (
    <div className="card" style={{ overflow: "hidden", position: "relative" }}>
      {active && <div style={{ position: "absolute", left: 0, top: 0, bottom: 0, width: 5, background: "var(--accent)" }} />}
      <div style={{ padding: "var(--s-4)" }}>
        <div style={{ display: "flex", alignItems: "flex-start", gap: "var(--s-3)" }}>
          {/* time block */}
          <div style={{ textAlign: "center", minWidth: 58, flexShrink: 0 }}>
            <div style={{ font: "var(--t-h3)", color: active ? "var(--brand)" : "var(--fg1)", lineHeight: 1 }}>{job.time}</div>
            <div className="over" style={{ marginTop: 3 }}>{job.ampm}</div>
          </div>
          <div style={{ width: 1, alignSelf: "stretch", background: "var(--border)" }} />
          {/* body */}
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", gap: 8 }}>
              <div style={{ font: "var(--t-title)", color: "var(--fg1)" }}>{job.name}</div>
              {active
                ? <span className="spill spill-prog">Active</span>
                : <span style={{ display: "inline-flex", alignItems: "center", gap: 4, font: "var(--t-caption)", color: "var(--fg3)" }}><I.pin size={14} sw={2} />{job.dist}</span>}
            </div>
            <div style={{ font: "var(--t-body-sm)", color: "var(--fg3)", marginTop: 2, display: "flex", alignItems: "center", gap: 6 }}>
              <I.pin size={14} sw={1.9} /> {job.area} · {job.trees} trees
            </div>
            <div style={{ display: "flex", flexWrap: "wrap", gap: 6, marginTop: "var(--s-3)" }}>
              {job.crops.map((c) => <CropChip key={c} name={c} />)}
            </div>
          </div>
        </div>
        {/* actions */}
        <div style={{ display: "flex", gap: "var(--s-2)", marginTop: "var(--s-4)" }}>
          {active ? (
            <button className="btn btn-brand" onClick={onOpen}>
              Open job <I.chevR size={20} sw={2.2} />
            </button>
          ) : (
            <>
              <button className="btn btn-ghost" style={{ flex: 1 }}>
                <I.nav size={19} /> Navigate
              </button>
              <button className="btn btn-soft" style={{ flex: 1 }} onClick={onOpen}>Details</button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

function MapView() {
  return (
    <div className="card" style={{ overflow: "hidden", height: 420, position: "relative",
      background: "linear-gradient(160deg,#E6EFD9,#CFE0BC 60%,#BCD6A3)" }}>
      {/* faux roads */}
      <svg viewBox="0 0 390 420" style={{ position: "absolute", inset: 0, width: "100%", height: "100%" }}>
        <g stroke="#FBF8F1" strokeWidth="9" fill="none" strokeLinecap="round" opacity=".9">
          <path d="M-10 120 Q 120 90 200 160 T 410 150" />
          <path d="M60 -10 Q 100 140 70 250 T 130 430" />
          <path d="M300 -10 Q 280 160 330 260 T 290 430" />
          <path d="M-10 320 Q 160 300 410 340" />
        </g>
        <g stroke="#94B97F" strokeWidth="2.5" fill="none" opacity=".5">
          <path d="M0 60 H390 M0 230 H390 M150 0 V420 M250 0 V420" />
        </g>
      </svg>
      {/* pins */}
      {[{x:175,y:150,t:"now",a:true},{x:95,y:255,t:"11:30"},{x:300,y:330,t:"2:15"}].map((p,i)=>(
        <div key={i} style={{ position: "absolute", left: p.x, top: p.y, transform: "translate(-50%,-100%)", textAlign: "center" }}>
          <div style={{ background: p.a ? "var(--accent)" : "var(--brand)", color: p.a ? "var(--green-forest-900)" : "#fff",
            font: "var(--t-caption)", fontWeight: 700, padding: "4px 9px", borderRadius: "var(--r-pill)",
            boxShadow: "var(--shadow-md)", whiteSpace: "nowrap" }}>{p.t}</div>
          <div style={{ width: 0, height: 0, margin: "0 auto", borderLeft: "6px solid transparent",
            borderRight: "6px solid transparent", borderTop: `8px solid ${p.a ? "var(--accent)" : "var(--brand)"}` }} />
        </div>
      ))}
      <div style={{ position: "absolute", left: 12, bottom: 12, right: 12, background: "var(--surface)",
        borderRadius: "var(--r-md)", padding: "10px 14px", boxShadow: "var(--shadow-md)",
        display: "flex", alignItems: "center", gap: 10 }}>
        <I.nav size={20} style={{ color: "var(--brand)" }} />
        <div style={{ font: "var(--t-body-sm)", color: "var(--fg2)" }}>Total route <b style={{ color: "var(--fg1)" }}>9.0 km</b> · ~24 min drive</div>
      </div>
    </div>
  );
}

function ScreenQueue({ onOpenJob }) {
  const [view, setView] = useState1("list");
  return (
    <div className="kera">
      {/* header */}
      <header className="hdr">
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div>
            <div className="over" style={{ color: "var(--green-sage-400)" }}>Wednesday · 4 June</div>
            <div style={{ font: "var(--t-h2)", color: "#fff", marginTop: 2, whiteSpace: "nowrap" }}>Today · 3 jobs</div>
          </div>
          <img src="assets/logo-mark-light.svg" width="40" height="40" alt="" style={{ display: "block" }}
            onError={(e)=>{e.target.style.display='none';}} />
        </div>
        <div style={{ display: "flex", gap: 8, marginTop: "var(--s-4)" }}>
          {[["1 done","var(--green-sage-400)"],["1 active","var(--accent)"],["1 upcoming","var(--green-sage-400)"]].map(([t,c],i)=>(
            <div key={i} style={{ flex: 1, background: "rgba(255,255,255,.08)", borderRadius: "var(--r-md)", padding: "8px 10px" }}>
              <span style={{ display: "inline-block", width: 8, height: 8, borderRadius: 4, background: c, marginRight: 6 }} />
              <span style={{ font: "var(--t-caption)", color: "#fff", fontWeight: 600 }}>{t}</span>
            </div>
          ))}
        </div>
      </header>

      <div className="kera-body">
        <div className="pad" style={{ paddingBottom: 8 }}>
          <div className="seg">
            <button className={"seg-btn" + (view==="list"?" on":"")} onClick={()=>setView("list")}><I.list size={18} sw={2.1} /> List</button>
            <button className={"seg-btn" + (view==="map"?" on":"")} onClick={()=>setView("map")}><I.map size={18} sw={2.1} /> Map</button>
          </div>
        </div>
        <div className="pad stack" style={{ gap: "var(--s-3)", paddingTop: 4 }}>
          {view === "list"
            ? QUEUE.map((j) => <JobCard key={j.id} job={j} onOpen={onOpenJob} />)
            : <MapView />}
        </div>
      </div>
    </div>
  );
}

window.ScreenQueue = ScreenQueue;
