extends GutTest
## M02-T09/T10 and Q1/E10/E11: V01 (capability levels, a repeating loop at level 7, fixed
## fertilizer without Smart, Smart/R/p at level 9), DVS-012 (selection is not a purchase,
## ready-on-enable, manual-harvest replant, future settings, reset/rebuy), Plot > Group > Farm
## resolution and configuration codes.

const MINUTE_US: int = 60_000_000
const WHEAT_US: int = 8 * MINUTE_US
const CORN_US: int = 30 * MINUTE_US

var state: GameState
var engine: SimulationEngine
var registry: ContentRegistry
var counter: int = 0


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	state.simulation_time_us = 100 * MINUTE_US
	engine = Fixtures.engine_for(state)
	counter = 0


func _restart_engine() -> void:
	engine = Fixtures.engine_for(state)


func _submit(command: GameCommand) -> CommandResult:
	return engine.submit_command(command)


func _cmd(type: String, terms: Dictionary) -> GameCommand:
	counter += 1
	return Fixtures.command(state, type, terms, counter)


func _configure(plot_id: int, field: String, value: Variant, set_flag: bool = true) -> CommandResult:
	counter += 1
	return _submit(AutomationFixtures.configure_cmd(state, plot_id, field, value, counter, set_flag))


func _apply_and_start(plot_id: int, crop_id: String, policy: String = "none", fallback: bool = false) -> CommandResult:
	var specs: Array[Dictionary] = [{"plot_id": plot_id, "crop_id": crop_id, "fertilizer_policy": policy, "fallback_accepted": fallback}]
	return _submit(_cmd(GameCommand.TYPE_APPLY_AND_START, {"members": AutomationSystem.quote_apply_and_start(state, registry, specs)}))


func _count(events: Array[SimulationEvent], type: String) -> int:
	return events.filter(func(e: SimulationEvent) -> bool: return e.type == type).size()


func test_v01_capability_levels() -> void:
	var expected: Dictionary = {"batch_planting": 3, "batch_harvesting": 4, "automatic_harvesting": 6, "automatic_replanting": 7,
		"smart_fertilizer": 9, "farm_presets": 12, "enhanced_budget_management": 15, "crop_rotation": 20}
	for skill_id: String in expected:
		assert_eq(registry.skill(skill_id).min_level, expected[skill_id], skill_id)


func test_v01_loop_repeats_at_level_7() -> void:
	AutomationFixtures.level7_automation(state)
	assert_true(_configure(1, FarmingSettings.CROP_ID, "wheat").success)
	assert_true(_configure(1, FarmingSettings.AUTO_HARVEST, true).success)
	assert_true(_configure(1, FarmingSettings.AUTO_REPLANT, true).success)
	assert_null(state.plot(1).crop_cycle, "configuration alone plants nothing")
	assert_false(state.automation.plot(1).authorization.armed, "configuration alone never arms")
	var started: CommandResult = _apply_and_start(1, "wheat")
	assert_true(started.success, started.failure_code)
	var ranks: Dictionary = state.player.skill_ranks.duplicate()
	var start: int = state.simulation_time_us
	var batch: StateChangeBatch = engine.advance_to(start + 5 * WHEAT_US)
	assert_eq(_count(batch.events, SimulationEvent.CROP_HARVESTED), 5, "five automatic harvests")
	assert_eq(_count(batch.events, SimulationEvent.CROP_PLANTED), 5, "five automatic replants")
	assert_eq(state.plot(1).crop_cycle.status, CropCycle.STATUS_GROWING)
	assert_eq(state.plot(1).crop_cycle.planted_at_us, start + 5 * WHEAT_US)
	assert_eq(state.player.coins, 5 * 16, "wheat: free seed, 16 coins per harvest")
	assert_eq(SettingsResolver.effective(state, 1).crop_id, "wheat", "selected crop persists")
	assert_eq(state.player.skill_ranks, ranks, "earned points are never auto-spent")
	assert_eq(state.research.completed.size(), 0, "no automatic research")
	for tx: EconomicTransaction in batch.transactions:
		assert_eq(tx.origin(), EconomicTransaction.ORIGIN_AUTOMATIC)
	assert_eq(state.validate(registry), PackedStringArray())


