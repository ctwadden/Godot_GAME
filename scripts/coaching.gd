extends RefCounted

const Simulation = preload("res://scripts/simulation.gd")
const DEMO = [
 {"title":"Your job, and the automatic jobs", "why":"I am the operations coach. Watch my first decisions, then try a fresh company yourself.\n\nYOU buy parts, choose expertise and advance time. The game automatically receives parts, assembles phones, sends delivery trucks and records customer payments. There is no Deliver button.\n\nThis small training scenario starts with $28,000, 80 chips, 10 screens, 80 batteries and 20 orders/day. It differs from the advanced campaign.","action":"none"},
 {"title":"First, diagnose the bottleneck", "why":"We have 80 chips, 10 screens and 80 batteries. Each phone needs one of each. Capacity is 30/day, but we can assemble at most 10 phones until more screens arrive.\n\nI would fix the screen shortage before hiring. A new engineer researches the product; an engineer does not create screens.","action":"none"},
 {"title":"I order screens, not more chips", "why":"I buy 40 screens by air for $4,200. Sea costs $3,000 but needs 4 travel days plus clearance. Our existing 10 screens will not cover that wait.\n\nThe map now shows a plane. Cash fell, but usable screens stayed at 10. Payment and order data are not physical goods.","action":"order"},
 {"title":"I advance time: goods are still arriving", "why":"One day passes. The screen shipment reaches the border; it is not yet usable stock.\n\nThe factory automatically uses our original 10 screens to assemble 10 phones and dispatches them by truck. Customers have received 0 so far.\n\nI do not click Deliver or hire someone to move the truck.","action":"day"},
 {"title":"Receipt, assembly and delivery are different", "why":"Another day passes. The 40 screens clear the border and enter stock. Assembly automatically makes 30 phones: 10 waiting orders plus 20 new orders.\n\nCustomers receive the first 10 phones dispatched yesterday: $3,400 revenue, less daily operating costs. The newer phones are still in delivery.","action":"day"},
 {"title":"Deliveries continue, so parts must be replenished", "why":"Customers receive another 30 phones. Only 10 screens remained for this turn’s assembly, so 10 new orders must wait. Parts have been consumed again. I must keep checking all three stocks and incoming shipments.\n\nI order before a shortage, allowing for travel AND clearance. I advance time to move trucks. Hiring is a response to a skill/capacity need, not a substitute for parts.","action":"day"},
 {"title":"Compare an external expert", "why":"Now I demonstrate R&D choices. These next choices illustrate concepts; buying every option is not a recommended budget strategy.\n\nAn external Canadian studio costs $6,500 setup plus $450/day and provides 12 research points/day. Own Canadian team → external Canadian studio is OUTSOURCING. Location stays in Canada: it is not offshoring.","action":"outsource"},
 {"title":"Bring the task to existing staff", "why":"I train existing staff for $2,500, then move R&D from the external studio to them. This is INSOURCING: external → internal. Both teams are in Canada.\n\nInternal research is now 4 points/day. It is slower than the studio, so I would compare that time cost with continuing contract charges.","action":"insource"},
 {"title":"Hire only for a reason", "why":"I demonstrate hiring Maya after examining her relevant product-design work. Recruitment costs $4,200 and salary is $280/day. Her +8 adds to the trained team's +4, making 12 internal research points/day.\n\nHiring builds internal capability. Hiring by itself does not prove that an outsourced task moved inside. Compare evidence, costs and the goal before choosing.","action":"hire"},
 {"title":"Location is a separate decision", "why":"I move the same internal R&D team to Nova's Portuguese lab. This is OFFSHORING without outsourcing: Nova still performs the work.\n\nThe fictional leased equipment adds +4 research/day, with $8,000 setup and $150/day overhead. This is a site-contract assumption, not a claim that a country's workers are better.","action":"offshore"},
 {"title":"Bring work home, then explain your plan", "why":"I return the internal work to Canada. Overseas → home is RESHORING. The provider stays internal, so this move is not a new insourcing transition.\n\nMy decision sequence: identify the shortage; order the needed parts; allow time for receipt and automatic delivery; choose ONE suitable R&D strategy; monitor stock again.\n\nIn practice you get a current task, optional advice and a review of your actual choices. Start a fresh student company below.","action":"reshore"}
]
const PRACTICE_REFLECTIONS = [
 {"id":"decision","prompt":"Why was the first purchase about parts, while hiring served a different goal? Use your stock, delivery or cost figures."},
 {"id":"system","prompt":"What did the record audit fix? What physical problem could it not fix?"},
 {"id":"transfer","prompt":"A Canadian company moves R&D from an external Portuguese studio to existing Canadian staff. Name both changes and explain who/where before and after."}
]
const TASKS = [
 "Identify the missing part", "Buy your first screens", "Wait for physical receipt", "Observe customer delivery", "Choose one research strategy", "Replenish and deliver 80 phones", "Repair a faulty stock record", "Deliver 150 phones by day 10", "Review and explain"
]
var sim = Simulation.new()
var mode = "student"
var stage = 0
var correct_diagnosis = false
var first_order = false
var first_mode = ""
var expertise = ""
var audited = false
var hints = 0
var feedback = ""
var evidence: Array = []

