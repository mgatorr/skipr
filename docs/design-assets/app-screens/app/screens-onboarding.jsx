/* ============================================================
   skipr — ONBOARDING screens
   1 Welcome + connect Claude   2 Guided setup (+ action-needed)
   3 Connect GitHub             (+ Spanish proof of Welcome)
   ============================================================ */

function ValueRow({ mark, tone, title, body }){
  const col = tone === "b" ? "var(--blue-d)" : "var(--orange-d)";
  return (
    <div className="row" style={{ alignItems: "flex-start", gap: 14 }}>
      <span style={{ width: 30, height: 30, flex: "none", borderRadius: 8, border: "1.5px solid var(--ink)",
        display: "flex", alignItems: "center", justifyContent: "center", color: col,
        background: tone === "b" ? "var(--blue-s)" : "var(--orange-s)" }}>
        <Icon name={mark} size={16} />
      </span>
      <div>
        <div className="h-disp" style={{ fontSize: 15.5, marginBottom: 2 }}>{title}</div>
        <div className="read" style={{ fontSize: 13.5, color: "var(--ink-3)", lineHeight: 1.4 }}>{body}</div>
      </div>
    </div>
  );
}

function WelcomePane({ es }){
  const t = es ? {
    coming: "Hola 👋", h: ["Bienvenido al lado", "donde el código", "es tuyo."],
    recap: "Convierte tu idea en software real y desplegado — tu código, tu repo, tu deploy. Sin terminal.",
    v1t: "Posee todo", v1b: "Tu código, tu repo de GitHub, tu deploy. Para siempre.",
    v2t: "Aprende construyendo", v2b: "Claude te muestra qué hace y por qué. Nada de cajas negras.",
    v3t: "Sin terminal", v3b: "Lenguaje claro de principio a fin. Tú al mando.",
    signin: "Conecta tu cuenta de Claude", signsub: "skipr usa Claude Code como motor. Tu cuenta, tus controles.",
    cta: "Continuar con Claude", foot: "Gratis durante la beta · cancela cuando quieras", step: "Paso 1 de 3",
    title: "Bienvenida"
  } : {
    coming: "Hi 👋", h: ["Welcome to the side", "where the code", "is yours."],
    recap: "Turn your idea into real, deployed software — your code, your repo, your deploy. No terminal.",
    v1t: "Own everything", v1b: "Your code, your GitHub repo, your deploy. Forever.",
    v2t: "Learn as you build", v2b: "Claude shows you what it's doing and why. No black boxes.",
    v3t: "No terminal", v3b: "Plain language end to end. You stay in control.",
    signin: "Connect your Claude account", signsub: "skipr runs on Claude Code. Your account, your controls.",
    cta: "Continue with Claude", foot: "Free during the beta · cancel anytime", step: "Step 1 of 3",
    title: "Welcome"
  };
  return (
    <AppWindow title={t.title} right={<span>{t.step}</span>}>
      {/* left brand panel */}
      <div style={{ width: "52%", background: "var(--paper-3)", borderRight: "1.5px solid var(--ink)",
        padding: "44px 46px", display: "flex", flexDirection: "column", position: "relative" }}>
        <div className="gridlines" style={{ position: "absolute", inset: 0, opacity: .6, pointerEvents: "none" }}></div>
        <div style={{ position: "relative" }}>
          <span className="kik" style={{ color: "var(--orange-d)" }}>{t.coming}</span>
          <h1 className="h-disp" style={{ fontSize: 40, lineHeight: .98, margin: "16px 0 14px" }}>
            {t.h[0]}<br />{t.h[1]}<br /><span className="o">{t.h[2]}</span>
          </h1>
          <p className="serif-lead" style={{ maxWidth: "34ch", marginBottom: 34 }}>{t.recap}</p>
          <div className="col" style={{ gap: 20 }}>
            <ValueRow mark="key" tone="b" title={t.v1t} body={t.v1b} />
            <ValueRow mark="eye" tone="o" title={t.v2t} body={t.v2b} />
            <ValueRow mark="chat" tone="b" title={t.v3t} body={t.v3b} />
          </div>
        </div>
        <div style={{ marginTop: "auto", position: "relative" }} className="kik">skipr.dev — independent software</div>
      </div>
      {/* right sign-in */}
      <div style={{ flex: 1, padding: "44px 46px", display: "flex", flexDirection: "column", justifyContent: "center", alignItems: "center", textAlign: "center" }}>
        <div className="card blue" style={{ maxWidth: 360, width: "100%", padding: 30 }}>
          <div style={{ width: 54, height: 54, margin: "0 auto 18px", borderRadius: 14, border: "1.5px solid var(--ink)",
            background: "var(--orange-s)", display: "flex", alignItems: "center", justifyContent: "center",
            fontFamily: "var(--mono)", fontWeight: 600, color: "var(--orange-d)", fontSize: 16 }}>CC</div>
          <h2 className="h-disp" style={{ fontSize: 22, marginBottom: 8 }}>{t.signin}</h2>
          <p className="read" style={{ fontSize: 14, color: "var(--ink-3)", marginBottom: 22, lineHeight: 1.45 }}>{t.signsub}</p>
          <Btn kind="primary" sz="lg" icon="spark" style={{ width: "100%" }}>{t.cta}</Btn>
          <div className="kik" style={{ marginTop: 16 }}>{t.foot}</div>
        </div>
        <div className="row" style={{ gap: 7, marginTop: 26 }}>
          <i style={{ width: 22, height: 5, borderRadius: 9, background: "var(--orange)" }}></i>
          <i style={{ width: 7, height: 5, borderRadius: 9, background: "var(--rule)" }}></i>
          <i style={{ width: 7, height: 5, borderRadius: 9, background: "var(--rule)" }}></i>
        </div>
      </div>
    </AppWindow>
  );
}

