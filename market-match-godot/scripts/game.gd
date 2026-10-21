extends Control
const Market = preload("res://scripts/market.gd")
const Street = preload("res://scripts/street.gd")
const INK = Color("e5f2ee")
const MUTED = Color("9db7c3")
const TEAL = Color("72e5c0")
const GOLD = Color("ffcf70")
const PANEL = Color("142d3a")
var audience = Market.profiles()
var runs: Array = []
var pinned: Dictionary = {}
var attempts: Array = []
var reflections = ["", "", "", ""]
var mode = "menu"
var page = "welcome"
var task = 0
var choice = -1
var task_feedback = ""
var demo_step = 0
var selected = 3
var product = 0
var policy = 0
var slots = 10
var seed_value = 23
var prediction_relevance = 0
var prediction_reach = 0
var current_run: Dictionary = {}
var screen: Control
var board: Control
var sidebar: VBoxContainer
var popup: AcceptDialog
var message = "Choose a product and policy. Predict, then launch the campaign."
var report_notice = ""
var prediction_boxes: Array = []
var prediction_history: Array = []
var experiments_visited = false
const DEMO_TEXT = [
 "First, follow the actual buyer and seller. ForgeWorks sells to BrightLearn Schools Ltd, explicitly an education business: B2B. The marketplace connects them; the payment provider processes the payment.",
 "The shop selling headphones to a household is B2C. Two individuals trading a personal bicycle is C2C. One marketplace can host all three. The platform is not automatically the item seller.",
 "Predict broad reach but mixed relevance. Launch headphones with 10 slots. All 20 are eligible; the seeded queue gives only 10 an advert. Watch the street, then inspect shoppers.",
 "Keep product, audience, slots and seed fixed; change only to interest targeting. P04 browsed music for a gift. The rule infers music, although the declared interest is cycling. A profile can be wrong.",
 "Now use current page context. P09 refuses browsing targeting but is on a music page. It can still receive a contextual advert. No browsing events are read by this policy; context itself can still be sensitive.",
 "Remove P04's first music event, then rerun interest targeting. Only one music event remains; P04 fails the two-event rule. This compares changed inputs, not two different policies.",
 "More clicks did not guarantee more purchases. Explain a benefit for a seller, a consumer risk and who might miss a useful job/course opportunity. Now try your own fresh marketplace."
]

func _ready():
 DisplayServer.window_set_title("Market Match / Ad Street — Godot")
 if OS.has_feature("web"):
  var requested = str(JavaScriptBridge.eval("new URLSearchParams(window.location.search).get('mode') || 'menu'"))
  if requested in ["demo", "student"]:
   start(requested)
   return
 render()

func style(color: Color, radius: int = 12) -> StyleBoxFlat:
 var s = StyleBoxFlat.new()
 s.bg_color = color
 s.set_corner_radius_all(radius)
 s.content_margin_left = 14
 s.content_margin_right = 14
 s.content_margin_top = 10
 s.content_margin_bottom = 10
 return s

func text(value: String, parent: Node, size_px: int = 17, color: Color = INK) -> Label:
 var l = Label.new()
 l.text = value
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 l.add_theme_font_size_override("font_size",size_px)
 l.add_theme_color_override("font_color",color)
 parent.add_child(l)
 return l

func btn(value: String, parent: Node, action: Callable, accent: bool = false) -> Button:
 var b = Button.new()
 b.text = value
 b.custom_minimum_size.y = 43
 b.add_theme_font_size_override("font_size",17)
 b.add_theme_color_override("font_color",Color("102d33") if accent else INK)
 b.add_theme_stylebox_override("normal",style(TEAL if accent else Color("294655"),9))
 b.add_theme_stylebox_override("hover",style(Color("b2f2d8") if accent else Color("3b6170"),9))
 b.add_theme_stylebox_override("pressed",style(Color("4db196"),9))
 b.add_theme_color_override("font_disabled_color",Color("748d98"))
 b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
 b.pressed.connect(action)
 parent.add_child(b)
 return b

func column(at: Vector2, extent: Vector2, parent: Node) -> VBoxContainer:
 var panel = PanelContainer.new()
 panel.position = at
 panel.size = extent
 panel.add_theme_stylebox_override("panel",style(PANEL))
 parent.add_child(panel)
 var scroll = ScrollContainer.new()
 scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 panel.add_child(scroll)
 var c = VBoxContainer.new()
 c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 c.add_theme_constant_override("separation",10)
 scroll.add_child(c)
 return c