func _init(chosen_mode: String = "student"):
 mode = chosen_mode
 sim.cash = 28000
 sim.inventory = [80,10,80]
 sim.demand = 20
 sim.event_plan = []
 sim.notice = "Training company: choose one decision at a time. Assembly and delivery are automatic."
 sim.tutorial_done = true

func demo_next():
 if stage >= DEMO.size()-1: return
 stage += 1
 match DEMO[stage].action:
  "order": sim.order(1,true)
  "day": sim.advance()
  "outsource": sim.set_research_mode(2)
  "insource": sim.invest("training"); sim.set_research_mode(0)
  "hire": sim.hire(0)
  "offshore": sim.set_research_mode(1)
  "reshore": sim.set_research_mode(0)
 sim.notice = "Expert step %d: %s" % [stage+1,DEMO[stage].title]

func answer(part: int):
 evidence.append({"task":"bottleneck","choice":["processors","screens","hire"][part],"correct":part==1})
 correct_diagnosis = part == 1
 feedback = "Yes: only 10 screens. Order screens before adding staff." if correct_diagnosis else "Compare all three counts: 10 screens limit assembly. More chips or staff cannot replace a missing screen. Try again."

func purchase(index: int, air: bool):
 if stage == 1 and (index != 1 or first_order): return
 var freight = 300 if index == 3 else (1600 if air else 400)
 if sim.has_role("logistics"): freight = int(freight*0.75)
 if not audited and sim.cash-(sim.suppliers[index].price*40+freight) < 500:
  feedback = "Keep the practice contingency reserve of $500. This protects the later stock audit; choose a smaller-cost plan or wait for customer payment."
  return
 if sim.order(index,air):
  if stage == 1:
   first_order = true
   first_mode = "air" if air else "sea"
  evidence.append({"task":"purchase","day":sim.day,"supplier":index,"air":air,"cash_after":sim.cash})
  feedback = "Order placed. Stock changes only after receipt. Check the moving shipment; advance time to see its progress."
 else: feedback = sim.notice

func choose_expertise(choice: String):
 if not expertise.is_empty(): return
 var success = false
 match choice:
  "train": success = sim.invest("training")
  "hire": success = sim.hire(0)
  "external": success = sim.set_research_mode(2)
 if success:
  expertise = choice
  evidence.append({"task":"expertise","choice":choice,"day":sim.day,"rate":sim.research_rate()})
  feedback = "External Canadian studio: outsourcing without offshoring. It adds 12 research/day and $450/day until release." if choice == "external" else "You built internal capability. It is not an insourcing transition because R&D was already internal. Research now advances %d points/day." % sim.research_rate()
 else: feedback = sim.notice

func advance():
 if stage not in [2,3,5,7] or sim.day > 10 or sim.ended: return
 if stage in [2,3,5] and can_continue(): return
 sim.advance()
 if stage == 7 and (sim.delivered >= 150 or sim.day > 10 or sim.ended): stage = 8
 if sim.ended: stage = 8
 if sim.day > 10: stage = 8
 feedback = "Day %d complete: %d assembled, %d received by customers. Delivery was automatic." % [sim.day-1,sim.history.back().assembled,sim.history.back().arrived]
 sim.notice = feedback

func can_continue() -> bool:
 match stage:
  0: return correct_diagnosis
  1: return first_order
  2: return first_order and sim.shipments.is_empty()
  3: return sim.delivered >= 30
  4: return not expertise.is_empty()
  5: return sim.delivered >= 80
  6: return audited
 return false

func next_task():
 if not can_continue(): return
 stage += 1
 feedback = ""
 if stage == 6:
  sim.apply_event("records")
  feedback = "A duplicate scan added 60 recorded screens. Actual screens did not change. Compare both counts before making a purchase."

func audit():
 if sim.audit_stock():
  audited = true
  feedback = "Record repaired for $500. Physical screens stayed at %d. An accurate database does not manufacture parts." % sim.inventory[1]
  evidence.append({"task":"audit","day":sim.day,"physical":sim.inventory[1]})

