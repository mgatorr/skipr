/* ============================================================
   skipr — COCKPIT: Skills · Connections (MCP) · Model & cost
   Exports: SkillsScreen, ConnScreen, ConnConnect, CostScreen, CostAlert
   ============================================================ */

function SkillSuggest({ icon, name, why, added }){
  return (
    <div className="card" style={{ flex: 1, padding: 16, boxShadow: "4px 4px 0 var(--ink)" }}>
      <div className="row" style={{ gap: 11, marginBottom: 10 }}>
        <span style={{ width: 32, height: 32, flex: "none", borderRadius: 8, border: "1.5px solid var(--ink)", background: "var(--orange-s)", color: "var(--orange-d)", display: "flex", alignItems: "center", justifyContent: "center" }}><Icon name={icon} size={17} /></span>
        <div className="h-disp" style={{ fontSize: 15 }}>{name}</div>
      </div>
      <p className="read" style={{ fontSize: 13.5, color: "var(--ink-3)", lineHeight: 1.4, marginBottom: 14, minHeight: 56 }}>{why}</p>
      <Btn kind={added ? "" : "primary"} sz="sm" icon={added ? "check" : "plus"} style={{ width: "100%" }}>{added ? "Added" : "Add skill"}</Btn>
    </div>
  );
}

function SkillRow({ name, desc, uses, tokens, on, unused }){
  return (
    <div className="check-item" style={{ alignItems: "center" }}>
      <div className="ci-body">
        <h4>{name}
          {unused ? <span className="pill action" style={{ transform: "scale(.82)" }}><span className="dot"></span>Unused — turn off?</span>
                  : <span className="tag" style={{ color: "var(--blue-d)", borderColor: "var(--blue-d)" }}>used {uses}× this week</span>}
        </h4>
        <p>{desc}</p>
      </div>
      <div className="row" style={{ gap: 18, flex: "none" }}>
        <span className="mono" style={{ fontSize: 11, color: "var(--ink-4)" }}>{tokens}</span>
        <Toggle on={on} />
      </div>
    </div>
  );
}

