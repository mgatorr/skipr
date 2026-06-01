/* ============================================================
   skipr — COCKPIT: Build workspace (the hero screen)
   Exports: BuildWorkspace (diff + approve), BuildPreview (running app)
   File tree + tabs + plain-language conversation. Never a black box.
   ============================================================ */

function TNode({ icon, name, dir, on, changed, indent }){
  return (
    <div className={"tnode" + (on ? " on" : "") + (changed ? " changed" : "") + (indent ? " indent" : "")}>
      <Icon name={icon} size={13} /><span className={dir ? "dir" : ""}>{name}</span>
    </div>
  );
}

function FileTree(){
  return (
    <div style={{ width: 232, flex: "none", borderRight: "1.5px solid var(--ink)", background: "var(--paper-2)", display: "flex", flexDirection: "column" }}>
      <div className="between" style={{ padding: "11px 14px", borderBottom: "1.5px solid var(--ink)" }}>
        <span className="kik">Your files</span>
        <Icon name="search" size={14} style={{ color: "var(--ink-4)" }} />
      </div>
      <div className="tree" style={{ flex: 1 }}>
        <TNode icon="folder" name="src" dir />
        <TNode icon="file" name="App.tsx" indent />
        <TNode icon="folder" name="screens" dir indent />
        <TNode icon="file" name="Members.tsx" on changed indent />
        <TNode icon="file" name="CheckIns.tsx" indent />
        <TNode icon="folder" name="components" dir indent />
        <TNode icon="folder" name="supabase" dir />
        <TNode icon="file" name="schema.sql" changed indent />
        <TNode icon="file" name="README.md" />
      </div>
      <div style={{ padding: "11px 14px", borderTop: "1.5px solid var(--ink)" }}>
        <span className="stamp-sm">all yours · on your Mac</span>
      </div>
    </div>
  );
}

function CodeLine({ n, kind, children }){
  return <div className={"ln" + (kind ? " " + kind : "")}><span className="n">{n}</span><span className="g">{children}</span></div>;
}

function DiffView(){
  return (
    <div className="code scroll" style={{ flex: 1 }}>
      <CodeLine n="12"><span className="com">{"// one-tap check-in for today's class"}</span></CodeLine>
      <CodeLine n="13" kind="add"><span className="kw">function</span> CheckInButton({"{ member }"}) {"{"}</CodeLine>
      <CodeLine n="14" kind="add">{"  "}<span className="kw">const</span> markPresent = () =&gt; checkIn(member.id);</CodeLine>
      <CodeLine n="15" kind="add">{"  "}<span className="kw">return</span> &lt;Button onClick={"{markPresent}"}&gt;<span className="str">Check in</span>&lt;/Button&gt;;</CodeLine>
      <CodeLine n="16" kind="add">{"}"}</CodeLine>
      <CodeLine n="17">&nbsp;</CodeLine>
      <CodeLine n="18">&lt;MemberRow member={"{m}"}&gt;</CodeLine>
      <CodeLine n="19" kind="del">{"  "}&lt;Status value={"{m.status}"} /&gt;</CodeLine>
      <CodeLine n="20" kind="add">{"  "}&lt;Status value={"{m.status}"} /&gt;</CodeLine>
      <CodeLine n="21" kind="add">{"  "}&lt;CheckInButton member={"{m}"} /&gt;</CodeLine>
      <CodeLine n="22">&lt;/MemberRow&gt;</CodeLine>
    </div>
  );
}

function ConvPanel({ preview }){
  return (
    <div style={{ width: 388, flex: "none", borderLeft: "1.5px solid var(--ink)", background: "var(--paper-2)", display: "flex", flexDirection: "column", minHeight: 0 }}>
      <div className="tabs" style={{ background: "var(--paper-3)" }}>
        <div className="tab on"><Icon name="chat" size={13} />Main</div>
        <div className="tab"><Icon name="chat" size={13} />Styling</div>
        <div className="tab" style={{ color: "var(--ink-4)" }}><Icon name="plus" size={13} /></div>
      </div>
      <div className="chat scroll" style={{ flex: 1, minHeight: 0 }}>
        <div className="msg you">
          <div className="who">you</div>
          <div className="bubble">Can you add a way to mark someone as checked in for today's class?</div>
        </div>
        <div className="msg agent">
          <div className="who"><span style={{ width: 6, height: 6, borderRadius: 9, background: "var(--orange)" }}></span>skipr</div>
          <div className="bubble">{preview ? "Done! Your members screen now has a one-tap check-in. Take a look on the left 👈" : "Sure — here's what I'll change. It's a one-tap check-in on each member:"}</div>
        </div>
        <div className="col" style={{ gap: 8 }}>
          <div className={"action-line" + (preview ? " done" : "")}>
            <Icon name={preview ? "check" : "pencil"} size={15} />
            <span>Added a <b style={{ color: "var(--ink)" }}>Check in</b> button to every member.</span>
          </div>
          <div className={"action-line" + (preview ? " done" : "")}>
            <Icon name={preview ? "check" : "plus"} size={15} />
            <span>Created a <span className="fn">check_ins</span> table in your database.</span>
          </div>
          <div className={"action-line" + (preview ? " done" : "")}>
            <Icon name={preview ? "check" : "pencil"} size={15} />
            <span>Updated <span className="fn">Members.tsx</span> to show today's check-ins.</span>
          </div>
        </div>
        {preview && (
          <div className="msg agent"><div className="bubble" style={{ background: "var(--blue-s)", borderColor: "var(--blue-d)" }}>Looks good? When you're happy, you can <b style={{ color: "var(--ink)" }}>publish it</b> — it stays 100% yours.</div></div>
        )}
      </div>
      {!preview ? (
        <div className="approvebar" style={{ flexDirection: "column", alignItems: "stretch", gap: 10 }}>
          <span className="q"><b style={{ color: "var(--ink)" }}>Apply these 3 changes</b> to your app?</span>
          <div className="btnrow" style={{ justifyContent: "flex-end" }}>
            <Btn kind="ghost" sz="sm" icon="undo">Revert</Btn>
            <Btn kind="primary" sz="sm" icon="check">Approve changes</Btn>
          </div>
        </div>
      ) : (
        <div className="composer">
          <input className="inp" placeholder="Ask for a change in plain words…" />
          <Btn kind="primary" icon="spark" style={{ padding: "10px 14px" }}></Btn>
        </div>
      )}
    </div>
  );
}

