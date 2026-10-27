extends RefCounted
const PRICE = 1000 # Integer hundredths of fictional credits.
const ROUTES = ["Cash handover", "Central mobile ledger", "Simplified shared ledger"]
const POLICIES = ["Cash only", "Digital only", "Mixed: digital + cash fallback"]
const OUTAGES = ["Normal operation", "Central connection down", "Shared connection down", "Shop internet down (both digital routes)", "Shared node A down", "Shared nodes A+B down"]
const CUSTOMERS = [
 {"id":"P01","label":"Banked / reliable internet","account":true,"phone":true,"cash":true,"shared":true,"accessible":false,"detail":"Has central account, charged phone, shared-demo access and 10 FC cash."},
 {"id":"P02","label":"No bank account","account":false,"phone":true,"cash":true,"shared":true,"accessible":false,"detail":"No central account. Has charged phone, explicitly provisioned shared-demo access and 10 FC cash. These are separate conditions."},
 {"id":"P03","label":"Phone battery flat","account":true,"phone":false,"cash":true,"shared":true,"accessible":false,"detail":"Has central account and shared-demo access, but phone is flat. Carries 10 FC cash. Physical cards/offline terminals are outside this model."},
 {"id":"P04","label":"Needs accessible interface","account":true,"phone":true,"cash":false,"shared":true,"accessible":true,"detail":"Needs keyboard + large-text support at the fictional terminal. Has account, charged phone and shared access, but brought no cash."}
]
const FEES = [0,10,20]
const TIMES = [18,4,7]
const WORK = [2,1,1]
const TOKEN_ID = "CLASS-LAB / 0001"
const IMAGE_PATH = "res://assets/harbour-source.txt"

static func image_bytes() -> PackedByteArray:
 return FileAccess.get_file_as_bytes(IMAGE_PATH)
const LICENCE = "FICTIONAL LICENCE L1 / Cedar Studio retains copyright. All three classroom users may store a copy and display it in this classroom with credit to Cedar Studio. Commercial reproduction is not permitted by this licence. Token control gives no additional image-use rights. These terms stay unchanged when token control changes. This is a teaching example, not a legal instrument."

static func fingerprint(data: PackedByteArray) -> String:
 var context=HashingContext.new()
 context.start(HashingContext.HASH_SHA256)
 context.update(data)
 return context.finish().hex_encode()

static func fc(value: int) -> String:
 return "%.2f FC" % (float(value)/100.0)

static func route_check(person: Dictionary, route: int, outage: int, accessible: bool) -> Dictionary:
 var why = "Ready under the stated assumptions."
 if route == 0:
  if not person.cash: return {"ok":false,"why":"No cash carried. Cash does not require internet or this phone."}
  return {"ok":true,"why":"Has cash; cashier checks amount and change manually. No internet needed."}
 if person.accessible and not accessible:
  return {"ok":false,"why":"This fictional terminal lacks the required keyboard/large-text support. The game's own controls remain usable."}
 if not person.phone:
  return {"ok":false,"why":"Phone flat. Both digital routes HERE are phone-dependent; this does not describe all digital payment methods."}
 if route == 1:
  if not person.account: return {"ok":false,"why":"No central account for this route. Having a phone is not the same as having an account."}
  if outage in [1,3]: return {"ok":false,"why":"Central connection unavailable. No debit or record is committed."}
 else:
  if not person.shared: return {"ok":false,"why":"No shared-demo access provisioned."}
  if outage in [2,3]: return {"ok":false,"why":"Shared route connection unavailable. No debit or record is committed."}
  if outage == 5: return {"ok":false,"why":"Only 1 of 3 validator nodes available; this toy rule requires 2. No commit."}
  if outage == 4: why = "2 of 3 nodes available; the toy 2-of-3 validation rule still commits."
 return {"ok":true,"why":why}

