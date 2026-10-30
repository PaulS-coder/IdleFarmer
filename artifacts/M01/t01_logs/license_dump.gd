extends SceneTree

func _init() -> void:
	var f := FileAccess.open("res://logs/godot_license_inventory.txt", FileAccess.WRITE)
	f.store_line("== Engine.get_license_text()")
	f.store_line(Engine.get_license_text())
	f.store_line("== Engine.get_copyright_info() components")
	for c in Engine.get_copyright_info():
		var lic := []
		for p in c["parts"]:
			lic.append(p["license"])
		f.store_line("%s: %s" % [c["name"], ", ".join(lic)])
	f.store_line("== Engine.get_license_info() keys")
	f.store_line(", ".join(Engine.get_license_info().keys()))
	f.store_line("== renderer/audio")
	f.store_line("rendering_method=%s audio_driver=%s display=%s" % [RenderingServer.get_current_rendering_method(), AudioServer.get_driver_name() if AudioServer.has_method("get_driver_name") else "n/a", DisplayServer.get_name()])
	f.close()
	quit(0)
