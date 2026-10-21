extends SceneTree
func _initialize(): call_deferred("capture")
func capture():
 var scene = load("res://main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 scene.popup.hide()
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/nova-preview-intro.png")
 scene.sim.tutorial_done = true
 scene.sim.order(0,false)
 scene.sim.order(1,true)
 scene.sim.order(3,false)
 for tab in [0,1,2,3,4]:
  scene.tab = tab
  scene.refresh()
  await process_frame
  await process_frame
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/private/tmp/nova-preview-tab-%d.png" % tab)
 scene.tab = 3
 scene.check_feedback = "Correct. " + scene.Learning.CHECKS[0].feedback
 scene.refresh()
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/nova-preview-check.png")
 scene.sim.day = 9
 scene.tab = 0
 scene.step()
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/nova-preview-event.png")
 print("VISUAL CAPTURE COMPLETE")
 quit()