function OnbWelcome(){ return <WelcomePane es={false} />; }
function OnbWelcomeES(){ return <WelcomePane es={true} />; }

function SetupRow({ state, title, body, action }){
  const map = { done: ["done", "check"], doing: ["doing", null], todo: ["todo", null], alert: ["alert", "alert"] };
  const [cls, ic] = map[state];
  return (
    <div className="check-item">
      <span className={"ci-mark " + cls}>
        {ic ? <Icon name={ic} size={14} /> : (state === "doing" ? <span className="spinner"></span> : <span style={{ width: 7, height: 7, borderRadius: 9, border: "1.5px solid currentColor" }}></span>)}
      </span>
      <div className="ci-body">
        <h4>{title}
          {state === "done" && <span className="pill ready" style={{ transform: "scale(.85)" }}><span className="dot"></span>Ready</span>}
          {state === "doing" && <span className="pill building" style={{ transform: "scale(.85)" }}><span className="dot"></span>In progress</span>}
          {state === "alert" && <span className="pill action" style={{ transform: "scale(.85)" }}><span className="dot"></span>Action needed</span>}
        </h4>
        <p>{body}</p>
        {action && <div style={{ marginTop: 10 }}>{action}</div>}
      </div>
    </div>
  );
}

function SetupPane({ alertMode }){
  return (
    <AppWindow title="Setup" right={<span>Step 2 of 3</span>}>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", alignItems: "center", padding: "40px 24px", overflow: "hidden" }}>
        <div style={{ width: "100%", maxWidth: 620 }}>
          <span className="kik" style={{ color: "var(--orange-d)" }}>Getting your studio ready</span>
          <h1 className="h-disp" style={{ fontSize: 30, lineHeight: 1.02, margin: "12px 0 10px" }}>
            We're setting up everything <em className="it">you</em> need.
          </h1>
          <p className="serif-lead" style={{ marginBottom: 22 }}>
            No terminal, no config files, ever. {alertMode ? "One thing needs a quick tap from you." : "Sit tight — this takes about a minute."}
          </p>

          <div className="card flat" style={{ padding: "4px 22px" }}>
            <div className="check">
              <SetupRow state="done" title="Claude Code engine" body="Connected to your Claude account and ready to build." />
              <SetupRow state="done" title="Your workspace folder" body="A private folder on your Mac where your apps live — you can open it anytime." />
              {alertMode ? (
                <SetupRow state="alert" title="App runtime" body="skipr needs a small helper to run your apps locally. We can install it for you — it's safe and takes a few seconds."
                  action={<div className="btnrow"><Btn kind="accent" sz="sm" icon="check">Install it for me</Btn><Btn kind="ghost" sz="sm">What is this?</Btn></div>} />
              ) : (
                <SetupRow state="doing" title="App runtime" body="Installing a small helper so your apps can run locally. Nothing for you to do." />
              )}
              <SetupRow state="todo" title="Preview browser" body="Used to show your app live as you build it." />
            </div>
          </div>

          <div className="between" style={{ marginTop: 22 }}>
            <div className="row" style={{ gap: 10 }}>
              <div className="meter" style={{ width: 150 }}>
                <i className="b" style={{ width: alertMode ? "50%" : "55%" }}></i>
                {alertMode ? <i className="o" style={{ width: "8%" }}></i> : <i className="o" style={{ width: "20%" }}></i>}
              </div>
              <span className="kik">{alertMode ? "2 of 4 ready" : "2 of 4 ready · 1 working"}</span>
            </div>
            <Btn kind="primary" icon="back" style={{ flexDirection: "row-reverse" }} >Continue</Btn>
          </div>
        </div>
      </div>
    </AppWindow>
  );
}

