extends GutTest
## M02-T07, V06 / DVS-006 / AV-004-03 (engine level): project table and gates, one active run,
## the one-time boost ceil(C/2) / ceil(remaining/2), stale-event invalidation, completion without
## auto-next. Exact values come from the independent Python oracle (M02OracleVectors).

const MINUTE_US: int = 60_000_000
const CORN: String = "unlock_corn"
const CORN_US: int = 1_200_000_000

var state: GameState
var engine: SimulationEngine
var registry: ContentRegistry
var counter: int = 0


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	engine = Fixtures.engine_for(state)
	counter = 0


func _submit(type: String, terms: Dictionary) -> CommandResult:
	counter += 1
	return engine.submit_command(Fixtures.command(state, type, terms, counter))


func _start(project_id: String) -> CommandResult:
	return _submit(GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, project_id))


func _boost() -> CommandResult:
	return _submit(GameCommand.TYPE_ACCELERATE_RESEARCH, ResearchSystem.quote_boost(state))


func _assert_rejected(type: String, terms: Dictionary, code: String) -> void:
	var before: String = state.digest()
	var result: CommandResult = _submit(type, terms)
	assert_eq(result.failure_code, code)
	assert_eq(state.digest(), before, "%s leaves state unchanged (no charge, no ID allocated)" % code)


## Level 4 with `coins`, ready to research Corn.
func _corn_ready(coins: int) -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(4))
	state.player.coins = coins


func test_v06_project_table_matches_oracle() -> void:
	assert_eq(registry.research_ids().size(), 14, "14 source projects")
	for row: Array in M02OracleVectors.RESEARCH:
		var project: ResearchDefinition = registry.research(row[0])
		assert_eq([project.crop_id, project.required_level, project.cost, project.duration_us], [row[1], row[2], row[3], row[4]], row[0])
		assert_eq(ResearchSystem.quote_start(registry, row[0]), {"project_id": row[0], "cost": row[3], "duration_us": row[4]})
		assert_eq(ResearchSystem.boost_charge(row[3]).value, row[5], "%s boost charge" % row[0])


func test_v06_every_project_starts_and_boosts_at_oracle_values() -> void:
	for row: Array in M02OracleVectors.RESEARCH:
		state = Fixtures.new_game_v2()
		engine = Fixtures.engine_for(state)
		Fixtures.set_xp(state, registry.threshold_for_level(row[2]))
		state.player.coins = row[3] + row[5]
		var started: CommandResult = _start(row[0])
		assert_true(started.success, "%s: %s" % [row[0], started.failure_code])
		assert_eq([state.player.coins, state.research.active_completes_us], [row[5], row[4]], row[0])
		var boosted: CommandResult = _boost()
		assert_true(boosted.success, "%s: %s" % [row[0], boosted.failure_code])
		assert_eq([state.player.coins, state.research.active_completes_us], [0, row[6]], "%s boosted at start" % row[0])
		assert_eq(engine.get_next_event_time(), row[6], "%s rescheduled" % row[0])
		assert_eq(state.validate(registry), PackedStringArray())


func test_halving_matches_oracle() -> void:
	for row: Array in M02OracleVectors.BOOST:
		var halved: int = ResearchSystem.halve_remaining(row[0]).value
		if row[1] == -1:
			assert_eq(halved, row[0], "%d μs: no time saved" % row[0])
		else:
			assert_eq([halved, row[0] - halved], [row[1], row[2]], "%d μs" % row[0])


func test_dvs006_corn_boost_at_20_and_10_minutes() -> void:
	_corn_ready(1_200)
	var started: CommandResult = _start(CORN)
	assert_true(started.success)
	assert_eq(state.player.coins, 400, "paid 800")
	assert_eq([started.transactions[0].type(), started.transactions[0].coin_delta(), started.transactions[0].category()],
		["research_purchase", -800, "research"])
	var boosted: CommandResult = _boost()
	assert_true(boosted.success, boosted.failure_code)
	assert_eq(state.player.coins, 0, "boost costs ceil(800/2) = 400")
	assert_eq(state.research.active_completes_us, 10 * MINUTE_US, "20 min remaining → 10")
	assert_eq(boosted.events[0].data["saved_us"], 10 * MINUTE_US)
	assert_eq([boosted.transactions[0].type(), boosted.transactions[0].coin_delta()], ["research_boost", -400])
	assert_true(state.research.boost_used)
	state.player.coins = 10_000
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, ResearchSystem.quote_boost(state), FailureCode.BOOST_USED)

	before_each()
	_corn_ready(1_200)
	assert_true(_start(CORN).success)
	engine.advance_to(10 * MINUTE_US)
	assert_true(_boost().success)
	assert_eq(state.player.coins, 0, "same 400 at 10 minutes remaining")
	assert_eq(state.research.active_completes_us, 15 * MINUTE_US, "10 min remaining → 5")


