extends GutTest
## M02-T07 at the engine/controller boundary: phase-1 ResearchCompleted before same-time maturity
## (TRS §4.2, DVS-007 part), scheduler rebuild after restart (E7), and AV-004-03 — the boost preview
## ages naturally while the accepted-time result halves what remains at acceptance. Expected values
## come from M02OracleVectors.BOOST_ACCEPTED.

const MINUTE_US: int = 60_000_000

var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry_v2()


func _command(state: GameState, type: String, terms: Dictionary, counter: int) -> GameCommand:
	return Fixtures.command(state, type, terms, counter)


func test_research_completes_before_same_time_maturity() -> void:
	var state: GameState = Fixtures.new_game_v2()
	Fixtures.set_xp(state, registry.threshold_for_level(2))
	state.player.coins = 150
	state.simulation_time_us = 12 * MINUTE_US
	# The cycle gets the lower entity counter and insertion sequence; only the phase puts research first.
	var cycle: CropCycle = Fixtures.add_cycle(state, 1, "wheat", 12 * MINUTE_US)
	assert_eq(cycle.matures_at_us, 20 * MINUTE_US)
	var engine: SimulationEngine = Fixtures.engine_for(state)
	var started: CommandResult = engine.submit_command(_command(state, GameCommand.TYPE_START_RESEARCH,
		ResearchSystem.quote_start(registry, "unlock_carrots"), 1))
	assert_true(started.success, started.failure_code)
	assert_gt(state.research.active_insertion_seq, cycle.maturity_insertion_seq)
	var batch: StateChangeBatch = engine.advance_to(20 * MINUTE_US)
	var types: Array[String] = []
	for event: SimulationEvent in batch.events:
		types.append(event.type)
	assert_eq(types, [SimulationEvent.RESEARCH_COMPLETED, SimulationEvent.CROP_MATURED] as Array[String])
	assert_eq(state.state_sequence, 2, "one start command plus one logical batch")


func test_restart_rebuilds_the_boosted_event() -> void:
	var state: GameState = Fixtures.new_game_v2()
	Fixtures.set_xp(state, registry.threshold_for_level(4))
	state.player.coins = 2_000
	var engine: SimulationEngine = Fixtures.engine_for(state)
	assert_true(engine.submit_command(_command(state, GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, "unlock_corn"), 1)).success)
	engine.advance_to(6 * MINUTE_US)
	assert_true(engine.submit_command(_command(state, GameCommand.TYPE_ACCELERATE_RESEARCH, ResearchSystem.quote_boost(state), 2)).success)
	var pending: Array[ScheduledEvent] = EventScheduler.rebuild(state).pending_in_order()
	assert_eq(pending.size(), 1)
	assert_eq(pending[0].key(), [13 * MINUTE_US, EventPhase.RESEARCH_COMPLETION, 0, state.research.active_run_id.counter,
		state.research.active_insertion_seq] as Array[int], "14 min remaining → 7; key from persisted fields")

	var restored: GameState = state.clone()
	var restarted: SimulationEngine = Fixtures.engine_for(restored)
	assert_eq(restarted.get_next_event_time(), 13 * MINUTE_US)
	var coins: int = restored.player.coins
	var again: CommandResult = restarted.submit_command(_command(restored, GameCommand.TYPE_ACCELERATE_RESEARCH,
		ResearchSystem.quote_boost(restored), 3))
	assert_eq(again.failure_code, FailureCode.BOOST_USED, "reload never restores the boost")
	assert_eq(restored.player.coins, coins)
	engine.advance_to(30 * MINUTE_US)
	restarted.advance_to(30 * MINUTE_US)
	assert_eq(restored.gameplay_digest(), state.gameplay_digest(), "restarted run completes identically")
	assert_eq(restored.research.completed, PackedStringArray(["unlock_corn"]))


