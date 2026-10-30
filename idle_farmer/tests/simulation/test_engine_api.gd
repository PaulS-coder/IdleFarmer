extends GutTest
## M01-T13, V03/V04/V10 (engine parts): initialize/advance/submit/snapshot/validate, event-driven
## advancement, due-before-command ordering, strict accepted-time envelopes, replay guards.

const WHEAT_US: int = 480_000_000

var catalog: ManifestCatalog
var state: GameState
var engine: SimulationEngine


func before_each() -> void:
	catalog = ManifestFixtures.catalog()
	state = Fixtures.new_game()
	engine = SimulationEngine.new()
	assert_eq(engine.initialize(state, catalog), PackedStringArray())


func _submit(command: GameCommand) -> CommandResult:
	return engine.submit_command(command)


func _plant_at(plot_id: int, counter: int, crop_id: String = "wheat") -> CommandResult:
	return _submit(Fixtures.plant_cmd(state, plot_id, crop_id, counter))


func _assert_rejected(command: GameCommand, code: String) -> void:
	var before: String = state.digest()
	var result: CommandResult = _submit(command)
	assert_false(result.success)
	assert_eq(result.failure_code, code)
	assert_eq(state.digest(), before, "%s leaves state unchanged" % code)


func test_initialize_rejects_invalid_or_unsupported_state() -> void:
	var bad: GameState = Fixtures.new_game()
	bad.player.coins = -1
	assert_true(Fixtures.has_code(SimulationEngine.new().initialize(bad, catalog), "PLAYER_NEGATIVE"))
	var foreign: GameState = Fixtures.new_game()
	foreign.content_version = "content_future"
	assert_true(Fixtures.has_code(SimulationEngine.new().initialize(foreign, catalog), "MANIFEST_UNRESOLVED"))
	assert_true(Fixtures.has_code(SimulationEngine.new().initialize(null, catalog), "STATE_MISSING"))


func test_snapshot_is_an_independent_copy() -> void:
	var snap: GameState = engine.get_state_snapshot()
	snap.player.coins = 99
	assert_eq(state.player.coins, 0)
	assert_eq(engine.validate_state(), PackedStringArray())


func test_advance_is_event_driven_and_sequences_batches() -> void:
	_plant_at(1, 1)
	_plant_at(2, 2)
	var seq_after_plants: int = state.state_sequence
	assert_eq(engine.get_next_event_time(), WHEAT_US)
	var batch: StateChangeBatch = engine.advance_to(WHEAT_US * 10)
	assert_eq(batch.events.size(), 2, "two maturities")
	assert_eq(state.state_sequence, seq_after_plants + 1, "one logical batch at one timestamp")
	assert_eq(state.simulation_time_us, WHEAT_US * 10)
	assert_eq(engine.get_next_event_time(), -1)
	assert_eq(engine.advance_to(WHEAT_US * 10).events.size(), 0, "re-advance to now is a no-op")
	assert_eq(state.state_sequence, seq_after_plants + 1)


func test_advance_backward_is_rejected_unchanged() -> void:
	engine.advance_to(100)
	var before: String = state.digest()
	assert_eq(engine.advance_to(99).failure_code, FailureCode.INVALID_COMMAND_TIME)
	assert_eq(state.digest(), before)


func test_same_timestamp_maturities_on_32_plots_terminate() -> void:
	Fixtures.unlock_prefix(state, 32)
	for plot_id: int in range(1, 33):
		assert_true(_plant_at(plot_id, plot_id).success)
	var batch: StateChangeBatch = engine.advance_to(WHEAT_US)
	assert_eq(batch.events.size(), 32, "each maturity processed exactly once")
	var order: Array[int] = []
	for e: SimulationEvent in batch.events:
		order.append(e.cycle_id.counter)
	var sorted: Array[int] = order.duplicate()
	sorted.sort()
	assert_eq(order, sorted, "numeric entity order within the timestamp")


