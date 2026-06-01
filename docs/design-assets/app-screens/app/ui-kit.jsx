/* ============================================================
   skipr UI kit — shared chrome + atoms for the product screens
   Exports to window: Icon, Logo, AppWindow, Shell, Sidebar,
   Pill, Toggle, Btn, NAV
   ============================================================ */

const ICONS = {
  apps:   "M4 4h6v6H4zM14 4h6v6h-6zM4 14h6v6H4zM14 14h6v6h-6z",
  spark:  "M12 3l1.8 5.2L19 10l-5.2 1.8L12 17l-1.8-5.2L5 10l5.2-1.8z",
  build:  "M12 3l8 4.5v9L12 21l-8-4.5v-9zM4 7.5l8 4.5 8-4.5M12 12v9",
  skills: "M12 3l2.4 4.9 5.4.8-3.9 3.8.9 5.4-4.8-2.5-4.8 2.5.9-5.4L4.2 8.7l5.4-.8z",
  plug:   "M9 3v5M15 3v5M6 8h12v3a6 6 0 01-12 0zM12 17v4",
  gauge:  "M21 12a9 9 0 10-18 0M12 12l4-3M7 16h10",
  rocket: "M5 15c-1 2-1 4-1 4s2 0 4-1m1-3a8 8 0 018-8c2 0 3 1 3 3a8 8 0 01-8 8l-3-3zM14 9h.01",
  gear:   "M12 9a3 3 0 100 6 3 3 0 000-6zM19.4 13a7.8 7.8 0 000-2l1.8-1.4-1.8-3.1-2.2.7a7.5 7.5 0 00-1.7-1l-.3-2.3H9.6l-.3 2.3a7.5 7.5 0 00-1.7 1l-2.2-.7-1.8 3.1L5.4 11a7.8 7.8 0 000 2l-1.8 1.4 1.8 3.1 2.2-.7a7.5 7.5 0 001.7 1l.3 2.3h4.8l.3-2.3a7.5 7.5 0 001.7-1l2.2.7 1.8-3.1z",
  back:   "M15 5l-7 7 7 7M8 12h11",
  plus:   "M12 5v14M5 12h14",
  check:  "M5 13l4 4 10-11",
  alert:  "M12 4l9 16H3zM12 10v4M12 17h.01",
  lock:   "M7 11V8a5 5 0 0110 0v3M5 11h14v9H5z",
  key:    "M9 12a3 3 0 100-6 3 3 0 000 6zm2.5-1.5L20 19M17 16l2-2M15 18l1.5-1.5",
  file:   "M7 3h7l4 4v14H7zM14 3v4h4",
  folder: "M4 6h6l2 2h8v11H4z",
  chat:   "M5 5h14v10H9l-4 4z",
  branch: "M7 4v12M7 20a2 2 0 100-4 2 2 0 000 4zM7 6a2 2 0 100-4 2 2 0 000 4zM17 8a2 2 0 100-4 2 2 0 000 4zm0 0v2a4 4 0 01-4 4H7",
  search: "M11 18a7 7 0 100-14 7 7 0 000 14zM21 21l-4-4",
  more:   "M5 12h.01M12 12h.01M19 12h.01",
  close:  "M6 6l12 12M18 6L6 18",
  eye:    "M2 12s4-7 10-7 10 7 10 7-4 7-10 7S2 12 2 12zM12 15a3 3 0 100-6 3 3 0 000 6z",
  refresh:"M4 12a8 8 0 0114-5l2 2M20 12a8 8 0 01-14 5l-2-2M17 4v5h-5M7 20v-5h5",
  ext:    "M14 4h6v6M20 4l-9 9M18 14v6H4V6h6",
  user:   "M12 12a4 4 0 100-8 4 4 0 000 8zM5 21a7 7 0 0114 0",
  doc:    "M6 3h9l3 3v15H6zM9 13h6M9 17h6M9 9h3",
  globe:  "M12 3a9 9 0 100 18 9 9 0 000-18zM3 12h18M12 3c2.5 2.5 2.5 15 0 18M12 3c-2.5 2.5-2.5 15 0 18",
  shield: "M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z",
  money:  "M12 3v18M16 7H10a2.5 2.5 0 000 5h4a2.5 2.5 0 010 5H8",
  undo:   "M9 7L4 12l5 5M4 12h11a5 5 0 010 10",
  play:   "M7 4l12 8-12 8z",
  pencil: "M4 20h4L19 9l-4-4L4 16zM14 6l4 4",
};

