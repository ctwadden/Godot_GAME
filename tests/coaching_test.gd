extends SceneTree
const Coach = preload("res://scripts/coaching.gd")
var failures: Array = []
func check(condition: bool, message: String):
 if not condition:
  failures.append(message)
  push_error(message)
func _initialize():
 var demo = Coach.new("demo")
 check(demo.sim.inventory == [80,10,80],"Demo has small explicit starting state")
 demo.demo_next()
 demo.demo_next()
 check(demo.sim.cash == 23800 and demo.sim.inventory[1] == 10,"Expert order is real, and payment does not create stock")
 demo.demo_next()
 check(demo.sim.shipments[0].stage == "border" and demo.sim.delivered == 0 and demo.sim.dispatched() == 10,"Demo explains border and dispatch")
 demo.demo_next()
 check(demo.sim.delivered == 10 and demo.sim.inventory[1] == 10,"Demo receipt and first customer arrival")
 demo.demo_next()
 check(demo.sim.delivered == 40,"Demo customer deliveries are automatic")
 demo.demo_next()
 check(demo.sim.outsourcing and demo.sim.research_mode == 2,"Demo outsources within Canada")
 demo.demo_next()
 check(not demo.sim.outsourcing and demo.sim.research_rate() == 4,"Demo insources to trained staff")
 demo.demo_next()
 check(demo.sim.research_rate() == 12,"Hiring is a different expertise choice")
 demo.demo_next()
 check(demo.sim.research_mode == 1 and not demo.sim.outsourcing,"Demo offshores without outsourcing")
 demo.demo_next()
 check(demo.sim.research_mode == 0 and demo.sim.cash > 0,"Demo reshores and completes without budget failure")
 for air in [true,false]:
  for expertise in ["train","hire","external"]:
   run_student(air,expertise)
 print("PASS: expert demonstration, student branches, progression gates, advice, practice saves and post-run review." if failures.is_empty() else str(failures))
 quit(0 if failures.is_empty() else 1)

func advance_to_task_end(c):
 var attempts = 0
 while not c.can_continue() and c.stage < 8 and attempts < 12:
  c.advance()
  attempts += 1
 check(attempts < 12,"Task has a finite progression")

func replenish(c):
 var projected = c.sim.inventory.duplicate()
 for shipment in c.sim.shipments:
  var part = c.sim.suppliers[shipment.supplier].part
  if part == -1:
   for j in range(3): projected[j] += shipment.quantity
  else: projected[part] += shipment.quantity
 if mini(projected[0],mini(projected[1],projected[2])) < 70: c.purchase(3,false)

func run_student(air: bool, expertise: String):
 var c = Coach.new("student")
 c.answer(0)
 c.next_task()
 check(c.stage == 0,"Incorrect diagnosis does not advance")
 c.answer(1)
 c.next_task()
 c.purchase(1,air)
 var cash_after = c.sim.cash
 c.purchase(1,air)
 check(c.sim.cash == cash_after,"First purchase cannot accidentally repeat")
 c.next_task()
 advance_to_task_end(c)
 check(c.stage == 2 and c.sim.shipments.is_empty(),"Both freight choices can reach physical receipt")
 c.next_task()
 advance_to_task_end(c)
 check(c.sim.delivered >= 30,"Customer receipt objective is reachable")
 c.next_task()
 c.choose_expertise(expertise)
 var cash_after_expertise = c.sim.cash
 c.choose_expertise(expertise)
 check(c.sim.cash == cash_after_expertise,"Expertise chosen once")
 c.next_task()
 var attempts = 0
 while c.stage == 5 and not c.can_continue() and attempts < 12:
  replenish(c)
  c.advance()
  attempts += 1
 if c.stage == 5:
  c.next_task()
  check(c.sim.stock_error == 60,"Practice includes a real record discrepancy")
  var stock = c.sim.inventory.duplicate()
  c.audit()
  check(c.sim.inventory == stock,"Audit does not manufacture parts")
  c.next_task()
 while c.stage == 7 and attempts < 24:
  replenish(c)
  c.advance()
  attempts += 1
 check(c.stage == 8,"All student branches reach a debrief")
 var hints_before = c.hints
 var review = c.review()
 check(review.contains("ONE ALTERNATIVE") and review.contains("IF YOU CONTINUED"),"Review explains actual state and alternative")
 check(c.hints == hints_before,"Displaying review does not count as asking for advice")
 c.sim.reflections["_guided_state"] = c.pack()
 check(c.sim.save_game("user://test-student-practice.json") == OK,"Student practice save succeeds")
 var loaded = Coach.new()
 check(loaded.sim.load_game("user://test-student-practice.json"),"Practice simulation loads")
 loaded.restore(loaded.sim.reflections._guided_state)
 check(loaded.stage == 8 and loaded.expertise == expertise,"Mode-specific task and choices persist")
 print("Student %s / %s: %d deliveries in %d days; stage %d" % ["air" if air else "sea",expertise,c.sim.delivered,c.sim.history.size(),c.stage])
