extends SceneTree
var failures=[]
func check(ok: bool,msg: String):
 if not ok:failures.append(msg);push_error(msg)
func find_button(n: Node,prefix: String) -> Button:
 if n is Button and n.text.begins_with(prefix):return n
 for c in n.get_children():
  var found=find_button(c,prefix)
  if found!=null:return found
 return null
func _initialize():call_deferred("run_test")
func run_test():
 var lessons=JSON.parse_string(FileAccess.get_file_as_string("res://assets/lessons.json"))
 var manifest=JSON.parse_string(FileAccess.get_file_as_string("res://assets/narration/manifest.json"))
 check(lessons.size()==11,"Eleven focused ideas")
 var total=0
 for i in range(lessons.size()):
  var l=lessons[i]
  check(l.parts.size()==3,"What/why/impact per idea")
  check(l.options.size()==2 and int(l.correct) in [0,1],"Optional question has valid evidence feedback")
  for j in range(3):
   var path="res://assets/narration/lesson-%02d-%d.wav" % [i,j]
   check(ResourceLoader.exists(path),"Recorded clip exists")
   var stream=load(path)
   check(stream is AudioStream and stream.get_length()>4,"Audio has real duration")
   check(l.parts[j].sha256_text()==manifest.clips[i*3+j].caption_sha256,"Audio transcript matches current caption")
   total+=1
 var s=load("res://main.tscn").instantiate();root.add_child(s);await process_frame
 check(not s.started,"Entry offers narration or silent reading")
 s.start_lesson(false)
 check(s.index==0 and s.phase==0 and not s.audio.playing,"Silent reading supported")
 check(find_button(s,"Optional question")==null,"No question before explanation")
 s.next_part();check(s.phase==1,"Next part reveals why")
 check(find_button(s,"Optional question")==null,"Why still precedes question")
 s.next_part();check(s.phase==2,"Impact follows why")
 check(find_button(s,"Optional question")!=null,"Optional check only after all parts revealed")
 s.open_check();check(s.checking,"Optional check opens")
 s.check_answer(int(lessons[0].correct));check(s.feedback.begins_with("Yes."),"Check explains rather than scores")
 s.next_idea();check(s.index==1 and s.phase==0 and not s.checking,"Question does not block next idea")
 s.sound=true;s.play_part();check(s.audio.playing,"Bundled narration plays")
 s.toggle_pause();check(s.paused and s.audio.stream_paused and s.visual.paused,"Pause affects voice and visual")
 s.toggle_pause();check(not s.paused and not s.audio.stream_paused,"Resume works")
 s.part_finished();check(s.phase==1,"Narration advances to why")
 s.part_finished();check(s.phase==2,"Narration advances to impact")
 s.part_finished();check(s.finished_part and s.index==1,"Wait at end of idea")
 s.toggle_sound();check(not s.sound and not s.audio.playing,"Sound can be disabled")
 for i in range(lessons.size()):
  s.index=i;s.phase=2;s.render();await process_frame
  check(find_button(s,"Optional question")!=null,"All ideas offer an optional check")
  s.next_idea()
 check(not s.started,"Lesson finishes without mandatory answers")
 print("Narrated lesson: %d clips, %d failures" % [total,failures.size()]);quit(1 if not failures.is_empty() else 0)