func test_dvs006_two_and_one_microsecond_remaining() -> void:
	_corn_ready(1_200)
	assert_true(_start(CORN).success)
	engine.advance_to(CORN_US - 2)
	assert_eq(ResearchSystem.preview_boost(state)["new_remaining_us"], 1)
	assert_true(_boost().success)
	assert_eq(state.research.active_completes_us, CORN_US - 1, "2 μs → 1 μs")

	before_each()
	_corn_ready(1_200)
	assert_true(_start(CORN).success)
	engine.advance_to(CORN_US - 1)
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, ResearchSystem.quote_boost(state), FailureCode.NO_TIME_SAVED)
	assert_false(state.research.boost_used, "the boost is not consumed")
	assert_eq(state.player.coins, 400, "uncharged")


func test_one_active_project_and_no_restart() -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(4))
	state.player.coins = 5_000
	assert_true(_start(CORN).success)
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, "unlock_carrots"), FailureCode.RESEARCH_ACTIVE)
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, CORN), FailureCode.RESEARCH_ACTIVE)
	engine.advance_to(CORN_US)
	assert_true(state.research.completed.has(CORN))
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, CORN), FailureCode.RESEARCH_DONE)
	assert_true(_start("unlock_carrots").success, "a new run may start once the slot is free")


func test_start_gates_and_precedence() -> void:
	state.player.coins = 1_000_000
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, {"project_id": "unlock_mango", "cost": 1, "duration_us": 1}, FailureCode.UNKNOWN_RESEARCH)
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, {"project_id": "unlock_wheat", "cost": 0, "duration_us": 1}, FailureCode.UNKNOWN_RESEARCH)
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, CORN), FailureCode.LEVEL_REQUIRED)
	state.player.coins = 0
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, {"project_id": CORN, "cost": 700, "duration_us": CORN_US}, FailureCode.LEVEL_REQUIRED)
	_corn_ready(799)
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, {"project_id": CORN, "cost": 700, "duration_us": CORN_US}, FailureCode.STALE_TERMS)
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, {"project_id": CORN, "cost": 800, "duration_us": CORN_US - 1}, FailureCode.STALE_TERMS)
	_assert_rejected(GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, CORN), FailureCode.INSUFFICIENT_COINS)
	state.player.coins = 800
	assert_true(_start(CORN).success, "exact funds suffice")
	assert_eq(state.player.coins, 0)


func test_boost_rejections_are_uncharged() -> void:
	_corn_ready(800)
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, {"run_id": "x", "charge": 400, "rule": "halve_remaining"}, FailureCode.NO_ACTIVE_RESEARCH)
	assert_true(_start(CORN).success)
	var terms: Dictionary = ResearchSystem.quote_boost(state)
	assert_eq(terms["charge"], 400)
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, terms, FailureCode.INSUFFICIENT_COINS)
	state.player.coins = 399
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, terms, FailureCode.INSUFFICIENT_COINS)
	state.player.coins = 5_000
	var other_run: Dictionary = terms.duplicate()
	other_run["run_id"] = EntityId.new(state.save_id, state.allocation_namespace, 99).key()
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, other_run, FailureCode.STALE_TERMS)
	var other_charge: Dictionary = terms.duplicate()
	other_charge["charge"] = 399
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, other_charge, FailureCode.STALE_TERMS)
	var other_rule: Dictionary = terms.duplicate()
	other_rule["rule"] = "instant"
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, other_rule, FailureCode.MALFORMED_ENVELOPE)
	assert_false(state.research.boost_used)


func test_completed_run_boost_is_rejected() -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(4))
	state.player.coins = 5_000
	assert_true(_start(CORN).success)
	var old_terms: Dictionary = ResearchSystem.quote_boost(state)
	engine.advance_to(CORN_US)
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, old_terms, FailureCode.NO_ACTIVE_RESEARCH)
	assert_true(_start("unlock_carrots").success)
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, old_terms, FailureCode.STALE_TERMS)


func test_completion_unlocks_without_auto_next() -> void:
	_corn_ready(800)
	assert_true(_start(CORN).success)
	assert_false(state.is_crop_available("corn", registry))
	var before_end: StateChangeBatch = engine.advance_to(CORN_US - 1)
	assert_eq(before_end.events.size(), 0)
	var batch: StateChangeBatch = engine.advance_to(CORN_US + 5)
	assert_eq(batch.events.size(), 1)
	var done: SimulationEvent = batch.events[0]
	assert_eq([done.type, done.time_us, done.data["project_id"], done.data["crop_id"]],
		[SimulationEvent.RESEARCH_COMPLETED, CORN_US, CORN, "corn"])
	assert_eq(state.research.completed, PackedStringArray([CORN]))
	assert_false(state.research.is_active(), "no automatic next project")
	assert_eq(state.player.coins, 0, "no automatic boost or purchase")
	assert_true(state.is_crop_available("corn", registry), "level and research gates both met")
	for p: PlotState in state.plots:
		assert_null(p.crop_cycle, "no crop assigned or planted")
	assert_eq(engine.get_next_event_time(), -1, "nothing else scheduled")
	assert_eq(state.validate(registry), PackedStringArray())


