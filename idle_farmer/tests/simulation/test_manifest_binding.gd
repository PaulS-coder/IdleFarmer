extends GutTest
## AV-003-01/02/03 (DVS-019) and AV-001-01 (DVS-018) at controller level: profiles stay on their
## immutable manifest; unsupported manifests fail without overwrite; level−1 = unspent + allocated
## across active/offline/replay/restart; a restore under a fresh epoch allocates new identities.

const WHEAT_US: int = 480_000_000


func _level7_profile() -> GameState:
	var state: GameState = Fixtures.new_game()
	state.player.total_xp = 5_200
	state.player.level = 7
	state.player.skill_ranks = {"batch_planting": 1, "batch_harvesting": 1, "automatic_harvesting": 1, "automatic_replanting": 1}
	state.player.available_skill_points = 2
	return state


func test_av003_01_profile_keeps_its_manifest_when_another_moves_level_7() -> void:
	var catalog: ManifestCatalog = ManifestFixtures.catalog([ManifestFixtures.level7_at_6000()])
	var controller: GameController = GameController.new(catalog, FakeCommitSink.new())
	assert_eq(controller.start(_level7_profile(), Fixtures.uuid("A")), PackedStringArray(), "v1 profile valid while test_l7_6000 coexists")
	assert_eq(controller.snapshot().player.level, 7)
	var other: ContentRegistry = catalog.resolve("test_l7_6000")
	assert_eq(other.level_for_xp(5_200), 6, "the other manifest would say level 6")
	var rebound: GameState = _level7_profile()
	rebound.content_version = "test_l7_6000"
	assert_true(Fixtures.has_code(rebound.validate(other), "PLAYER_LEVEL_MISMATCH"), "the same numbers are invalid under the other curve")


func test_av003_02_unsupported_manifest_fails_without_overwrite() -> void:
	var sink: FakeCommitSink = FakeCommitSink.new()
	var catalog: ManifestCatalog = ManifestFixtures.catalog([ManifestFixtures.lowered_and_rank_changed()], false)
	var controller: GameController = GameController.new(catalog, sink)
	var errors: PackedStringArray = controller.start(_level7_profile(), Fixtures.uuid("A"))
	assert_true(Fixtures.has_code(errors, "MANIFEST_UNRESOLVED"))
	assert_false(controller.is_started())
	assert_eq(sink.commit_attempts, 0, "nothing written")


func test_av003_02_lowered_thresholds_never_apply_implicitly() -> void:
	var catalog: ManifestCatalog = ManifestFixtures.catalog([ManifestFixtures.lowered_and_rank_changed()])
	var controller: GameController = GameController.new(catalog, FakeCommitSink.new())
	var state: GameState = Fixtures.new_game()
	state.player.skill_ranks = {}
	assert_eq(controller.start(state, Fixtures.uuid("A")), PackedStringArray())
	controller.submit_intent(RawIntent.plant("p", 1, controller.quote_plant("wheat")))
	controller.advance_active(WHEAT_US)
	controller.submit_intent(RawIntent.harvest("h", 1, controller.snapshot().plot(1).crop_cycle.cycle_id))
	var s: GameState = controller.snapshot()
	assert_eq(s.player.total_xp, 6)
	assert_eq(s.player.level, 1, "6 XP is level 1 under v1 even though test_lowered would differ")
	assert_eq(s.content_version, "content_m01_v1")


func test_av003_03_point_conservation_across_modes_and_restart() -> void:
	var catalog: ManifestCatalog = ManifestFixtures.catalog()
	var initial: GameState = _level7_profile()
	initial.player.total_xp = 7_290  # 10 XP below level 8
	var allocated: int = 4
	for mode: String in [ScenarioDriver.MODE_ACTIVE_1X, ScenarioDriver.MODE_OFFLINE, ScenarioDriver.MODE_MIXED]:
		var driver: ScenarioDriver = ScenarioDriver.new(initial, Fixtures.uuid("A"), mode, 7, catalog)
		driver.run([[0, "plant", 1, "wheat"], [0, "plant", 2, "wheat"], [WHEAT_US, "harvest", 1, ""], [WHEAT_US, "harvest", 2, ""]], WHEAT_US)
		var s: GameState = driver.final_state()
		assert_eq(s.player.level, 8, mode)
		assert_eq(s.player.available_skill_points + allocated, s.player.level - 1, "%s conservation" % mode)
		var restarted: GameController = GameController.new(catalog, driver.sink)
		assert_eq(restarted.start(s, Fixtures.uuid("B")), PackedStringArray(), "restart validates conservation")
		assert_eq(restarted.snapshot().player.available_skill_points, s.player.available_skill_points)


func test_av001_01_restore_under_fresh_epoch_allocates_new_identities() -> void:
	var catalog: ManifestCatalog = ManifestFixtures.catalog()
	var sink: FakeCommitSink = FakeCommitSink.new()
	var original: GameController = GameController.new(catalog, sink)
	original.start(Fixtures.new_game(), Fixtures.uuid("A"))
	var backup: GameState = original.snapshot()  # checkpoint before the allocation
	original.submit_intent(RawIntent.plant("p1", 1, original.quote_plant("wheat")))
	var discarded_cycle: EntityId = original.snapshot().plot(1).crop_cycle.cycle_id
	var old_command: GameCommand = GameCommand.from_primitive(original.accepted_log()[0])

	var restored_sink: FakeCommitSink = FakeCommitSink.new()
	restored_sink._store({"commit_id": backup.last_commit_id, "new_revision": backup.durable_revision, "state": backup.to_primitive()})
	var restored: GameController = GameController.new(catalog, restored_sink)
	assert_eq(restored.start(backup, Fixtures.uuid("B")), PackedStringArray())
	restored.submit_intent(RawIntent.plant("p1-again", 1, restored.quote_plant("wheat")))
	var new_cycle: EntityId = restored.snapshot().plot(1).crop_cycle.cycle_id
	assert_eq(new_cycle.counter, discarded_cycle.counter, "same numeric order position")
	assert_false(new_cycle.equals(discarded_cycle), "but a different full identity (namespace B)")
	assert_eq(new_cycle.allocation_namespace, Fixtures.uuid("B"))

	var engine: SimulationEngine = SimulationEngine.new()
	var working: GameState = restored.snapshot()
	assert_eq(engine.initialize(working, catalog), PackedStringArray())
	var stale: PlantCropCommand = PlantCropCommand.new(old_command.command_id(), working.simulation_time_us, 9, 2, "wheat",
		"content_m01_v1", 0, WHEAT_US, 16, 6)
	assert_eq(engine.submit_command(stale).failure_code, FailureCode.STALE_COMMAND, "retired epoch payload is stale")
