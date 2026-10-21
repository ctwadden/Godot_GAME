extends SceneTree
func _initialize(): call_deferred("capture")
func capture():
 var scene = load("res://main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 for mode in ["menu","demo","student"]:
  scene.active_mode = "demo" # Capture must not overwrite an existing student's save.
  if mode == "menu": scene.active_mode = "menu"; scene.refresh()
  else: scene.start_mode(mode)
  if mode == "demo":
   for i in range(4): scene.coach.demo_next()
   scene.refresh()
  await process_frame
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/private/tmp/nova-mode-%s.png" % mode)
 scene.coach.stage = 5
 scene.refresh()
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/nova-mode-orders.png")
 scene.coach.stage = 8
 scene.refresh()
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/nova-mode-review.png")
 print("Mode captures saved")
 quit()