func fixed_text(value: String, at: Vector2, extent: Vector2, size_px: int = 18, color: Color = INK) -> Label:
 var l = text(value,screen,size_px,color)
 l.position = at
 l.size = extent
 return l

func render():
 if screen != null:
  remove_child(screen)
  screen.queue_free()
 screen = Control.new()
 screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(screen)
 fixed_text("M / M",Vector2(25,17),Vector2(130,55),37,TEAL)
 fixed_text("MARKET MATCH  /  AD STREET",Vector2(170,19),Vector2(900,34),28)
 fixed_text("A GODOT MARKETPLACE GAME  •  FICTIONAL DATA, REAL QUESTIONS",Vector2(172,55),Vector2(970,24),14,MUTED)
 var tools = HBoxContainer.new()
 tools.position = Vector2(1100,25)
 tools.size.x = 312
 screen.add_child(tools)
 btn("How to play",tools,show_help)
 btn("Menu",tools,func(): page="welcome";mode="menu";render())
 if page == "welcome": render_welcome()
 elif page == "transactions": render_transactions()
 elif page == "lab": render_lab()
 elif page == "compare": render_compare()
 elif page == "reflect": render_reflect()
 fixed_text("No live ads, accounts or tracking. Teaching rules and probabilities are invented. Play landscape on a phone.",Vector2(25,869),Vector2(1380,25),14,MUTED)

func add_street(at: Vector2) -> Control:
 var s = Street.new()
 s.position = at
 s.size = Vector2(940,515)
 s.audience = audience
 s.result = current_run
 s.selected = selected
 s.reveal = 20.0
 s.profile_selected.connect(func(i): selected=i;show_profile(i))
 screen.add_child(s)
 board = s
 return s

func render_welcome():
 fixed_text("RUN THE MARKET.\nQUESTION THE MATCH.",Vector2(35,110),Vector2(930,100),39)
 add_street(Vector2(25,240))
 var c = column(Vector2(990,113),Vector2(425,710),screen)
 text("YOUR MISSION",c,15,TEAL)
 text("Help a small seller get seen.",c,29)
 text("First identify who is trading. Then launch adverts, watch the shoppers and investigate who was included or missed.",c,19)
 text("Three products. Three ad policies. Twenty fictional shoppers. No single policy wins every trade-off.",c,18,MUTED)
 if experiments_visited and mode=="menu": btn("Resume my current marketplace",c,func():mode="student";page="lab";render(),true)
 btn("Start student game",c,func():start("student"),true)
 btn("Watch optional expert demo",c,func():start("demo"))
 text("PLAY / LEARN / EXPLAIN",c,15,GOLD)
 text("1  Match buyer and seller roles.\n2  Predict and launch a campaign.\n3  Inspect a surprising shopper.\n4  Compare a second policy fairly.\n5  Change consent or remove an input.\n6  Explain your evidence.",c,18)
 text("The demo is a paced worked example. Independent play includes optional advice. No forced replay, timer or click-score grade.",c,16,MUTED)

func start(which: String):
 audience = Market.profiles()
 runs.clear()
 pinned = {}
 current_run = {}
 attempts.clear()
 prediction_history.clear()
 reflections = ["", "", "", ""]
 task = 0
 choice = -1
 task_feedback = ""
 product = 0
 policy = 0
 slots = 10
 seed_value = 23
 prediction_relevance = 0
 prediction_reach = 0
 demo_step = 0
 experiments_visited = false
 message = "Choose a product and policy. Predict, then launch the campaign."
 report_notice = ""
 mode = which
 page = "transactions"
 render()

