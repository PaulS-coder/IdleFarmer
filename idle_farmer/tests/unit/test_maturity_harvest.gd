extends GutTest
## M01-T11, V02/V03, T-001/T-003/T-020 (single-transition parts): exact maturity boundary, derived
## stages, no reward until harvest, no spoilage, one payment per cycle, stale-event immunity.

const WHEAT_US: int = 480_000_000

var state: GameState
var registry: ContentRegistry
var scheduler: EventScheduler


func before_each() -> void:
	registry = Fixtures.registry()
	state = Fixtures.new_game()
	scheduler = EventScheduler.new()


func _plant(plot_id: int, crop_id: String = "wheat", counter: int = 1) -> CropCycle:
	var result: CommandResult = FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, plot_id, crop_id, counter))
	assert_true(result.success, result.failure_code)
	return state.plot(plot_id).crop_cycle


func _assert_harvest_rejected(command: HarvestCropCommand, code: String) -> void:
	var before: String = state.digest()
	var result: CommandResult = FarmSystem.harvest(state, registry, command)
	assert_false(result.success)
	assert_eq(result.failure_code, code)
	assert_eq(state.digest(), before, "%s leaves state unchanged" % code)


func test_v02_wheat_exact_maturity_boundary() -> void:
	var cycle: CropCycle = _plant(1)
	Fixtures.advance(state, scheduler, WHEAT_US - 1)
	assert_eq(cycle.status, CropCycle.STATUS_GROWING, "479,999,999 us: growing")
	assert_eq(cycle.stage_at(state.simulation_time_us), 3)
	var emitted: Array[SimulationEvent] = Fixtures.advance(state, scheduler, WHEAT_US)
	assert_eq(cycle.status, CropCycle.STATUS_READY, "480,000,000 us: ready")
	assert_eq(emitted.size(), 1, "one ready outcome")
	assert_eq(emitted[0].type, SimulationEvent.CROP_MATURED)
	assert_eq([state.player.coins, state.player.total_xp], [0, 0], "maturity pays nothing")


func test_derived_stage_boundaries() -> void:
	var cycle: CropCycle = _plant(1)
	var expected: Array[Array] = [
		[0, 0], [119_999_999, 0], [120_000_000, 1], [239_999_999, 1], [240_000_000, 2],
		[359_999_999, 2], [360_000_000, 3], [479_999_999, 3], [480_000_000, 4], [480_000_000 * 1000, 4],
	]
	for pair: Array in expected:
		assert_eq(cycle.stage_at(pair[0]), pair[1], "stage at %d" % pair[0])


func test_v02_harvest_pays_snapshot_once() -> void:
	var cycle: CropCycle = _plant(1)
	Fixtures.advance(state, scheduler, WHEAT_US)
	var command: HarvestCropCommand = Fixtures.harvest_cmd(state, 1)
	var result: CommandResult = FarmSystem.harvest(state, registry, command)
	assert_true(result.success)
	assert_eq([state.player.coins, state.player.total_xp], [16, 6])
	assert_null(state.plot(1).crop_cycle, "cycle terminated; plot Empty")
	assert_eq(result.transactions[0].coin_delta(), 16)
	assert_eq(result.transactions[0].xp_delta(), 6)
	assert_true(result.transactions[0].cycle_id().equals(cycle.cycle_id))
	assert_eq(result.events[0].type, SimulationEvent.CROP_HARVESTED)
	_assert_harvest_rejected(command, FailureCode.NO_CYCLE)
	assert_eq([state.player.coins, state.player.total_xp], [16, 6], "no double reward")
	assert_eq(state.validate(registry), PackedStringArray())


func test_v02_corn_fixture() -> void:
	Fixtures.unlock_crop(state, "corn")
	state.player.coins = 18
	var xp_before: int = state.player.total_xp
	_plant(2, "corn")
	assert_eq(state.player.coins, 0, "debits 18")
	Fixtures.advance(state, scheduler, 1_800_000_000)
	assert_true(FarmSystem.harvest(state, registry, Fixtures.harvest_cmd(state, 2)).success)
	assert_eq(state.player.coins, 110)
	assert_eq(state.player.total_xp - xp_before, 32)


