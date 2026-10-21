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
func press(scene: Node, prefix: String):
 var b = find_button(scene,prefix)
 check(b != null,"Button exists: " + prefix)
 if b != null:
  check(not b.disabled,"Button enabled: " + prefix)
  if not b.disabled: b.pressed.emit()
func _initialize(): call_deferred("run_ui")
func run_ui():
 var scene = load("res://main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.start_mode("campaign")
 await process_frame
 check(scene.tab == 3 and not scene.sim.tutorial_done,"First run opens Learn")
 press(scene,"Next")
 await process_frame
 check(scene.sim.tutorial_step == 1,"Guide moves to order task")
 check(find_button(scene,"Next").disabled,"Order action gates progression")
 press(scene,"Order 40 processors")
 await process_frame
 check(scene.sim.shipments.size() == 1 and scene.sim.inventory[0] == 120,"Tutorial action changes real campaign without inventing stock")
 press(scene,"Next")
 await process_frame
 check(find_button(scene,"Next").disabled,"Advance-day action gates progression")
 press(scene,"Advance one day")
 await process_frame
 check(scene.sim.day == 2 and scene.sim.delivered == 0 and scene.sim.dispatched() == 30,"Guided day distinguishes dispatch from arrival")
 for i in range(4):
  press(scene,"Next")
  await process_frame
 press(scene,"Begin campaign")
 await process_frame
 check(scene.sim.tutorial_done and scene.tab == 0,"Guide completes into Supply")
 scene.running = true
 scene.tab = 3
 scene.refresh()
 await process_frame
 check(not scene.running,"Learning screen pauses time")
 press(scene,"Outsourcing only")
 await process_frame
 check(scene.sim.answers.provider[0].correct,"Quiz retains an answer attempt")
 scene.running = true
 scene.tab = 4
 scene.refresh()
 await process_frame
 check(not scene.running,"Report pauses time")
 var edits: Array = []
 for child in scene.content.get_children():
  if child is TextEdit: edits.append(child)
 check(edits.size() == 3,"Report has three individual explanation fields")
 edits[0].text = "Test explanation with evidence."
 edits[0].text_changed.emit()
 scene.refresh()
 await process_frame
 check(scene.sim.reflections.decision == "Test explanation with evidence.","Writing retained after UI refresh")
 scene.sim.ended = true
 scene.tab = 3
 scene.refresh()
 await process_frame
 check(scene.tab == 3,"Learn remains reachable after campaign ends")
 scene.export_report("user://test-nova-report.txt")
 check(FileAccess.get_file_as_string("user://test-nova-report.txt").contains("Test explanation with evidence."),"Export includes individual explanation")
 scene.sim.ended = false
 scene.sim.day = 9
 scene.tab = 0
 scene.running = true
 scene.step()
 check(not scene.running and scene.popup.visible,"Disruption pauses and explains consequences")
 if failures.is_empty(): print("PASS: guided actions, gates, quiz persistence, paused learning/writing, post-game navigation, report export and event pause.")
 quit(0 if failures.is_empty() else 1)
