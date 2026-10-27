extends SceneTree
var failures=[]
func check(ok: bool,msg: String):
 if not ok:failures.append(msg);push_error(msg)
func find_button(n: Node,prefix: String) -> Button:
 if n is Button and n.text.begins_with(prefix):return n
 for child in n.get_children():
  var b=find_button(child,prefix)
  if b!=null:return b
 return null
func press(n: Node,prefix: String):
 var b=find_button(n,prefix)
 check(b!=null,"Button present: "+prefix)
 if b!=null:check(not b.disabled,"Button enabled: "+prefix);b.pressed.emit()
func _initialize():call_deferred("run_test")
func run_test():
 var s=load("res://main.tscn").instantiate();root.add_child(s);await process_frame
 check(s.page=="menu","Entry menu")
 press(s,"Demonstrate Mode A")
 check(s.demo and s.step==0,"Demo starts before reveal")
 press(s,"Next demonstration")
 check(s.last_run.totals.access==2,"Authored normal example")
 press(s,"Next demonstration")
 check(s.last_run.totals.access==0,"Authored central outage")
 press(s,"Next demonstration")
 check(s.last_run.totals.access==3,"Authored cash fallback")
 press(s,"Next demonstration")
 check(s.last_run.totals.access==4,"Authored mixed restored")
 press(s,"Next demonstration")
 check(s.last_run.totals.access==4 and s.last_run.rows[1].route==2,"Shared route provisions unbanked case explicitly")
 press(s,"Next demonstration")
 check(s.last_run.totals.access==3,"Two node failure shows fallback")
 press(s,"Explore this state")
 check(not s.demo,"Demo releases independent controls")
 var count=s.history.size();press(s,"Reveal comparison")
 check(s.history.size()==count,"Prediction required")
 s.prediction=3;press(s,"Reveal comparison")
 check(s.history.size()==count+1 and s.prediction==-1,"Run logs and clears prediction")
 s.start_mode("token",true)
 press(s,"Next demonstration")
 check(s.Lab.token_facts(s.token).copies==3,"Demo copies actual SVG bytes")
 press(s,"Next demonstration")
 check(s.token.controller=="Alias B" and s.token.licence==s.Lab.LICENCE,"Demo transfer consistent")
 press(s,"Next demonstration");press(s,"Next demonstration")
 check(not s.token.host_up and s.Lab.token_facts(s.token).local_available,"Broken link leaves local files")
 press(s,"Next demonstration");press(s,"Explore this state")
 check(not s.demo,"B independent route")
 s.match_choices=[0,1,2,3];press(s,"Check evidence")
 check(s.match_feedback.begins_with("4/4"),"Evidence feedback")
 s.page="evidence";s.render();await process_frame
 var edits=s.find_children("*","TextEdit",true,false)
 check(edits.size()==3,"Three exit response fields")
 edits[0].text="Mixed serves three during the central outage.";edits[0].text_changed.emit()
 check(s.report_text().contains("Mixed serves three"),"Report retains student evidence")
 check(s.report_text().contains("Commercial reproduction is not permitted"),"Report records licence evidence")
 s.page="discussion";s.render();await process_frame
 check(find_button(s,"Buy")==null and find_button(s,"Open reward")==null and find_button(s,"Trade")==null,"Discussion has no purchase/draw/trade controls")
 print("Payment/token UI: %d failures" % failures.size());quit(1 if not failures.is_empty() else 0)