func test_stale_event_after_boost_is_ignored() -> void:
	_corn_ready(1_200)
	assert_true(_start(CORN).success)
	var original: ScheduledEvent = ResearchSystem.completion_event(state.research)
	engine.advance_to(4 * MINUTE_US)
	assert_true(_boost().success)
	var boosted_end: int = 4 * MINUTE_US + 8 * MINUTE_US
	assert_eq(state.research.active_completes_us, boosted_end, "16 min remaining → 8")
	var before: String = state.digest()
	assert_null(ResearchSystem.complete(state, registry, original), "the cancelled pre-boost event does nothing")
	assert_eq(state.digest(), before)
	var at_boosted_end: StateChangeBatch = engine.advance_to(boosted_end)
	assert_eq(at_boosted_end.events.size(), 1)
	assert_false(state.research.is_active(), "completed at the boosted time")
	var after: StateChangeBatch = engine.advance_to(CORN_US + 1)
	assert_eq(after.events.size(), 0, "the original time passes without a second completion")
	assert_eq(state.research.completed, PackedStringArray([CORN]))
	before = state.digest()
	var duplicate: ScheduledEvent = ScheduledEvent.new(boosted_end, EventPhase.RESEARCH_COMPLETION, 0,
		original.entity_order, original.insertion_seq + 1, ScheduledEvent.TYPE_RESEARCH_COMPLETED, 0, original.target_id)
	assert_null(ResearchSystem.complete(state, registry, duplicate), "duplicate completion is ignored")
	assert_eq(state.digest(), before)


func test_boost_charge_matches_oracle() -> void:
	for row: Array in M02OracleVectors.BOOST_CHARGE:
		assert_eq(ResearchSystem.boost_charge(row[0]).value, row[1], "ceil(%d/2)" % row[0])


func test_paid_snapshot_not_repriced() -> void:
	# Fixture: the run was paid 599 under an earlier price. Odd, so ceil and floor differ.
	var charge: int = -1
	for row: Array in M02OracleVectors.BOOST_CHARGE:
		if row[0] == 599:
			charge = row[1]
	_corn_ready(800 + charge)
	assert_true(_start(CORN).success)
	state.research.active_paid_cost = 599
	assert_eq(state.validate(registry), PackedStringArray(), "the snapshot need not match current content")
	assert_eq(ResearchSystem.quote_boost(state)["charge"], charge, "ceil(paid/2), not the current price")
	state.player.coins = charge - 1
	_assert_rejected(GameCommand.TYPE_ACCELERATE_RESEARCH, ResearchSystem.quote_boost(state), FailureCode.INSUFFICIENT_COINS)
	state.player.coins = charge
	assert_true(_boost().success)
	assert_eq(state.player.coins, 0, "charged exactly ceil(599/2)")


func test_state_round_trip_and_validation() -> void:
	_corn_ready(1_200)
	assert_true(_start(CORN).success)
	assert_true(_boost().success)
	var copy: GameState = state.clone()
	assert_eq(copy.digest(), state.digest(), "active run, snapshot and boost flag round-trip")
	assert_true(copy.research.boost_used)
	var cases: Dictionary = {
		"RESEARCH_OVERDUE": func(s: GameState) -> void: s.simulation_time_us = s.research.active_completes_us,
		"RESEARCH_TIMING_INVALID": func(s: GameState) -> void: s.research.boost_used = false,
		"RESEARCH_RUN_ID_FOREIGN": func(s: GameState) -> void: s.research.active_run_id = EntityId.new(s.save_id, s.allocation_namespace, 999),
		"RESEARCH_INSERTION_SEQ_INVALID": func(s: GameState) -> void: s.research.active_insertion_seq = 999,
		"RESEARCH_ACTIVE_COMPLETED": func(s: GameState) -> void: s.research.completed = PackedStringArray([CORN]),
		"RESEARCH_STATE_INCONSISTENT": func(s: GameState) -> void: s.research.active_project_id = "",
		"RESEARCH_RUN_ID_MISSING": func(s: GameState) -> void: s.research.active_run_id = null,
	}
	for code: String in cases:
		var broken: GameState = state.clone()
		(cases[code] as Callable).call(broken)
		assert_true(Fixtures.has_code(broken.validate(registry), code), code)
	var shared: GameState = state.clone()
	Fixtures.add_cycle(shared, 1, "wheat", shared.simulation_time_us)
	shared.research.active_insertion_seq = shared.plot(1).crop_cycle.maturity_insertion_seq
	assert_true(Fixtures.has_code(shared.validate(registry), "RESEARCH_INSERTION_SEQ_INVALID"), "sequence shared with a cycle")
