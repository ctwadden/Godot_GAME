extends RefCounted

const SAVE_KEYS = ["day","cash","trust","wellbeing","emissions","delivered","demand","backlog","inventory","shipments","staff","research","upgraded","tracking","local_factory","outsourcing","overtime","ended","journal","history","notice","research_mode","seed_value","random_events","event_plan","events_seen","route_delay_until","border_delay_until","stock_error","outbound","tutorial_step","tutorial_done","answers","reflections"]
const RESEARCH_OPTIONS = [
 {"name":"Own team · Canada","who":"Internal","where":"Canada","setup":0,"daily":0,"rate":0},
 {"name":"Own team · Portugal","who":"Internal","where":"Portugal","setup":8000,"daily":150,"rate":4},
 {"name":"External studio · Canada","who":"External","where":"Canada","setup":6500,"daily":450,"rate":12},
 {"name":"External studio · Portugal","who":"External","where":"Portugal","setup":4500,"daily":300,"rate":10}
]
var day = 1
var cash = 68000
var trust = 80
var wellbeing = 85
var emissions = 0
var delivered = 0
var demand = 35
var backlog = 0
var inventory = [120,120,120]
var shipments: Array = []
var outbound: Array = []
var staff: Array = []
var research = 0
var research_mode = 0
var upgraded = false
var tracking = false
var local_factory = false
var outsourcing = false
var overtime = false
var ended = false
var journal: Array = []
var history: Array = []
var notice = "Start in Learn. Your first mission is to trace one order from payment to delivery."
var random_events = false
var seed_value = 23
var event_plan: Array = []
var events_seen: Array = []
var route_delay_until = 0
var border_delay_until = 0
var stock_error = 0
var tutorial_step = 0
var tutorial_done = false
var answers: Dictionary = {}
var reflections: Dictionary = {}
# Fictional companies located at recognizable cities; locations do not imply country performance.
var suppliers = [
 {"name":"Silicon Harbor","part":0,"region":"Taipei · external","price":80,"days":5,"pos":Vector2(121,25)},
 {"name":"Prism Optics","part":1,"region":"Lisbon · external","price":65,"days":4,"pos":Vector2(-9,39)},
 {"name":"Volt Collective","part":2,"region":"Recife · external","price":45,"days":3,"pos":Vector2(-35,-8)},
 {"name":"NearWorks","part":-1,"region":"Montréal · external","price":245,"days":2,"pos":Vector2(-74,46)}
]
var candidates = [
 {"name":"Maya Chen","role":"Product engineer","skill":"Internal research +8/day","cost":4200,"salary":280,"type":"engineer"},
 {"name":"Amara Okafor","role":"Logistics lead","skill":"Freight costs −25%","cost":3500,"salary":230,"type":"logistics"},
 {"name":"Leo Martins","role":"People & quality lead","skill":"Wellbeing +3/day; capacity +5","cost":3000,"salary":210,"type":"people"}
]

func _init():
 configure_events(false,23)

func configure_events(random_mode: bool, chosen_seed: int):
 random_events = random_mode
 seed_value = chosen_seed
 if not random_mode:
  event_plan = [{"day":9,"kind":"weather"},{"day":16,"kind":"customs"},{"day":22,"kind":"records"}]
 else:
  var rng = RandomNumberGenerator.new()
  rng.seed = seed_value
  var kinds = ["weather","customs","records","recall","demand"]
  event_plan = []
  for start in [7,14,21]:
   var index = rng.randi_range(0,kinds.size()-1)
   event_plan.append({"day":start+rng.randi_range(0,3),"kind":kinds[index]})
   kinds.remove_at(index)

func has_role(role: String) -> bool: return role in staff

func record(message: String):
 notice = message
 journal.push_front("Day %d · %s" % [day,message])

func spend(amount: int) -> bool:
 if ended: return false
 if cash < amount:
  notice = "Insufficient cash. Needed $%d; available $%d." % [amount,cash]
  return false
 cash -= amount
 return true

func order(index: int, air: bool) -> bool:
 if index < 0 or index >= suppliers.size(): return false
 var s = suppliers[index]
 var mode = "truck" if index == 3 else ("plane" if air else "ship")
 var freight = 300 if mode == "truck" else (1600 if air else 400)
 if has_role("logistics"): freight = int(freight*0.75)
 var cost = s.price*40+freight
 if not spend(cost): return false
 var travel = 1 if mode == "plane" else s.days
 if index == 0 and day <= route_delay_until and mode == "ship": travel += 2
 shipments.append({"supplier":index,"remaining":travel,"total":travel,"air":air,"mode":mode,"quantity":40,"stage":"travel"})
 emissions += 4 if mode == "truck" else (35 if air else 7)
 record("Order recorded; $%d paid. 40 %s by %s, travel %d days%s. Physical stock has NOT arrived." % [cost,"sets" if s.part == -1 else ["chips","screens","batteries"][s.part],mode,travel," + border clearance" if index != 3 else ""])
 return true