function SkillsScreen(){
  return (
    <AppWindow title="Skills" right={<span>Cohort CRM</span>}>
      <Shell active="skills" title="Skills" crumbs="COHORT CRM › SKILLS"
        actions={<Btn icon="search">Browse all skills</Btn>}>
        <div className="banner info" style={{ marginBottom: 22 }}>
          <Icon name="skills" size={19} />
          <span className="read"><b>Skills give Claude extra know-how</b> for your goal — like sending email or taking payments. Turn on what helps; turn off what you don't use to stay fast and cheap.</span>
        </div>

        <div className="between" style={{ marginBottom: 13 }}>
          <span className="kik" style={{ color: "var(--orange-d)" }}>Suggested for Cohort CRM</span>
          <span className="mono" style={{ fontSize: 11, color: "var(--ink-4)" }}>based on your plan</span>
        </div>
        <div className="row" style={{ gap: 14, alignItems: "stretch", marginBottom: 26 }}>
          <SkillSuggest icon="chat" name="Email notifications" why="Your plan nudges quiet members — this skill sends those reminder emails for you." />
          <SkillSuggest icon="doc" name="Import from a spreadsheet" why="Already have a member list? Bring it in from a CSV in one step." />
          <SkillSuggest icon="money" name="Stripe payments" why="For later — when you're ready to take membership payments." />
        </div>

        <div className="between" style={{ marginBottom: 4 }}>
          <span className="kik">In use — audit</span>
          <span className="row" style={{ gap: 8 }}><span className="pill ready" style={{ transform: "scale(.9)" }}><span className="dot"></span>4 on</span><span className="pill action" style={{ transform: "scale(.9)" }}><span className="dot"></span>1 unused</span></span>
        </div>
        <div className="card flat" style={{ padding: "2px 18px" }}>
          <div className="check">
            <SkillRow name="Database & data" desc="Stores and fetches your members and check-ins." uses="40" tokens="1.2M tok" on />
            <SkillRow name="Forms & inputs" desc="The add-member and check-in forms." uses="18" tokens="320K tok" on />
            <SkillRow name="Accounts & sign-in" desc="Lets you (and staff) log in securely." uses="6" tokens="90K tok" on />
            <SkillRow name="PDF export" desc="Used to export reports — you haven't needed it yet." tokens="0 tok" unused />
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}

/* ---- Connections (MCP) ---- */
function ConnCard({ mark, tone, name, sub, status }){
  const map = {
    on: <span className="pill live" style={{ transform: "scale(.86)" }}><span className="dot"></span>Connected</span>,
    err: <span className="pill action" style={{ transform: "scale(.86)" }}><span className="dot"></span>Needs attention</span>,
    off: <span className="pill idea" style={{ transform: "scale(.86)" }}><span className="dot"></span>Not connected</span>,
  };
  return (
    <div className={"card" + (status === "err" ? " accent" : "")} style={{ padding: 17, boxShadow: status === "err" ? "4px 4px 0 var(--orange)" : "4px 4px 0 var(--ink)" }}>
      <div className="between" style={{ marginBottom: 11 }}>
        <div className="row" style={{ gap: 11 }}><Svc mark={mark} tone={tone} /><div className="h-disp" style={{ fontSize: 15.5 }}>{name}</div></div>
        {map[status]}
      </div>
      <p className="read" style={{ fontSize: 13.5, color: "var(--ink-3)", lineHeight: 1.4, marginBottom: 14 }}>{sub}</p>
      <div className="btnrow">
        {status === "on" && <><Btn sz="sm" icon="gear">Manage</Btn><Btn kind="ghost" sz="sm">Disconnect</Btn></>}
        {status === "err" && <Btn kind="accent" sz="sm" icon="refresh">Reconnect</Btn>}
        {status === "off" && <Btn kind="primary" sz="sm" icon="plus">Connect</Btn>}
      </div>
    </div>
  );
}

function ConnScreen(){
  return (
    <AppWindow title="Connections" right={<span>Cohort CRM</span>}>
      <Shell active="connections" title="Connections" crumbs="COHORT CRM › CONNECTIONS"
        actions={<Btn kind="primary" icon="plus">Add connection</Btn>}>
        <p className="serif-lead" style={{ marginBottom: 20 }}>Connections let your app talk to real services. <b style={{ color: "var(--ink)" }}>Your keys stay yours</b> — skipr keeps them safe.</p>
        <div className="grid" style={{ gridTemplateColumns: "1fr 1fr" }}>
          <ConnCard mark="GH" tone="b" name="GitHub" sub="Where your code lives — your repo, your commits." status="on" />
          <ConnCard mark="Su" tone="b" name="Supabase" sub="Your app's database and stored data." status="on" />
          <ConnCard mark="St" tone="o" name="Stripe" sub="Key expired — reconnect to keep payments working." status="err" />
          <ConnCard mark="Re" tone="n" name="Resend (email)" sub="Send reminder emails to your members." status="off" />
        </div>
        <div className="banner ok" style={{ marginTop: 20 }}>
          <Icon name="lock" size={19} />
          <span className="read"><b>Your secrets are encrypted</b> and stored on your Mac. skipr never sees them in plain text, and nothing is shared without you.</span>
        </div>
      </Shell>
    </AppWindow>
  );
}

function ConnConnect(){
  return (
    <AppWindow title="Connections" right={<span>add a service</span>}>
      <Shell active="connections" title="Connect Stripe" crumbs="CONNECTIONS › ADD" scroll={false}
        actions={<Btn kind="ghost" icon="close">Cancel</Btn>}>
        <div style={{ maxWidth: 560, margin: "0 auto", paddingTop: 8 }}>
          <div className="row" style={{ gap: 13, marginBottom: 20 }}>
            <Svc mark="St" tone="o" /><div><div className="h-disp" style={{ fontSize: 19 }}>Connect Stripe</div><div className="read muted" style={{ fontSize: 14 }}>Take membership payments, safely.</div></div>
          </div>
          <div className="stepper" style={{ marginBottom: 22 }}>
            <div className="st done"><span className="num"><Icon name="check" size={13} /></span><span className="nm">Open Stripe</span></div>
            <span className="bar done"></span>
            <div className="st active"><span className="num">2</span><span className="nm">Paste key</span></div>
            <span className="bar"></span>
            <div className="st"><span className="num">3</span><span className="nm">Done</span></div>
          </div>
          <div className="card">
            <div className="field" style={{ marginBottom: 14 }}>
              <label className="lbl">Secret key from Stripe</label>
              <div className="inp-key"><Icon name="lock" size={14} style={{ color: "var(--blue-d)" }} /><span className="masked">sk_live_••••••••••••••••4f9c</span><Icon name="eye" size={15} style={{ color: "var(--ink-4)" }} /></div>
            </div>
            <div className="banner info" style={{ marginBottom: 16 }}>
              <Icon name="shield" size={18} />
              <span className="read">This key is <b>encrypted on your Mac</b> the moment you paste it. We never store it on our servers.</span>
            </div>
            <div className="btnrow" style={{ justifyContent: "flex-end" }}>
              <Btn kind="ghost">Where do I find this?</Btn>
              <Btn kind="primary" icon="check">Connect securely</Btn>
            </div>
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}

/* ---- Model & cost ---- */
function ModelCard({ name, blurb, speed, cost, on, rec }){
  return (
    <div className="card" style={{ flex: 1, padding: 16, boxShadow: on ? "4px 4px 0 var(--blue)" : "none", borderColor: on ? "var(--ink)" : "var(--rule)", position: "relative" }}>
      {rec && <span className="stamp-sm" style={{ position: "absolute", top: -10, right: 12 }}>recommended</span>}
      <div className="between" style={{ marginBottom: 8 }}>
        <div className="h-disp" style={{ fontSize: 16 }}>{name}</div>
        {on ? <span className="pill live" style={{ transform: "scale(.84)" }}><span className="dot"></span>On</span> : <Btn kind="ghost" sz="sm">Switch</Btn>}
      </div>
      <p className="read" style={{ fontSize: 13, color: "var(--ink-3)", lineHeight: 1.4, marginBottom: 12 }}>{blurb}</p>
      <div className="col" style={{ gap: 6 }}>
        <div className="row" style={{ gap: 8 }}><span className="mono" style={{ fontSize: 10, width: 46, color: "var(--ink-4)" }}>SPEED</span><Dots n={speed} tone="b" /></div>
        <div className="row" style={{ gap: 8 }}><span className="mono" style={{ fontSize: 10, width: 46, color: "var(--ink-4)" }}>COST</span><Dots n={cost} tone="o" /></div>
      </div>
    </div>
  );
}
function Dots({ n, tone }){
  return <div className="row" style={{ gap: 4 }}>{[1,2,3].map(i => <span key={i} style={{ width: 16, height: 6, borderRadius: 9, background: i <= n ? (tone === "b" ? "var(--blue)" : "var(--orange)") : "var(--paper-3)", border: "1px solid var(--rule)" }}></span>)}</div>;
}

function CostBars(){
  const rows = [["Building your app", 54, "o"],["Database (Supabase)", 18, "b"],["Planning", 11, "n"],["Email skill", 7, "o"],["Accounts & sign-in", 10, "b"]];
  const amt = ["$6.10","$2.10","$1.20","$0.80","$1.20"];
  return (
    <div className="barlist">
      {rows.map((r,i)=>(
        <div className="barrow" key={i}>
          <span className="nm">{r[0]}</span>
          <span className="track"><i style={{ width: r[1]+"%", background: r[2]==="o"?"var(--orange)":r[2]==="b"?"var(--blue)":"var(--ink-4)" }}></i></span>
          <span className="amt">{amt[i]}</span>
        </div>
      ))}
    </div>
  );
}

function CostShell({ alert }){
  return (
    <AppWindow title="Model & cost" right={<span>Cohort CRM</span>}>
      <Shell active="cost" title="Model & cost" crumbs="COHORT CRM › COST">
        {alert && (
          <div className="banner warn" style={{ marginBottom: 20 }}>
            <Icon name="alert" size={20} />
            <span className="read"><b>Heads up — you've used 82% of your $20 budget</b> this month. Want to stretch it? Switch simple edits to a cheaper model below.</span>
            <Btn kind="accent" sz="sm">Switch to Haiku</Btn>
          </div>
        )}
        <span className="kik" style={{ color: "var(--orange-d)" }}>Your model</span>
        <p className="serif-lead" style={{ fontSize: 14.5, margin: "6px 0 14px" }}>skipr picks a sensible default. For quick edits, a lighter model saves money; for tricky bugs, a sharper one thinks harder.</p>
        <div className="row" style={{ gap: 14, alignItems: "stretch", marginBottom: 24 }}>
          <ModelCard name="Haiku" blurb="Fast & cheap. Great for small text and layout tweaks." speed={3} cost={1} />
          <ModelCard name="Sonnet" blurb="Balanced — skipr's default for most building." speed={2} cost={2} on rec />
          <ModelCard name="Opus" blurb="The deep thinker. Best for gnarly bugs and big features." speed={1} cost={3} />
        </div>

        <div className="grid" style={{ gridTemplateColumns: "1fr 1.4fr", alignItems: "start" }}>
          <div className="card">
            <div className="kik" style={{ marginBottom: 10 }}>This month</div>
            <div className="row" style={{ alignItems: "baseline", gap: 8, marginBottom: 12 }}>
              <span className="h-disp" style={{ fontSize: 38 }}>{alert ? "$16.40" : "$11.40"}</span>
              <span className="read muted" style={{ fontSize: 15 }}>/ $20 budget</span>
            </div>
            <div className="meter" style={{ marginBottom: 10 }}><i className={alert ? "o" : "b"} style={{ width: alert ? "82%" : "57%" }}></i></div>
            <div className="between">
              <span className="read" style={{ fontSize: 13.5 }}>Alert me at 80%</span>
              <Toggle on />
            </div>
          </div>
          <div className="card flat">
            <div className="kik" style={{ marginBottom: 14 }}>Where it goes</div>
            <CostBars />
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}
function CostScreen(){ return <CostShell alert={false} />; }
function CostAlert(){ return <CostShell alert={true} />; }

Object.assign(window, { SkillsScreen, ConnScreen, ConnConnect, CostScreen, CostAlert });
