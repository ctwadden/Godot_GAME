extends Control

const Simulation = preload("res://scripts/simulation.gd")
const Learning = preload("res://scripts/learning.gd")
const VEHICLES = {"ship":preload("res://assets/ship.svg"),"plane":preload("res://assets/plane.svg"),"truck":preload("res://assets/truck.svg"),"factory":preload("res://assets/factory.svg"),"border":preload("res://assets/border.svg")}
const HUB = Vector2(-63.6,44.7)
const MAP_RECT = Rect2(45,268,810,365)
const INK = Color("e7efff")
const MUTED = Color("8fa4c3")
const TEAL = Color("51e0bc")
const PANEL = Color("101e33")
var sim = Simulation.new()
var tab = 3
var running = false
var speed = 1
var elapsed = 0.0
var animation = 0.0
var ui: Control
var content: VBoxContainer
var status: Label
var ticker: Label
var timer_label: Label
var popup: AcceptDialog
var font = ThemeDB.fallback_font
var selected_supplier = 0
var coastlines: Array = []
var check_index = 0
var check_feedback = ""
var last_delta = 0.0
var scroll_view: ScrollContainer
var previous_tab = -1
var previous_intro_step = -1
var tab_buttons: Array = []
var show_targets = false

func _ready():
 DisplayServer.window_set_title("Nova / Global Launch — Learning edition")
 load_coastlines()
 build_ui()
 refresh()

func style(color: Color, radius: int = 12) -> StyleBoxFlat:
 var box = StyleBoxFlat.new()
 box.bg_color = color
 box.corner_radius_top_left = radius
 box.corner_radius_top_right = radius
 box.corner_radius_bottom_left = radius
 box.corner_radius_bottom_right = radius
 box.content_margin_left = 14
 box.content_margin_right = 14
 box.content_margin_top = 10
 box.content_margin_bottom = 10
 return box

func label(text: String, size_px: int = 16, color: Color = INK) -> Label:
 var l = Label.new()
 l.text = text
 l.add_theme_font_size_override("font_size",size_px)
 l.add_theme_color_override("font_color",color)
 return l

func button(text: String, action: Callable, parent: Node, accent: bool = false) -> Button:
 var b = Button.new()
 b.text = text
 b.custom_minimum_size.y = 40
 if text.length() > 48:
  b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
  b.custom_minimum_size.x = 450
 b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
 b.add_theme_stylebox_override("normal",style(Color("234b50") if accent else Color("20324c"),8))
 b.add_theme_stylebox_override("hover",style(Color("32646b"),8))
 b.add_theme_stylebox_override("pressed",style(Color("397e74"),8))
 b.add_theme_color_override("font_color",INK)
 b.pressed.connect(action)
 parent.add_child(b)
 return b

func build_ui():
 ui = Control.new()
 ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 add_child(ui)
 var top = HBoxContainer.new()
 top.position = Vector2(30,20)
 top.add_theme_constant_override("separation",22)
 ui.add_child(top)
 top.add_child(label("N /",36,TEAL))
 var brand = VBoxContainer.new()
 top.add_child(brand)
 brand.add_child(label("NOVA",26))
 brand.add_child(label("GLOBAL LAUNCH  /  OPERATIONS SIMULATOR",12,MUTED))
 var controls = HBoxContainer.new()
 controls.position = Vector2(875,25)
 controls.add_theme_constant_override("separation",8)
 ui.add_child(controls)
 button("Run / Pause",func(): running = not running and not sim.ended; refresh(),controls,true)
 button("+ Day",func(): step(),controls)
 button("Speed",func(): speed = 3 if speed == 1 else 1; refresh(),controls)
 button("Save",func(): sim.notice = ("Saved in this browser on this device." if OS.has_feature("web") else "Campaign saved.") if sim.save_game() == OK else "Could not save campaign."; refresh(),controls)
 button("Load",func(): running = false; sim.notice = "Saved campaign loaded." if sim.load_game() else "No compatible saved campaign found."; tab = 3; refresh(),controls)
 button("?",func(): show_help(),controls)
 status = label("",18)
 status.position = Vector2(32,100)
 ui.add_child(status)
 timer_label = label("",14,TEAL)
 timer_label.position = Vector2(35,150)
 ui.add_child(timer_label)
 var tabs = HBoxContainer.new()
 tabs.position = Vector2(900,160)
 tabs.add_theme_constant_override("separation",6)
 ui.add_child(tabs)
 for i in range(5):
  var index = i
  tab_buttons.append(button(["Supply","People","Develop","Learn","Report"][i],func(): tab = index; refresh(),tabs))
 var panel = PanelContainer.new()
 panel.position = Vector2(900,215)
 panel.size = Vector2(510,570)
 panel.add_theme_stylebox_override("panel",style(PANEL))
 ui.add_child(panel)
 scroll_view = ScrollContainer.new()
 scroll_view.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
 panel.add_child(scroll_view)
 content = VBoxContainer.new()
 content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
 content.add_theme_constant_override("separation",12)
 scroll_view.add_child(content)
 ticker = label("",17)
 ticker.position = Vector2(32,810)
 ticker.size = Vector2(1370,60)
 ticker.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 ui.add_child(ticker)
 popup = AcceptDialog.new()
 popup.title = "Welcome to Nova"
 popup.min_size = Vector2i(650,340)
 popup.dialog_autowrap = true
 add_child(popup)


