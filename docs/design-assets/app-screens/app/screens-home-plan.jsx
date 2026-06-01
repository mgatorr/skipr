/* ============================================================
   skipr — COCKPIT: Your apps (Home) + Idea→Plan (spec)
   Exports: HomeApps, HomeEmpty, IdeaPlan, IdeaPlanGen
   ============================================================ */

const PROJECTS = [
  { id: "tide", name: "Tide", glyph: "T", tone: "b", desc: "Tide times + alerts for my surf spots.", status: "live", when: "live · edited 2h ago" },
  { id: "cohort", name: "Cohort CRM", glyph: "C", tone: "o", desc: "Track members, classes and check-ins for my gym.", status: "building", when: "building · 5 min ago" },
  { id: "supper", name: "Supper Club", glyph: "S", tone: "b", desc: "Bookings + waitlist for our pop-up dinners.", status: "live", when: "live · 3 days ago" },
  { id: "invoice", name: "Invoice Ninja", glyph: "I", tone: "o", desc: "Send invoices and chase late payers, politely.", status: "building", when: "building · yesterday" },
  { id: "field", name: "Field Notes", glyph: "F", tone: "n", desc: "A place to jot site visits with photos.", status: "idea", when: "idea · draft" },
];

function StatusPill({ status }){
  const label = { live: "Live", building: "Building", idea: "Idea" }[status];
  return <span className={"pill " + status}><span className="dot"></span>{label}</span>;
}

function ProjectCard({ p }){
  return (
    <div className="proj">
      <div className={"thumb " + p.tone}><span className="glyph">{p.glyph}</span>
        <span style={{ position: "absolute", top: 10, right: 10 }}><StatusPill status={p.status} /></span>
      </div>
      <div className="pbody">
        <h4>{p.name}</h4>
        <p>{p.desc}</p>
        <div className="pmeta"><span className="when mono">{p.when}</span><Icon name="more" size={16} style={{ color: "var(--ink-4)" }} /></div>
      </div>
    </div>
  );
}

