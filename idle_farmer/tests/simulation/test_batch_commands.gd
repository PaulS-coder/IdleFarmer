extends GutTest
## M02-T08 (FRS §9.2, DEC-025): BatchPlant / BatchHarvest / ApplyAndStart skip ineligible members
## with per-plot codes, apply the eligible subset as one outcome, change nothing when no member is
## eligible, and are skill-gated. Plus the manual reserve override (FR-AUD-004).

const MINUTE_US: int = 60_000_000

var state: GameState
var engine: SimulationEngine
var registry: ContentRegistry
var counter: int = 0


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	state.simulation_time_us = 100 * MINUTE_US
	Fixtures.unlock_crop(state, "corn")
	AutomationFixtures.level7_automation(state)
	engine = Fixtures.engine_for(state)
	counter = 0


func _submit(type: String, terms: Dictionary) -> CommandResult:
	counter += 1
	return engine.submit_command(Fixtures.command(state, type, terms, counter))


func _plant_specs(plots: Array, crop: String = "corn", fertilizer: String = "none") -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	for id: int in plots:
		specs.append({"plot_id": id, "crop_id": crop, "fertilizer_id": fertilizer})
	return specs


func test_batch_plant_eligible_subset() -> void:
	state.player.coins = 40
	Fixtures.add_cycle(state, 2, "wheat", state.simulation_time_us)
	_restart()
	var members: Array[Dictionary] = AutomationSystem.quote_batch_plant(state, registry, _plant_specs([3, 1, 2, 4]))
	var result: CommandResult = _submit(GameCommand.TYPE_BATCH_PLANT, {"members": members})
	assert_true(result.success, result.failure_code)
	var outcomes: Array = result.member_outcomes.map(func(o: Dictionary) -> Array: return [o["plot_id"], o["failure_code"]])
	assert_eq(outcomes, [[1, ""], [2, FailureCode.PLOT_OCCUPIED], [3, ""], [4, FailureCode.INSUFFICIENT_COINS]],
		"canonical order; occupied and unfunded members skipped")
	assert_eq(state.player.coins, 4)
	assert_null(state.plot(4).crop_cycle)
	assert_eq(state.plot(2).crop_cycle.crop_id, "wheat")


func test_batch_plant_all_invalid_changes_nothing() -> void:
	state.player.coins = 10
	var before: String = state.digest()
	var members: Array[Dictionary] = AutomationSystem.quote_batch_plant(state, registry, _plant_specs([1, 2]))
	var result: CommandResult = _submit(GameCommand.TYPE_BATCH_PLANT, {"members": members})
	assert_eq(result.failure_code, FailureCode.INSUFFICIENT_COINS)
	assert_eq(result.member_outcomes.size(), 2)
	assert_eq(state.digest(), before)


func test_batch_commands_are_skill_gated() -> void:
	AutomationFixtures.with_skills(state, 7, PackedStringArray())
	state.player.coins = 100
	var before: String = state.digest()
	var members: Array[Dictionary] = AutomationSystem.quote_batch_plant(state, registry, _plant_specs([1]))
	assert_eq(_submit(GameCommand.TYPE_BATCH_PLANT, {"members": members}).failure_code, FailureCode.SKILL_NOT_UNLOCKED)
	Fixtures.add_cycle(state, 5, "wheat", 0, CropCycle.STATUS_READY)
	before = state.digest()
	var harvest: Dictionary = {"members": [{"plot_id": 5, "cycle_id": state.plot(5).crop_cycle.cycle_id.to_primitive()}]}
	_restart()
	assert_eq(_submit(GameCommand.TYPE_BATCH_HARVEST, harvest).failure_code, FailureCode.SKILL_NOT_UNLOCKED)
	var specs: Array[Dictionary] = [{"plot_id": 1, "crop_id": "corn", "fertilizer_policy": "none", "fallback_accepted": false},
		{"plot_id": 2, "crop_id": "corn", "fertilizer_policy": "none", "fallback_accepted": false}]
	assert_eq(_submit(GameCommand.TYPE_APPLY_AND_START, {"members": AutomationSystem.quote_apply_and_start(state, registry, specs)}).failure_code,
		FailureCode.SKILL_NOT_UNLOCKED)
	assert_eq(state.digest(), before)


