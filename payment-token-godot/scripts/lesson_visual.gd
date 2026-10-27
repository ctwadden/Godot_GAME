extends Control
const ART=preload("res://assets/harbour.svg")
const INK=Color("e8f1f4")
const MUTED=Color("a6bacb")
const TEAL=Color("79dbcf")
const GOLD=Color("efc783")
var kind="currency"
var phase=0
var elapsed=0.0
var paused=false
var font: Font
func _ready():font=ThemeDB.fallback_font;mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(dt):
 if not paused:elapsed+=dt
 queue_redraw()
func box(rect: Rect2,color: Color):
 var b=StyleBoxFlat.new();b.bg_color=color;b.set_corner_radius_all(16);draw_style_box(b,rect)
func text(value: String,pos: Vector2,sz: int=25,color: Color=INK):
 draw_multiline_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,sz,-1,color)
func node(rect: Rect2,title: String,body: String,color: Color=Color("28435c")):
 box(rect,color);text(title,rect.position+Vector2(22,37),27,TEAL);text(body,rect.position+Vector2(22,84),25)
func arrow(a: Vector2,b: Vector2,active: bool=true):
 var c=TEAL if active else Color("677687")
 draw_line(a,b,c,4)
 var v=(b-a).normalized();var normal=Vector2(-v.y,v.x)
 draw_colored_polygon(PackedVector2Array([b,b-v*17+normal*9,b-v*17-normal*9]),c)
 if active:
  var t=fmod(elapsed*0.18,1.0)
  draw_circle(a.lerp(b,t),7,GOLD)
func person(at: Vector2):
 draw_circle(at+Vector2(0,-23),18,GOLD)
 box(Rect2(at+Vector2(-28,0),Vector2(56,65)),Color("719ab9"))
func book(at: Vector2):
 box(Rect2(at,Vector2(115,143)),Color("c17f64"));draw_line(at+Vector2(15,0),at+Vector2(15,143),GOLD,4)
 text("BOOK",at+Vector2(24,65),22);text("10 credits",at+Vector2(10,115),20)