func test_due_events_precede_same_time_commands() -> void:
	_plant_at(1, 1)
	var cycle_id: EntityId = state.plot(1).crop_cycle.cycle_id
	state.simulation_time_us = WHEAT_US  # pretend time passed without processing due work
	var harvest: HarvestCropCommand = HarvestCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 2), WHEAT_US, 2, 1, cycle_id)
	_assert_rejected(harvest, FailureCode.INVALID_COMMAND_TIME)
	state.simulation_time_us = 0
	engine.advance_to(WHEAT_US)
	assert_true(_submit(harvest).success, "after due work the same command executes")


func test_accepted_time_must_equal_engine_time() -> void:
	engine.advance_to(1_000)
	var id: CommandId = CommandId.new(state.save_id, Fixtures.uuid("A"), 1)
	_assert_rejected(PlantCropCommand.new(id, 999, 1, 1, "wheat", "content_m01_v1", 0, WHEAT_US, 16, 6), FailureCode.INVALID_COMMAND_TIME)
	_assert_rejected(PlantCropCommand.new(id, 1_001, 1, 1, "wheat", "content_m01_v1", 0, WHEAT_US, 16, 6), FailureCode.INVALID_COMMAND_TIME)
	assert_true(_submit(PlantCropCommand.new(id, 1_000, 1, 1, "wheat", "content_m01_v1", 0, WHEAT_US, 16, 6)).success)


func test_malformed_envelope_precedes_time_check() -> void:
	_assert_rejected(PlantCropCommand.new(CommandId.new("other-save", Fixtures.uuid("A"), 1), 5, 1, 1, "wheat",
		"content_m01_v1", 0, WHEAT_US, 16, 6), FailureCode.MALFORMED_ENVELOPE)


func test_duplicate_and_stale_commands_never_execute() -> void:
	var command: PlantCropCommand = Fixtures.plant_cmd(state, 1, "wheat", 1)
	assert_true(_submit(command).success)
	engine.advance_to(WHEAT_US)
	var harvest: HarvestCropCommand = Fixtures.harvest_cmd(state, 1, 2)
	assert_true(_submit(harvest).success)
	var replay: PlantCropCommand = PlantCropCommand.new(command.command_id(), WHEAT_US, 3, 1, "wheat", "content_m01_v1", 0, WHEAT_US, 16, 6)
	_assert_rejected(replay, FailureCode.DUPLICATE_COMMAND)
	_assert_rejected(HarvestCropCommand.new(harvest.command_id(), WHEAT_US, 4, 1, harvest.cycle_id()), FailureCode.DUPLICATE_COMMAND)
	assert_eq(state.player.coins, 16, "paid once")
	state.command_replay.start_epoch(Fixtures.uuid("B"))
	state.allocation_namespace = Fixtures.uuid("B")
	_assert_rejected(PlantCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 9), WHEAT_US, 5, 2, "wheat",
		"content_m01_v1", 0, WHEAT_US, 16, 6), FailureCode.STALE_COMMAND)


func test_v10_cache_eviction_never_permits_repayment() -> void:
	state.command_replay.cache_capacity = 2
	var first: PlantCropCommand = Fixtures.plant_cmd(state, 1, "wheat", 1)
	assert_true(_submit(first).success)
	for counter: int in range(2, 6):
		assert_true(_plant_at(counter, counter).success)
	assert_eq(state.command_replay.cached_result(first.command_id()), {}, "first response evicted")
	_assert_rejected(first, FailureCode.DUPLICATE_COMMAND)


func test_success_records_replay_mark_and_sequence() -> void:
	var result: CommandResult = _plant_at(1, 7)
	assert_eq(result.state_sequence, state.state_sequence)
	assert_eq(state.command_replay.committed_success_counter, 7)
	assert_eq(state.command_replay.cached_result(CommandId.new(state.save_id, Fixtures.uuid("A"), 7))["success"], true)
	assert_true(_plant_at(2, 9).success, "gaps are permanently retired by higher successes")
	_assert_rejected(Fixtures.plant_cmd(state, 3, "wheat", 8), FailureCode.DUPLICATE_COMMAND)