func show_help():
 running = false
 tab = 3
 refresh()


func paragraph(text: String, color: Color = MUTED):
 var l = label(text,15,color)
 l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
 l.custom_minimum_size.x = 450
 content.add_child(l)

func heading(text: String): content.add_child(label(text,24))

func refresh():
 status.text = "$%s CASH     %d / 900 DELIVERED     %d WAITING     %d%% TRUST     %d%% WELLBEING" % [sim.cash,sim.delivered,sim.backlog,sim.trust,sim.wellbeing]
 timer_label.text = "DAY %02d / 30    •    %s    •    %dx SPEED    /    SELECT A SUPPLIER ON THE MAP" % [mini(sim.day,30),"FINISHED" if sim.ended else ("LIVE" if running else "PAUSED"),speed]
 ticker.text = "OPERATIONS BRIEF   /   " + sim.notice
 for child in content.get_children():
  content.remove_child(child)
  child.queue_free()
 if tab in [3,4]: running = false
 if previous_tab != tab or previous_intro_step != sim.tutorial_step:
  scroll_view.scroll_vertical = 0
 previous_tab = tab
 previous_intro_step = sim.tutorial_step
 for i in range(tab_buttons.size()): tab_buttons[i].add_theme_stylebox_override("normal",style(Color("234b50") if i == tab else Color("20324c"),8))
 match tab:
  0: supply_ui()
  1: people_ui()
  2: develop_ui()
  3: learn_ui()
  4: report_ui()
 queue_redraw()

func supply_ui():
 heading("Keep the world moving")
 paragraph("One phone = 1 processor + 1 screen + 1 battery. Production is automatic when parts are available.")
 paragraph("PHYSICAL: %d chips / %d screens / %d batteries" % sim.inventory,TEAL)
 paragraph("RECORDED: %d chips / %d screens / %d batteries" % sim.recorded_stock())
 var alerts: Array = []
 for i in range(3): alerts.append(["chips","screens","batteries"][i] + (" YES" if sim.recorded_stock()[i] < 80 else " NO"))
 paragraph("ALERT RULE: record < 80? " + " / ".join(alerts))
 button("Reconcile screen record · $500",func(): sim.audit_stock(); refresh(),content).disabled = sim.stock_error == 0 or sim.ended
 for i in range(sim.suppliers.size()):
  var index = i
  var s = sim.suppliers[i]
  var box = VBoxContainer.new()
  content.add_child(box)
  box.add_child(label(("● " if selected_supplier == i else "") + s.name + "  /  " + s.region,17))
  box.add_child(label("%s · $%d/unit · %s %dd%s" % ["Complete component sets" if s.part == -1 else ["Processors","Screens","Batteries"][s.part],s.price,"truck" if index == 3 else "sea",s.days," + border" if index != 3 else ""],14,MUTED))
  var row = HBoxContainer.new()
  box.add_child(row)
  var freight = 300 if index == 3 else 400
  if sim.has_role("logistics"): freight = int(freight*0.75)
  button("40 × %s · $%d" % ["Truck" if index == 3 else "Sea",s.price*40+freight],func(): sim.order(index,false); refresh(),row).disabled = sim.ended
  if index != 3:
   var air_cost = s.price*40+(1200 if sim.has_role("logistics") else 1600)
   button("Air · $%d" % air_cost,func(): sim.order(index,true); refresh(),row).disabled = sim.ended
 paragraph("Emissions per order: truck 4 / sea 7 / air 35 model units. These are invented comparison values, not measured CO₂.")
 paragraph("INBOUND: %d lots. OUTBOUND: %d phones in delivery. Customer receipt earns revenue." % [sim.shipments.size(),sim.dispatched()])
 for shipment in sim.shipments:
  paragraph("%s / %s / %s / %d days remaining" % [sim.suppliers[shipment.supplier].name,shipment.mode,shipment.stage,int(shipment.remaining)])
 if sim.tracking:
  for event in sim.event_plan:
   if int(event.day) >= sim.day and int(event.day) <= sim.day+1 and event.kind in ["weather","customs"]:
    paragraph("TRACKING WARNING: %s risk on day %d. This is scenario intelligence, not a guarantee of arrival." % [event.kind,event.day],TEAL)

