/* ============================================================
   skipr — COCKPIT: Deploy (ready / publishing / live) · Settings
   Exports: DeployReady, DeployProgress, DeployLive, SettingsScreen
   ============================================================ */

function DeployStepper({ step }){
  const steps = ["Save to GitHub", "Set up database", "Publish to web", "Live"];
  return (
    <div className="stepper">
      {steps.map((s, i) => (
        <React.Fragment key={i}>
          <div className={"st " + (i < step ? "done" : i === step ? "active" : "")}>
            <span className="num">{i < step ? <Icon name="check" size={13} /> : i + 1}</span>
            <span className="nm">{s}</span>
          </div>
          {i < steps.length - 1 && <span className={"bar" + (i < step ? " done" : "")}></span>}
        </React.Fragment>
      ))}
    </div>
  );
}

function OwnRow({ mark, tone, what, where, state }){
  return (
    <div className="between" style={{ padding: "14px 16px", border: "1.5px solid var(--ink)", borderRadius: 10, background: "var(--card)" }}>
      <div className="row" style={{ gap: 12 }}>
        <Svc mark={mark} tone={tone} />
        <div><div className="h-disp" style={{ fontSize: 14.5 }}>{what}</div><div className="mono" style={{ fontSize: 11, color: "var(--ink-4)" }}>{where}</div></div>
      </div>
      {state === "ready" && <span className="pill ready"><span className="dot"></span>Ready</span>}
      {state === "done" && <span className="pill live"><span className="dot"></span>Done</span>}
      {state === "doing" && <span className="row" style={{ gap: 8 }}><span className="spinner"></span><span className="mono" style={{ fontSize: 11, color: "var(--orange-d)" }}>working…</span></span>}
    </div>
  );
}