func test_v01_fixed_fertilizer_repeats_without_smart() -> void:
	AutomationFixtures.level7_automation(state)
	Fixtures.unlock_crop(state, "corn")
	AutomationFixtures.level7_automation(state)
	state.player.coins = 38
	state.automation.plot(1).settings.set_value(FarmingSettings.AUTO_HARVEST, true)
	var started: CommandResult = _apply_and_start(1, "corn", "basic")
	assert_true(started.success, started.failure_code)
	assert_eq(state.player.coins, 0, "first planting: seed 18 + Basic 20")
	assert_eq(state.plot(1).crop_cycle.fertilizer_id, "basic")
	var batch: StateChangeBatch = engine.advance_to(state.simulation_time_us + 3 * CORN_US)
	assert_eq(_count(batch.events, SimulationEvent.CROP_PLANTED), 3)
	# Each cycle: gross floor(110 × 1.25) = 137, then seed 18 + Basic 20 for the next one.
	assert_eq(state.player.coins, 3 * (137 - 38))
	assert_eq(state.plot(1).crop_cycle.fertilizer_id, "basic", "fixed fertilizer bought at every planting")
	var fertilizer_spend: int = 0
	for tx: EconomicTransaction in batch.transactions:
		if tx.type() == EconomicTransaction.TYPE_FERTILIZER_PURCHASE:
			fertilizer_spend -= tx.coin_delta()
	assert_eq(fertilizer_spend, 3 * 20)


func test_v01_smart_and_budget_need_level_9_node() -> void:
	AutomationFixtures.level7_automation(state)
	assert_eq(_configure(1, FarmingSettings.FERTILIZER_POLICY, "smart_mp").failure_code, FailureCode.SKILL_NOT_UNLOCKED)
	assert_eq(_submit(_cmd(GameCommand.TYPE_CONFIGURE_BUDGET, {"reserve": 50, "protection_percent": 40})).failure_code,
		FailureCode.SKILL_NOT_UNLOCKED)
	assert_true(_configure(1, FarmingSettings.FERTILIZER_POLICY, "basic").success, "fixed policy needs no Smart")
	var chain: PackedStringArray = AutomationFixtures.AUTOMATION_CHAIN.duplicate()
	chain.append("smart_fertilizer")
	AutomationFixtures.with_skills(state, 9, chain)
	assert_true(_configure(1, FarmingSettings.FERTILIZER_POLICY, "smart_mp").success)
	assert_true(_submit(_cmd(GameCommand.TYPE_CONFIGURE_BUDGET, {"reserve": 50, "protection_percent": 40})).success)
	assert_eq([state.automation.budget_reserve, state.automation.budget_protection_percent], [50, 40])
	assert_eq(_submit(_cmd(GameCommand.TYPE_CONFIGURE_BUDGET, {"reserve": 50, "protection_percent": 101})).failure_code,
		FailureCode.INVALID_CONFIGURATION)


func test_dvs012_selection_is_not_a_purchase() -> void:
	AutomationFixtures.level7_automation(state)
	var before: int = state.player.coins
	assert_true(_configure(2, FarmingSettings.CROP_ID, "wheat").success)
	assert_true(_configure(2, FarmingSettings.AUTO_REPLANT, true).success)
	engine.advance_to(state.simulation_time_us + 10 * WHEAT_US)
	assert_null(state.plot(2).crop_cycle, "a configured Empty plot never starts by itself")
	assert_false(state.automation.plot(2).authorization.armed)
	assert_eq(state.player.coins, before)


func test_dvs012_ready_on_enable_harvests_in_the_command() -> void:
	AutomationFixtures.level7_automation(state)
	AutomationFixtures.ready_cycle(state, 3, "wheat")
	AutomationFixtures.ready_cycle(state, 4, "wheat")
	# Plot 4 already has Auto Harvest on (e.g. the capability was just bought): it waits for the
	# next due batch and is not collected by another plot's enable.
	state.automation.plot(4).settings.set_value(FarmingSettings.AUTO_HARVEST, true)
	_restart_engine()
	var result: CommandResult = _configure(3, FarmingSettings.AUTO_HARVEST, true)
	assert_true(result.success)
	assert_eq(_count(result.events, SimulationEvent.CROP_HARVESTED), 1, "only the plot whose setting was enabled")
	assert_null(state.plot(3).crop_cycle)
	assert_eq(state.plot(4).crop_cycle.status, CropCycle.STATUS_READY)
	assert_eq(state.player.coins, 16)