func people_ui():
 heading("Expertise changes everything")
 paragraph("Recruit for evidence of relevant skills. The work-sample review reveals capabilities before you commit.")
 for i in range(sim.candidates.size()):
  var index = i
  var c = sim.candidates[i]
  content.add_child(label(c.name + "  /  " + c.role,18))
  paragraph(c.skill + " · recruitment $%d · salary $%d/day" % [c.cost,c.salary])
  var row = HBoxContainer.new()
  content.add_child(row)
  button("Work sample",func(): popup.title = c.name + " — work sample"; popup.dialog_text = ["Designed a camera prototype and documented testing failures.\n\nRelevant evidence: product research and iterative development.\nAdds 8 research points/day when assigned to internal R&D.","Planned an alternative freight network with two backup suppliers.\n\nRelevant evidence: logistics planning.\nReduces freight charges by 25%; component prices stay the same.","Reorganized shifts after interviewing assembly staff.\n\nRelevant evidence: workload planning and quality improvement.\nAdds 3 wellbeing/day and 5 phones/day of capacity."][index]; popup.popup_centered(Vector2i(720,380)),row)
  var b = button("On team" if sim.has_role(c.type) else "Hire specialist",func(): sim.hire(index); refresh(),row,true)
  b.disabled = sim.has_role(c.type) or sim.ended
 button("Train existing team · $2,500",func(): sim.invest("training"); refresh(),content).disabled = sim.has_role("trained") or sim.ended
 paragraph("Training adds +4 internal research/day. Hiring adds internal capacity. Insourcing requires moving externally performed work to your own team in Develop. Automated screening and bias are not simulated.")

func develop_ui():
 heading("Build the next Nova")
 paragraph("Nova 23 Pro: improve camera processing and battery efficiency. Complete 100 research points to raise revenue per phone from $340 to $390.")
 var progress = ProgressBar.new()
 progress.max_value = 100
 progress.value = mini(sim.research,100)
 progress.custom_minimum_size.y = 28
 content.add_child(progress)
 paragraph("%d / 100 RESEARCH  •  %s" % [mini(sim.research,100),"PRO RELEASED" if sim.upgraded else "IN DEVELOPMENT"],TEAL)
 paragraph("R&D now: " + sim.RESEARCH_OPTIONS[sim.research_mode].name + " / %d points per day" % sim.research_rate(),TEAL)
 paragraph("WHO does the work? WHERE? Switching from external to your existing team insources; overseas to Canada reshores. Both may change together.")
 for i in range(sim.RESEARCH_OPTIONS.size()):
  var index = i
  var choice = sim.RESEARCH_OPTIONS[i]
  button(choice.name + (" · active" if sim.research_mode == i else " · $%d" % choice.setup),func(): sim.set_research_mode(index); refresh(),content).disabled = sim.research_mode == i or sim.ended or sim.upgraded
  paragraph("%s / %s. +$%d/day overhead%s" % [choice.who,choice.where,choice.daily,". External rate: %d/day." % choice.rate if i >= 2 else ". Requires engineer or trained staff." + (" Leased lab equipment adds +4/day." if i == 1 else "")])
 paragraph("Current staff salaries continue in every mode. All costs are scenario assumptions; countries do not determine expertise or ethics.")
 button("Expand local assembly line · $12,000",func(): sim.invest("factory"); refresh(),content).disabled = sim.local_factory or sim.ended
 paragraph("Expand the assembly stage you already own: +15 phones/day and $350/day overhead. Components still need to arrive.")
 button("Install shipment tracking · $3,800",func(): sim.invest("tracking"); refresh(),content).disabled = sim.tracking or sim.ended
 paragraph("Sensor scans → dashboard → route warnings → your decision. Tracking does not create stock or remove border checks.")
 button("Overtime: " + ("ON — click to stop" if sim.overtime else "OFF — click to enable"),func(): sim.overtime = not sim.overtime; sim.record("Overtime enabled: +10 capacity, −6 wellbeing/day." if sim.overtime else "Overtime stopped. Normal recovery resumes."); refresh(),content)
 paragraph("Capacity: %d/day. Below 45 wellbeing, effective capacity falls by 15/day." % sim.capacity())