func _draw():
 if font==null:return
 box(Rect2(Vector2.ZERO,size),Color("152b40"))
 match kind:
  "currency":
   text("ONE PRICE",Vector2(875,60),23,TEAL);book(Vector2(900,112))
   text("10 fictional credits",Vector2(846,310),32,GOLD)
   for i in range(3):
    node(Rect2(45,36+i*107,450,88),["Cash","Card","Account transfer"][i],"")
    arrow(Vector2(515,80+i*107),Vector2(820,190))
   text("PAYMENT METHODS",Vector2(55,365),21,MUTED)
  "cash":
   person(Vector2(170,147));text("CUSTOMER",Vector2(90,265),28)
   node(Rect2(895,105,330,175),"SHOP","Cashier checks cash")
   arrow(Vector2(270,175),Vector2(850,175))
   box(Rect2(520,125,210,100),Color("38745f"));text("10 credits",Vector2(542,186),31)
   text("Physical cash changes hands",Vector2(410,325),31,GOLD)
  "central":
   node(Rect2(35,103,330,180),"CUSTOMER ACCOUNT","20 -> 10 credits")
   node(Rect2(505,80,350,220),"PAYMENT PROVIDER","Checks authorization\nChecks funds\nUpdates ledger")
   node(Rect2(995,103,330,180),"SHOP ACCOUNT","0 -> 10 credits")
   arrow(Vector2(380,190),Vector2(480,190));arrow(Vector2(870,190),Vector2(970,190))
   text("Account records change; no physical note travels through the network.",Vector2(180,352),27,GOLD)
  "shared":
   text("THREE SHOPS / ONE COMMON VOUCHER RECORD",Vector2(65,54),27,TEAL)
   for i in range(3):
    var x=65+i*430
    var down=phase==2 and i==0
    node(Rect2(x,101,365,170),"SHOP "+["A","B","C"][i]+" / COMPUTER","Temporarily offline" if down else "Copy of voucher record\nChecks agreed rules",Color("55495e") if down else Color("28435c"))
    if i<2:arrow(Vector2(x+375,185),Vector2(x+415,185),not down)
   if phase==0:
    text("Which account holds the vouchers? Have they already been spent?",Vector2(180,320),28,GOLD)
    text("No single shop controls the common record alone.",Vector2(350,370),25,MUTED)
   elif phase==1:
    text("Check the transfer, then agree on the update.",Vector2(350,320),29,GOLD)
    text("2 of 3 approvals is an illustration, not a universal network rule.",Vector2(240,370),25,MUTED)
   else:
    text("Other sites may continue / coordination still has a cost.",Vector2(300,320),28,GOLD)
    text("A trusted central database can be simpler. Shared does not mean anonymous.",Vector2(170,370),25,MUTED)
  "crypto":
   node(Rect2(80,95,460,205),"DIGITAL ASSET","What is transferred",Color("36574e"))
   arrow(Vector2(560,192),Vector2(780,192))
   node(Rect2(805,95,470,205),"LEDGER ENTRY","Record of the transfer")
   text("Transferable does not mean accepted everywhere or stable in value.",Vector2(215,350),28,GOLD)
  "token":
   for i in range(3):
    var x=45+i*440
    box(Rect2(x,30,390,230),Color("28435c"));text("FOLDER "+["A","B","C"][i],Vector2(x+26,66),24,TEAL)
    if i==0 or phase>0:draw_texture_rect(ART,Rect2(x+68,82,250,166),false)
    else:text("Empty",Vector2(x+138,165),31,MUTED)
   text("ONE TOKEN ENTRY: CLASSROOM / 0001",Vector2(260,320),32,GOLD)
   text("Controller: Alias A" if phase<2 else "Controller: Alias B — same identifier",Vector2(430,362),25)
  "licence":
   node(Rect2(40,77,550,242),"TOKEN REGISTER","Controller: Alias A" if phase==0 else "Controller: Alias B\nIdentifier unchanged")
   node(Rect2(710,45,600,300),"FICTIONAL LICENCE L1","Classroom display with credit: YES\nCommercial reproduction: NO\nCreator keeps copyright",Color("36574e"))
   arrow(Vector2(610,195),Vector2(690,195),false)
   text("Changing token control does not change these permission terms.",Vector2(220,377),27,GOLD)
  "link":
   node(Rect2(40,80,390,185),"TOKEN RECORD","Image pointer remains")
   arrow(Vector2(448,175),Vector2(890,175),phase==0)
   node(Rect2(910,80,390,185),"EXTERNAL HOST","Available" if phase==0 else "Unavailable",Color("28435c") if phase==0 else Color("664a4f"))
   if phase>0:text("X",Vector2(650,190),49,GOLD)
   text("Existing local copies can remain.",Vector2(448,330),31,TEAL)
   text("A pointer to an image is not the image itself.",Vector2(390,372),26,MUTED)
  "access":
   var names=["ACCOUNT + PHONE","NO ACCEPTED ACCOUNT","PHONE BATTERY FLAT","NEEDS ACCESSIBLE UI"]
   for i in range(4):
    var x=37+i*332
    box(Rect2(x,55,310,260),Color("28435c"));person(Vector2(x+151,130))
    text(names[i],Vector2(x+16,232),19,TEAL)
    text(["Route available","Account barrier","Device barrier","Interface barrier"][i],Vector2(x+26,276),23)
   text("Different barriers need different responses.",Vector2(385,369),31,GOLD)
  "micro":
   text("STATIC WORKSHEET / FAKE DOLLARS",Vector2(50,55),25,TEAL)
   for i in range(5):
    var x=47+i*266
    node(Rect2(x,104,242,158),"ITEM "+str(i+1),"$2 each")
    text("Total $"+str((i+1)*2),Vector2(x+45,307),28,GOLD)
   text("5 x $2 = $10",Vector2(545,367),36)
  "trading":
   node(Rect2(35,85,395,220),"ACCESS","Who can participate?")
   node(Rect2(485,85,395,220),"PLATFORM POWER","Who sets restrictions?")
   node(Rect2(935,85,395,220),"FINANCIAL RISK","Who can lose money?")
   text("Analyse the chapter's historical case. This is not a price prediction.",Vector2(225,363),28,GOLD)