function DeployReady(){
  return (
    <AppWindow title="Deploy" right={<span>Cohort CRM</span>}>
      <Shell active="deploy" title="Deploy" crumbs="COHORT CRM › DEPLOY" scroll={false}>
        <div style={{ maxWidth: 600, margin: "0 auto", paddingTop: 6 }}>
          <span className="kik" style={{ color: "var(--blue-d)" }}>Publish</span>
          <h2 className="h-disp" style={{ fontSize: 28, margin: "8px 0 6px" }}>Put it on the internet —<br /><em className="it">and keep every key.</em></h2>
          <p className="serif-lead" style={{ marginBottom: 22 }}>skipr publishes to your own accounts. Nothing is rented, nothing is locked. You can move or undo it anytime.</p>
          <DeployStepper step={0} />
          <div className="col" style={{ gap: 10, margin: "24px 0" }}>
            <OwnRow mark="GH" tone="b" what="Your code" where="github.com/maya/cohort-crm" state="ready" />
            <OwnRow mark="Su" tone="b" what="Your database" where="your Supabase project" state="ready" />
            <OwnRow mark="Ve" tone="o" what="Your live app" where="cohort-crm.vercel.app" state="ready" />
          </div>
          <div className="between">
            <span className="stamp-sm" style={{ color: "var(--orange-d)", borderColor: "var(--orange-d)" }}>100% yours</span>
            <Btn kind="primary" sz="lg" icon="rocket">Publish my app</Btn>
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}

function DeployProgress(){
  return (
    <AppWindow title="Deploy" right={<span>publishing…</span>}>
      <Shell active="deploy" title="Publishing your app…" crumbs="COHORT CRM › DEPLOY" scroll={false}>
        <div style={{ maxWidth: 600, margin: "0 auto", paddingTop: 6 }}>
          <DeployStepper step={2} />
          <div className="col" style={{ gap: 10, margin: "26px 0 20px" }}>
            <OwnRow mark="GH" tone="b" what="Saved to your GitHub repo" where="12 files committed — by you" state="done" />
            <OwnRow mark="Su" tone="b" what="Your database is set up" where="tables created in your project" state="done" />
            <OwnRow mark="Ve" tone="o" what="Putting it on the web" where="building & uploading…" state="doing" />
          </div>
          <div className="card flat" style={{ background: "var(--paper-2)" }}>
            <div className="row between" style={{ marginBottom: 10 }}><span className="kik">Progress</span><span className="mono" style={{ fontSize: 11, color: "var(--ink-3)" }}>step 3 of 4</span></div>
            <div className="meter"><i className="b" style={{ width: "72%" }}></i><i className="o" style={{ width: "8%" }}></i></div>
            <p className="read" style={{ fontSize: 13.5, color: "var(--ink-3)", marginTop: 12 }}>This usually takes under a minute. You don't need to do anything — grab a coffee.</p>
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}

function DeployLive(){
  return (
    <AppWindow title="Deploy" right={<span>live ✓</span>}>
      <Shell active="deploy" title="Deploy" crumbs="COHORT CRM › DEPLOY" scroll={false}>
        <div style={{ maxWidth: 580, margin: "0 auto", paddingTop: 4, textAlign: "center" }}>
          <span className="stamp-sm" style={{ fontSize: 11 }}>shipped {new Date().getFullYear()}</span>
          <h2 className="h-disp" style={{ fontSize: 34, margin: "14px 0 8px", lineHeight: 1 }}>Your app is <span className="b">live.</span></h2>
          <p className="serif-lead" style={{ marginBottom: 22 }}>You went from an idea to real, deployed software — and it's all yours.</p>

          <div className="card blue" style={{ padding: 0, overflow: "hidden", textAlign: "left", marginBottom: 20 }}>
            <div className="between" style={{ padding: "14px 16px" }}>
              <div className="row" style={{ gap: 11 }}>
                <span style={{ width: 34, height: 34, borderRadius: 9, border: "1.5px solid var(--ink)", background: "var(--blue-s)", display: "flex", alignItems: "center", justifyContent: "center", color: "var(--blue-d)" }}><Icon name="globe" size={18} /></span>
                <div><div className="mono" style={{ fontSize: 13, color: "var(--ink)" }}>cohort-crm.vercel.app</div><div className="kik" style={{ marginTop: 2 }}>your live address</div></div>
              </div>
              <div className="btnrow"><Btn sz="sm" icon="doc">Copy</Btn><Btn kind="primary" sz="sm" icon="ext">Open app</Btn></div>
            </div>
          </div>

          <div className="row" style={{ gap: 10, justifyContent: "center", marginBottom: 22 }}>
            {[["GH","b","your repo"],["Su","b","your database"],["Ve","o","your hosting"]].map((c,i)=>(
              <div key={i} className="row" style={{ gap: 8, padding: "8px 12px", border: "1.5px solid var(--ink)", borderRadius: 999, background: "var(--card)" }}>
                <Svc mark={c[0]} tone={c[1]} /><span className="mono" style={{ fontSize: 11 }}>{c[2]}</span>
              </div>
            ))}
          </div>
          <div className="btnrow" style={{ justifyContent: "center" }}>
            <Btn icon="branch">View your repo</Btn>
            <Btn kind="accent" icon="spark">Keep building</Btn>
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}

/* ---- Settings ---- */
function SetBlock({ title, children, note }){
  return (
    <div className="card flat" style={{ marginBottom: 16 }}>
      <div className="between" style={{ marginBottom: 14 }}>
        <span className="kik">{title}</span>
        {note && <span className="mono" style={{ fontSize: 11, color: "var(--ink-4)" }}>{note}</span>}
      </div>
      {children}
    </div>
  );
}

function SettingsScreen(){
  return (
    <AppWindow title="Settings" right={<span>Maya Okonkwo</span>}>
      <Shell active="settings" title="Settings" crumbs="SETTINGS">
        <div style={{ maxWidth: 680 }}>
          <SetBlock title="Account">
            <div className="between">
              <div className="row" style={{ gap: 13 }}>
                <span className="avatar" style={{ width: 44, height: 44, fontSize: 17 }}>M</span>
                <div><div className="h-disp" style={{ fontSize: 16 }}>Maya Okonkwo</div><div className="read muted" style={{ fontSize: 13.5 }}>maya@hellostudio.co</div></div>
              </div>
              <div className="row" style={{ gap: 12 }}>
                <span className="pill plain"><span className="dot" style={{ background: "var(--orange)" }}></span>Free trial · 12 days</span>
                <Btn kind="primary" sz="sm">Upgrade</Btn>
              </div>
            </div>
          </SetBlock>

          <div className="grid" style={{ gridTemplateColumns: "1fr 1fr" }}>
            <SetBlock title="Language" note="English primary · Español secondary">
              <div className="seg" style={{ width: "100%" }}>
                <button className="on" style={{ flex: 1 }}>English</button>
                <button style={{ flex: 1 }}>Español</button>
              </div>
              <p className="read muted" style={{ fontSize: 13, marginTop: 10 }}>skipr speaks your language, end to end.</p>
            </SetBlock>
            <SetBlock title="Appearance" note="matches skipr.dev">
              <div className="seg" style={{ width: "100%" }}>
                <button className="on" style={{ flex: 1 }}>Light (paper)</button>
                <button style={{ flex: 1 }}>Dark (ink)</button>
              </div>
              <p className="read muted" style={{ fontSize: 13, marginTop: 10 }}>Warm by day, deep by night.</p>
            </SetBlock>
          </div>

          <SetBlock title="Connections" note="3 connected">
            <div className="between">
              <div className="row" style={{ gap: 8 }}>
                <Svc mark="GH" tone="b" /><Svc mark="Su" tone="b" /><Svc mark="CC" tone="o" />
                <span className="read muted" style={{ fontSize: 13.5, marginLeft: 4 }}>GitHub, Supabase, Claude</span>
              </div>
              <Btn sz="sm" icon="plug">Manage connections</Btn>
            </div>
          </SetBlock>

          <div className="banner info" style={{ marginTop: 4 }}>
            <Icon name="shield" size={19} />
            <span className="read"><b>skipr is independent.</b> Not affiliated with, endorsed by, or sponsored by Anthropic. Your code, repos and data are always yours.</span>
          </div>
          <div className="btnrow" style={{ marginTop: 18 }}>
            <Btn kind="ghost" icon="back">Sign out</Btn>
            <span className="mono" style={{ fontSize: 11, color: "var(--ink-4)", marginLeft: "auto", alignSelf: "center" }}>skipr v0.9 (beta) · skipr.dev</span>
          </div>
        </div>
      </Shell>
    </AppWindow>
  );
}

Object.assign(window, { DeployReady, DeployProgress, DeployLive, SettingsScreen });