func report_ui():
 heading("Launch report" if sim.ended else "Evidence and decisions")
 var won = sim.delivered >= 900 and sim.trust >= 65 and sim.wellbeing >= 60 and sim.cash >= 0
 paragraph(("MISSION ACHIEVED" if won else "CAMPAIGN COMPLETE — ROOM TO IMPROVE") if sim.ended else "Target: 900 deliveries • trust ≥65 • wellbeing ≥60 • cash ≥0",TEAL)
 paragraph("Delivered: %d   |   Waiting: %d\nCash: $%d   |   Emissions: %d\nTrust: %d%%   |   Wellbeing: %d%%" % [sim.delivered,sim.backlog,sim.cash,sim.emissions,sim.trust,sim.wellbeing],INK)
 paragraph("Game results and learning evidence are separate. Check your understanding in Learn and explain your own decisions below.")
 for item in Learning.REFLECTIONS:
  paragraph(item.prompt,INK)
  var edit = TextEdit.new()
  edit.custom_minimum_size = Vector2(450,110)
  edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
  edit.text = sim.reflections.get(item.id,"")
  edit.placeholder_text = "Use evidence, explain a consequence, and state a limit."
  var key = item.id
  edit.text_changed.connect(func(): sim.reflections[key] = edit.text)
  content.add_child(edit)
 paragraph("Answers remain local. Save your campaign or export before closing.")
 button("Export answers and decision report",func(): export_report(),content)
 if sim.ended: button("New campaign",func(): sim = Simulation.new(); tab = 3; running = false; refresh(),content,true)
 content.add_child(label("DAILY EVIDENCE",15,TEAL))
 for i in range(sim.history.size()-1,-1,-1):
  var row = sim.history[i]
  paragraph("Day %d: assembled %d / received by customers %d / backlog %d / cash $%d / trust %d / wellbeing %d" % [row.day,row.assembled,row.arrived,row.backlog,row.cash,row.trust,row.wellbeing])
 content.add_child(label("DECISION LOG",15,TEAL))
 for entry in sim.journal: paragraph(entry)

func export_report(path: String = "user://nova-report.txt"):
 var f = FileAccess.open(path,FileAccess.WRITE)
 if f == null:
  sim.notice = "Could not write the report."
 else:
  var report = "NOVA / GLOBAL LAUNCH — LEARNING AND DECISIONS\nScenario seed %d / random events %s\nDelivered %d | Cash $%d | Trust %d | Wellbeing %d | Emissions %d model units\n\nI CAN TARGETS\n%s\n\n" % [sim.seed_value,str(sim.random_events),sim.delivered,sim.cash,sim.trust,sim.wellbeing,sim.emissions,"\n".join(Learning.TARGETS)]
  for question in Learning.CHECKS:
   report += question.question + "\n"
   var attempts = sim.answers.get(question.id,[])
   if attempts.is_empty(): report += "[not yet answered]\n"
   for attempt in attempts: report += "Day %d: %s — %s\n" % [int(attempt.day),question.choices[int(attempt.choice)],"correct after feedback/retry available" if attempt.correct else "retry needed"]
  report += "\nEXPLANATIONS (teacher review; no automatic grade)\n"
  for item in Learning.REFLECTIONS: report += item.prompt + "\n" + sim.reflections.get(item.id,"[not yet answered]") + "\n\n"
  report += "DAILY RECORDS\n" + JSON.stringify(sim.history,"  ") + "\n\nEVENTS\n" + JSON.stringify(sim.events_seen,"  ") + "\n\nDECISIONS\n" + "\n".join(sim.journal)
  f.store_string(report)
  f.close()
  if OS.has_feature("web"):
   JavaScriptBridge.download_buffer(report.to_utf8_buffer(),"nova-report.txt","text/plain")
   sim.notice = "Report download requested. Check your browser downloads."
  else:
   sim.notice = "Report exported: " + ProjectSettings.globalize_path(path)
 refresh()