func advice(count_hint: bool = true) -> String:
 if count_hint: hints += 1
 if sim.stock_error > 0: return "Compare recorded and physical screens. Audit reconciles the record for $500; it does not add screens. Then check what parts you actually need."
 var part = 0
 for i in range(1,3):
  if sim.inventory[i] < sim.inventory[part]: part = i
 var name = ["processors","screens","batteries"][part]
 var incoming = 0
 var soonest = 99
 for shipment in sim.shipments:
  if sim.suppliers[shipment.supplier].part in [part,-1]:
   incoming += shipment.quantity
   var days_left = int(shipment.remaining)+(1 if shipment.stage == "travel" and shipment.supplier != 3 else 0)
   soonest = mini(soonest,days_left)
 if sim.inventory[part] < sim.demand:
  return "Only %d %s are usable; demand is %d/day. %s Hiring cannot fix missing parts. Compare waiting with a faster order, including clearance and cost." % [sim.inventory[part],name,sim.demand,"%d are incoming, earliest in about %d turns." % [incoming,soonest] if incoming > 0 else "None are incoming."]
 if sim.dispatched() > 0 and sim.inventory[part] >= sim.demand:
  return "%d phones are already on trucks. Advance a day to receive customer payment automatically. You have %d %s, the lowest stock. Plan replacement orders before that buffer is consumed." % [sim.dispatched(),sim.inventory[part],name]
 return "You have usable parts. Advance time to assemble and dispatch automatically. Keep a buffer for all three parts; only hire or contract when the task requires that expertise."

func review() -> String:
 var zero_days = 0
 for row in sim.history:
  if row.assembled == 0: zero_days += 1
 var text = "YOUR RUN: %d deliveries in %d days, $%d cash, %d waiting for assembly, emissions %d model units. %d days had no assembly.\n\n" % [sim.delivered,sim.history.size(),sim.cash,sim.backlog,sim.emissions,zero_days]
 text += "FIRST ORDER: screens by %s. %s\n\n" % [first_mode if not first_mode.is_empty() else "not yet ordered","Air shortened travel but cost $1,200 more than sea for this lot; clearance still applied." if first_mode == "air" else ("Sea saved $1,200 on the first screen lot, but the small starting screen buffer could not cover the longer wait." if first_mode == "sea" else "No first order was completed.")]
 text += "EXPERTISE: %s. %s\n\n" % [expertise if not expertise.is_empty() else "not yet chosen","You used an external Canadian studio: outsourcing, not offshoring." if expertise == "external" else ("You added internal capability; no provider boundary changed." if not expertise.is_empty() else "No expertise choice was completed.")]
 text += "IF YOU CONTINUED: " + advice(false) + "\n\n"
 text += "EXPERT APPROACH: check the limiting part before buying; count both usable and incoming stock; budget for lead time; let trucks deliver automatically; choose expertise for a stated R&D goal. An engineer does not supply missing components.\n\n"
 var reference = reference_run(sim.history.size())
 text += "ONE ALTERNATIVE FOR THE SAME %d DAYS: %d deliveries, $%d cash, emissions %d model units. It orders initial screens by air, replenishes with nearby sets when projected minimum stock falls below 70, and trains existing staff from day 4.\n\n" % [sim.history.size(),reference.delivered,reference.cash,reference.emissions]
 text += "Both runs start with the same company and day-6 demand rise. The scan fault triggers after 80 deliveries. Your run: %s. Alternative: %s. This is an illustrative policy, not a perfect answer: compare costs, timing and environmental impact before judging it." % ["event reached" if not sim.events_seen.is_empty() else "event not yet reached","event reached" if not reference.events_seen.is_empty() else "event not yet reached"]
 return text

func reference_run(days: int):
 var reference = Simulation.new()
 reference.cash = 28000
 reference.inventory = [80,10,80]
 reference.demand = 20
 reference.event_plan = []
 reference.order(1,true)
 var event_done = false
 for i in range(mini(days,10)):
  if i == 3: reference.invest("training")
  var projected = reference.inventory.duplicate()
  for shipment in reference.shipments:
   var part = reference.suppliers[shipment.supplier].part
   if part == -1:
    for j in range(3): projected[j] += shipment.quantity
   else: projected[part] += shipment.quantity
  if mini(projected[0],mini(projected[1],projected[2])) < 70: reference.order(3,false)
  reference.advance()
  if reference.delivered >= 80 and not event_done:
   reference.apply_event("records")
   reference.audit_stock()
   event_done = true
 return reference

func pack() -> Dictionary:
 return {"stage":stage,"correct_diagnosis":correct_diagnosis,"first_order":first_order,"first_mode":first_mode,"expertise":expertise,"audited":audited,"hints":hints,"feedback":feedback,"evidence":evidence}

func restore(data: Dictionary):
 for key in ["stage","correct_diagnosis","first_order","first_mode","expertise","audited","hints","feedback","evidence"]:
  if data.has(key): set(key,data[key])
 stage = clampi(int(stage),0,8)
