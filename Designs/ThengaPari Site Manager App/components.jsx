// components.jsx — shared UI for ThengaPari Site Manager
const { useState, useEffect, useRef } = React;

/* ============ ICONS (stroke, 26px grid, outdoor-legible weight) ============ */
const Ico = ({ d, size = 24, sw = 2, fill = "none", style }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill={fill} stroke="currentColor"
    strokeWidth={sw} strokeLinecap="round" strokeLinejoin="round" style={style}>
    {Array.isArray(d) ? d.map((p, i) => <path key={i} d={p} />) : <path d={d} />}
  </svg>
);
const I = {
  list:   (p) => <Ico {...p} d={["M8 6h13","M8 12h13","M8 18h13","M3.5 6h.01","M3.5 12h.01","M3.5 18h.01"]} />,
  map:    (p) => <Ico {...p} d={["M9 4 3 6.5v13L9 17l6 2.5 6-2.5v-13L15 7 9 4Z","M9 4v13","M15 7v12.5"]} />,
  pin:    (p) => <Ico {...p} d={["M12 21s7-6.3 7-11a7 7 0 1 0-14 0c0 4.7 7 11 7 11Z","M12 10.5h.01"]} sw={2} />,
  nav:    (p) => <Ico {...p} fill="currentColor" d="M12 2 3 21l9-4 9 4L12 2Z" sw={0} />,
  clock:  (p) => <Ico {...p} d={["M12 7v5l3 2"]} />,
  clockC: (p) => <Ico {...p} d={["M12 22a10 10 0 1 0 0-20 10 10 0 0 0 0 20Z","M12 7v5l3 2"]} />,
  check:  (p) => <Ico {...p} d="M20 6 9 17l-5-5" sw={2.6} />,
  chevR:  (p) => <Ico {...p} d="M9 6l6 6-6 6" />,
  back:   (p) => <Ico {...p} d={["M19 12H5","M11 18l-6-6 6-6"]} sw={2.4} />,
  bolt:   (p) => <Ico {...p} fill="currentColor" sw={0} d="M13 2 4.5 13.2c-.4.5 0 1.3.6 1.3H11l-1 8 8.5-11.2c.4-.5 0-1.3-.6-1.3H12l1-8Z" />,
  scale:  (p) => <Ico {...p} d={["M12 3v18","M5 7h14","M5 7 2 14h6L5 7Z","M19 7l-3 7h6l-3-7Z","M8 21h8"]} />,
  camera: (p) => <Ico {...p} d={["M3 8.5A2 2 0 0 1 5 6.5h1.6l1-1.6h4.8l1 1.6H20a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-9Z","M12 17a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7Z"]} sw={1.9} />,
  radio:  (p) => <Ico {...p} d={["M12 14a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z","M7.8 7.8a6 6 0 0 0 0 8.4M16.2 7.8a6 6 0 0 1 0 8.4M5 5a9 9 0 0 0 0 14M19 5a9 9 0 0 1 0 14"]} sw={1.9} />,
  star:   (p) => <Ico {...p} fill="currentColor" sw={0} d="M12 2.5l2.7 5.9 6.3.7-4.7 4.3 1.3 6.2L12 16.9 6.1 19.6l1.3-6.2L2.7 9.1l6.3-.7L12 2.5Z" />,
  user:   (p) => <Ico {...p} d={["M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Z","M4.5 20a7.5 7.5 0 0 1 15 0"]} sw={1.9} />,
  truck:  (p) => <Ico {...p} d={["M3 6h11v9H3z","M14 9h4l3 3v3h-7","M7 19a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z","M18 19a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z"]} sw={1.8} />,
  leaf:   (p) => <Ico {...p} d={["M5 19c8 0 14-5 14-14C9 5 5 11 5 19Z","M5 19c2-5 5-8 9-10"]} sw={1.9} />,
  plus:   (p) => <Ico {...p} d={["M12 5v14","M5 12h14"]} sw={2.6} />,
  minus:  (p) => <Ico {...p} d="M5 12h14" sw={2.6} />,
  phone:  (p) => <Ico {...p} d="M6.5 3.5 9 4l1 4-2 1.5a12 12 0 0 0 6.5 6.5L16 14l4 1 .5 2.5a2 2 0 0 1-2 2.4A16 16 0 0 1 4.1 5.5a2 2 0 0 1 2.4-2Z" sw={1.9} />,
  home:   (p) => <Ico {...p} d={["M4 11 12 4l8 7","M6 9.5V20h12V9.5","M10 20v-5h4v5"]} sw={1.9} />,
  wallet: (p) => <Ico {...p} d={["M4 7h14a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H5a1 1 0 0 1-1-1V7Z","M4 7l1.5-3 11 2.5","M16.5 13h.01"]} sw={1.8} />,
};

