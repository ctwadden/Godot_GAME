extends Control
const Lab=preload("res://scripts/lab.gd")
const Diagram=preload("res://scripts/diagram.gd")
const INK=Color("e8f1f4")
const MUTED=Color("a6bacb")
const CYAN=Color("79dbcf")
const AMBER=Color("efc783")
var page="menu"
var demo=false
var step=0
var policy=1
var digital=1
var outage=0
var accessible=true
var prediction=-1
var last_run={}
var history=[]
var token=Lab.new_token()
var match_choices=[-1,-1,-1,-1]
var match_feedback=""
var answers=["","",""]
var screen: Control
var popup: AcceptDialog
var selected_person=0
var notice=""
const A_STEPS=[
 "START / Four customers use the same fictional credits. Digital-only means THIS shop accepts the selected phone-based route. Predict who can pay: having a phone, an account, cash and an accessible interface are separate conditions.",
 "NORMAL / Central mobile route: P01 and P04 can pay, 2 of 4. P02 has no central account. P03 has a flat phone. Inspect a customer to trace authorization, recorded fields and balances. No real transfer occurs.",
 "NAMED OUTAGE / Only the central connection goes down. Central transfers cannot commit: 0 of 4. Cash and the shared route have not lost connectivity. A failed request changes no balances and incurs no fee in this model.",
 "CASH FALLBACK / Keep that outage; change only to mixed acceptance. Three customers carried cash and can pay. P04 brought no cash, so is still excluded. More routes add handling work and setup requirements.",
 "RESTORE / Mixed acceptance now serves all four: P01 and P04 use central; P02 and P03 use cash fallback. Compare access, fees and handling separately. This does not make mixed acceptance best in every shop.",
 "SHARED DOES NOT MEAN MAGIC / Switch to the toy shared route. P02 has separately provisioned shared access, not a bank account. One node down leaves 2 of 3, so validation continues. P03 still needs cash because the phone is flat.",
 "DEPENDENCY / With two nodes down, the toy shared route cannot commit. Cash fallback still works for three. Names of outages and explicit assumptions matter. Recommend a policy for the shop, different customers and infrastructure providers."
]
const B_STEPS=[
 "START / Folder A holds the original classroom SVG. The registry has ONE identifier, CLASS-LAB / 0001, controlled by Alias A. The licence is separate evidence about permitted uses.",
 "COPY / The same image bytes now appear in three virtual folders. All have the same SHA-256 fingerprint. This copied the file, not the registry entry or its unique collection/token identifier.",
 "TRANSFER / Control of the existing token changes to Alias B. The identifier stays the same; the control history gains an entry. The licence and creator's copyright stay unchanged.",
 "READ THE LICENCE / L1 lets all three classroom users store and display a copy with credit. It does not permit commercial reproduction. Permission comes from these terms, not from holding a file or controlling the token.",
 "BROKEN LINK / The external media host is now unavailable. The token register and local files persist. A persistent record does not itself preserve linked media. This missing preview is simulated; nothing is fetched online.",
 "CITE EVIDENCE / Match each claim to a folder, register or licence clause. Then explain what this token establishes and what it does not. A different explicit licence could grant different rights."
]
func _ready():
 DisplayServer.window_set_title("Payment & Token Lab / Godot classroom demonstration")
 if OS.has_feature("web"):
  var requested=str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('mode') || ''"))
  if requested in ["a","b","demo-a","demo-b"]:
   start_mode("access" if requested.ends_with("a") else "token",requested.begins_with("demo"));return
 render()
func style(color: Color) -> StyleBoxFlat:
 var s=StyleBoxFlat.new();s.bg_color=color;s.set_corner_radius_all(12)
 s.content_margin_left=14;s.content_margin_right=14;s.content_margin_top=12;s.content_margin_bottom=12
 return s
func label(value: String,parent: Node,sz: int=18,color: Color=INK) -> Label:
 var l=Label.new();l.text=value;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 l.add_theme_font_size_override("font_size",sz);l.add_theme_color_override("font_color",color);parent.add_child(l);return l
func fixed(value: String,pos: Vector2,extent: Vector2,sz: int=20,color: Color=INK):
 var l=label(value,screen,sz,color);l.position=pos;l.size=extent
