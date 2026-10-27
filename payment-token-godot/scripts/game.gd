extends Control
const Visual=preload("res://scripts/lesson_visual.gd")
const PHASES=["WHAT HAPPENS","WHY IT HAPPENS","THE IMPACT"]
const INK=Color("e8f1f4")
const MUTED=Color("a6bacb")
const TEAL=Color("79dbcf")
const GOLD=Color("efc783")
var lessons: Array=[]
var index=0
var phase=0
var started=false
var sound=true
var paused=false
var finished_part=false
var checking=false
var feedback=""
var audio: AudioStreamPlayer
var screen: Control
var visual: Control
var status: Label
var elapsed_bar: ProgressBar
var pause_button: Button
var missing_audio=false
func _ready():
 lessons=JSON.parse_string(FileAccess.get_file_as_string("res://assets/lessons.json"))
 audio=AudioStreamPlayer.new();add_child(audio);audio.finished.connect(part_finished)
 DisplayServer.window_set_title("Payments & Tokens — One Idea at a Time")
 render()
func style(color: Color) -> StyleBoxFlat:
 var s=StyleBoxFlat.new();s.bg_color=color;s.set_corner_radius_all(12);s.content_margin_left=18;s.content_margin_right=18;s.content_margin_top=10;s.content_margin_bottom=10;return s
func label(value: String,pos: Vector2,extent: Vector2,sz: int=24,color: Color=INK) -> Label:
 var l=Label.new();l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.text=value;l.add_theme_font_size_override("font_size",sz);l.add_theme_color_override("font_color",color);screen.add_child(l);l.position=pos;l.size=extent;return l
func button(value: String,pos: Vector2,extent: Vector2,action: Callable,accent: bool=false) -> Button:
 var b=Button.new();b.text=value;b.position=pos;b.size=extent;b.add_theme_font_size_override("font_size",19)
 b.add_theme_stylebox_override("normal",style(TEAL if accent else Color("29465f")));b.add_theme_stylebox_override("hover",style(Color("acecdd") if accent else Color("41647b")))
 b.add_theme_color_override("font_color",Color("112e35") if accent else INK);b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND;b.pressed.connect(action);screen.add_child(b);return b
func render():
 if screen!=null:remove_child(screen);screen.queue_free()
 screen=Control.new();screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(screen)
 label("PAYMENTS & TOKENS",Vector2(40,22),Vector2(1000,45),31,TEAL)
 if not started:render_start();return
 var lesson=lessons[index]
 label("IDEA %d OF %d  /  %s" % [index+1,lessons.size(),lesson.title],Vector2(40,79),Vector2(1360,62),31)
 for i in range(3):
  var mark=Label.new();mark.text=("• " if i<=phase else "- ")+PHASES[i];mark.position=Vector2(47+i*453,142);mark.size=Vector2(440,27)
  mark.add_theme_font_size_override("font_size",16);mark.add_theme_color_override("font_color",TEAL if i==phase else MUTED);screen.add_child(mark)
 visual=Visual.new();visual.kind=lesson.visual;visual.phase=phase;visual.position=Vector2(40,184);visual.size=Vector2(1360,400);visual.paused=paused;screen.add_child(visual)
 if checking:render_check();return
 label(PHASES[phase],Vector2(48,607),Vector2(1350,34),21,TEAL)
 label(lesson.parts[phase],Vector2(48,649),Vector2(1335,122),26)
 pause_button=button("Resume" if paused else "Pause",Vector2(40,795),Vector2(130,48),toggle_pause)
 button("Replay",Vector2(185,795),Vector2(125,48),replay)
 button("Sound: on" if sound else "Sound: off",Vector2(325,795),Vector2(165,48),toggle_sound)
 button("Back",Vector2(830,795),Vector2(115,48),go_back).disabled=index==0 and phase==0
 if phase<2:button("Next part",Vector2(960,795),Vector2(190,48),next_part,true)
 else:
  if not sound or finished_part:button("Optional question",Vector2(510,795),Vector2(220,48),open_check)
  button("Next idea" if index<lessons.size()-1 else "Finish lesson",Vector2(960,795),Vector2(280,48),next_idea,true)
 elapsed_bar=ProgressBar.new();elapsed_bar.position=Vector2(40,855);elapsed_bar.size=Vector2(1360,8);elapsed_bar.show_percentage=false;screen.add_child(elapsed_bar)
 status=label("",Vector2(42,873),Vector2(1355,22),14,MUTED)
 update_status()