func render_transactions():
 fixed_text("01 / WHO IS TRADING?",Vector2(30,111),Vector2(930,42),31)
 var c = column(Vector2(25,178),Vector2(940,660),screen)
 if mode == "demo":
  text("EXPERT EXAMPLE / %d OF 7" % (demo_step+1),c,16,TEAL)
  text(DEMO_TEXT[demo_step],c,24)
  for t in Market.TRANSACTIONS:
   text(t.item.to_upper()+"  /  "+["B2B","B2C","C2C"][t.answer],c,21,GOLD)
   text(t.seller+"  ->  "+t.buyer,c,18)
  btn("Next expert step",c,demo_next,true)
 else:
  text("TRANSACTION CHECK / %d OF 5" % (task+1),c,16,TEAL)
  if task < 3:
   var t = Market.TRANSACTIONS[task]
   text(t.item,c,35)
   text("SELLER",c,15,GOLD)
   text(t.seller,c,25)
   text("|  MARKET MATCH connects the parties  |",c,20,TEAL)
   text("BUYER",c,15,GOLD)
   text(t.buyer,c,25)
   text("PAYMENT PROVIDER / LedgerBridge processes the payment.",c,17,MUTED)
   text("Classify the item sale:",c,20)
   var row = HBoxContainer.new()
   row.add_theme_constant_override("separation",12)
   c.add_child(row)
   for i in range(3):
    var answer_index = i
    btn(["B2B","B2C","C2C"][i],row,func():answer_transaction(answer_index),choice==i)
  else:
   text("Separate the intermediaries",c,31)
   text("What does the %s do in these cases?" % ("platform" if task==3 else "payment provider"),c,24)
   var options = ["Connects buyers and sellers", "Manufactures every listed item", "Makes every sale C2C"] if task==3 else ["Processes payment between parties", "Sells the item instead of the seller", "Guarantees the buyer will like it"]
   for i in range(options.size()):
    var answer_index = i
    btn(options[i],c,func():answer_transaction(answer_index),choice==i)
  if task_feedback != "":
   text(task_feedback,c,20,TEAL if choice == correct_answer() else GOLD)
   if choice == correct_answer(): btn("Continue" if task<4 else "Open my marketplace",c,next_task,true)
 var side = column(Vector2(990,178),Vector2(425,660),screen)
 text("FOLLOW THE PARTIES",side,20,TEAL)
 text("B2B\nBusiness sells to a business.\n\nB2C\nBusiness sells to a consumer.\n\nC2C\nAn individual sells a personal item to another individual.",side,22)
 text("One platform can host different types of transaction. Classify the actual sale, not the website.",side,20,GOLD)
 text("The school buyer here is explicitly a fictional education business. A public school purchaser would require attention to its actual role.",side,16,MUTED)

func correct_answer() -> int:
 return Market.TRANSACTIONS[task].answer if task < 3 else 0

func answer_transaction(answer: int):
 choice = answer
 attempts.append({"task":task,"choice":answer,"correct":answer==correct_answer()})
 task_feedback = ("Correct. " if answer==correct_answer() else "Try again. ")
 if task<3: task_feedback += Market.TRANSACTIONS[task].why
 else: task_feedback += "The platform connects parties; LedgerBridge processes the payment. Neither becomes the item seller just by helping the exchange."
 render()

func next_task():
 if choice != correct_answer(): return
 task += 1
 choice = -1
 task_feedback = ""
 if task >= 5: page="lab";experiments_visited=true
 render()

func selector(title: String, items: Array, value: int, action: Callable, parent: Node) -> OptionButton:
 text(title,parent,15,MUTED)
 var b = OptionButton.new()
 b.custom_minimum_size.y = 39
 b.add_theme_font_size_override("font_size",17)
 for item in items: b.add_item(str(item))
 b.select(value)
 b.item_selected.connect(action)
 b.disabled = mode == "demo"
 parent.add_child(b)
 return b