func button(value: String,parent: Node,action: Callable,accent: bool=false) -> Button:
 var b=Button.new();b.text=value;b.custom_minimum_size.y=42;b.add_theme_font_size_override("font_size",17)
 b.add_theme_stylebox_override("normal",style(CYAN if accent else Color("2a455d")))
 b.add_theme_stylebox_override("hover",style(Color("b4ede1") if accent else Color("3d6077")))
 b.add_theme_color_override("font_color",Color("122b3b") if accent else INK)
 b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;b.pressed.connect(action);parent.add_child(b);return b
func column(pos: Vector2,extent: Vector2) -> VBoxContainer:
 var p=PanelContainer.new();p.position=pos;p.size=extent;p.add_theme_stylebox_override("panel",style(Color("172b40")));screen.add_child(p)
 var scroll=ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;p.add_child(scroll)
 var c=VBoxContainer.new();c.size_flags_horizontal=Control.SIZE_EXPAND_FILL;c.add_theme_constant_override("separation",10);scroll.add_child(c);return c
func select(title: String,items: Array,value: int,parent: Node,action: Callable,locked: bool=false) -> OptionButton:
 label(title,parent,15,MUTED)
 var b=OptionButton.new();b.fit_to_longest_item=false;b.custom_minimum_size.y=38;b.add_theme_font_size_override("font_size",17)
 for item in items:b.add_item(str(item))
 b.select(value);b.disabled=locked;b.item_selected.connect(action);parent.add_child(b);return b
func render():
 if screen!=null:remove_child(screen);screen.queue_free()
 screen=Control.new();screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(screen)
 fixed("P / T",Vector2(26,20),Vector2(120,50),35,CYAN)
 fixed("PAYMENT & TOKEN LAB",Vector2(158,20),Vector2(890,40),30)
 fixed("TRACE THE ROUTE. CHECK THE RECORD. READ THE LICENCE.",Vector2(160,59),Vector2(890,26),15,MUTED)
 var nav=HBoxContainer.new();nav.position=Vector2(1050,25);screen.add_child(nav)
 button("Help",nav,show_help);button("Discussion",nav,func():page="discussion";render());button("Menu",nav,func():page="menu";render())
 if page=="menu":render_menu()
 elif page=="access":render_access()
 elif page=="token":render_token()
 elif page=="discussion":render_discussion()
 elif page=="evidence":render_evidence()
 fixed("Fictional teaching model only / no wallets, trading, purchases, gambling, live finance or personal data. Save a report before closing.",Vector2(25,870),Vector2(1390,25),14,MUTED)
func render_menu():
 var a=column(Vector2(25,125),Vector2(685,642))
 label("MODE A / ACCESS & RESILIENCE",a,27,CYAN)
 label("Who can pay when a connection fails?",a,31)
 label("Choose a shop's payment policy, inspect four different customer situations and trace verification, records and infrastructure. Same fictional currency; different payment methods.",a,22)
 button("Demonstrate Mode A",a,func():start_mode("access",true),true)
 button("Explore Mode A independently",a,func():start_mode("access",false))
 label("Approximately 15 minutes including prediction and discussion. Each comparison resets the same independent cases; there is no profit score.",a,19,MUTED)
 var b=column(Vector2(735,125),Vector2(680,642))
 label("MODE B / TOKEN & LICENCE",b,27,AMBER)
 label("A file, a token and a right are different.",b,31)
 label("Copy one image into three virtual folders. Change token control. Inspect an explicit fictional licence. Break a simulated media link and find out what actually persists.",b,22)
 button("Demonstrate Mode B",b,func():start_mode("token",true),true)
 button("Explore Mode B independently",b,func():start_mode("token",false))
 label("Approximately 15 minutes including evidence matching. Includes a static cost worksheet and a source-analysis discussion, with no purchase or reward controls.",b,19,MUTED)
 fixed("I CAN: distinguish route / currency / record; explain access trade-offs; distinguish token control from permission.",Vector2(35,797),Vector2(1360,50),20,CYAN)
func start_mode(which: String,worked: bool):
 page=which;demo=worked;step=0;notice="";prediction=-1
 if which=="access":policy=1;digital=1;outage=0;accessible=true;last_run={}
 else:token=Lab.new_token();match_choices=[-1,-1,-1,-1];match_feedback=""
 render()
func diagram(section: String):
 var d=Diagram.new();d.position=Vector2(25,190);d.size=Vector2(940,515);d.section=section;d.result=last_run;d.token=token;screen.add_child(d)
