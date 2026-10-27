extends SceneTree
func _initialize():call_deferred("capture")
func capture():
 var s=load("res://main.tscn").instantiate();root.add_child(s);await process_frame
 for mode in ["access","token","discussion"]:
  if mode=="access":
   s.start_mode("access",true)
   for i in range(3):s.advance_demo()
  elif mode=="token":
   s.start_mode("token",true)
   for i in range(4):s.advance_demo()
  else:s.page="discussion";s.render()
  await process_frame;await process_frame;await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png("/private/tmp/payment-token-%s.png" % mode)
 print("Payment/token captures saved");quit()
