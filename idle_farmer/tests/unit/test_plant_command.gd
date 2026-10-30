extends GutTest
## M01-T10, FR-FARM-03–05, V02/V03 (planting parts): all-or-nothing planting and rejections that
## leave every byte of state — including ID and sequence counters — unchanged.

var state: GameState
var registry: ContentRegistry
var scheduler: EventScheduler


func before_each() -> void:
	registry = Fixtures.registry()
	state = Fixtures.new_game()
	scheduler = EventScheduler.new()


func _assert_rejected(command: PlantCropCommand, code: String) -> void:
	var before: String = state.digest()
	var queued: int = scheduler.size()
	var result: CommandResult = FarmSystem.plant(state, registry, scheduler, command)
	assert_false(result.success, code)
	assert_eq(result.failure_code, code)
	assert_eq(state.digest(), before, "%s leaves state unchanged" % code)
	assert_eq(scheduler.size(), queued, "%s schedules nothing" % code)
	assert_eq(result.events.size() + result.transactions.size(), 0)


func test_plant_wheat_from_new_game() -> void:
	var result: CommandResult = FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 3, "wheat"))
	assert_true(result.success, result.failure_code)
	var cycle: CropCycle = state.plot(3).crop_cycle
	assert_not_null(cycle)
	assert_eq(cycle.status, CropCycle.STATUS_GROWING)
	assert_eq([cycle.planted_at_us, cycle.matures_at_us, cycle.effective_growth_us], [0, 480_000_000, 480_000_000])
	assert_eq([cycle.seed_cost_paid, cycle.gross_coin_reward, cycle.xp_reward], [0, 16, 6])
	assert_eq(cycle.content_version, "content_m01_v1")
	assert_eq(cycle.modifier_snapshot, {"growth_reduction_bp": 0, "coin_bonus_bp": 0, "fertilizer_bonus_bp": 0})
	assert_eq(cycle.fertilizer_id, "none")
	assert_null(cycle.fertilizer_transaction_id)
	assert_eq(state.player.coins, 0, "free basic seed; no reward on planting")
	assert_eq(state.player.total_xp, 0)
	assert_eq(state.automation.to_primitive(), AutomationState.new_default().to_primitive(), "planting does not change settings")
	assert_eq([cycle.cycle_id.counter, cycle.planting_transaction_id.counter, cycle.maturity_insertion_seq], [1, 2, 1])
	assert_eq(scheduler.size(), 1)
	assert_eq(scheduler.peek_time(), 480_000_000)
	assert_eq(result.transactions[0].coin_delta(), 0)
	assert_eq(result.events[0].type, SimulationEvent.CROP_PLANTED)
	assert_eq(state.validate(registry), PackedStringArray())


func test_plant_corn_debits_seed_cost() -> void:
	Fixtures.unlock_crop(state, "corn")
	state.player.coins = 20
	var result: CommandResult = FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "corn"))
	assert_true(result.success)
	assert_eq(state.player.coins, 2)
	assert_eq(state.plot(1).crop_cycle.matures_at_us, 1_800_000_000)
	assert_eq(result.transactions[0].coin_delta(), -18)
	assert_eq(state.validate(registry), PackedStringArray())


func test_independent_plots() -> void:
	FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "wheat", 1))
	state.simulation_time_us = 100
	FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 2, "wheat", 2))
	assert_eq(state.plot(1).crop_cycle.matures_at_us, 480_000_000)
	assert_eq(state.plot(2).crop_cycle.matures_at_us, 480_000_100)
	assert_false(state.plot(1).crop_cycle.cycle_id.equals(state.plot(2).crop_cycle.cycle_id))


