extends SceneTree
const Sim = preload("res://scripts/simulation.gd")
var failures: Array = []
func check(condition: bool, message: String):
 if not condition:
  failures.append(message)
  push_error(message)

func _initialize():
 # Goods, data and money move at different moments.
 var s = Sim.new()
 check(s.order(0,false),"Order succeeds")
 check(s.cash == 64400 and s.inventory[0] == 120,"Payment is not stock receipt")
 for i in range(5): s.advance()
 check(s.shipments.size() == 1 and s.shipments[0].stage == "border","International cargo clears border after travel")
 s.advance()
 check(s.shipments.is_empty(),"Receipt follows clearance")
 var d = Sim.new()
 d.advance()
 check(d.delivered == 0 and d.dispatched() == 30,"Assembly is separate from customer receipt")
 d.advance()
 check(d.delivered == 30,"Customer receipt occurs next day")
 # Provider/location must be independently manipulable.
 var modes = Sim.new()
 modes.invest("training")
 check(modes.set_research_mode(1),"Company can offshore its own work")
 check(not modes.outsourcing and modes.research_rate() == 8,"Offshoring need not outsource")
 modes.set_research_mode(3)
 check(modes.outsourcing and modes.research_rate() == 10,"External overseas R&D")
 modes.set_research_mode(2)
 check(modes.journal[0].contains("reshoring") and not modes.journal[0].contains("insourcing"),"Reshoring can retain external provider")
 modes.set_research_mode(0)
 check(modes.journal[0].contains("insourcing") and modes.research_rate() == 4,"Existing trained staff can insource")
 # Consequences of events are bounded and specific.
 var weather = Sim.new()
 weather.order(0,false)
 weather.order(1,true)
 var before = weather.shipments[0].remaining
 weather.apply_event("weather")
 check(weather.shipments[0].remaining == before+2 and weather.shipments[1].remaining == 1,"Storm affects relevant sea cargo only")
 weather.order(0,false)
 check(weather.shipments.back().total == 7,"Storm affects new sea orders within active window")
 var border = Sim.new()
 border.shipments.append({"supplier":1,"remaining":1,"total":1,"mode":"ship","air":false,"quantity":40,"stage":"border"})
 border.apply_event("customs")
 check(border.shipments[0].remaining == 3,"Border inspection delays cargo already waiting")
 var records = Sim.new()
 records.apply_event("records")
 var physical = records.inventory.duplicate()
 check(records.recorded_stock()[1] == physical[1]+60,"Duplicate scan affects record only")
 check(records.audit_stock() and records.inventory == physical and records.stock_error == 0,"Audit reconciles without creating goods")
 # Seeded replay has identical event plans, unaffected by UI RNG.
 var random_a = Sim.new()
 var random_b = Sim.new()
 random_a.configure_events(true,101)
 random_b.configure_events(true,101)
 check(random_a.event_plan == random_b.event_plan,"Same seed repeats event schedule")
 var random_c = Sim.new()
 random_c.configure_events(true,202)
 check(random_a.event_plan != random_c.event_plan,"Different seeds vary plans")
 var campaign = run_campaign(false,23)
 check(campaign.ended and campaign.delivered >= 900,"Classroom campaign has a feasible winning strategy")
 check(campaign.cash > 0 and campaign.trust >= 65 and campaign.wellbeing >= 60,"Winning strategy meets stakeholder thresholds")
 check(campaign.upgraded and campaign.events_seen.size() == 3,"Research and all classroom events occur")
 for seed_value in [101,202,303]:
  var replay = run_campaign(true,seed_value)
  check(replay.ended and replay.day == 31,"Random campaign completes for seed %d" % seed_value)
 # Save without overwriting the user's campaign; preserve in-transit state and explanations.
 random_a.order(2,true)
 random_a.answers["provider"] = [{"choice":0,"correct":true,"day":1}]
 random_a.reflections["decision"] = "Evidence goes here."
 check(random_a.save_game("user://test-campaign.json") == OK,"Save succeeds")
 var loaded = Sim.new()
 check(loaded.load_game("user://test-campaign.json"),"Load succeeds")
 check(loaded.event_plan == random_a.event_plan and loaded.shipments.size() == 1,"Event plan and shipments persist")
 check(loaded.reflections == random_a.reflections and loaded.answers["provider"][0].correct,"Learning evidence persists")
 loaded.advance()
 var poor = Sim.new()
 poor.cash = 0
 check(not poor.order(0,true) and poor.shipments.is_empty(),"No order can exceed budget")
 var exhausted = Sim.new()
 exhausted.overtime = true
 for i in range(10): exhausted.advance()
 check(exhausted.wellbeing < 45,"Sustained overtime harms wellbeing")
 if failures.is_empty(): print("PASS: staged logistics, provider/location transitions, event effects, seeded replay, full campaigns, records, persistence, budgets and wellbeing.")
 else: print("FAILURES: ",failures)
 quit(0 if failures.is_empty() else 1)

func run_campaign(random_mode: bool, chosen_seed: int):
 var c = Sim.new()
 c.configure_events(random_mode,chosen_seed)
 c.hire(0)
 c.hire(2)
 c.invest("factory")
 c.invest("training")
 c.order(3,false)
 c.order(3,false)
 for i in range(30):
  c.overtime = c.day >= 21
  if c.stock_error > 0: c.audit_stock()
  for part in range(3):
   var transit = 0
   for shipment in c.shipments:
    if c.suppliers[shipment.supplier].part == part: transit += shipment.quantity
   while c.inventory[part]+transit < 300:
    var cost = c.suppliers[part].price*40+400
    if c.cash < cost+2000: break
    if not c.order(part,false): break
    transit += 40
   if c.inventory[part] < 45 and c.cash > c.suppliers[part].price*40+4000: c.order(part,true)
  c.advance()
 print("Campaign seed %d / random %s: %d deliveries, $%d, trust %d, wellbeing %d" % [chosen_seed,str(random_mode),c.delivered,c.cash,c.trust,c.wellbeing])
 return c