func hire(index: int) -> bool:
 var c = candidates[index]
 if has_role(c.type) or not spend(c.cost): return false
 staff.append(c.type)
 record("Hired %s based on work evidence. %s. Salary $%d/day. Recruitment alone is not a transfer from an external provider." % [c.name,c.skill,c.salary])
 return true

func set_research_mode(index: int) -> bool:
 if index < 0 or index >= RESEARCH_OPTIONS.size() or index == research_mode or upgraded: return false
 var choice = RESEARCH_OPTIONS[index]
 if not spend(choice.setup): return false
 var before = RESEARCH_OPTIONS[research_mode]
 var changes: Array = []
 if before.who != choice.who: changes.append("insourcing" if choice.who == "Internal" else "outsourcing")
 if before.where != choice.where: changes.append("reshoring" if choice.where == "Canada" else "offshoring")
 research_mode = index
 outsourcing = choice.who == "External"
 record("R&D: %s → %s. %s. $%d setup; $%d/day additional overhead. Existing employee salaries continue." % [before.name,choice.name," + ".join(changes),choice.setup,choice.daily])
 return true

func research_rate() -> int:
 if upgraded: return 0
 if outsourcing: return RESEARCH_OPTIONS[research_mode].rate
 var internal_rate = (8 if has_role("engineer") else 0)+(4 if has_role("trained") else 0)
 return internal_rate+(4 if research_mode == 1 and internal_rate > 0 else 0)

func invest(kind: String) -> bool:
 if kind == "contract": return set_research_mode(2)
 var prices = {"tracking":3800,"factory":12000,"training":2500}
 if not prices.has(kind): return false
 if (kind == "tracking" and tracking) or (kind == "factory" and local_factory) or (kind == "training" and has_role("trained")): return false
 if not spend(prices[kind]): return false
 match kind:
  "tracking": tracking = true
  "factory": local_factory = true
  "training": staff.append("trained")
 record({"tracking":"Tracking connects sensor scans to a dashboard and advance route notices. It does not move cargo or guarantee delivery.","factory":"Expanded existing Canadian assembly capacity by 15/day. $350/day overhead. Expansion alone does not prove vertical diversification.","training":"Trained existing employees: +4 internal research/day. To insource, move an externally performed task back to this team."}[kind])
 return true

func audit_stock() -> bool:
 if stock_error == 0:
  notice = "Stock records already match the physical count."
  return false
 if not spend(500): return false
 stock_error = 0
 record("Physical audit reconciled screen records, costing $500. Accurate records improve decisions; no new screens were created.")
 return true

func recorded_stock() -> Array: return [inventory[0],inventory[1]+stock_error,inventory[2]]
func capacity() -> int: return 30+(15 if local_factory else 0)+(5 if has_role("people") else 0)+(10 if overtime else 0)
func dispatched() -> int:
 var total = 0
 for delivery in outbound: total += delivery.quantity
 return total

func apply_event(kind: String):
 var message = ""
 match kind:
  "weather":
   route_delay_until = day+3
   for shipment in shipments:
    if shipment.supplier == 0 and shipment.mode == "ship" and shipment.stage == "travel":
     shipment.remaining += 2
     shipment.total += 2
   message = "STORM: Taipei sea cargo in transit and new sea orders gain 2 travel days through day %d. Air, domestic truck and other suppliers remain available. Stock buffers can protect customers." % route_delay_until
  "customs":
   border_delay_until = day+2
   for shipment in shipments:
    if shipment.stage == "border":
     shipment.remaining += 2
     shipment.total += 2
   message = "BORDER INSPECTION: cargo waiting at the border and overseas arrivals through day %d gain 2 clearance days. Already received stock is usable; NearWorks is domestic." % border_delay_until
  "records":
   stock_error = 60
   message = "DUPLICATE SCAN: recorded screens exceed physical screens by 60. The stock-alert rule reads the record; assembly still needs actual parts. Pay for a physical audit or plan from the physical count."
  "recall":
   var lost = mini(40,inventory[2])
   inventory[2] -= lost
   message = "BATTERY RECALL: quarantined %d batteries after a safety inspection. Replace parts to protect customers. Recorded stock updated; no loss of other components." % lost
  "demand":
   demand += 8
   message = "UNEXPECTED DEMAND: +8 orders/day. More orders do not create more parts, assembly capacity or delivery capacity."
 events_seen.append({"day":day,"kind":kind,"message":message})
 record(message)