func step():
 var event_count = sim.events_seen.size()
 sim.advance()
 elapsed = 0
 if sim.events_seen.size() > event_count:
  running = false
  tab = 0
  popup.title = "Disruption — pause and decide"
  popup.dialog_text = sim.events_seen.back().message + "\n\nTrace: event → affected resource → production/delivery → customer. Compare a response with a competing cost. Resume when ready."
  popup.popup_centered(Vector2i(720,380))
 if sim.ended:
  running = false
  tab = 4
 refresh()

func _process(delta):
 animation += delta
 last_delta = delta
 if running and not sim.ended:
  elapsed += delta * speed
  if elapsed >= 2.5:
   elapsed = 0
   step()
 timer_label.text = "DAY %02d / 30    •    %s    •    %dx SPEED" % [mini(sim.day,30),"FINISHED" if sim.ended else ("LIVE" if running else "PAUSED"),speed]
 if running: queue_redraw()

func _input(event):
 if popup.visible or get_viewport().gui_get_focus_owner() is TextEdit or get_viewport().gui_get_focus_owner() is LineEdit: return
 if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SPACE:
  running = not running and not sim.ended
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  var p = get_global_mouse_position()
  for i in range(sim.suppliers.size()):
   if p.distance_to(map_point(sim.suppliers[i].pos)) < 30:
    selected_supplier = i
    tab = 0
    refresh()

func learn_ui():
 heading("Learn to run Nova")
 if not sim.tutorial_done:
  var intro = Learning.INTRO[sim.tutorial_step]
  paragraph(intro.title,TEAL)
  var nav = HBoxContainer.new()
  content.add_child(nav)
  button("Back",func(): sim.tutorial_step = maxi(0,sim.tutorial_step-1); refresh(),nav).disabled = sim.tutorial_step == 0
  var next = button("Begin campaign" if sim.tutorial_step == 6 else "Next",func():
   if sim.tutorial_step == 6:
    sim.tutorial_done = true
    tab = 0
   else: sim.tutorial_step += 1
   refresh(),nav,true)
  next.disabled = (sim.tutorial_step == 1 and sim.shipments.is_empty()) or (sim.tutorial_step == 2 and sim.day == 1)
  paragraph(intro.body,INK)
  if sim.tutorial_step == 0:
   paragraph("SCENARIO: " + ("Random replay" if sim.random_events else "Classroom comparison") + " / seed %d" % sim.seed_value)
   if sim.day == 1 and sim.events_seen.is_empty():
    var modes = HBoxContainer.new()
    content.add_child(modes)
    button("Classroom · fixed events",func(): sim.configure_events(false,23); refresh(),modes)
    button("Random · new seed",func(): sim.configure_events(true,randi_range(1,999999)); refresh(),modes)
    var seed_edit = SpinBox.new()
    seed_edit.min_value = 1
    seed_edit.max_value = 999999
    seed_edit.value = sim.seed_value
    seed_edit.prefix = "Replay seed "
    seed_edit.value_changed.connect(func(value): sim.configure_events(true,int(value)))
    content.add_child(seed_edit)
    paragraph("Same seed = same event plan. Decisions still affect outcomes. Three bounded events occur per campaign; this is not a real-world risk forecast.")
  if sim.tutorial_step == 1:
   button("Order 40 processors by sea · $3,600",func(): sim.order(0,false); refresh(),content).disabled = not sim.shipments.is_empty() or sim.ended
   paragraph("Cash now: $%d. Physical chips: %d. Inbound lots: %d." % [sim.cash,sim.inventory[0],sim.shipments.size()],TEAL)
  if sim.tutorial_step == 2:
   button("Advance one day",func(): step(),content)
   paragraph("Day %d: %d phones dispatched, %d received by customers." % [sim.day,sim.dispatched(),sim.delivered],TEAL)
  button("Skip guide / free play",func(): sim.tutorial_done = true; tab = 0; refresh(),content)
  return
 paragraph("These are learning targets, not automatic achievement claims. Use your own explanation to show understanding.")
 button("Revisit the 7-step guide",func(): sim.tutorial_done = false; sim.tutorial_step = 0; running = false; refresh(),content)
 var q = Learning.CHECKS[check_index]
 paragraph("CHECK %d / %d" % [check_index+1,Learning.CHECKS.size()],TEAL)
 paragraph(q.question,INK)
 for i in range(q.choices.size()):
  var answer_index = i
  button(q.choices[i],func():
   if not sim.answers.has(q.id): sim.answers[q.id] = []
   sim.answers[q.id].append({"choice":answer_index,"correct":answer_index == q.correct,"day":sim.day})
   check_feedback = ("Correct. " if answer_index == q.correct else "Try again. ") + q.feedback
   refresh(),content)
 if not check_feedback.is_empty(): paragraph(check_feedback,TEAL)
 var row = HBoxContainer.new()
 content.add_child(row)
 button("Previous check",func(): check_index = maxi(0,check_index-1); check_feedback = ""; refresh(),row)
 button("Next check",func(): check_index = (check_index+1)%Learning.CHECKS.size(); check_feedback = ""; refresh(),row)
 paragraph("Report contains a new school-printing case. Explain a conditional recommendation; quiz correctness and game profit do not establish that skill on their own.")
 button("Hide learning targets" if show_targets else "Show 8 I can targets",func(): show_targets = not show_targets; refresh(),content)
 if show_targets:
  for target in Learning.TARGETS: paragraph(target)