func render_start():
 label("One idea at a time.",Vector2(65,130),Vector2(1300,70),48)
 label("Watch a visual explanation. Listen or read.\nFirst: what happens. Then: why. Finally: the impact.",Vector2(65,235),Vector2(1260,140),31)
 label("No dashboard to operate. No purchases or trading.\nQuestions are optional and appear after the explanation.",Vector2(65,420),Vector2(1250,110),27,MUTED)
 button("Start with narration",Vector2(65,595),Vector2(425,68),func():start_lesson(true),true)
 button("Read without sound",Vector2(515,595),Vector2(390,68),func():start_lesson(false))
 label("Recorded synthetic narration is included. No microphone, account or live AI connection.\nChapter 4.2C, pp.223–225 / fictional values and licence / not financial or legal advice.",Vector2(65,735),Vector2(1300,90),19,MUTED)
func start_lesson(with_sound: bool):
 started=true;index=0;phase=0;sound=with_sound;paused=false;checking=false;feedback="";play_part()
func play_part():
 audio.stop();audio.stream_paused=false;paused=false;finished_part=false;missing_audio=false;checking=false
 var path="res://assets/narration/lesson-%02d-%d.wav" % [index,phase]
 if ResourceLoader.exists(path):audio.stream=load(path)
 else:audio.stream=null;missing_audio=true
 render()
 if sound and audio.stream!=null:audio.play()
func _process(_dt):
 if started and not checking and status!=null:
  update_status()
  if elapsed_bar!=null and audio.stream!=null:
   elapsed_bar.value=100.0 if finished_part else 100.0*audio.get_playback_position()/maxf(audio.stream.get_length(),0.1)
func update_status():
 if status==null:return
 if pause_button!=null:pause_button.disabled=not sound or finished_part or missing_audio
 if missing_audio:status.text="Audio unavailable: all narration remains on screen. Use Next part to read."
 elif not sound:status.text="Silent reading / use Next part. Questions are optional after the impact."
 elif finished_part:status.text="Explanation complete. Continue to the next idea, replay, or try the optional question."
 elif paused:status.text="Paused / visual and narration paused together."
 else:status.text="Narration playing / the next part follows automatically. Each new idea waits for you."
func part_finished():
 if not started or checking or paused:return
 if phase<2:
  phase+=1;play_part()
 else:
  finished_part=true;render()
func toggle_pause():
 if not sound or audio.stream==null or finished_part:return
 paused=not paused;audio.stream_paused=paused
 if visual!=null:visual.paused=paused
 if pause_button!=null:pause_button.text="Resume" if paused else "Pause"
 update_status()
func toggle_sound():
 sound=not sound
 if sound:play_part()
 else:audio.stop();paused=false;render()
func replay():play_part()
func next_part():
 if phase<2:phase+=1;play_part()
func go_back():
 if phase>0:phase-=1
 elif index>0:index-=1;phase=2
 play_part()
func next_idea():
 audio.stop()
 if index<lessons.size()-1:index+=1;phase=0;play_part()
 else:
  started=false;render();label("Lesson complete. Explain one distinction and one impact in your own words.",Vector2(65,675),Vector2(1300,44),24,TEAL)
func open_check():
 if phase!=2:return
 audio.stop();checking=true;feedback="";render()
func render_check():
 var lesson=lessons[index]
 label("OPTIONAL / CHECK YOUR UNDERSTANDING",Vector2(48,607),Vector2(1340,32),20,TEAL)
 label(lesson.question,Vector2(48,646),Vector2(1335,65),25)
 for i in range(2):
  var answer=i
  button(lesson.options[i],Vector2(48,727+i*51),Vector2(1240,46),func():check_answer(answer))
 button("Continue without answering",Vector2(950,835),Vector2(400,45),next_idea)
func check_answer(choice: int):
 feedback=("Yes. " if choice==int(lessons[index].correct) else "Reconsider. ")+lessons[index].feedback
 audio.stop();render()
 for child in screen.get_children():
  if child is Button and child.position.y in [727.0,778.0]:child.disabled=true
 # Replace the question and choices with explanation rather than a score.
 for child in screen.get_children():
  if child is Control and child.position.y>=646 and child.position.y<830:child.hide()
 label(feedback,Vector2(48,646),Vector2(1320,160),27,TEAL)