function Icon({ name, size = 18, style }){
  const d = ICONS[name] || "";
  return (
    <svg className="ic" width={size} height={size} viewBox="0 0 24 24" fill="none"
      stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round" style={style}>
      {d.split("M").filter(Boolean).map((seg, i) => <path key={i} d={"M" + seg} />)}
    </svg>
  );
}

function Logo({ size = 20 }){
  return <span className="logo" style={{ fontSize: size }}>skipr<span className="pin">.</span></span>;
}

/* service monogram chip (avoids recreating brand logos) */
function Svc({ mark, tone = "n" }){
  const bg = tone === "b" ? "var(--blue-s)" : tone === "o" ? "var(--orange-s)" : "var(--paper-3)";
  const col = tone === "b" ? "var(--blue-d)" : tone === "o" ? "var(--orange-d)" : "var(--ink-2)";
  return (
    <span style={{ width: 28, height: 28, flex: "none", border: "1.5px solid var(--ink)", borderRadius: 7,
      display: "flex", alignItems: "center", justifyContent: "center", background: bg, color: col,
      fontFamily: "var(--mono)", fontSize: 11, fontWeight: 600 }}>{mark}</span>
  );
}

function Pill({ kind = "plain", children }){
  return <span className={"pill " + kind}><span className="dot"></span>{children}</span>;
}
function Toggle({ on }){ return <span className={"toggle" + (on ? " on" : "")}><i></i></span>; }
function Btn({ kind, sz, icon, children, style }){
  return (
    <button className={"btn" + (kind ? " btn-" + kind : "") + (sz ? " btn-" + sz : "")} style={style}>
      {icon && <Icon name={icon} size={sz === "lg" ? 17 : 15} />}{children}
    </button>
  );
}

/* window chrome */
function AppWindow({ title = "skipr", right, children }){
  return (
    <div className="skapp win">
      <div className="titlebar">
        <div className="lights"><i></i><i></i><i></i></div>
        <div className="tb-title"><b>skipr<span className="pin">.</span></b> {title}</div>
        <div className="tb-right">{right}</div>
      </div>
      <div className="win-body">{children}</div>
    </div>
  );
}

const NAV = [
  { id: "apps",        icon: "apps",   label: "Your apps" },
  { id: "skills",      icon: "skills", label: "Skills" },
  { id: "connections", icon: "plug",   label: "Connections" },
  { id: "cost",        icon: "gauge",  label: "Model & cost" },
  { id: "deploy",      icon: "rocket", label: "Deploy" },
];

function Sidebar({ active }){
  return (
    <div className="sidebar">
      <div className="sb-brand"><Logo /></div>
      <div className="sb-section">Build</div>
      {NAV.slice(0,1).map(n => (
        <div key={n.id} className={"navi" + (active === n.id ? " on" : "")}>
          <Icon name={n.icon} size={17} className="ic" />{n.label}
        </div>
      ))}
      <div className="sb-section">Workspace</div>
      {NAV.slice(1).map(n => (
        <div key={n.id} className={"navi" + (active === n.id ? " on" : "")}>
          <Icon name={n.icon} size={17} />{n.label}
        </div>
      ))}
      <div style={{ flex: 1 }}></div>
      <div className={"navi" + (active === "settings" ? " on" : "")}>
        <Icon name="gear" size={17} />Settings
      </div>
      <div className="sb-foot">
        <span className="avatar">M</span>
        <span className="who">Maya Okonkwo<small>founder · free trial</small></span>
      </div>
    </div>
  );
}

/* full shell: sidebar + main(topbar + content) [+ optional right panel] */
function Shell({ active, title, crumbs, actions, children, rightPanel, scroll = true }){
  return (
    <>
      <Sidebar active={active} />
      <div className="main">
        <div className="topbar">
          <div className="col" style={{ gap: 2 }}>
            {crumbs && <div className="crumbs">{crumbs}</div>}
            <h1>{title}</h1>
          </div>
          <div className="tb-actions">{actions}</div>
        </div>
        <div className={"content" + (scroll ? " scroll" : "")}>{children}</div>
      </div>
      {rightPanel}
    </>
  );
}

Object.assign(window, { Icon, Logo, Svc, Pill, Toggle, Btn, AppWindow, Shell, Sidebar, NAV });