func test_av004_03_preview_ages_and_accepted_time_result() -> void:
	for row: Array in M02OracleVectors.BOOST_ACCEPTED:
		var project: ResearchDefinition = registry.research(row[0])
		var state: GameState = Fixtures.new_game_v2()
		Fixtures.set_xp(state, registry.threshold_for_level(project.required_level))
		var charge: int = ResearchSystem.boost_charge(project.cost).value
		state.player.coins = project.cost + charge
		var controller: GameController = GameController.new(ManifestFixtures.catalog(), FakeCommitSink.new())
		assert_eq(controller.start(state, Fixtures.uuid("B")), PackedStringArray())
		var start: int = controller.now_us()
		assert_true(controller.submit_intent(RawIntent.new("start", GameCommand.TYPE_START_RESEARCH, controller.quote_research(row[0]))).success)
		controller.advance_active(row[1])
		var terms: Dictionary = controller.quote_research_boost()
		var preview: Dictionary = controller.preview_research_boost()
		var remaining_at_quote: int = project.duration_us - row[1]
		assert_eq(terms["charge"], charge)
		assert_eq([preview["as_of_us"], preview["remaining_us"]], [start + row[1], remaining_at_quote], "%s preview" % row[0])
		assert_eq(preview["new_remaining_us"], ResearchSystem.halve_remaining(remaining_at_quote).value)
		controller.advance_active(row[2] - row[1])
		var result: CommandResult = controller.submit_intent(RawIntent.new("boost", GameCommand.TYPE_ACCELERATE_RESEARCH, terms))
		var after: GameState = controller.snapshot()
		if row[3] == -1:
			assert_eq(result.failure_code, FailureCode.NO_TIME_SAVED, "%s at %d" % [row[0], row[2]])
			assert_eq(after.player.coins, charge, "uncharged")
			assert_false(after.research.boost_used)
		else:
			assert_true(result.success, "%s at %d: %s" % [row[0], row[2], result.failure_code])
			assert_eq(after.research.active_completes_us, start + row[3], "%s accepted-time result" % row[0])
			assert_eq(result.events[0].data["completes_us"], start + row[3])
			assert_eq(result.events[0].data["remaining_before_us"], project.duration_us - row[2])
			assert_eq(after.player.coins, 0)


func test_completed_before_acceptance_rejects_uncharged() -> void:
	var state: GameState = Fixtures.new_game_v2()
	Fixtures.set_xp(state, registry.threshold_for_level(4))
	state.player.coins = 1_200
	var controller: GameController = GameController.new(ManifestFixtures.catalog(), FakeCommitSink.new())
	assert_eq(controller.start(state, Fixtures.uuid("B")), PackedStringArray())
	assert_true(controller.submit_intent(RawIntent.new("start", GameCommand.TYPE_START_RESEARCH, controller.quote_research("unlock_corn"))).success)
	var intent: RawIntent = RawIntent.new("boost", GameCommand.TYPE_ACCELERATE_RESEARCH, controller.quote_research_boost())
	controller.advance_active(20 * MINUTE_US)
	var result: CommandResult = controller.submit_intent(intent)
	assert_eq(result.failure_code, FailureCode.NO_ACTIVE_RESEARCH, "due completion runs before the boost")
	assert_eq(controller.snapshot().player.coins, 400)
	assert_eq(controller.snapshot().research.completed, PackedStringArray(["unlock_corn"]))
	assert_eq(controller.quote_research_boost(), {})
	assert_eq(controller.preview_research_boost(), {})


func test_redelivered_intents_and_replay() -> void:
	var state: GameState = Fixtures.new_game_v2()
	Fixtures.set_xp(state, registry.threshold_for_level(4))
	state.player.coins = 5_000
	var controller: GameController = GameController.new(ManifestFixtures.catalog(), FakeCommitSink.new())
	assert_eq(controller.start(state, Fixtures.uuid("B")), PackedStringArray())
	var start_intent: RawIntent = RawIntent.new("start", GameCommand.TYPE_START_RESEARCH, controller.quote_research("unlock_corn"))
	assert_true(controller.submit_intent(start_intent).success)
	controller.advance_active(3 * MINUTE_US)
	var boost_intent: RawIntent = RawIntent.new("boost", GameCommand.TYPE_ACCELERATE_RESEARCH, controller.quote_research_boost())
	assert_true(controller.submit_intent(boost_intent).success)
	var coins: int = controller.snapshot().player.coins
	assert_eq(coins, 5_000 - 800 - 400)
	assert_true(controller.submit_intent(start_intent).success, "re-delivered start returns its recorded result")
	assert_true(controller.submit_intent(boost_intent).success, "re-delivered boost returns its recorded result")
	assert_eq(controller.snapshot().player.coins, coins, "never charged twice")
	var fresh: RawIntent = RawIntent.new("boost-2", GameCommand.TYPE_ACCELERATE_RESEARCH, boost_intent.terms)
	assert_eq(controller.submit_intent(fresh).failure_code, FailureCode.BOOST_USED)
	controller.advance_active(20 * MINUTE_US)
	var initial: GameState = state.clone()
	initial.allocation_namespace = Fixtures.uuid("B")
	initial.command_replay.start_epoch(Fixtures.uuid("B"))
	var replay: Dictionary = CommandReplayer.replay(initial, ManifestFixtures.catalog(), controller.accepted_log(), controller.now_us())
	assert_true(replay["ok"], str(replay["errors"]))
	assert_eq((replay["state"] as GameState).research.to_primitive(), controller.snapshot().research.to_primitive())
	assert_eq((replay["state"] as GameState).player.coins, coins)