func test_dvs012_manual_harvest_replants_under_automatic_budget() -> void:
	AutomationFixtures.level7_automation(state)
	AutomationFixtures.configure_plot(state, 4, "wheat", false, true)
	AutomationFixtures.arm(state, 4)
	AutomationFixtures.ready_cycle(state, 4, "wheat")
	_restart_engine()
	counter += 1
	var result: CommandResult = _submit(Fixtures.harvest_cmd(state, 4, counter))
	assert_true(result.success)
	var types: Array = result.events.map(func(e: SimulationEvent) -> String: return e.type)
	assert_eq(types, [SimulationEvent.CROP_HARVESTED, SimulationEvent.CROP_PLANTED], "credit first, then replant")
	assert_eq(result.transactions[0].origin(), EconomicTransaction.ORIGIN_MANUAL, "the harvest is manual")
	assert_eq(result.transactions[1].origin(), EconomicTransaction.ORIGIN_AUTOMATIC, "the replant is automatic")
	assert_eq(state.plot(4).crop_cycle.status, CropCycle.STATUS_GROWING)


func test_dvs012_future_settings_keep_the_growing_snapshot() -> void:
	AutomationFixtures.level7_automation(state)
	state.automation.plot(5).settings.set_value(FarmingSettings.AUTO_HARVEST, true)
	assert_true(_apply_and_start(5, "wheat").success)
	var snapshot: Dictionary = state.plot(5).crop_cycle.to_primitive()
	var coins: int = state.player.coins
	var result: CommandResult = _apply_and_start(5, "wheat", "basic")
	assert_true(result.success, result.failure_code)
	assert_eq(state.plot(5).crop_cycle.to_primitive(), snapshot, "future settings never replace the snapshot")
	assert_eq(state.player.coins, coins, "nothing charged for an occupied plot")
	state.player.coins = 20
	engine.advance_to(state.simulation_time_us + WHEAT_US)
	assert_eq(state.plot(5).crop_cycle.fertilizer_id, "basic", "the next cycle follows the new plan")
	assert_eq(state.player.coins, 20 + 16 - 20)


func test_dvs012_reset_disarms_and_rebuy_does_not_rearm() -> void:
	AutomationFixtures.level7_automation(state)
	state.automation.plot(6).settings.set_value(FarmingSettings.AUTO_HARVEST, true)
	assert_true(_apply_and_start(6, "wheat").success)
	state.player.coins = 10_000
	var reset: CommandResult = _submit(_cmd(GameCommand.TYPE_RESET_SKILLS, SkillSystem.quote_reset(state, registry)))
	assert_true(reset.success, reset.failure_code)
	assert_false(state.automation.plot(6).authorization.armed, "reset disarms")
	assert_eq(SettingsResolver.effective(state, 6).crop_id, "wheat", "settings stay stored")
	for skill_id: String in AutomationFixtures.AUTOMATION_CHAIN:
		assert_true(_submit(_cmd(GameCommand.TYPE_ALLOCATE_SKILL, SkillSystem.quote_allocate(state, skill_id))).success)
	var batch: StateChangeBatch = engine.advance_to(state.simulation_time_us + WHEAT_US)
	assert_eq(_count(batch.events, SimulationEvent.CROP_HARVESTED), 1, "Auto Harvest needs no arming")
	assert_eq(_count(batch.events, SimulationEvent.CROP_PLANTED), 0, "re-buying never re-arms the replant loop")
	assert_eq(state.plot(6).stall_reason, PlotState.STALL_UNARMED)
	assert_true(_apply_and_start(6, "wheat").success, "explicit re-arm")
	assert_true(state.automation.plot(6).authorization.armed)