function HomeApps(){
  return (
    <AppWindow title="Your apps" right={<span>5 apps</span>}>
      <Shell active="apps" title="Your apps" crumbs="HOME"
        actions={<><div className="inp-key" style={{ width: 200, padding: "7px 12px" }}><Icon name="search" size={15} style={{ color: "var(--ink-4)" }} /><span style={{ color: "var(--ink-4)", fontFamily: "var(--read)", fontSize: 14 }}>Search</span></div><Btn kind="primary" icon="plus">New app</Btn></>}>
        <div className="between" style={{ marginBottom: 18 }}>
          <p className="serif-lead" style={{ fontSize: 15 }}>Everything here is <b style={{ color: "var(--ink)" }}>yours</b> — your code, your repos, your deploys.</p>
          <div className="seg"><button className="on">All</button><button>Live</button><button>Building</button></div>
        </div>
        <div className="grid" style={{ gridTemplateColumns: "repeat(3, 1fr)" }}>
          {PROJECTS.map(p => <ProjectCard key={p.id} p={p} />)}
          <div className="proj new">
            <div className="plus"><div className="sym"><Icon name="plus" size={22} /></div>
              <div className="h-disp" style={{ fontSize: 16 }}>New app</div>
              <div className="mono" style={{ fontSize: 11, color: "var(--ink-4)", marginTop: 4 }}>start from an idea</div>
            </div>
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}

function HomeEmpty(){
  const chips = ["a CRM for my gym", "a booking page for my studio", "an invoice tracker", "a tide-times app"];
  return (
    <AppWindow title="Your apps" right={<span>get started</span>}>
      <Shell active="apps" title="Your apps" crumbs="HOME"
        actions={<Btn kind="primary" icon="plus">New app</Btn>} scroll={false}>
        <div className="empty">
          <span className="stamp-sm" style={{ color: "var(--orange-d)", borderColor: "var(--orange-d)" }}>blank canvas</span>
          <div className="big" style={{ fontSize: 34, marginTop: 10 }}>Your first app<br />starts with a <em className="it">sentence.</em></div>
          <p className="sub">Tell skipr what you want in plain words. It writes a clear plan, builds real code, and hands you the keys.</p>
          <div className="row" style={{ gap: 9, marginTop: 18, flexWrap: "wrap", justifyContent: "center", maxWidth: 520 }}>
            {chips.map((c, i) => (
              <span key={i} className="tag" style={{ fontFamily: "var(--read)", fontSize: 14, padding: "8px 13px", borderStyle: "dashed", borderColor: "var(--ink-3)", color: "var(--ink-2)", cursor: "pointer" }}>“{c}”</span>
            ))}
          </div>
          <div style={{ marginTop: 24 }}><Btn kind="primary" sz="lg" icon="spark">Describe your first app</Btn></div>
        </div>
      </Shell>
    </AppWindow>
  );
}

/* ---- Idea → Plan (Spec-driven) ---- */
function PlanSection({ n, title, items, editable }){
  return (
    <div className="card flat" style={{ padding: "15px 18px", marginBottom: 12 }}>
      <div className="between" style={{ marginBottom: items ? 11 : 0 }}>
        <div className="row" style={{ gap: 10 }}>
          <span className="mono" style={{ fontSize: 11, color: "var(--orange-d)" }}>{n}</span>
          <span className="h-disp" style={{ fontSize: 15 }}>{title}</span>
        </div>
        {editable && <Icon name="pencil" size={14} style={{ color: "var(--ink-4)" }} />}
      </div>
      {items && <div className="col" style={{ gap: 8 }}>
        {items.map((it, i) => (
          <div key={i} className="row" style={{ gap: 10, alignItems: "flex-start" }}>
            <span style={{ width: 17, height: 17, flex: "none", marginTop: 1, borderRadius: 5, border: "1.5px solid var(--blue-d)", color: "var(--blue-d)", display: "flex", alignItems: "center", justifyContent: "center" }}><Icon name="check" size={11} /></span>
            <span className="read" style={{ fontSize: 14, color: "var(--ink-2)", lineHeight: 1.4 }}>{it}</span>
          </div>
        ))}
      </div>}
    </div>
  );
}

function PlanShell({ generating }){
  return (
    <AppWindow title="New app — the plan" right={<span>Spec-driven</span>}>
      <div style={{ flex: 1, display: "flex", minWidth: 0 }}>
        {/* left: the idea */}
        <div style={{ width: 380, flex: "none", borderRight: "1.5px solid var(--ink)", background: "var(--paper-2)", padding: 24, display: "flex", flexDirection: "column" }}>
          <span className="kik" style={{ color: "var(--orange-d)" }}>Step 1 — your idea</span>
          <h2 className="h-disp" style={{ fontSize: 21, margin: "10px 0 14px" }}>In your own words.</h2>
          <div className="card flat" style={{ background: "var(--card)", padding: 0, flex: "none" }}>
            <div className="between" style={{ padding: "10px 13px", borderBottom: "1.5px solid var(--rule-2)" }}>
              <span className="kik">what you typed</span><Icon name="pencil" size={13} style={{ color: "var(--ink-4)" }} />
            </div>
            <p className="read" style={{ padding: "14px 15px", fontSize: 15, lineHeight: 1.5, color: "var(--ink)" }}>
              “A simple CRM for my gym. I want to add members, see who's active, track class check-ins, and get a nudge when someone hasn't shown up in two weeks.”
            </p>
          </div>
          <div className="banner info" style={{ marginTop: 18 }}>
            <Icon name="shield" size={18} />
            <span className="read"><b>Plan first, build second.</b> Nothing gets built until you approve. Edit anything you like.</span>
          </div>
          <div style={{ marginTop: "auto" }} className="kik">skipr reads your idea, never your data.</div>
        </div>

        {/* right: the plan */}
        <div className="main">
          <div className="topbar">
            <div className="col" style={{ gap: 2 }}>
              <div className="crumbs">STEP 2 — THE PLAN</div>
              <h1>{generating ? "Turning your words into a plan…" : "Here's what skipr will build"}</h1>
            </div>
            <div className="tb-actions">{generating ? <span className="spinner"></span> : <span className="pill ready"><span className="dot"></span>Ready to approve</span>}</div>
          </div>
          <div className="content scroll">
            {generating ? (
              <div className="col" style={{ gap: 12 }}>
                {[0,1,2,3].map(i => (
                  <div key={i} className="card flat" style={{ padding: "16px 18px" }}>
                    <div style={{ height: 12, width: "32%", background: "var(--paper-3)", borderRadius: 6, marginBottom: 12 }}></div>
                    <div style={{ height: 9, width: "82%", background: "var(--paper-3)", borderRadius: 6, marginBottom: 8 }}></div>
                    <div style={{ height: 9, width: "68%", background: "var(--paper-3)", borderRadius: 6 }}></div>
                  </div>
                ))}
              </div>
            ) : (
              <>
                <PlanSection n="A" title="What it does" items={["Add and edit gym members", "See who's active vs. lapsed at a glance", "Log class check-ins in one tap", "Nudge you when a member goes quiet for 2 weeks"]} editable />
                <PlanSection n="B" title="Screens skipr will build" items={["Members list with search & status", "Member detail with check-in history", "Today's check-ins", "Quiet-members watchlist"]} editable />
                <PlanSection n="C" title="Where your data lives" items={["A private database in your Supabase account", "You own it — export anytime"]} editable />
                <PlanSection n="D" title="Not in this version" items={["Payments & billing (we can add later)", "A public-facing website"]} editable />
              </>
            )}
          </div>
          {!generating && (
            <div className="approvebar">
              <span className="q"><b style={{ color: "var(--ink)" }}>Happy with the plan?</b> You can still change everything later.</span>
              <Btn kind="ghost" icon="pencil">Tweak the plan</Btn>
              <Btn kind="primary" icon="check">Approve &amp; build</Btn>
            </div>
          )}
        </div>
      </div>
    </AppWindow>
  );
}

function IdeaPlan(){ return <PlanShell generating={false} />; }
function IdeaPlanGen(){ return <PlanShell generating={true} />; }

Object.assign(window, { HomeApps, HomeEmpty, IdeaPlan, IdeaPlanGen, StatusPill });