func render_access():
 fixed("A / ACCESS & RESILIENCE",Vector2(30,111),Vector2(940,48),30)
 diagram("access")
 if not last_run.is_empty():
  var t=last_run.totals
  fixed("ACCESS %d/4   |   FEES %s   |   PROCESSING %d s" % [t.access,Lab.fc(t.fee),t.seconds],Vector2(35,726),Vector2(925,34),22,CYAN)
  fixed("Handling: %d transaction steps + %d setup steps (invented work units)." % [t.work,t.setup_work],Vector2(35,767),Vector2(925,30),19,AMBER)
  var stale=last_run.policy!=policy or last_run.digital!=digital or last_run.outage!=outage or last_run.accessible!=accessible
  fixed("SETTINGS CHANGED / run again; diagram and totals remain the last snapshot." if stale else Lab.POLICIES[policy]+" / "+Lab.OUTAGES[outage],Vector2(35,805),Vector2(925,45),17,AMBER if stale else MUTED)
 else:fixed("Predict access, then reveal the four cases. Select any case to trace its route.",Vector2(35,740),Vector2(920,80),24,CYAN)
 var c=column(Vector2(990,112),Vector2(425,740))
 if demo:
  label("EXPERT ROUND %d / %d" % [step+1,A_STEPS.size()],c,16,CYAN);label(A_STEPS[step],c,22)
  button("Explore this state" if step==A_STEPS.size()-1 else "Next demonstration step",c,advance_demo,true)
 else:
  select("Shop acceptance",Lab.POLICIES,policy,c,func(i):policy=i)
  select("Selected digital route",[Lab.ROUTES[1],Lab.ROUTES[2]],digital-1,c,func(i):digital=i+1)
  select("Named outage",Lab.OUTAGES,outage,c,func(i):outage=i)
  var cb=CheckBox.new();cb.text="Fictional terminal: keyboard + large text";cb.button_pressed=accessible
  cb.toggled.connect(func(v):accessible=v);c.add_child(cb)
  select("Prediction: how many can pay?",["Choose…","0 of 4","1 of 4","2 of 4","3 of 4","4 of 4"],prediction+1,c,func(i):prediction=i-1)
  button("Reveal comparison",c,run_access,true)
  if notice!="":label(notice,c,16,AMBER)
 select("Inspect a customer",Lab.CUSTOMERS.map(func(p):return p.id+" / "+p.label),selected_person,c,func(i):selected_person=i)
 button("Trace selected customer",c,show_customer)
 button("Rules, assumed costs & privacy",c,show_rules)
 if not demo:button("Write my recommendation",c,func():page="evidence";render())
func run_access(authored: bool=false):
 if not authored and prediction<0:notice="Predict 0–4 before revealing.";render();return
 last_run=Lab.run(policy,digital,outage,accessible)
 history.append({"prediction":prediction,"result":last_run.duplicate(true)})
 prediction=-1;notice="Inspect the blocked customer and name the failed dependency. Change one condition and compare."
 render()
func advance_demo():
 if page=="access":
  if step>=A_STEPS.size()-1:demo=false;render();return
  step+=1
  if step==1:pass
  elif step==2:outage=1
  elif step==3:policy=2
  elif step==4:outage=0
  elif step==5:digital=2;outage=4
  elif step==6:outage=5
  run_access(true)
 else:
  if step>=B_STEPS.size()-1:demo=false;render();return
  step+=1
  if step==1:Lab.copy_image(token)
  elif step==2:Lab.transfer_token(token,"Alias B")
  elif step==4:token.host_up=false
  render()
func message(title_value: String,body: String):
 if popup!=null:popup.hide();popup.queue_free()
 popup=AcceptDialog.new();popup.title=title_value;popup.min_size=Vector2i(870,160);add_child(popup)
 var sc=ScrollContainer.new();sc.custom_minimum_size=Vector2(840,540);sc.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;popup.add_child(sc)
 var c=VBoxContainer.new();c.size_flags_horizontal=Control.SIZE_EXPAND_FILL;sc.add_child(c)
 label(body,c,21);popup.popup_centered()