func test_q1_plant_arms_only_with_the_plan_digest() -> void:
	AutomationFixtures.level7_automation(state)
	AutomationFixtures.configure_plot(state, 7, "wheat", true, true)
	var armed_quote: PlantingQuote = FarmSystem.quote_for(state, registry, "wheat", "none", 7)
	assert_eq(armed_quote.plan_digest, SettingsResolver.effective_plan_digest(state, 7))
	var one_off: PlantingQuote = FarmSystem.quote_for(state, registry, "wheat")
	assert_true(_submit(_cmd(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("p", 7, one_off).terms)).success)
	assert_false(state.automation.plot(7).authorization.armed, "a planting without the digest is one-off")
	engine.advance_to(state.simulation_time_us + WHEAT_US)
	assert_null(state.plot(7).crop_cycle, "harvested, not replanted")
	assert_eq(state.plot(7).stall_reason, PlotState.STALL_UNARMED)
	assert_true(_submit(_cmd(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("p", 7, FarmSystem.quote_for(state, registry, "wheat", "none", 7)).terms)).success)
	assert_true(state.automation.plot(7).authorization.armed, "matching Plant with the digest arms")
	assert_eq(state.plot(7).stall_reason, PlotState.STALL_NONE)
	var other: PlantingQuote = FarmSystem.quote_for(state, registry, "wheat", "none", 8)
	assert_eq(other.plan_digest, "", "plot 8 has no configured plan")


func test_q1_changed_plan_between_quote_and_acceptance_is_stale() -> void:
	AutomationFixtures.level7_automation(state)
	AutomationFixtures.configure_plot(state, 7, "wheat", true, true)
	var terms: Dictionary = RawIntent.plant("p", 7, FarmSystem.quote_for(state, registry, "wheat", "none", 7)).terms
	assert_true(_configure(7, FarmingSettings.FALLBACK_ACCEPTED, true).success)
	var before: String = state.digest()
	assert_eq(_submit(_cmd(GameCommand.TYPE_PLANT_CROP, terms)).failure_code, FailureCode.STALE_TERMS)
	assert_eq(state.digest(), before)


func test_plan_change_disarms_and_reverting_does_not_rearm() -> void:
	AutomationFixtures.level7_automation(state)
	Fixtures.unlock_crop(state, "carrots")
	AutomationFixtures.level7_automation(state)
	assert_true(_apply_and_start(8, "wheat").success)
	assert_true(_configure(8, FarmingSettings.AUTO_HARVEST, false).success)
	assert_true(state.automation.plot(8).authorization.armed, "a field outside the plan keeps authorization")
	var changed: CommandResult = _configure(8, FarmingSettings.CROP_ID, "carrots")
	assert_eq(_count(changed.events, SimulationEvent.LOOPS_DISARMED), 1)
	assert_false(state.automation.plot(8).authorization.armed)
	assert_true(_configure(8, FarmingSettings.CROP_ID, "wheat").success)
	assert_false(state.automation.plot(8).authorization.armed, "reverting never re-arms silently")
	assert_true(_apply_and_start(9, "wheat").success)
	assert_true(_configure(9, FarmingSettings.AUTO_REPLANT, false).success)
	assert_false(state.automation.plot(9).authorization.armed, "turning Auto Replant off disarms")


func test_loop_runs_only_for_the_authorized_plan_digest() -> void:
	AutomationFixtures.level7_automation(state)
	Fixtures.unlock_crop(state, "carrots")
	AutomationFixtures.level7_automation(state)
	state.automation.groups["g1"] = FarmingSettings.new()
	state.automation.plot(1).group_id = "g1"
	AutomationFixtures.configure_plot(state, 1, "wheat", true, true)
	state.automation.plot(1).settings.clear(FarmingSettings.CROP_ID)
	state.automation.groups["g1"].set_value(FarmingSettings.CROP_ID, "wheat")
	AutomationFixtures.arm(state, 1)
	AutomationFixtures.ready_cycle(state, 1, "wheat")
	# The inherited plan changes without any plot command (a group edit path, M05): the armed digest
	# no longer matches, so the loop must not buy the new plan.
	state.automation.groups["g1"].set_value(FarmingSettings.CROP_ID, "carrots")
	assert_true(state.automation.plot(1).authorization.armed)
	var proposal: BatchProposal = BatchPlanner.plan(state, registry, {"auto_harvest": true})
	assert_eq(proposal.harvests.size(), 1)
	assert_eq(proposal.plantings.size(), 0, "no replant under a changed effective plan")
	assert_eq(proposal.stalls, {1: PlotState.STALL_UNARMED} as Dictionary[int, String])