/* ============ DONUT (grade breakdown) ============ */
function Donut({ segs, size = 132, thick = 22, center }) {
  const total = segs.reduce((s, x) => s + x.v, 0) || 1;
  const r = (size - thick) / 2;
  const C = 2 * Math.PI * r;
  let off = 0;
  return (
    <div style={{ position: "relative", width: size, height: size, flexShrink: 0 }}>
      <svg width={size} height={size} style={{ transform: "rotate(-90deg)" }}>
        <circle cx={size/2} cy={size/2} r={r} fill="none" stroke="var(--surface-sunk)" strokeWidth={thick} />
        {segs.map((s, i) => {
          const len = (s.v / total) * C;
          const el = (
            <circle key={i} cx={size/2} cy={size/2} r={r} fill="none"
              stroke={s.color} strokeWidth={thick} strokeLinecap="butt"
              strokeDasharray={`${len} ${C - len}`} strokeDashoffset={-off}
              style={{ transition: "stroke-dasharray .45s cubic-bezier(.2,.8,.2,1), stroke-dashoffset .45s cubic-bezier(.2,.8,.2,1)" }} />
          );
          off += len;
          return el;
        })}
      </svg>
      {center && (
        <div style={{ position: "absolute", inset: 0, display: "flex", flexDirection: "column",
          alignItems: "center", justifyContent: "center", textAlign: "center" }}>
          {center}
        </div>
      )}
    </div>
  );
}

/* ============ BOTTOM NAV ============ */
function BottomNav({ active, onNav, pingCount }) {
  const items = [
    { k: "queue",   label: "Today",    ico: I.home },
    { k: "onsite",  label: "On-site",  ico: I.pin },
    { k: "earnings",label: "Earnings", ico: I.wallet },
    { k: "profile", label: "Profile",  ico: I.user },
  ];
  return (
    <nav className="bnav">
      {items.map((it) => {
        const on = active === it.k || (active === "weigh" && it.k === "onsite") || (active === "broadcast" && it.k === "onsite");
        return (
          <button key={it.k} className={"bnav-item" + (on ? " on" : "")} onClick={() => onNav(it.k)}>
            <it.ico size={26} sw={on ? 2.3 : 1.9} />
            <span>{it.label}</span>
            {it.k === "onsite" && pingCount > 0 && <span className="bnav-dot">{pingCount}</span>}
          </button>
        );
      })}
    </nav>
  );
}

/* ============ elapsed timer hook ============ */
function useElapsed(startMs) {
  const [now, setNow] = useState(Date.now());
  useEffect(() => {
    const t = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(t);
  }, []);
  const s = Math.max(0, Math.floor((now - startMs) / 1000));
  const hh = Math.floor(s / 3600), mm = Math.floor((s % 3600) / 60), ss = s % 60;
  const p2 = (n) => String(n).padStart(2, "0");
  return hh > 0 ? `${hh}:${p2(mm)}:${p2(ss)}` : `${p2(mm)}:${p2(ss)}`;
}

Object.assign(window, { Ico, I, Donut, BottomNav, useElapsed });