function BuildShell({ preview }){
  return (
    <AppWindow title="Cohort CRM" right={<span>your workspace</span>}>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
        {/* project topbar */}
        <div className="topbar" style={{ paddingLeft: 14 }}>
          <Btn kind="ghost" sz="sm" icon="back" style={{ padding: "6px 9px" }}></Btn>
          <div className="row" style={{ gap: 10 }}>
            <h1 style={{ fontSize: 16 }}>Cohort CRM</h1>
            <span className="pill building"><span className="dot"></span>Building</span>
          </div>
          <div className="tb-actions">
            <div className="seg">
              <button className={preview ? "" : "on"}>Changes</button>
              <button className={preview ? "on" : ""}>Preview</button>
            </div>
            <Btn kind="accent" icon="rocket">Deploy</Btn>
          </div>
        </div>

        <div style={{ flex: 1, display: "flex", minHeight: 0 }}>
          <FileTree />
          {/* center editor */}
          <div className="main" style={{ minWidth: 0 }}>
            <div className="tabs">
              <div className="tab"><Icon name="file" size={12} />App.tsx</div>
              <div className="tab on"><Icon name="file" size={12} />Members.tsx <span className="chg"></span></div>
              <div className="tab"><Icon name="file" size={12} />schema.sql <span className="chg"></span></div>
            </div>
            {preview ? (
              <div style={{ flex: 1, minHeight: 0, background: "var(--paper-3)", padding: 20, overflow: "hidden" }}>
                {/* mini running app */}
                <div className="card" style={{ height: "100%", padding: 0, overflow: "hidden", boxShadow: "4px 4px 0 var(--blue)" }}>
                  <div className="between" style={{ padding: "12px 16px", borderBottom: "1.5px solid var(--ink)", background: "var(--paper-2)" }}>
                    <span className="h-disp" style={{ fontSize: 16 }}>Members</span>
                    <span className="tag" style={{ fontFamily: "var(--mono)" }}>localhost · live</span>
                  </div>
                  <div style={{ padding: 14 }}>
                    {[["Ana Ruiz","Active","b"],["Leo Park","Active","b"],["Priya Shah","Quiet 16d","o"],["Sam Cole","Active","b"]].map((m,i)=>(
                      <div key={i} className="between" style={{ padding: "11px 12px", border: "1.5px solid var(--rule)", borderRadius: 8, marginBottom: 9 }}>
                        <div className="row" style={{ gap: 11 }}>
                          <span className="avatar" style={{ width: 30, height: 30, fontSize: 12 }}>{m[0][0]}</span>
                          <div><div className="h-disp" style={{ fontSize: 14 }}>{m[0]}</div>
                            <div className={"mono " + (m[2]==="o"?"o":"")} style={{ fontSize: 11, color: m[2]==="o"?"var(--orange-d)":"var(--blue-d)" }}>{m[1]}</div></div>
                        </div>
                        <Btn kind={m[2]==="o"?"accent":"primary"} sz="sm" icon="check">Check in</Btn>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            ) : (
              <>
                <div className="between" style={{ padding: "8px 16px", borderBottom: "1.5px solid var(--rule-2)", background: "var(--paper)" }}>
                  <span className="row" style={{ gap: 9 }}>
                    <span className="kik">Members.tsx</span>
                    <span className="tag" style={{ color: "var(--orange-d)", borderColor: "var(--orange-d)" }}>3 lines added · 1 changed</span>
                  </span>
                  <span className="kik">plain diff — green is new, you decide</span>
                </div>
                <DiffView />
              </>
            )}
          </div>
          <ConvPanel preview={preview} />
        </div>
      </div>
    </AppWindow>
  );
}

function BuildWorkspace(){ return <BuildShell preview={false} />; }
function BuildPreview(){ return <BuildShell preview={true} />; }

Object.assign(window, { BuildWorkspace, BuildPreview });