static func trace(person: Dictionary, route: int, ok: bool) -> Dictionary:
 var info = {
  "currency":"Fictional credits (FC), same unit on every route",
  "verifier":["Cashier checks physical amount and change","Central provider checks simulated credential, balance and transfer sequence","Available validator nodes check simulated authorization, balance and sequence; 2 of 3 must agree"][route],
  "infrastructure":["Cash, change, cashier and secure handling; optional receipt book","Charged customer phone, central account, accessible terminal as needed, shop link and central provider","Charged phone, separate shared-demo access, accessible terminal as needed, shared link and at least 2 of 3 nodes"][route],
  "visibility":["Optional shop receipt records amount and time, without customer identity","Private provider stores account-linked record; class sees only sanitized aliases","Authorized demo nodes share alias-linked records; this is not automatic public broadcasting"][route],
  "fields":[],"customer_before":2000,"customer_after":2000,"shop_before":10000,"shop_after":10000,"provider_after":0,
  "fee":0,"seconds":0,"work":0,"committed":ok,"balance_exists":true
 }
 if route==0:
  info.customer_before=1000 if person.cash else 0;info.customer_after=info.customer_before
  info.balance_exists=person.cash
 elif route==1 and not person.account:
  info.customer_before=0;info.customer_after=0;info.balance_exists=false
 elif route==2 and not person.shared:
  info.customer_before=0;info.customer_after=0;info.balance_exists=false
 if ok:
  info.customer_after -= PRICE
  info.shop_after += PRICE-FEES[route]
  info.provider_after = FEES[route]
  info.fee=FEES[route];info.seconds=TIMES[route];info.work=WORK[route]
  if route==0: info.fields=["receipt R-CASH","amount 10 FC","time slot T1"]
  else: info.fields=["record R-DEMO","from alias "+person.id,"to alias SHOP","amount 10 FC","sequence 1","verification accepted"]
 return info

static func run(policy: int, digital: int, outage: int, accessible: bool) -> Dictionary:
 assert(policy in [0,1,2] and digital in [1,2] and outage>=0 and outage<OUTAGES.size())
 var rows=[]
 var totals={"access":0,"fee":0,"seconds":0,"work":0,"setup_work":[1,2,3][policy]}
 for p in CUSTOMERS:
  var cash=route_check(p,0,outage,accessible)
  var electronic=route_check(p,digital,outage,accessible)
  var route=0 if policy==0 else digital
  var status=cash if policy==0 else electronic
  var fallback=false
  if policy==2 and not electronic.ok and cash.ok:
   route=0;status=cash;fallback=true
  var t=trace(p,route,status.ok)
  rows.append({"id":p.id,"ok":status.ok,"route":route,"why":status.why,"digital_why":electronic.why,"fallback":fallback,"trace":t})
  if status.ok:
   totals.access+=1;totals.fee+=t.fee;totals.seconds+=t.seconds;totals.work+=t.work
 return {"policy":policy,"digital":digital,"outage":outage,"accessible":accessible,"rows":rows,"totals":totals}

static func new_token() -> Dictionary:
 return {"id":TOKEN_ID,"controller":"Alias A","copies":[image_bytes(),PackedByteArray(),PackedByteArray()],"licence":LICENCE,"host_up":true,"history":["Record 1: control assigned to Alias A"],"media_pointer":"https://media.example.invalid/harbour.svg"}

static func copy_image(state: Dictionary):
 for i in range(3): state.copies[i]=image_bytes()

static func transfer_token(state: Dictionary, controller: String):
 assert(controller in ["Alias A","Alias B","Alias C"])
 if controller==state.controller: return
 state.controller=controller
 state.history.append("Record %d: control -> %s" % [state.history.size()+1,controller])

static func token_facts(state: Dictionary) -> Dictionary:
 return {"copies":state.copies.filter(func(s):return not s.is_empty()).size(),"registry_entries":1,"token_id":state.id,"controller":state.controller,"display_permitted":true,"commercial_permitted":false,"copyright_holder":"Cedar Studio","remote_available":state.host_up,"local_available":not state.copies[0].is_empty()}