function OnbSetup(){ return <SetupPane alertMode={false} />; }
function OnbSetupAlert(){ return <SetupPane alertMode={true} />; }

function OnbGitHub(){
  return (
    <AppWindow title="Connect GitHub" right={<span>Step 3 of 3</span>}>
      <div style={{ flex: 1, display: "flex", padding: 0 }}>
        <div style={{ flex: 1, padding: "48px 50px", display: "flex", flexDirection: "column", justifyContent: "center" }}>
          <span className="kik" style={{ color: "var(--blue-d)" }}>Make it yours</span>
          <h1 className="h-disp" style={{ fontSize: 33, lineHeight: 1.0, margin: "12px 0 14px", maxWidth: "16ch" }}>
            Your code deserves a home <span className="b">you own.</span>
          </h1>
          <p className="serif-lead" style={{ maxWidth: "44ch", marginBottom: 18 }}>
            GitHub is where your code lives — think of it as a safe, versioned folder on the internet that is <b style={{ color: "var(--ink)" }}>100% yours</b>. skipr creates a repo in <em className="it">your</em> account. You keep the keys.
          </p>
          <div className="banner info" style={{ maxWidth: 460, marginBottom: 24 }}>
            <Icon name="shield" size={19} />
            <span className="read">No lock-in, ever. Disconnect whenever you like — your code stays with you, on your account.</span>
          </div>
          <div className="btnrow">
            <Btn kind="primary" sz="lg" icon="branch">Connect GitHub</Btn>
            <Btn kind="ghost" sz="lg">I'll do this later</Btn>
          </div>
        </div>
        {/* repo preview */}
        <div style={{ width: 420, flex: "none", background: "var(--paper-3)", borderLeft: "1.5px solid var(--ink)",
          padding: "48px 40px", display: "flex", flexDirection: "column", justifyContent: "center", position: "relative" }}>
          <div className="gridlines" style={{ position: "absolute", inset: 0, opacity: .5 }}></div>
          <div className="card blue" style={{ position: "relative", padding: 0, overflow: "hidden" }}>
            <div className="row between" style={{ padding: "12px 15px", borderBottom: "1.5px solid var(--ink)", background: "var(--blue-s2)" }}>
              <span className="row" style={{ gap: 8, fontFamily: "var(--mono)", fontSize: 12, color: "var(--blue-d)" }}>
                <Icon name="branch" size={14} /> main
              </span>
              <span className="stamp-sm">owner: you ✓</span>
            </div>
            <div className="tree">
              {[["folder","src","dir"],["file","App.tsx",""],["folder","components","dir"],["folder","supabase","dir"],["file","README.md",""]].map((r,i)=>(
                <div className="tnode" key={i}><Icon name={r[0]} size={13} /><span className={r[2]}>{r[1]}</span></div>
              ))}
            </div>
            <div className="row" style={{ gap: 9, padding: "11px 15px", borderTop: "1.5px solid var(--ink)", fontFamily: "var(--mono)", fontSize: 11, color: "var(--ink-3)" }}>
              <span style={{ color: "var(--blue-d)" }}>a1f9c2e</span> first commit — by you
            </div>
          </div>
          <p className="kik" style={{ textAlign: "center", marginTop: 18, position: "relative" }}>github.com/maya/<b style={{ color: "var(--ink)" }}>your-app</b></p>
        </div>
      </div>
    </AppWindow>
  );
}

Object.assign(window, { OnbWelcome, OnbWelcomeES, OnbSetup, OnbSetupAlert, OnbGitHub });
