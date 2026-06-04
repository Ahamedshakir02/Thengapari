// app.jsx — root: shared state + routing
const { useState: useStateA, useRef: useRefA } = React;

function buildSteps(s) {
  const weighStatus = s.weighDone ? "done" : "active";
  const pingStatus  = !s.weighDone ? "pending" : (s.pingDone ? "done" : "active");
  const routeStatus = s.pingDone ? "active" : "pending";
  return [
    { k: "arrived",  label: "Arrived on site",       status: "done",       time: "9:16 AM", sub: "Geo-checked at gate" },
    { k: "harvest",  label: "Harvest complete",      status: "done",       time: "9:48 AM", sub: "14 trees climbed" },
    { k: "weigh",    label: "Weigh & grade yield",   status: weighStatus,  time: s.weighDone ? s.weighTime : null, sub: "Record weight per grade", cta: "Open weighing" },
    { k: "ping",     label: "Broadcast to processors", status: pingStatus, time: s.pingDone ? s.pingTime : null, sub: s.pingDone ? "Assigned to processor" : "Notify nearby buyers", cta: "Open broadcast" },
    { k: "route",    label: "Route byproducts",      status: routeStatus,  sub: "Husk · shell · fronds", cta: "Assign byproducts" },
    { k: "report",   label: "Submit site report",    status: "pending",    sub: "Photos, totals & sign-off" },
  ];
}

function nowTime() {
  const d = new Date();
  let h = d.getHours(), m = d.getMinutes();
  const ap = h >= 12 ? "PM" : "AM";
  h = h % 12 || 12;
  return `${h}:${String(m).padStart(2, "0")} ${ap}`;
}

function App() {
  const [route, setRoute] = useStateA("queue");
  const startMs = useRefA(Date.now() - (38 * 60 + 12) * 1000).current;
  const [state, setState] = useStateA({
    weight: 47.2,
    grades: { A: 31, B: 9, Tender: 4 },
    weighDone: false, weighTime: null,
    pingDone: false, pingTime: null,
  });

  const steps = buildSteps(state);
  const pingStep = steps.find((s) => s.k === "ping");
  const pingBadge = pingStep.status === "active" ? 1 : 0;

  const onStep = (s) => {
    if (s.k === "weigh") setRoute("weigh");
    else if (s.k === "ping" && s.status !== "pending") setRoute("broadcast");
  };
  const saveYield = ({ weight, grades }) => {
    setState((p) => ({ ...p, weight, grades, weighDone: true, weighTime: nowTime() }));
    setRoute("onsite");
  };
  const onAssigned = () => setState((p) => ({ ...p, pingDone: true, pingTime: nowTime() }));

  let screen;
  if (route === "queue") screen = <ScreenQueue onOpenJob={() => setRoute("onsite")} />;
  else if (route === "weigh") screen = <ScreenWeigh state={state} onSave={saveYield} onBack={() => setRoute("onsite")} />;
  else if (route === "broadcast") screen = <ScreenBroadcast state={state} onBack={() => setRoute("onsite")} onAssigned={onAssigned} />;
  else if (route === "earnings") screen = <ScreenStub title="Earnings" icon={I.wallet} />;
  else if (route === "profile") screen = <ScreenStub title="Profile" icon={I.user} />;
  else screen = <ScreenOnsite state={state} steps={steps} startMs={startMs}
    onStep={onStep}
    onPing={() => setRoute("broadcast")} />;

  const showNav = ["queue", "onsite", "earnings", "profile"].includes(route);

  return (
    <div style={{ height: "100%", display: "flex", flexDirection: "column", background: "var(--bg)" }}>
      <div style={{ flex: 1, minHeight: 0, display: "flex", flexDirection: "column" }}>{screen}</div>
      {showNav && <BottomNav active={route} onNav={setRoute} pingCount={route === "onsite" ? 0 : pingBadge} />}
    </div>
  );
}

function ScreenStub({ title, icon: Icon }) {
  return (
    <div className="kera">
      <header className="hdr"><div style={{ font: "var(--t-h2)", color: "#fff" }}>{title}</div></header>
      <div className="kera-body" style={{ display: "flex", alignItems: "center", justifyContent: "center" }}>
        <div style={{ textAlign: "center", color: "var(--fg3)" }}>
          <Icon size={48} sw={1.4} style={{ color: "var(--border-strong)" }} />
          <div style={{ font: "var(--t-body)", marginTop: 12 }}>{title} — not in this prototype</div>
        </div>
      </div>
    </div>
  );
}

window.App = App;