func render_lab():
 fixed_text("02 / CAMPAIGN CONTROL",Vector2(30,107),Vector2(940,44),30)
 if mode == "demo":
  fixed_text("EXPERT %d / 7  •  %s" % [demo_step+1,Market.POLICIES[policy]],Vector2(30,155),Vector2(940,29),19,GOLD)
 else:
  fixed_text("Launch an advert, watch the street, then select a shopper to investigate.",Vector2(30,155),Vector2(940,30),18,MUTED)
 add_street(Vector2(25,198))
 if not current_run.is_empty():
  var m = current_run.metrics
  fixed_text("SHOWN %d/20     RELEVANT %d     MISSED %d     IRRELEVANT %d" % [m.served,m.relevant,m.missed,m.irrelevant],Vector2(35,728),Vector2(925,29),21,TEAL)
  fixed_text("%d simulated clicks  /  %d purchases  /  %d matching input-field reads" % [m.clicks,m.purchases,m.fields],Vector2(35,766),Vector2(925,29),19,GOLD)
  var stale = current_run.audience != audience
  fixed_text("INPUTS CHANGED — rerun; the street still shows the previous snapshot." if stale else "Run %d / %s / %d slots / seed %d" % [runs.size(),Market.PRODUCTS[current_run.product],current_run.slots,current_run.seed],Vector2(35,805),Vector2(925,40),16,GOLD if stale else MUTED)
 else:
  fixed_text("The street is waiting for your first campaign.",Vector2(35,740),Vector2(925,35),24,TEAL)
  fixed_text("Green = relevant ad   •   Coral = irrelevant ad   •   Purple = potential customer missed",Vector2(35,790),Vector2(925,40),17,MUTED)
 sidebar = column(Vector2(990,112),Vector2(425,740),screen)
 if mode=="demo":
  text("WORKED EXAMPLE / %d OF 7" % (demo_step+1),sidebar,16,TEAL)
  text(DEMO_TEXT[demo_step],sidebar,21)
  btn("Try my own fresh game" if demo_step==6 else "Next expert step",sidebar,func():start("student") if demo_step==6 else demo_next(),true)
  btn("Inspect P04 / wrong inference",sidebar,func():show_profile(3))
  btn("Inspect P09 / consent refusal",sidebar,func():show_profile(8))
  if runs.size()>1: btn("Inspect experiment comparison",sidebar,func():page="compare";render())
 else:
  text("YOUR AD CAMPAIGN",sidebar,17,TEAL)
  selector("Product",Market.PRODUCTS,product,func(i):product=i,sidebar)
  selector("Advertising policy",Market.POLICIES,policy,func(i):policy=i,sidebar)
  var row = HBoxContainer.new()
  sidebar.add_child(row)
  row.add_theme_constant_override("separation",8)
  text("Slots",row,16).custom_minimum_size.x=48
  var count = OptionButton.new()
  count.custom_minimum_size.x=72
  for v in [5,10,20]: count.add_item(str(v))
  count.select([5,10,20].find(slots))
  count.item_selected.connect(func(i):slots=[5,10,20][i])
  row.add_child(count)
  text("Seed",row,16).custom_minimum_size.x=48
  var seed_box = SpinBox.new()
  seed_box.min_value=1;seed_box.max_value=9999;seed_box.value=seed_value
  seed_box.custom_minimum_size.x=140
  seed_box.value_changed.connect(func(v):seed_value=int(v))
  row.add_child(seed_box)
  prediction_boxes.clear()
  prediction_boxes.append(selector("Predict relevance",["Choose…","Mostly relevant","Mixed / mostly irrelevant","Not enough information"],prediction_relevance,func(i):prediction_relevance=i,sidebar))
  prediction_boxes.append(selector("Predict reach",["Choose…","Many profiles","Few profiles","Not enough information"],prediction_reach,func(i):prediction_reach=i,sidebar))
  btn("Launch campaign",sidebar,launch,true)
  text(message,sidebar,16,GOLD)
  btn("Advice / what should I inspect?",sidebar,advice)
  var comparison_button = btn("Compare campaigns",sidebar,func():page="compare";render())
  comparison_button.disabled=runs.size()<2
  btn("Rules & teaching assumptions",sidebar,show_rules)
  var reflect_button = btn("Explain & finish",sidebar,func():page="reflect";render())
  reflect_button.disabled=not has_policy_comparison()

func launch(authored: bool = false):
 if not authored and (prediction_relevance == 0 or prediction_reach == 0):
  message = "Make both predictions before launching."
  if sidebar != null: show_message("Predict first",message)
  return
 if authored:
  prediction_relevance=2 if policy==0 else 1
  prediction_reach=1 if policy==0 else 2
 var r = Market.run(audience,product,policy,slots,seed_value)
 prediction_history.append({"run":runs.size()+1,"relevance":prediction_relevance,"reach":prediction_reach})
 current_run = r
 runs.append(r)
 if runs.size()>40: runs.pop_front()
 if pinned.is_empty(): pinned=r
 prediction_relevance=0;prediction_reach=0
 message="Campaign complete. Inspect shoppers, then change only policy for a fair comparison."
 render()
 board.show_run(r)