func test_ready_crop_never_spoils_or_accrues() -> void:
	_plant(1)
	Fixtures.advance(state, scheduler, WHEAT_US + 30 * 86_400_000_000)
	assert_eq(state.plot(1).crop_cycle.status, CropCycle.STATUS_READY)
	assert_true(FarmSystem.harvest(state, registry, Fixtures.harvest_cmd(state, 1)).success)
	assert_eq([state.player.coins, state.player.total_xp], [16, 6], "same reward after 30 days ready")


func test_growing_crop_cannot_be_harvested() -> void:
	_plant(1)
	Fixtures.advance(state, scheduler, WHEAT_US - 1)
	_assert_harvest_rejected(Fixtures.harvest_cmd(state, 1), FailureCode.CROP_NOT_READY)


func test_old_cycle_id_cannot_harvest_replacement() -> void:
	# T-020: a harvest naming a terminated cycle never pays the plot's later cycle.
	_plant(1)
	Fixtures.advance(state, scheduler, WHEAT_US)
	var old_command: HarvestCropCommand = Fixtures.harvest_cmd(state, 1, 2)
	FarmSystem.harvest(state, registry, old_command)
	_plant(1, "wheat", 3)
	Fixtures.advance(state, scheduler, 2 * WHEAT_US)
	_assert_harvest_rejected(old_command, FailureCode.CYCLE_MISMATCH)
	assert_eq(state.player.coins, 16)


func test_other_harvest_rejections() -> void:
	_assert_harvest_rejected(HarvestCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 99,
		EntityId.new(state.save_id, Fixtures.uuid("A"), 1)), FailureCode.UNKNOWN_PLOT)
	_assert_harvest_rejected(HarvestCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 25,
		EntityId.new(state.save_id, Fixtures.uuid("A"), 1)), FailureCode.PLOT_LOCKED)
	_assert_harvest_rejected(HarvestCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 1,
		EntityId.new(state.save_id, Fixtures.uuid("A"), 1)), FailureCode.NO_CYCLE)


func test_stale_maturity_events_are_ignored() -> void:
	var first: CropCycle = _plant(1)
	var stale_event: ScheduledEvent = ScheduledEvent.for_maturity(first)
	Fixtures.advance(state, scheduler, WHEAT_US)
	FarmSystem.harvest(state, registry, Fixtures.harvest_cmd(state, 1))
	var second: CropCycle = _plant(1, "wheat", 3)
	state.simulation_time_us = WHEAT_US + 5
	assert_null(FarmSystem.mark_mature(state, stale_event), "old cycle's event cannot touch the new cycle")
	assert_eq(second.status, CropCycle.STATUS_GROWING)
	Fixtures.advance(state, scheduler, 2 * WHEAT_US)
	assert_null(FarmSystem.mark_mature(state, ScheduledEvent.for_maturity(second)), "already ready: no second outcome")


func test_early_maturity_event_is_ignored() -> void:
	var cycle: CropCycle = _plant(1)
	state.simulation_time_us = WHEAT_US - 1
	assert_null(FarmSystem.mark_mature(state, ScheduledEvent.for_maturity(cycle)))
	assert_eq(cycle.status, CropCycle.STATUS_GROWING)


func test_wallet_overflow_on_harvest_is_atomic() -> void:
	_plant(1)
	Fixtures.advance(state, scheduler, WHEAT_US)
	state.player.coins = IntegerMath.INT64_MAX - 5
	_assert_harvest_rejected(Fixtures.harvest_cmd(state, 1), FailureCode.NUMERIC_LIMIT)
	assert_not_null(state.plot(1).crop_cycle, "cycle not consumed")