func advance():
 if ended: return
 if day == 6:
  demand += 10
  record("Launch demand increases by 10 orders/day.")
 if day == 21:
  demand += 10
  record("Final launch rush: another 10 orders/day.")
 for event in event_plan:
  if int(event.day) == day: apply_event(event.kind)
 # Customer delivery is a separate stage from assembly and creates the sale receipt.
 var arrived = 0
 for i in range(outbound.size()-1,-1,-1):
  var delivery = outbound[i]
  delivery.remaining -= 1
  if delivery.remaining <= 0:
   arrived += delivery.quantity
   delivered += delivery.quantity
   cash += delivery.quantity*delivery.price
   outbound.remove_at(i)
 for i in range(shipments.size()-1,-1,-1):
  var shipment = shipments[i]
  shipment.remaining -= 1
  if shipment.remaining > 0: continue
  if shipment.stage == "travel" and shipment.supplier != 3:
   shipment.stage = "border"
   shipment.remaining = 1+(2 if day <= border_delay_until else 0)
   shipment.total = shipment.remaining
   continue
  var part = suppliers[shipment.supplier].part
  if part == -1:
   for j in range(3): inventory[j] += shipment.quantity
  else: inventory[part] += shipment.quantity
  shipments.remove_at(i)
 backlog += demand
 var available = mini(inventory[0],mini(inventory[1],inventory[2]))
 var effective_capacity = capacity() if wellbeing >= 45 else maxi(10,capacity()-15)
 var made = mini(backlog,mini(available,effective_capacity))
 for i in range(3): inventory[i] -= made
 backlog -= made
 if made > 0: outbound.append({"quantity":made,"remaining":1,"price":390 if upgraded else 340})
 var wages = 650+(350 if local_factory else 0)
 for c in candidates:
  if has_role(c.type): wages += c.salary
 if not upgraded: wages += RESEARCH_OPTIONS[research_mode].daily
 cash -= wages
 wellbeing = clampi(wellbeing+(3 if has_role("people") else 0)+(-6 if overtime else 1),0,100)
 research += research_rate()
 if research >= 100 and not upgraded:
  upgraded = true
  record("Nova 23 Pro released. New dispatches earn $390 instead of $340 per delivered phone. A product upgrade alone is not evidence of diversification.")
 if backlog+dispatched() > demand*2 and arrived < demand: trust = maxi(0,trust-4)
 elif arrived >= demand: trust = mini(100,trust+2)
 history.append({"day":day,"cash":cash,"delivered":delivered,"assembled":made,"arrived":arrived,"backlog":backlog,"trust":trust,"stock":inventory.duplicate(),"recorded":recorded_stock(),"research_mode":research_mode,"wellbeing":wellbeing})
 day += 1
 if cash < 0 or trust == 0 or day > 30:
  ended = true
  record("Campaign ended. Phones still in delivery do not count as received. Explain your choices in Report; a game score is not proof of understanding.")

func save_game(path: String = "user://campaign.json") -> Error:
 var data = {"version":2}
 for key in SAVE_KEYS: data[key] = get(key)
 var file = FileAccess.open(path,FileAccess.WRITE)
 if file == null: return FileAccess.get_open_error()
 file.store_string(JSON.stringify(data))
 return OK

func load_game(path: String = "user://campaign.json") -> bool:
 if not FileAccess.file_exists(path): return false
 var data = JSON.parse_string(FileAccess.get_file_as_string(path))
 if not data is Dictionary or data.get("version",0) != 2:
  notice = "This save uses an earlier campaign model. Start a new campaign."
  return false
 for key in SAVE_KEYS:
  if not data.has(key): return false
 # Validate basic shapes before replacing live state. Local saves contain no executable code.
 if not data.inventory is Array or data.inventory.size() != 3 or not data.shipments is Array or not data.outbound is Array or not data.answers is Dictionary or not data.reflections is Dictionary: return false
 if int(data.research_mode) < 0 or int(data.research_mode) > 3 or int(data.day) < 1 or int(data.day) > 31: return false
 for key in SAVE_KEYS: set(key,data[key])
 for i in range(inventory.size()): inventory[i] = int(inventory[i])
 for event in event_plan: event.day = int(event.day)
 for shipment in shipments:
  for field in ["supplier","remaining","total","quantity"]: shipment[field] = int(shipment[field])
 for delivery in outbound:
  for field in ["quantity","remaining","price"]: delivery[field] = int(delivery[field])
 return true