func show_customer():
 if last_run.is_empty():message("Run a case first","Predict and reveal, or advance the expert demonstration. The inspector always uses the last comparison snapshot.");return
 var p=Lab.CUSTOMERS[selected_person];var r=last_run.rows[selected_person];var t=r.trace
 var body=p.id+" / "+p.detail+"\n\nLAST SNAPSHOT: "+Lab.POLICIES[last_run.policy]+" / "+Lab.OUTAGES[last_run.outage]
 body+="\n\n"+("CAN PAY via "+Lab.ROUTES[r.route] if r.ok else "CANNOT PAY")+"\n"+r.why
 if r.fallback:body+="\nDigital failed because: "+r.digital_why+"\nCash fallback used."
 body+="\n\nCURRENCY: "+t.currency+"\nVERIFIES: "+t.verifier+"\nREQUIRES: "+t.infrastructure+"\nRECORD VISIBILITY: "+t.visibility
 body+="\nCOMMITTED FIELDS: "+("none: failed request" if t.fields.is_empty() else "; ".join(t.fields))
 body+="\n\nIndependent balance trace (not cumulative): customer %s -> %s; shop %s -> %s; provider fee %s." % [Lab.fc(t.customer_before),Lab.fc(t.customer_after),Lab.fc(t.shop_before),Lab.fc(t.shop_after),Lab.fc(t.provider_after)]
 if not t.balance_exists:body+="\nThe zero available balance above means no cash/account available for this route, not an existing funded account."
 body+="\n\nPseudonyms can be linked to people or other activity; they do not guarantee anonymity. No actual customer personal details are collected or shown."
 message("Transfer trace / "+p.id,body)
func show_rules():
 message("Classroom assumptions / not measured costs", "Every request is 10 fictional credits (FC). Same currency on cash, central and shared routes. Cases reset each run.\n\nSuccessful cash: fee 0 FC, 18 s, 2 handling steps (count/change; secure/record). Central: 0.10 FC, 4 s, 1 step. Shared: 0.20 FC, 7 s, 1 step. Setup work: cash-only 1, digital-only 2, mixed 3 invented units. Times are summed successful processing durations, not a queue simulation or measured productivity. Failed attempts have no fee/debit here; real arrangements may differ.\n\nBoth digital routes HERE require a charged phone. Physical cards, offline payments and alternative credentials are outside this example. P02 has separate shared-demo access; lack of a bank account is not proof that this access exists in real life. P04 needs an accessible terminal and brought no cash. Cash assumes usable change, staffed assistance and safe handling.\n\nCentral outage affects central only. Shared outage affects shared only. Shop internet affects both digital routes; cash continues. Shared route uses a toy 2-of-3 rule, not secure production consensus or mining. There are other consensus methods besides proof of work; not every digital payment is cryptocurrency.\n\nA ledger is a transaction record system, not itself a currency. Central records are private; the class sees sanitized aliases. Shared records are visible to authorized demo nodes. Pseudonyms are not anonymity. Mixed may improve access here but adds infrastructure/handling and is not a universal best choice.")
func render_token():
 fixed("B / TOKEN, FILE & LICENCE",Vector2(30,111),Vector2(940,48),30)
 diagram("token")
 var f=Lab.token_facts(token)
 fixed("LOCAL COPIES %d   |   TOKEN ENTRIES 1   |   CONTROLLER %s" % [f.copies,f.controller],Vector2(35,726),Vector2(925,34),22,CYAN)
 fixed("Media fingerprint: "+Lab.fingerprint(Lab.image_bytes()).substr(0,16)+"… / identical across copied files",Vector2(35,769),Vector2(925,40),17,MUTED)
 fixed("Copying is a local in-memory file operation. No new token is minted; no live network is contacted.",Vector2(35,814),Vector2(925,35),16,MUTED)
 var c=column(Vector2(990,112),Vector2(425,740))
 if demo:
  label("EXPERT ROUND %d / %d" % [step+1,B_STEPS.size()],c,16,CYAN);label(B_STEPS[step],c,22)
  button("Explore this state" if step==B_STEPS.size()-1 else "Next demonstration step",c,advance_demo,true)
 else:
  button("Copy image to all three folders",c,func():Lab.copy_image(token);render(),true)
  select("Recorded token controller",["Alias A","Alias B","Alias C"],["Alias A","Alias B","Alias C"].find(token.controller),c,func(i):Lab.transfer_token(token,["Alias A","Alias B","Alias C"][i]);render())
  button("Break external media link" if token.host_up else "Restore external media link",c,func():token.host_up=not token.host_up;render())
 button("Read explicit licence L1",c,func():message("Licence L1 / fictional evidence",token.licence))
 button("Inspect registry & copied bytes",c,show_registry)
 if not demo:button("Reset Mode B",c,func():start_mode("token",false))
 label("MATCH CLAIM TO EVIDENCE",c,16,AMBER)
 var claims=["A local file is present in Folder A.",token.controller+" controls the unique token.","Classroom display with credit is permitted.","Commercial reproduction is permitted."]
 for i in range(4):
  var idx=i
  select(claims[i],["Choose evidence…","Folder listing","Token register","Licence permits","Licence contradicts"],match_choices[i]+1,c,func(v):match_choices[idx]=v-1,demo)
 if not demo:button("Check evidence matches",c,check_matches)
 if match_feedback!="":label(match_feedback,c,18,CYAN)
 if not demo:button("Explain what the token establishes",c,func():page="evidence";render())
