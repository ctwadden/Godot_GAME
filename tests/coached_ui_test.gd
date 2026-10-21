extends SceneTree
var failures: Array = []
func check(condition: bool, message: String):
 if not condition:
  failures.append(message)
  push_error(message)
func find_button(node: Node, prefix: String) -> Button:
 if node is Button and node.text.begins_with(prefix): return node
 for child in node.get_children():
  var found = find_button(child,prefix)
  if found: return found
 return null
func _initialize(): call_deferred("test_ui")
func test_ui():
 var scene = load("res://main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 check(scene.active_mode == "menu","First run offers two versions")
 find_button(scene,"1. Watch").pressed.emit()
 await process_frame
 check(scene.active_mode == "demo" and scene.live_controls[0].disabled,"Demo locks unrelated campaign controls")
 for i in range(10):
  find_button(scene,"Next: watch").pressed.emit()
  await process_frame
 check(scene.coach.stage == 10 and scene.sim.delivered == 40,"Demo runs actual worked decisions through its ending")
 find_button(scene,"Now try a fresh").pressed.emit()
 await process_frame
 check(scene.active_mode == "student" and scene.sim.cash == 28000 and scene.sim.delivered == 0,"Student starts independently of demo state")
 check(find_button(scene,"Task complete") == null,"Diagnosis requires a response")
 find_button(scene,"Buy more processors").pressed.emit()
 await process_frame
 check(find_button(scene,"Task complete") == null,"Wrong prediction offers feedback, not progression")
 find_button(scene,"Buy more screens").pressed.emit()
 await process_frame
 find_button(scene,"Task complete").pressed.emit()
 await process_frame
 find_button(scene,"Order screens by air").pressed.emit()
 await process_frame
 check(scene.sim.shipments.size() == 1,"Student decision places a real order")
 find_button(scene,"Task complete").pressed.emit()
 await process_frame
 for i in range(2):
  find_button(scene,"Advance one day: follow the shipment").pressed.emit()
  await process_frame
 check(scene.coach.can_continue(),"Receipt unlocks the next task")
 check(find_button(scene,"Advance one day: follow the shipment").disabled,"Receipt task does not keep consuming unnecessary turns")
 # A depleted budget always has an explicit review/retry route.
 scene.coach.stage = 6
 scene.sim.stock_error = 60
 scene.sim.cash = 400
 scene.refresh()
 await process_frame
 check(find_button(scene,"End this attempt") != null,"Unaffordable audit cannot softlock practice")
 find_button(scene,"End this attempt").pressed.emit()
 await process_frame
 check(scene.coach.stage == 8,"Budget recovery opens a debrief")
 scene.export_report("user://test-coached-report.txt")
 var report = FileAccess.get_file_as_string("user://test-coached-report.txt")
 check(report.contains("Version: student") and report.contains("EXPERT REVIEW") and report.contains("What did the record audit fix?"),"Export labels the version and uses the actual practice prompts")
 print("PASS: mode chooser, expert controls, fresh student state, task gates, receipt stop, budget recovery and guided report." if failures.is_empty() else str(failures))
 quit(0 if failures.is_empty() else 1)
