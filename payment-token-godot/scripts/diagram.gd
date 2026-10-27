extends Control
const Lab=preload("res://scripts/lab.gd")
const ART=preload("res://assets/harbour.svg")
const INK=Color("e8f1f4")
const MUTED=Color("a6bacb")
const CYAN=Color("79dbcf")
const AMBER=Color("efc783")
var section="access"
var result={}
var token={}
var phase=0.0
var font: Font
func _ready(): font=ThemeDB.fallback_font;mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(dt):phase+=dt;queue_redraw()
func box(r: Rect2,color: Color):
 var s=StyleBoxFlat.new();s.bg_color=color;s.set_corner_radius_all(12);draw_style_box(s,r)
func txt(s: String,p: Vector2,sz: int=17,c: Color=INK):draw_string(font,p,s,HORIZONTAL_ALIGNMENT_LEFT,-1,sz,c)
func person(p: Vector2):
 draw_circle(p+Vector2(0,-12),9,AMBER)
 box(Rect2(p+Vector2(-13,0),Vector2(26,27)),Color("6b97b5"))
func line(a: Vector2,b: Vector2,up: bool):
 draw_line(a,b,CYAN if up else Color("795f70"),3)
 if up:draw_circle(a.lerp(b,fmod(phase*0.22,1.0)),5,CYAN)
 else:
  var mid=(a+b)*0.5
  draw_line(mid-Vector2(7,7),mid+Vector2(7,7),AMBER,3)
  draw_line(mid+Vector2(-7,7),mid+Vector2(7,-7),AMBER,3)
func _draw():
 if font==null:return
 box(Rect2(Vector2.ZERO,size),Color("172b40"))
 if section=="access":draw_access()
 else:draw_token()
func draw_access():
 txt("SAME CURRENCY: FICTIONAL CREDITS (FC) / DIFFERENT ROUTES",Vector2(22,31),19,CYAN)
 txt("Lines show route connectivity; moving dots illustrate paths, not simultaneous committed payments.",Vector2(22,52),13,MUTED)
 var outage=result.outage if not result.is_empty() else 0
 for route in range(3):
  var y=86+route*101
  txt(["CASH","CENTRAL LEDGER","SHARED LEDGER"][route],Vector2(24,y-14),16,AMBER)
  person(Vector2(61,y+11))
  var up=not (route==1 and outage in [1,3] or route==2 and outage in [2,3,5])
  line(Vector2(95,y+14),Vector2(302,y+14),up)
  if route==0:
   box(Rect2(315,y-14,158,57),Color("374b5e"));txt("Cashier",Vector2(348,y+9),20);txt("checks cash",Vector2(336,y+29),15,MUTED)
   line(Vector2(485,y+14),Vector2(665,y+14),true)
   box(Rect2(678,y-14,221,57),Color("294651"));txt("Shop / optional receipt",Vector2(695,y+9),17);txt("amount + time; no identity",Vector2(692,y+29),15,MUTED)
  elif route==1:
   box(Rect2(315,y-14,250,57),Color("374b5e"));txt("Central provider",Vector2(345,y+9),20);txt("credentials / balance / sequence",Vector2(328,y+29),15,MUTED)
   line(Vector2(577,y+14),Vector2(665,y+14),up)
   box(Rect2(678,y-14,221,57),Color("294651"));txt("Private account record",Vector2(695,y+9),17);txt("Class sees sanitized aliases",Vector2(692,y+29),15,MUTED)
  else:
   for i in range(3):
    var alive=not (outage==4 and i==0 or outage==5 and i<2)
    box(Rect2(315+i*84,y-16,76,61),Color("2c6262") if alive else Color("5d4558"))
    txt("Node "+["A","B","C"][i],Vector2(324+i*84,y+8),15)
    txt("up" if alive else "down",Vector2(334+i*84,y+29),14)
   line(Vector2(577,y+14),Vector2(665,y+14),up)
   box(Rect2(678,y-14,221,57),Color("294651"));txt("Shared alias record",Vector2(699,y+9),18);txt("Toy quorum: 2 of 3 agree",Vector2(696,y+29),15,MUTED)
 txt("INDEPENDENT CUSTOMER CASES / EACH REQUEST IS 10 FC",Vector2(22,381),17,CYAN)
 for i in range(4):
  var p=Lab.CUSTOMERS[i]
  var row={} if result.is_empty() else result.rows[i]
  box(Rect2(20+i*230,398,219,96),Color("254a4d") if not row.is_empty() and row.ok else Color("303b51"))
  txt(p.id,Vector2(33+i*230,423),20)
  txt(["Banked + online","No bank account","Phone battery flat","Accessible interface"][i],Vector2(33+i*230,447),15,MUTED)
  txt("Not run" if row.is_empty() else ("CAN PAY / "+["cash","central","shared"][row.route] if row.ok else "CANNOT PAY"),Vector2(33+i*230,476),15,CYAN if not row.is_empty() and row.ok else AMBER)
func draw_token():
 txt("IMAGE BYTES / TOKEN RECORD / LICENCE ARE SEPARATE EVIDENCE",Vector2(22,32),19,CYAN)
 for i in range(3):
  var x=23+i*302
  var has_copy=not token.copies[i].is_empty()
  box(Rect2(x,62,282,220),Color("243e55"))
  txt("VIRTUAL FOLDER "+["A","B","C"][i],Vector2(x+16,91),18,AMBER)
  if has_copy:
   draw_texture_rect(ART,Rect2(x+32,108,218,145),false)
   txt("harbour.svg / same bytes",Vector2(x+26,272),15,MUTED)
  else:
   txt("No local copy yet",Vector2(x+50,178),20,MUTED)
 box(Rect2(23,301,432,121),Color("254a4d"))
 txt("ONE REGISTRY ENTRY",Vector2(40,330),17,CYAN)
 txt(token.id,Vector2(40,358),25)
 txt("Controller: "+token.controller,Vector2(40,389),20,AMBER)
 box(Rect2(480,301,430,121),Color("243e55"))
 txt("EXTERNAL MEDIA POINTER / SIMULATED",Vector2(496,330),16,CYAN)
 txt("Remote preview available" if token.host_up else "REMOTE LINK BROKEN",Vector2(496,361),22,INK if token.host_up else AMBER)
 txt("Local copies remain; no network request is made.",Vector2(496,392),15,MUTED)
 txt("LICENCE L1: classroom display with credit; no commercial reproduction.",Vector2(24,459),19,AMBER)
 txt("Creator keeps copyright. Changing the controller leaves these terms unchanged.",Vector2(24,490),17,MUTED)