func test_batch_envelopes_reject_duplicates_and_empty() -> void:
	var members: Array[Dictionary] = AutomationSystem.quote_batch_plant(state, registry, _plant_specs([1]))
	members.append(members[0].duplicate())
	assert_eq(_submit(GameCommand.TYPE_BATCH_PLANT, {"members": members}).failure_code, FailureCode.MALFORMED_ENVELOPE)
	assert_eq(_submit(GameCommand.TYPE_BATCH_PLANT, {"members": []}).failure_code, FailureCode.MALFORMED_ENVELOPE)


func test_batch_harvest_skips_unready_members() -> void:
	Fixtures.add_cycle(state, 1, "wheat", 0, CropCycle.STATUS_READY)
	Fixtures.add_cycle(state, 2, "corn", state.simulation_time_us)
	_restart()
	var members: Array = [{"plot_id": 1, "cycle_id": state.plot(1).crop_cycle.cycle_id.to_primitive()},
		{"plot_id": 2, "cycle_id": state.plot(2).crop_cycle.cycle_id.to_primitive()}]
	var result: CommandResult = _submit(GameCommand.TYPE_BATCH_HARVEST, {"members": members})
	assert_true(result.success)
	assert_eq(result.member_outcomes[1]["failure_code"], FailureCode.CROP_NOT_READY)
	assert_eq(state.player.coins, 16)
	assert_not_null(state.plot(2).crop_cycle)


func test_apply_and_start_member_codes() -> void:
	state.player.coins = 18
	var specs: Array[Dictionary] = [
		{"plot_id": 1, "crop_id": "corn", "fertilizer_policy": "none", "fallback_accepted": false},
		{"plot_id": 2, "crop_id": "pumpkins", "fertilizer_policy": "none", "fallback_accepted": false},
		{"plot_id": 3, "crop_id": "corn", "fertilizer_policy": "smart_mp", "fallback_accepted": false},
		{"plot_id": 25, "crop_id": "corn", "fertilizer_policy": "none", "fallback_accepted": false},
		{"plot_id": 4, "crop_id": "corn", "fertilizer_policy": "none", "fallback_accepted": false},
	]
	var members: Array[Dictionary] = AutomationSystem.quote_apply_and_start(state, registry, specs)
	var result: CommandResult = _submit(GameCommand.TYPE_APPLY_AND_START, {"members": members})
	assert_true(result.success)
	var codes: Dictionary = {}
	for outcome: Dictionary in result.member_outcomes:
		codes[outcome["plot_id"]] = outcome["failure_code"]
	assert_eq(codes, {1: "", 2: FailureCode.LEVEL_REQUIRED, 3: FailureCode.SKILL_NOT_UNLOCKED, 4: FailureCode.INSUFFICIENT_COINS,
		25: FailureCode.PLOT_LOCKED})
	assert_true(state.automation.plot(1).authorization.armed)
	assert_false(state.automation.plot(4).authorization.armed, "a failed member writes no settings")
	assert_false(state.automation.plot(4).settings.is_set(FarmingSettings.CROP_ID))
	var stale: Array[Dictionary] = AutomationSystem.quote_apply_and_start(state, registry, [specs[4]])
	stale[0]["plan_digest"] = "other"
	state.player.coins = 100
	assert_eq(_submit(GameCommand.TYPE_APPLY_AND_START, {"members": stale}).failure_code, FailureCode.STALE_TERMS)


func test_manual_reserve_override_binds_the_ending_balance() -> void:
	state.player.coins = 50
	state.automation.budget_reserve = 40
	var quote: PlantingQuote = FarmSystem.quote_for(state, registry, "corn", "none", 1)
	assert_eq(quote.min_ending_balance, 32, "ending below R shows the confirmed minimum")
	var no_override: Dictionary = RawIntent.plant("p", 1, quote).terms
	no_override["min_ending_balance"] = -1
	assert_eq(_submit(GameCommand.TYPE_PLANT_CROP, no_override).failure_code, FailureCode.STALE_TERMS)
	state.player.coins = 49
	assert_eq(_submit(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("p", 1, quote).terms).failure_code, FailureCode.STALE_TERMS,
		"never a lower balance than confirmed")
	state.player.coins = 60
	assert_true(_submit(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("p", 1, quote).terms).success, "more income is fine")
	assert_eq(state.player.coins, 42)


func _restart() -> void:
	engine = Fixtures.engine_for(state)
