extends Control
signal profile_selected(index: int)
const Market = preload("res://scripts/market.gd")
const INK = Color("e5f2ee")
const GOLD = Color("ffcf70")
const TEAL = Color("72e5c0")
var audience = Market.profiles()
var result = {}
var selected = -1
var time = 0.0
var reveal = 0.0
var animating = false
var font: Font

func _ready():
 font = ThemeDB.fallback_font
 mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func show_run(value: Dictionary):
 result = value
 reveal = 0.0
 animating = true

func _process(delta):
 time += delta
 if animating:
  reveal += delta * 5.0
  if reveal >= 20.0: animating = false
 queue_redraw()

func card_rect(i: int) -> Rect2:
 return Rect2(15 + (i % 5) * 185, 189 + (i / 5) * 72, 174, 63)

func _gui_input(event):
 if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
  for i in range(20):
   if card_rect(i).has_point(event.position):
    selected = i
    profile_selected.emit(i)
    accept_event()

func box(rect: Rect2, color: Color, radius: int = 10):
 var b = StyleBoxFlat.new()
 b.bg_color = color
 b.set_corner_radius_all(radius)
 draw_style_box(b,rect)

func text_at(value: String, at: Vector2, size_px: int = 16, color: Color = INK):
 draw_string(font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size_px,color)

func person(at: Vector2, color: Color, phase: float = 0.0):
 var bounce = sin(phase) * 1.8
 draw_circle(at+Vector2(0,-12+bounce),7,Color("f5cdac"))
 box(Rect2(at+Vector2(-9,-3+bounce),Vector2(18,18)),color,5)
 draw_line(at+Vector2(-4,14+bounce),at+Vector2(-6,22),Color("93a9bb"),4)
 draw_line(at+Vector2(4,14+bounce),at+Vector2(7,22),Color("93a9bb"),4)
 draw_line(at+Vector2(9,1+bounce),at+Vector2(15,10+bounce),Color("f5cdac"),3)

func icon(kind: int, at: Vector2, color: Color):
 if kind == 0:
  draw_arc(at,16,PI,TAU,20,color,4)
  box(Rect2(at+Vector2(-20,-2),Vector2(9,17)),color,3)
  box(Rect2(at+Vector2(11,-2),Vector2(9,17)),color,3)
 elif kind == 1:
  draw_arc(at+Vector2(-17,10),12,0,TAU,24,color,3)
  draw_arc(at+Vector2(17,10),12,0,TAU,24,color,3)
  draw_polyline(PackedVector2Array([at+Vector2(-17,10),at+Vector2(-5,-10),at+Vector2(8,10),at+Vector2(-17,10),at+Vector2(12,-9),at+Vector2(17,10)]),color,3)
 else:
  box(Rect2(at+Vector2(-25,-18),Vector2(50,34)),color,4)
  box(Rect2(at+Vector2(-21,-14),Vector2(42,25)),Color("112c39"),2)
  text_at("</>",at+Vector2(-15,4),17,TEAL)
  draw_line(at+Vector2(-30,20),at+Vector2(30,20),color,4)

func _draw():
 if font == null: return
 box(Rect2(Vector2.ZERO,size),Color("142d3a"),18)
 # A hand-drawn night market: awnings, pavement, street lamps and moving shoppers.
 for i in range(3):
  var x = 24 + i * 305
  box(Rect2(x,37,285,112),Color("213c47"),8)
  draw_colored_polygon(PackedVector2Array([Vector2(x-3,46),Vector2(x+20,15),Vector2(x+265,15),Vector2(x+288,46)]),[Color("ed9f72"),Color("76c8bd"),Color("a8a1e0")][i])
  for stripe in range(8):
   box(Rect2(x+stripe*36,45,34,14),Color("e8e2c8") if stripe%2==0 else [Color("cb7855"),Color("469e99"),Color("7e77b6")][i],2)
  icon(i,Vector2(x+43,103),GOLD)
  text_at(["SOUND SHELF","CYCLE CORNER","CODE STUDIO"][i],Vector2(x+80,86),19)
  text_at(["Headphones / music","Bicycles / cycling","Courses / coding"][i],Vector2(x+80,112),15,Color("a6c0c8"))
 draw_line(Vector2(20,167),Vector2(920,167),Color("3c5660"),3)
 for x in range(35,920,60): draw_line(Vector2(x,173),Vector2(x+25,173),Color("60727b"),2)
 text_at("20 FICTIONAL SHOPPERS / SELECT ANYONE TO INSPECT",Vector2(22,495),15,Color("9ab5bf"))
 if animating and not result.is_empty():
  for i in range(20):
   var progress = clampf((reveal-float(i)+2.0)/2.0,0.0,1.0)
   if result.results[i].served and progress>0.0 and progress<1.0:
    var source = Vector2(164+result.product*305,140)
    var destination = card_rect(i).position+Vector2(150,20)
    var flyer = source.lerp(destination,progress)
    flyer.y -= sin(progress*PI)*55.0
    box(Rect2(flyer-Vector2(11,7),Vector2(22,14)),GOLD,3)
    draw_line(flyer-Vector2(6,2),flyer+Vector2(6,2),Color("8d6c3c"),2)
 for i in range(20):
  var rect = card_rect(i)
  var p = audience[i]
  var r = result.results[i] if not result.is_empty() and float(i) <= reveal else {}
  var color = Color("203d4c")
  var status_text = "Inspect inputs"
  if not r.is_empty():
   if r.irrelevant: color = Color("6b483e");status_text = "Irrelevant ad"
   elif r.missed: color = Color("55516b");status_text = "Potential missed"
   elif r.served: color = Color("235d53");status_text = "Relevant ad"
   else: status_text = "Not shown"
  box(rect,color,9)
  if i == selected: draw_rect(rect.grow(2),GOLD,false,2)
  person(rect.position+Vector2(23,30),[Color("80bada"),Color("e4a08d"),Color("aa9ad6"),Color("9acb90")][i%4],time*2.0+i)
  text_at(p.id,rect.position+Vector2(45,21),17)
  text_at(status_text,rect.position+Vector2(45,43),13,Color("d2dedc"))
  if not r.is_empty() and r.served:
   var sparkle = 2.0 + sin(time*4+i)*1.0
   draw_circle(rect.position+Vector2(156,15),sparkle,GOLD)
   if r.clicked: text_at("+",rect.position+Vector2(148,47),20,TEAL)
   if r.purchased: draw_arc(rect.position+Vector2(156,37),11,0,TAU,24,GOLD,2)