func check_matches():
 var correct=0
 for i in range(4):
  if match_choices[i]==i:correct+=1
 match_feedback="%d/4 evidence sources matched. Folder bytes establish a local copy; registry establishes token control; L1 permits classroom display and contradicts commercial-use permission. This is feedback, not a grade." % correct
 render()
func show_registry():
 var parts=[]
 for i in range(3):
  var bytes=token.copies[i]
  parts.append("Folder %s / %s" % [["A","B","C"][i],"empty" if bytes.is_empty() else "%d bytes, fingerprint %s" % [bytes.size(),Lab.fingerprint(bytes).substr(0,16)]])
 message("Evidence register / no actual wallet", "\n".join(parts)+"\n\nExactly one registry entry: "+token.id+"\nController: "+token.controller+"\n\n"+"\n".join(token.history)+"\n\nExternal pointer (never fetched): "+token.media_pointer+"\nHost state: "+("available" if token.host_up else "broken / remote preview unavailable")+"\n\nThe identifier is unique within this fictional collection. Neither the filename nor an alias proves creator identity, copyright, authenticity of a real-world claim or commercial permission. The token establishes only recorded control in this toy register. L1 is unchanged.")
func render_discussion():
 fixed("DISCUSS / COSTS, ACCESS & POWER",Vector2(30,111),Vector2(1380,48),30)
 var a=column(Vector2(25,180),Vector2(685,665))
 label("STATIC WORKSHEET / FAKE DOLLARS",a,20,CYAN)
 label("Five fixed-price digital items",a,29)
 label("Item 1    $2     cumulative $2\nItem 2    $2     cumulative $4\nItem 3    $2     cumulative $6\nItem 4    $2     cumulative $8\nItem 5    $2     cumulative $10\n\n5 × $2 = $10",a,23)
 label("DISCLOSED FIXED ITEM: $2 for the named blue avatar outfit.\n\nRANDOM-REWARD OFFER: $2 for an unspecified item from a pool. Odds, duplicates and restrictions would matter to informed judgement. No draw is run here.",a,20,AMBER)
 label("What would a buyer need to know about total cost, exact contents or probabilities, duplicate outcomes, spending controls and refund terms? Which interests conflict for the buyer, parent/carer and publisher?",a,19)
 var b=column(Vector2(735,180),Vector2(680,665))
 label("E-TRADING / SOURCE ANALYSIS ONLY",b,20,CYAN)
 label("Read a historical case, not a price pattern.",b,28)
 label("Chapter p.225, GameStop case (paraphrased): online traders used social platforms to coordinate interest in a stock; professional funds also faced financial exposure. The chapter describes platform restrictions during volatile trading and conflicting views about access and risk.",b,21)
 label("This is an account to analyse, not independent confirmation of every claim or a current market recommendation. No prices, trading orders or returns are simulated.",b,18,MUTED)
 label("COMPARE\n• Access: who could participate, and who faced barriers?\n• Power: who could set or change platform restrictions?\n• Risk: who could lose money, and what did they know?\n• Evidence: what additional primary sources and dates would you need before judging the restrictions?",b,21,AMBER)
 button("Write my exit evidence",b,func():page="evidence";render(),true)
 button("Back to mode selection",b,func():page="menu";render())