func has_policy_comparison() -> bool:
 for a in runs:
  for b in runs:
   if Market.comparison(a,b)=="policy": return true
 return false

func demo_next():
 demo_step += 1
 if demo_step>=2:
  page="lab"
  product=0;slots=10;seed_value=23
  if demo_step==2: policy=0;launch(true)
  elif demo_step==3: policy=2;launch(true)
  elif demo_step==4: policy=1;launch(true)
  elif demo_step==5:
   pinned=runs[1]
   audience[3].events[0]=""
   policy=2
   launch(true)
  else: render()
 else: render()

func show_message(title_value: String, body: String):
 if popup != null:
  popup.hide()
  popup.queue_free()
 popup=AcceptDialog.new()
 popup.title=title_value
 popup.dialog_text=body
 popup.min_size=Vector2i(650,150)
 add_child(popup)
 popup.popup_centered()

func advice():
 var hint = "Try a baseline broad campaign first. After running, inspect one shown shopper and one missed shopper."
 if not current_run.is_empty():
  if current_run.audience != audience: hint="You changed an input. Rerun with the same policy, product, seed and slots to isolate that edit. Pin the earlier run first if you want to compare it."
  elif not has_policy_comparison(): hint="Keep product, slots, seed and all profiles unchanged. Switch only policy and predict again. Compare relevance, missed customers and fields used, not just clicks."
  else: hint="Inspect P04 and P09. What does the rule read? What does it ignore? Try removing one of P04's music events or withdrawing fictional consent, then rerun. Explain before requesting another hint."
 show_message("Optional coach",hint)

func show_help():
 show_message("How to play", "Match three sales and two intermediary roles. In the marketplace, choose a product and ad policy, make two predictions, then launch.\n\nSelect any shopper for its inputs and decision trace. Green = relevant ad; coral = irrelevant impression; purple = potential customer missed. A plus means a simulated click.\n\nCompare two policies with the same product, profiles, slots and seed. Then change fictional consent or delete an event and rerun. Explain your reasoning in the final report.\n\nAll data are fictional. No names or personal information. The optional demo is always available from Menu. Play in landscape on a phone.")

func show_rules():
 show_message("Transparent teaching rules", "Broad: all 20 eligible. Contextual: page topic = product topic; no browsing history. Interest: consent required; most frequent active event topic must match and occur at least twice. Ties: music, cycling, coding, design.\n\nRank: interest uses event count, then seeded queue. Others use the same queue. First N eligible shoppers get an ad. Seeded hash draws repeat for the same profile/product/seed.\n\nClick probability: .55 for a declared-interest match, .12 otherwise. Purchase: separate .30 draw after a click. These are invented assumptions, not measured marketing effectiveness. Declared interests are an audit reference and separate outcome-generator input, never a matching input.\n\nField reads: broad 0 topic/consent fields; contextual 20 page topics; interest 20 consent fields + active event topics for consenting profiles. IDs are synthetic queue inputs. Counts are not a moral score or all processing/storage. Context can also be sensitive.\n\nAds can pay for a free service. That does not justify every collection practice. Consider purpose, control, retention and alternatives.")

