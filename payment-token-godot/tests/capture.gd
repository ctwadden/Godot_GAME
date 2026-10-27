extends SceneTree
func _initialize():call_deferred("capture")
func capture():
 var s=load("res://main.tscn").instantiate();root.add_child(s);await process_frame
 s.start_lesson(false)
 for i in [0,2,5,6,7,9]:
  s.index=i;s.phase=1;s.play_part()
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/private/tmp/payments-explained-%02d.png" % i)
 print("Narrated lesson captures saved");quit()