func render_evidence():
 fixed("EXIT / EXPLAIN WITH EVIDENCE",Vector2(30,111),Vector2(1380,48),30)
 var c=column(Vector2(25,180),Vector2(940,665))
 var prompts=["1 / Recommend a shop payment policy under a named outage. Cite results for two different customers, handling work and a provider dependency. Explain a condition that would change your recommendation.","2 / Explain what CLASS-LAB / 0001 establishes and what it does NOT establish under L1. Cite a folder, register and licence clause. What survived the broken media link? What would change under a different explicit licence?","3 / Explain 5 × $2, compare fixed contents with random-reward disclosure, and identify a conflict of interests. For the chapter's e-trading case, distinguish market access, platform restrictions and financial risk; name evidence still needed."]
 for i in range(3):
  label(prompts[i],c,21,CYAN)
  var e=TextEdit.new();e.text=answers[i];e.custom_minimum_size.y=130;e.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY;e.add_theme_font_size_override("font_size",18)
  e.placeholder_text="Use fictional cases only. Do not enter names or personal information."
  var idx=i;e.text_changed.connect(func():answers[idx]=e.text);c.add_child(e)
 var s=column(Vector2(990,180),Vector2(425,665))
 label("CONCEPTS IN YOUR EXPLANATION",s,21,AMBER)
 label("SYSTEMS: trace verification and infrastructure.\n\nPOWER: who controls access, records and permissions?\n\nVALUES & ETHICS: weigh convenience, exclusion, privacy and disclosure.\n\nIDENTITY: transaction aliases can reveal patterns and be linked to people.",s,21)
 button("Save / download my report",s,save_report,true)
 button("Return to Mode A",s,func():page="access";demo=false;render())
 button("Return to Mode B",s,func():page="token";demo=false;render())
 label(notice+"\n\nReports contain local responses and fake model states. No automatic upload, score-based assessment or student account. Reloading clears this session.",s,17,MUTED)
func report_text() -> String:
 var safe_token={"id":token.id,"controller":token.controller,"licence":token.licence,"history":token.history,"host_up":token.host_up,"copy_count":Lab.token_facts(token).copies,"fingerprint":Lab.fingerprint(Lab.image_bytes())}
 return "PAYMENT & TOKEN LAB / FICTIONAL TEACHING MODEL\nNo real value or live financial connections. No automatic grade.\n\nRESPONSES\n"+JSON.stringify(answers,"  ")+"\n\nPAYMENT COMPARISONS / EACH CASE RESET\n"+JSON.stringify(history,"  ")+"\n\nTOKEN STATE\n"+JSON.stringify(safe_token,"  ")+"\n\nEVIDENCE MATCH CHOICES\n"+JSON.stringify(match_choices)
func save_report():
 var bytes=report_text().to_utf8_buffer()
 if OS.has_feature("web"):
  JavaScriptBridge.download_buffer(bytes,"Payment-Token-Lab-report.txt","text/plain");notice="Report download requested; check browser downloads.";render()
 else:
  var d=FileDialog.new();d.file_mode=FileDialog.FILE_MODE_SAVE_FILE;d.access=FileDialog.ACCESS_FILESYSTEM;d.use_native_dialog=true;d.current_file="Payment-Token-Lab-report.txt";d.add_filter("*.txt","Text report")
  d.file_selected.connect(func(path):
   var file=FileAccess.open(path,FileAccess.WRITE)
   if file:file.store_buffer(bytes);notice="Report saved: "+path
   else:notice="Could not save there; choose another folder."
   render())
  add_child(d);d.popup_centered_ratio(0.7)
func show_help():
 message("How to use this demonstration", "Choose either 15-minute mode. Teacher demonstrations are paced and reproducible; choose independent exploration to change controls yourself. There is no timer or investment score.\n\nMode A: select payment acceptance, digital route, named outage and fictional terminal support. Predict access before revealing. Inspect the selected customer for verification, recorded fields and balance conservation. Change one condition at a time.\n\nMode B: copy the image, change token control and inspect L1. Break the simulated media link. Match statements to evidence, then explain the difference between possession, record and permission.\n\nDiscussion includes a static cumulative-cost worksheet and a paraphrased historical source case. No purchase, random draw or trading controls. Everything uses fake values. All examples are conceptual, not investment, tax or legal advice.\n\nButtons and selectors support keyboard focus. Scroll panels as needed. Desktop/projector recommended; canvas output is not a complete screen-reader interface. Save your local report before closing.")