func show_profile(index: int):
 selected=index
 if popup != null:
  popup.hide()
  popup.queue_free()
 popup=AcceptDialog.new()
 popup.title="SHOPPER DOSSIER / " + audience[index].id
 popup.min_size=Vector2i(880,690)
 add_child(popup)
 var sc=ScrollContainer.new()
 sc.custom_minimum_size=Vector2(850,610)
 sc.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
 popup.add_child(sc)
 var c=VBoxContainer.new()
 c.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 c.add_theme_constant_override("separation",9)
 sc.add_child(c)
 var p=audience[index]
 text("%s / FICTIONAL INPUTS" % p.id,c,23,TEAL)
 text("Declared interest: %s  •  Current page: %s" % [", ".join(p.declared),p.page],c,20)
 if p.note!="": text(p.note,c,18,GOLD)
 var consent=CheckBox.new()
 consent.text="Allow fictional browsing-based targeting"
 consent.button_pressed=p.consent
 consent.disabled=mode=="demo"
 consent.toggled.connect(func(v):p.consent=v;profile_edited(index))
 c.add_child(consent)
 text("Withdrawal stops future browsing reads; it does not erase events. Delete removes a current input. Historical run snapshots stay in the report; Restore regenerates the original synthetic topic. This is not permanent erasure.",c,15,MUTED)
 for i in range(3):
  var row=HBoxContainer.new()
  c.add_child(row)
  var description=text("E%d / %s" % [i+1,"input removed" if p.events[i]=="" else "viewed "+p.events[i]+" content"],row,19)
  description.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  var event_index=i
  var edit=btn(("Restore" if p.events[i]=="" else "Delete")+" E%d" % (i+1),row,func():
   p.events[event_index]=Market.profiles()[index].events[event_index] if p.events[event_index]=="" else ""
   profile_edited(index))
  edit.disabled=mode=="demo"
 if not current_run.is_empty():
  var r=current_run.results[index]
  text("LAST RUN SNAPSHOT / "+Market.POLICIES[current_run.policy],c,20,TEAL)
  text("Observed input: "+("none of the topic/consent fields" if r.fields.is_empty() else "; ".join(r.fields)),c,18)
  text("Inference: "+("no stored browsing preference inferred" if r.inference.is_empty() else "%s / %d events" % [r.inference.topic,r.inference.score]),c,18)
  text("Rule -> "+r.reason,c,18)
  text("Advert -> "+(Market.PRODUCTS[current_run.product] if r.served else "not shown"),c,19,GOLD)
  text("Possible effect -> %s; %s." % ["simulated click" if r.clicked else "no click","simulated purchase" if r.purchased else "no purchase"],c,18)
  text("Audit relevance: %s. Declared interests do not determine matching." % ("matches declared interest" if r.relevant else "does not match declared interest"),c,17,MUTED)
  text("Reproducible trace: shown=%s; click draw %.6f < %.2f = %s; clicked=%s. Purchase draw %.6f < .30 = %s; purchased=%s (requires click)." % [r.served,r.click_draw,r.click_probability,r.click_draw<r.click_probability,r.clicked,r.purchase_draw,r.purchase_draw<0.30,r.purchased],c,15,MUTED)
  if current_run.audience!=audience: text("Inputs changed. Rerun to update the decision and the street.",c,18,GOLD)
 else: text("Launch a campaign to inspect the rule and outcome here.",c,19,GOLD)
 popup.popup_centered()

func profile_edited(index: int):
 render()
 show_profile(index)

func render_compare():
 fixed_text("03 / COMPARE THE CONSEQUENCES",Vector2(30,111),Vector2(1380,44),31)
 var c=column(Vector2(25,178),Vector2(940,660),screen)
 if runs.size()<2:
  text("Launch two campaigns first.",c,24)
  btn("Back to market",c,func():page="lab";render(),true)
  return
 var b=current_run
 var kind=Market.comparison(pinned,b)
 var explanations={"policy":"CONTROLLED POLICY COMPARISON / same product, audience, slots and seed. Only policy changed.","input":"CHANGED INPUT / same policy, product, slots and seed. Explain the consent or event edit.","repeat":"EXACT REPEAT / identical conditions produce identical outcomes.","mixed":"SEVERAL CONDITIONS CHANGED / do not attribute the difference to policy alone."}
 if pinned==b: text("Current run is pinned as A. Launch another campaign for B.",c,21,GOLD)
 else: text(explanations[kind],c,21,TEAL)
 text("A / %s — %s\nB / %s — %s" % [Market.PRODUCTS[pinned.product],Market.POLICIES[pinned.policy],Market.PRODUCTS[b.product],Market.POLICIES[b.policy]],c,23)
 var measures=[["Profiles shown","served"],["Relevant impressions","relevant"],["Potential customers missed","missed"],["Irrelevant impressions","irrelevant"],["Simulated clicks","clicks"],["Simulated purchases","purchases"],["Matching input-field reads","fields"]]
 for pair in measures:
  text("%-32s   A: %d     B: %d" % [pair[0],pinned.metrics[pair[1]],b.metrics[pair[1]]],c,20)
 text("A zero input-field count does not mean zero privacy risk. It counts matching field reads, not all processing, storage or sensitivity. Declared interests provide a fictional audit reference.",c,17,MUTED)
 btn("Pin latest campaign as A",c,func():pinned=current_run;render()).disabled=mode=="demo"
 var s=column(Vector2(990,178),Vector2(425,660),screen)
 text("WHAT DO YOU CONCLUDE?",s,21,TEAL)
 text("Who got a relevant advert?\nWho was missed?\nWhich impressions were irrelevant?\nWhat inputs were read?\nWhat did clicks fail to tell you?",s,23)
 text("A small seller can gain visibility. A consumer may lose control or miss an opportunity. Explain both sides using evidence.",s,19,GOLD)
 btn("Back to the street",s,func():page="lab";render(),true)
 if mode!="demo": btn("Explain & finish",s,func():page="reflect";render()).disabled=not has_policy_comparison()

