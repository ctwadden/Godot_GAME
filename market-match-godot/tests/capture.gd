extends SceneTree
func _initialize():call_deferred("capture")
func capture():
 var scene=load("res://main.tscn").instantiate()
 root.add_child(scene)
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/market-godot-menu.png")
 scene.start("student")
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/market-godot-transactions.png")
 scene.page="lab"
 scene.product=0;scene.policy=2;scene.launch(true)
 scene.board.reveal=20;scene.board.animating=false
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/market-godot-street.png")
 scene.show_profile(3)
 await process_frame
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("/private/tmp/market-godot-profile.png")
 print("Market Godot captures saved")
 quit()