func test_resolution_plot_group_farm() -> void:
	state.automation.groups["g1"] = FarmingSettings.new()
	state.automation.groups["g1"].set_value(FarmingSettings.CROP_ID, "carrots")
	state.automation.groups["g1"].set_value(FarmingSettings.AUTO_HARVEST, true)
	state.automation.plot(2).group_id = "g1"
	state.automation.plot(2).settings.set_value(FarmingSettings.AUTO_HARVEST, false)
	state.automation.defaults.set_value(FarmingSettings.CROP_ID, "wheat")
	assert_eq(state.validate(registry), PackedStringArray())
	var plot2: FarmingSettings = SettingsResolver.effective(state, 2)
	assert_eq([plot2.crop_id, plot2.auto_harvest, plot2.fertilizer_policy], ["carrots", false, "none"], "explicit false stays set")
	var plot1: FarmingSettings = SettingsResolver.effective(state, 1)
	assert_eq([plot1.crop_id, plot1.auto_harvest], ["wheat", false])
	state.automation.plot(2).settings.clear(FarmingSettings.AUTO_HARVEST)
	assert_true(SettingsResolver.effective(state, 2).auto_harvest, "cleared field inherits from the group")


func test_sparse_automation_encoding() -> void:
	assert_eq(state.automation.to_primitive()["plots"], [], "default records are not serialized")
	AutomationFixtures.loop_plot(state, 9, "wheat")
	AutomationFixtures.configure_plot(state, 3, "wheat", false, false)
	var primitive: Dictionary = state.to_primitive()
	assert_eq(primitive["automation"]["plots"].map(func(r: Dictionary) -> int: return r["plot_id"]), [3, 9])
	assert_eq(GameState.from_primitive(primitive).digest(), state.digest(), "round trip")
	var unordered: Dictionary = primitive.duplicate(true)
	unordered["automation"]["plots"].reverse()
	assert_null(GameState.from_primitive(unordered), "records must be in ascending plot order")
	var with_default: Dictionary = primitive.duplicate(true)
	with_default["automation"]["plots"].append(PlotAutomation.new(20).to_primitive())
	assert_null(GameState.from_primitive(with_default), "a default record is not canonical")


func test_configuration_codes() -> void:
	AutomationFixtures.level7_automation(state)
	var cases: Array[Array] = [
		[0, FarmingSettings.PRIORITY, 5, true, FailureCode.FEATURE_UNAVAILABLE],
		[33, FarmingSettings.CROP_ID, "wheat", true, FailureCode.UNKNOWN_PLOT],
		[1, FarmingSettings.CROP_ID, "mango", true, FailureCode.UNKNOWN_CROP],
		[1, FarmingSettings.FERTILIZER_POLICY, "gold", true, FailureCode.UNKNOWN_FERTILIZER],
		[0, FarmingSettings.AUTO_HARVEST, false, false, FailureCode.INVALID_CONFIGURATION],
	]
	for row: Array in cases:
		var before: String = state.digest()
		assert_eq(_configure(row[0], row[1], row[2], row[3]).failure_code, row[4], str(row))
		assert_eq(state.digest(), before, "%s changes nothing" % row[4])
	state = Fixtures.new_game_v2()
	_restart_engine()
	assert_eq(_configure(1, FarmingSettings.AUTO_HARVEST, true).failure_code, FailureCode.SKILL_NOT_UNLOCKED)
	assert_eq(_configure(1, FarmingSettings.AUTO_REPLANT, true).failure_code, FailureCode.SKILL_NOT_UNLOCKED)
	assert_true(_configure(1, FarmingSettings.AUTO_HARVEST, false).success, "disabling needs no capability")
	assert_null(Fixtures.command(state, GameCommand.TYPE_CONFIGURE_AUTOMATION, {"plot_id": 1, "field": "crop_id", "set": true, "value": 3}, 99),
		"value type must match the field")


func test_reserved_commands_are_unavailable() -> void:
	for type: String in UnavailableCommand.TYPES:
		var before: String = state.digest()
		var result: CommandResult = _submit(_cmd(type, {"anything": 1}))
		assert_eq(result.failure_code, FailureCode.FEATURE_UNAVAILABLE, type)
		assert_eq(state.digest(), before)