func load_coastlines():
 var data = JSON.parse_string(FileAccess.get_file_as_string("res://assets/world-land.geojson"))
 if not data is Dictionary: return
 for feature in data.features:
  var geometry = feature.geometry
  var polygons = geometry.coordinates if geometry.type == "MultiPolygon" else [geometry.coordinates]
  for polygon in polygons:
   if polygon[0].all(func(coord): return float(coord[1]) < -60): continue
   var ring = PackedVector2Array()
   for coord in polygon[0]:
    ring.append(map_point(Vector2(float(coord[0]),maxf(-60,float(coord[1])))))
   if ring.size() > 3: coastlines.append(ring)

func map_point(p: Vector2) -> Vector2:
 return MAP_RECT.position + Vector2((p.x+180)/360.0,(85-p.y)/145.0)*MAP_RECT.size

func text_at(p: Vector2, text: String, size_px: int = 14, color: Color = INK):
 draw_string(font,p,text,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px,color)

func icon(kind: String, position_px: Vector2, scale_px: float = 32):
 draw_circle(position_px,scale_px*.63,Color("0a192c"))
 draw_texture_rect(VEHICLES[kind],Rect2(position_px-Vector2(scale_px,scale_px*.84)*.5,Vector2(scale_px,scale_px*.84)),false)

func route_points(supplier_index: int, mode: String) -> PackedVector2Array:
 var points: Array = [sim.suppliers[supplier_index].pos]
 if supplier_index == 0:
  if mode == "plane": points.append_array([Vector2(150,55),Vector2(179,60),Vector2(-179,60),Vector2(-110,60)])
  else: points.append_array([Vector2(140,10),Vector2(179,10),Vector2(-179,10),Vector2(-105,8),Vector2(-80,9),Vector2(-77,13),Vector2(-65,28)])
 elif supplier_index == 1: points.append(Vector2(-35,40))
 elif supplier_index == 2: points.append(Vector2(-49,18))
 points.append(HUB)
 var result = PackedVector2Array()
 for point in points: result.append(map_point(point))
 return result

func draw_route(points: PackedVector2Array, color: Color, dashed: bool):
 for i in range(points.size()-1):
  if absf(points[i].x-points[i+1].x) > 500: continue # Dateline wrap, not a line across land.
  if dashed: draw_dashed_line(points[i],points[i+1],color,1.5,6,true)
  else: draw_line(points[i],points[i+1],color,1.5,true)

func route_position(points: PackedVector2Array, fraction: float) -> Vector2:
 var total = 0.0
 for i in range(points.size()-1):
  if absf(points[i].x-points[i+1].x) < 500: total += points[i].distance_to(points[i+1])
 var target = total*clampf(fraction,0,1)
 for i in range(points.size()-1):
  if absf(points[i].x-points[i+1].x) > 500: continue
  var distance = points[i].distance_to(points[i+1])
  if target <= distance: return points[i].lerp(points[i+1],target/maxf(1,distance))
  target -= distance
 return points[-1]