func test_rejections_leave_state_unchanged() -> void:
	_assert_rejected(Fixtures.plant_cmd(state, 0, "wheat"), FailureCode.UNKNOWN_PLOT)
	_assert_rejected(Fixtures.plant_cmd(state, 33, "wheat"), FailureCode.UNKNOWN_PLOT)
	_assert_rejected(PlantCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 1, "mango",
		"content_m01_v1", 0, 1, 1, 1), FailureCode.UNKNOWN_CROP)
	_assert_rejected(Fixtures.plant_cmd(state, 25, "wheat"), FailureCode.PLOT_LOCKED)
	_assert_rejected(Fixtures.plant_cmd(state, 2, "carrots"), FailureCode.LEVEL_REQUIRED)
	Fixtures.set_xp(state, 240)  # level 2: Carrots level met, research not done
	_assert_rejected(Fixtures.plant_cmd(state, 2, "carrots"), FailureCode.RESEARCH_REQUIRED)
	FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 4, "wheat"))
	_assert_rejected(Fixtures.plant_cmd(state, 4, "wheat"), FailureCode.PLOT_OCCUPIED)


func test_level_gate_applies_even_with_research() -> void:
	state.research.completed = PackedStringArray(["unlock_carrots"])
	_assert_rejected(Fixtures.plant_cmd(state, 2, "carrots"), FailureCode.LEVEL_REQUIRED)


func test_unknown_crop_precedes_locked_plot() -> void:
	_assert_rejected(PlantCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 25, "mango",
		"content_m01_v1", 0, 1, 1, 1), FailureCode.UNKNOWN_CROP)


func test_insufficient_coins() -> void:
	Fixtures.unlock_crop(state, "corn")
	state.player.coins = 17
	_assert_rejected(Fixtures.plant_cmd(state, 1, "corn"), FailureCode.INSUFFICIENT_COINS)


func test_changed_terms_are_rejected_without_charge() -> void:
	# AV-004-02: any change in content context, cost or snapshotted results refreshes, never substitutes.
	Fixtures.unlock_crop(state, "corn")
	state.player.coins = 1_000
	var id: CommandId = CommandId.new(state.save_id, Fixtures.uuid("A"), 1)
	var variants: Array[PlantCropCommand] = [
		PlantCropCommand.new(id, 0, 1, 1, "corn", "content_m01_v0", 18, 1_800_000_000, 110, 32),
		PlantCropCommand.new(id, 0, 1, 1, "corn", "content_m01_v1", 17, 1_800_000_000, 110, 32),
		PlantCropCommand.new(id, 0, 1, 1, "corn", "content_m01_v1", 19, 1_800_000_000, 110, 32),
		PlantCropCommand.new(id, 0, 1, 1, "corn", "content_m01_v1", 18, 1_799_999_999, 110, 32),
		PlantCropCommand.new(id, 0, 1, 1, "corn", "content_m01_v1", 18, 1_800_000_000, 111, 32),
		PlantCropCommand.new(id, 0, 1, 1, "corn", "content_m01_v1", 18, 1_800_000_000, 110, 31),
	]
	for command: PlantCropCommand in variants:
		_assert_rejected(command, FailureCode.STALE_TERMS)


func test_stale_terms_precede_insufficient_coins() -> void:
	Fixtures.unlock_crop(state, "corn")
	state.player.coins = 0
	var stale: PlantCropCommand = PlantCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 1,
		"corn", "content_m01_v1", 5, 1_800_000_000, 110, 32)
	_assert_rejected(stale, FailureCode.STALE_TERMS)


func test_numeric_limit_rejects_without_partial_mutation() -> void:
	state.next_entity_id = IntegerMath.INT64_MAX - 1
	_assert_rejected(Fixtures.plant_cmd(state, 1, "wheat"), FailureCode.NUMERIC_LIMIT)
	state.next_entity_id = 1
	state.next_insertion_sequence = IntegerMath.INT64_MAX
	_assert_rejected(Fixtures.plant_cmd(state, 1, "wheat"), FailureCode.NUMERIC_LIMIT)
	state.next_insertion_sequence = 1
	state.simulation_time_us = IntegerMath.INT64_MAX - 100
	_assert_rejected(Fixtures.plant_cmd(state, 1, "wheat"), FailureCode.NUMERIC_LIMIT)