func render_reflect():
 fixed_text("04 / MAKE YOUR THINKING VISIBLE",Vector2(30,111),Vector2(1380,44),31)
 var c=column(Vector2(25,178),Vector2(940,660),screen)
 var questions=[
  "1 / Trace one profile: observed event -> inferred preference -> rule -> advert -> possible effect. Where could the inference be wrong?",
  "2 / Compare two policies with the same conditions. Cite two figures, one seller benefit and one consumer risk. What does the field count leave out?",
  "3 / Transfer to job or university-course adverts. Who might never see a useful opportunity? What extra evidence would you need to assess unfair exclusion?",
  "4 / How can advertising fund a free service? Why does that not justify every collection practice? Suggest a limit or alternative."
 ]
 for i in range(4):
  text(questions[i],c,20,TEAL)
  var edit=TextEdit.new()
  edit.custom_minimum_size.y=110
  edit.placeholder_text="Use your experiment evidence. Do not enter names or personal information."
  edit.text=reflections[i]
  edit.wrap_mode=TextEdit.LINE_WRAPPING_BOUNDARY
  edit.add_theme_font_size_override("font_size",18)
  var index=i
  edit.text_changed.connect(func():reflections[index]=edit.text)
  c.add_child(edit)
 var side=column(Vector2(990,178),Vector2(425,660),screen)
 text("YOUR EXIT REPORT",side,23,TEAL)
 text("Explain decisions, not just clicks. Your teacher reviews the reasoning; there is no automatic grade.",side,21)
 text("Identity / an inferred profile is not a person.\n\nPower / the platform controls ranking and data access.\n\nSystems / buyer, seller, platform and payment provider interact.\n\nValues / consent, funding and exclusion create trade-offs.",side,19)
 btn("Download / save my report",side,save_report,true)
 btn("Back to the street",side,func():page="lab";render())
 text(report_notice,side,16,GOLD)
 text("Work stays in page memory until you download. Reloading or starting fresh loses progress. No names, accounts, trackers or automatic uploads.",side,16,MUTED)

func report_text() -> String:
 return "MARKET MATCH / AD STREET — GODOT\nSynthetic teaching model, not measured marketing evidence.\nNo automatic grade.\n\nTRANSACTION ATTEMPTS\n"+JSON.stringify(attempts,"  ")+"\n\nPREDICTIONS (1=mostly/many; 2=mixed/few; 3=uncertain)\n"+JSON.stringify(prediction_history,"  ")+"\n\nREFLECTIONS\n"+JSON.stringify(reflections,"  ")+"\n\nEXPERIMENT SNAPSHOTS\n"+JSON.stringify(runs,"  ")+"\n\nCURRENT FICTIONAL INPUTS\n"+JSON.stringify(audience,"  ")

func save_report():
 var bytes=report_text().to_utf8_buffer()
 if OS.has_feature("web"):
  JavaScriptBridge.download_buffer(bytes,"Market-Match-Godot-report.txt","text/plain")
  report_notice="Report download requested. Check your browser downloads."
 else:
  var dialog=FileDialog.new()
  dialog.file_mode=FileDialog.FILE_MODE_SAVE_FILE
  dialog.access=FileDialog.ACCESS_FILESYSTEM
  dialog.use_native_dialog=true
  dialog.current_file="Market-Match-Godot-report.txt"
  dialog.add_filter("*.txt","Text report")
  dialog.file_selected.connect(func(path):
   var file=FileAccess.open(path,FileAccess.WRITE)
   if file:
    file.store_buffer(bytes)
    report_notice="Report saved to "+path
   else: report_notice="Could not save there. Choose another writable folder."
   render())
  add_child(dialog)
  dialog.popup_centered_ratio(0.7)
  return
 render()
