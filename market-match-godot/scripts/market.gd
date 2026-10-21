extends RefCounted

const TOPICS = ["music", "cycling", "coding", "design"]
const PRODUCTS = ["Studio headphones", "City bicycle", "Coding course"]
const POLICIES = ["Broad campaign", "Contextual advertising", "Consented interest targeting"]
const TRANSACTIONS = [
 {"item":"Workshop equipment", "seller":"ForgeWorks Manufacturing Ltd", "buyer":"BrightLearn Schools Ltd / business office", "parties":"Business → business", "answer":0, "why":"B2B: a manufacturer sells equipment to an education business. This fictional school purchaser is explicitly a business; do not assume every school is one."},
 {"item":"Headphones", "seller":"Sound Shelf shop", "buyer":"A household / personal use", "parties":"Business → consumer", "answer":1, "why":"B2C: the shop is a business and the household buys for personal use. The marketplace is the intermediary, not the item seller."},
 {"item":"Used bicycle", "seller":"An individual / personal bicycle", "buyer":"Another individual / personal use", "parties":"Consumer → consumer", "answer":2, "why":"C2C: two individuals exchange a personal item. A professional reseller would need a different classification. Being on a platform does not make every sale C2C."}
]

static func profiles() -> Array:
 var rows = []
 for i in range(20):
  var actual = TOPICS[i % 4]
  var observed = TOPICS[(i + 1) % 4] if i % 5 == 0 else actual
  rows.append({"id":"P%02d" % (i+1), "declared":[actual], "page":TOPICS[(i + (1 if i % 3 == 0 else 0)) % 4], "consent":i % 3 != 2, "events":[observed,observed,TOPICS[(i+2)%4]], "note":""})
 rows[3] = {"id":"P04", "declared":["cycling"], "page":"cycling", "consent":true, "events":["music","music","design"], "note":"Gift research! Music browsing does not describe this person's own declared interest in cycling."}
 rows[8] = {"id":"P09", "declared":["music"], "page":"music", "consent":false, "events":["music","music","coding"], "note":"Refuses browsing targeting, but is on a music page. Contextual matching is still available."}
 return rows

static func hash_text(value: String) -> int:
 var h = 2166136261
 for byte in value.to_utf8_buffer():
  h = ((h ^ int(byte)) * 16777619) & 0xffffffff
 return h

static func draw_value(seed: int, id: String, product: int, kind: String) -> float:
 var keys = ["headphones", "bicycle", "course"]
 return float(hash_text("%d:%s:%s:%s" % [seed,id,keys[product],kind])) / 4294967296.0

static func infer(p: Dictionary) -> Dictionary:
 var counts = [0,0,0,0]
 for event in p.events:
  if event != "": counts[TOPICS.find(event)] += 1
 var best = 0
 for i in range(1,4):
  if counts[i] > counts[best]: best = i
 return {"topic":TOPICS[best], "score":counts[best]}

static func run(audience: Array, product: int, policy: int, slots: int = 10, seed: int = 23) -> Dictionary:
 assert(product >= 0 and product < 3 and policy >= 0 and policy < 3)
 assert(slots > 0 and slots <= 20 and seed >= 1 and seed <= 9999)
 var target = TOPICS[product]
 var results = []
 var metrics = {"eligible":0,"served":0,"relevant":0,"missed":0,"irrelevant":0,"clicks":0,"purchases":0,"consent_fields":0,"browsing_fields":0,"page_fields":0,"fields":0}
 for p in audience:
  var eligible = false
  var inference = {}
  var fields = []
  var reason = ""
  if policy == 0:
   eligible = true
   reason = "Broad: all profiles eligible. No topic or consent inputs used for matching."
  elif policy == 1:
   fields.append("current page topic: " + p.page)
   metrics.page_fields += 1
   eligible = p.page == target
   reason = "Page topic %s %s product topic %s. No browsing history used." % [p.page,"matches" if eligible else "does not match",target]
  else:
   fields.append("targeting consent: " + str(p.consent))
   metrics.consent_fields += 1
   if not p.consent:
    reason = "Consent refused. Browsing topics not read. Not eligible under this policy."
   else:
    for i in range(p.events.size()):
     if p.events[i] != "":
      fields.append("E%d topic: %s" % [i+1,p.events[i]])
      metrics.browsing_fields += 1
    inference = infer(p)
    eligible = inference.topic == target and inference.score >= 2
    reason = "Most frequent topic = %s (%d events). Need %s and at least 2 events: %s." % [inference.topic,inference.score,target,"eligible" if eligible else "not eligible"]
  results.append({"id":p.id,"eligible":eligible,"inference":inference,"fields":fields,"reason":reason,"queue":hash_text("%d:%s:queue" % [seed,p.id]),"relevant":target in p.declared,"served":false,"rank":0,"click_draw":draw_value(seed,p.id,product,"click"),"purchase_draw":draw_value(seed,p.id,product,"purchase")})
 var ranked = results.filter(func(r): return r.eligible)
 ranked.sort_custom(func(a,b):
  if policy == 2 and a.inference.score != b.inference.score: return a.inference.score > b.inference.score
  return a.queue < b.queue if a.queue != b.queue else a.id < b.id)
 for i in range(ranked.size()):
  ranked[i].rank = i + 1
  ranked[i].served = i < slots
 for r in results:
  r.click_probability = 0.55 if r.relevant else 0.12
  r.clicked = r.served and r.click_draw < r.click_probability
  r.purchased = r.clicked and r.purchase_draw < 0.30
  r.missed = r.relevant and not r.served
  r.irrelevant = r.served and not r.relevant
  if r.eligible: r.reason += " Queue rank %d / %d slots: %s." % [r.rank,slots,"shown" if r.served else "missed slot limit"]
  for key in ["eligible","served","missed","irrelevant"]:
   if r[key]: metrics[key] += 1
  if r.served and r.relevant: metrics.relevant += 1
  if r.clicked: metrics.clicks += 1
  if r.purchased: metrics.purchases += 1
 metrics.fields = metrics.consent_fields + metrics.browsing_fields + metrics.page_fields
 return {"product":product,"policy":policy,"slots":slots,"seed":seed,"audience":audience.duplicate(true),"results":results,"metrics":metrics}

static func comparison(a: Dictionary, b: Dictionary) -> String:
 var same_conditions = a.product == b.product and a.slots == b.slots and a.seed == b.seed
 if same_conditions and a.audience == b.audience:
  return "policy" if a.policy != b.policy else "repeat"
 if same_conditions and a.policy == b.policy: return "input"
 return "mixed"
