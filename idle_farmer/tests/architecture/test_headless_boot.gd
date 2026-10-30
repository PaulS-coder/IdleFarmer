extends GutTest
## M01-T15 / V09: the run is headless (no display, dummy audio, Compatibility renderer configured)
## and booting/running the shared core creates no scene nodes. GUT's own SceneTree belongs to the
## test harness (approved G1 constraint), so only nodes added during the core run are counted.


func _count_nodes(node: Node) -> int:
	var total: int = 1
	for child: Node in node.get_children():
		total += _count_nodes(child)
	return total


func test_runner_environment_is_headless() -> void:
	assert_eq(DisplayServer.get_name(), "headless")
	assert_eq(AudioServer.get_driver_name(), "Dummy", "no audio device initialized")
	assert_eq(ProjectSettings.get_setting("rendering/renderer/rendering_method"), "gl_compatibility")


func test_core_boot_and_play_create_no_nodes() -> void:
	var before: int = _count_nodes(get_tree().root)
	var catalog: ManifestCatalog = ManifestCatalog.new()
	catalog.register(ContentM01V1.build_registry())
	var controller: GameController = GameController.new(catalog, CommitSink.new())
	var state: GameState = GameState.new_game("save-boot", "player-boot", "00000000-0000-4000-8000-0000000000B0", 0, catalog.resolve("content_m01_v1"))
	assert_eq(controller.start(state, "00000000-0000-4000-8000-0000000000B0"), PackedStringArray())
	assert_true(controller.submit_intent(RawIntent.plant("boot-plant", 1, controller.quote_plant("wheat"))).success)
	controller.advance_offline(480_000_000)
	var cycle: CropCycle = controller.snapshot().plot(1).crop_cycle
	assert_true(controller.submit_intent(RawIntent.harvest("boot-harvest", 1, cycle.cycle_id)).success)
	assert_eq(controller.snapshot().player.coins, 16)
	assert_eq(_count_nodes(get_tree().root), before, "core created no presentation nodes")