func _draw():
 draw_style_box(style(PANEL),Rect2(25,195,850,590))
 text_at(Vector2(48,225),"GLOBAL SOURCING / CANADIAN ASSEMBLY",17,TEAL)
 text_at(Vector2(48,248),"Natural Earth coastlines · fictional firms · schematic routes, not navigation",12,MUTED)
 for lon in range(-180,181,30):
  draw_line(map_point(Vector2(lon,85)),map_point(Vector2(lon,-60)),Color("1b3046"),1)
 for lat in range(-60,86,30):
  draw_line(map_point(Vector2(-180,lat)),map_point(Vector2(180,lat)),Color("1b3046"),1)
 for ring in coastlines:
  if Geometry2D.triangulate_polygon(ring).size() > 0: draw_colored_polygon(ring,Color("284a55"))
  draw_polyline(ring,Color("3b6470"),1,true)
 for i in range(sim.suppliers.size()):
  var s = sim.suppliers[i]
  var point = map_point(s.pos)
  var color = TEAL if i == selected_supplier else Color("85a7c7")
  draw_route(route_points(i,"truck" if i == 3 else "ship"),Color("426278"),false)
  draw_circle(point,7,color)
  draw_circle(point,3,PANEL)
  var offset = [Vector2(-95,24),Vector2(10,-22),Vector2(10,20),Vector2(-120,-22)][i]
  text_at(point+offset,s.name,14,color)
  text_at(point+offset+Vector2(0,16),["TAIPEI / CHIPS","LISBON / SCREENS","RECIFE / BATTERIES","MONTRÉAL / SETS"][i],10,MUTED)
 var hub = map_point(HUB)
 icon("factory",hub,29)
 text_at(hub+Vector2(15,9),"HALIFAX",12,Color("efbb73"))
 if sim.day <= sim.route_delay_until:
  var storm = map_point(Vector2(150,12))
  draw_circle(storm,22,Color(.9,.45,.25,.18))
  text_at(storm+Vector2(-25,-25),"STORM +2d",12,Color("ffb98b"))
 for shipment in sim.shipments:
  if shipment.stage == "border":
   icon("border",hub+Vector2(10,35),23)
   continue
  var points = route_points(int(shipment.supplier),shipment.mode)
  draw_route(points,TEAL if shipment.mode == "plane" else Color("c0a87a"),shipment.mode == "plane")
  var fractional_day = elapsed/2.5 if running else 0.0
  var fraction = 1.0-(float(shipment.remaining)-fractional_day)/maxf(1,float(shipment.total))
  icon(shipment.mode,route_position(points,fraction),26)
 # A separate local distribution schematic avoids implying assembly equals delivery.
 draw_line(Vector2(50,657),Vector2(850,657),Color("294359"),1)
 text_at(Vector2(48,682),"ORDER DATA > RECEIPT > ASSEMBLY > CUSTOMER",13,TEAL)
 icon("ship",Vector2(68,710),24)
 text_at(Vector2(90,716),"SEA",11,MUTED)
 icon("plane",Vector2(160,710),24)
 text_at(Vector2(180,716),"AIR",11,MUTED)
 icon("truck",Vector2(248,710),24)
 text_at(Vector2(268,716),"DOMESTIC",11,MUTED)
 text_at(Vector2(48,756),"%d inbound lots  /  %d phones in delivery  /  %d per day assembly" % [sim.shipments.size(),sim.dispatched(),sim.capacity()],14)
 draw_line(Vector2(410,720),Vector2(700,720),MUTED,2,true)
 icon("factory",Vector2(410,710),32)
 draw_style_box(style(Color("294a55"),4),Rect2(688,691,35,35))
 text_at(Vector2(725,714),"CUSTOMER",11)
 if not sim.outbound.is_empty():
  var move_fraction = elapsed/2.5 if running else .5
  icon("truck",Vector2(440+move_fraction*220,708),30)
 text_at(Vector2(445,697),"1 day delivery",11,MUTED)
 text_at(Vector2(445,740),"%d received / %d awaiting assembly" % [sim.delivered,sim.backlog],12,MUTED)
