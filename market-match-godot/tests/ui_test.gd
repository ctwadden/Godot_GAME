extends SceneTree
var failures=[]
func check(ok: bool,message: String):
 if not ok:failures.append(message);push_error(message)
func find_button(n: Node, prefix: String) -> Button:
 if n is Button and n.text.begins_with(prefix):return n
 for child in n.get_children():
  var b=find_button(child,prefix)
  if b!=null:return b
 return null
func press(n: Node,prefix: String):
 var b=find_button(n,prefix)
 check(b!=null,"Button exists: "+prefix)
 if b!=null:
  check(not b.disabled,"Button enabled: "+prefix)
  if not b.disabled:b.pressed.emit()
func _initialize():call_deferred("run_test")
func run_test():
 var scene=load("res://main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 check(scene.page=="welcome","Menu default")
 press(scene,"Start student game")
 await process_frame
 check(scene.page=="transactions","Student begins with transactions")
 press(scene,"C2C")
 check(scene.task==0 and scene.choice==2,"Wrong answer retains task")
 press(scene,"B2B");press(scene,"Continue")
 press(scene,"B2C");press(scene,"Continue")
 press(scene,"C2C");press(scene,"Continue")
 press(scene,"Connects");press(scene,"Continue")
 press(scene,"Processes");press(scene,"Open my marketplace")
 await process_frame
 check(scene.page=="lab","All five tasks unlock marketplace")
 scene.launch()
 check(scene.runs.is_empty(),"Predictions required")
 if scene.popup!=null:scene.popup.hide()
 scene.prediction_relevance=2;scene.prediction_reach=1
 press(scene,"Launch campaign")
 check(scene.runs.size()==1 and scene.current_run.metrics.served==10,"Actual launch runs model")
 check(scene.prediction_relevance==0 and scene.prediction_reach==0,"Clear predictions")
 scene.policy=2;scene.prediction_relevance=1;scene.prediction_reach=2
 scene.launch()
 check(scene.has_policy_comparison(),"Controlled pair enables reflection")
 scene.show_profile(3)
 await process_frame
 press(scene.popup,"Delete E1")
 check(scene.audience[3].events[0]=="","UI deletion removes topic")
 check(scene.current_run.audience[3].events[0]=="music","Current result retains historical snapshot")
 if scene.popup!=null:scene.popup.hide()
 scene.pinned=scene.current_run
 scene.prediction_relevance=1;scene.prediction_reach=2;scene.launch()
 check(not scene.current_run.results[3].eligible,"Rerun updates deleted event consequence")
 check(scene.Market.comparison(scene.pinned,scene.current_run)=="input","UI comparison tracks input change")
 scene.page="reflect";scene.render()
 await process_frame
 var edits=scene.find_children("*","TextEdit",true,false)
 check(edits.size()==4,"Four evidence fields")
 edits[0].text="P04 music browsing was gift research.";edits[0].text_changed.emit()
 scene.render()
 check(scene.reflections[0].contains("gift research"),"Reflection retained on render")
 var report=scene.report_text()
 check(report.contains("gift research") and report.contains("EXPERIMENT SNAPSHOTS"),"Report contains evidence and audit")
 scene.start("demo")
 for i in range(5):scene.demo_next()
 check(scene.page=="lab" and scene.runs.size()==4,"Demo runs four campaigns")
 check(scene.current_run.metrics.served==4 and scene.audience[3].events[0]=="","Authored input-change example consistent")
 check(scene.Market.comparison(scene.pinned,scene.current_run)=="input","Demo pins like-for-like baseline")
 scene.show_profile(3)
 check(find_button(scene.popup,"Restore E1").disabled,"Demo profile edits locked")
 scene.popup.hide()
 scene.demo_next()
 press(scene,"Try my own fresh game")
 check(scene.mode=="student" and scene.runs.is_empty() and scene.audience[3].events[0]=="music","Demo resets into fresh student game")
 print("Market UI: %d failures" % failures.size())
 quit(1 if failures.size()>0 else 0)
