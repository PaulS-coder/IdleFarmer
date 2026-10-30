extends GutTest
## M02-T03/T06, V09/V12, AV-006-01–03: sequential fourth-row expansion and equipment ranks with
## exact costs, every rejection leaving state byte-identical, and future-only equipment effects.

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


func _assert_rejected(type: String, terms: Dictionary, code: String) -> void:
	var before: String = state.digest()
	counter += 1
	var result: CommandResult = engine.submit_command(Fixtures.command(state, type, terms, counter))
	assert_eq(result.failure_code, code, "%s %s" % [type, str(terms)])
	assert_eq(state.digest(), before, "%s leaves state (and ID counters) unchanged" % code)


func _rich(level: int, coins: int) -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(level))
	state.player.coins = coins


# --- Plots (T03, V09, V12) ---

func test_sequential_expansion_25_to_32() -> void:
	_rich(12, 100_000)
	var expected_costs: Array[int] = [250, 250, 1000, 1000, 4000, 4000, 12000, 12000]
	var spent: int = 0
	for i: int in 8:
		var quote: Dictionary = PurchaseSystem.quote_plot(state, registry)
		assert_eq(quote, {"plot_id": 25 + i, "cost": expected_costs[i]})
		var result: CommandResult = _submit(GameCommand.TYPE_PURCHASE_PLOT, quote)
		assert_true(result.success, result.failure_code)
		assert_eq(result.transactions[0].type(), "plot_purchase")
		assert_null(result.transactions[0].cycle_id())
		spent += expected_costs[i]
		assert_true(state.plot(25 + i).unlocked)
		assert_null(state.plot(25 + i).crop_cycle, "purchase never plants")
	assert_eq(spent, 34_500)
	assert_eq(state.player.coins, 100_000 - 34_500)
	assert_eq(state.unlocked_plot_count(), 32)
	assert_eq(PurchaseSystem.quote_plot(state, registry), {})
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 250}, FailureCode.PLOTS_FULL)
	assert_eq(state.validate(registry), PackedStringArray())


func test_skipped_plot_fails_even_when_rich() -> void:
	_rich(30, 1_000_000)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 27, "cost": 1000}, FailureCode.PLOT_UNLOCK_ORDER_REQUIRED)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 24, "cost": 0}, FailureCode.PLOT_UNLOCK_ORDER_REQUIRED)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 33, "cost": 0}, FailureCode.UNKNOWN_PLOT)


func test_failed_25_does_not_make_26_eligible() -> void:
	_rich(12, 249)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 250}, FailureCode.INSUFFICIENT_COINS)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 26, "cost": 250}, FailureCode.PLOT_UNLOCK_ORDER_REQUIRED)


func test_level_and_cost_are_joint_preconditions() -> void:
	_rich(2, 100_000)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 250}, FailureCode.LEVEL_REQUIRED)
	_rich(3, 100_000)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 249}, FailureCode.STALE_TERMS)
	assert_true(_submit(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 250}).success)
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 250}, FailureCode.PLOT_UNLOCK_ORDER_REQUIRED)


func test_v1_profile_cannot_expand() -> void:
	state = Fixtures.new_game()
	engine = Fixtures.engine_for(state)
	Fixtures.set_xp(state, 24_000)
	state.player.coins = 100_000
	_assert_rejected(GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 250}, FailureCode.FEATURE_UNAVAILABLE)


# --- Equipment (T06, AV-006) ---

func test_av006_01_02_every_rank_sequentially_from_level_1() -> void:
	state.player.coins = 10_000_000  # isolated funded fixture at level 1 (AV-006-02), not a new-game grant
	var families: Dictionary = {"irrigation": [650, 2100, 12000, 60000, 300000, 1500000],
		"improved_soil": [900, 3000, 20000, 110000, 650000]}
	for family: String in families:
		var costs: Array = families[family]
		for i: int in costs.size():
			var rank: int = i + 1
			_assert_rejected(GameCommand.TYPE_PURCHASE_UPGRADE, {"family_id": family, "target_rank": rank + 1, "cost": 1},
				FailureCode.UPGRADE_PREDECESSOR_REQUIRED)
			var coins: int = state.player.coins
			state.player.coins = costs[i] - 1
			_assert_rejected(GameCommand.TYPE_PURCHASE_UPGRADE, {"family_id": family, "target_rank": rank, "cost": costs[i]},
				FailureCode.INSUFFICIENT_COINS)
			state.player.coins = coins
			var quote: Dictionary = PurchaseSystem.quote_upgrade(state, registry, family)
			assert_eq(quote, {"family_id": family, "target_rank": rank, "cost": costs[i]})
			var result: CommandResult = _submit(GameCommand.TYPE_PURCHASE_UPGRADE, quote)
			assert_true(result.success, "%s %d: %s" % [family, rank, result.failure_code])
			assert_eq(state.player.coins, coins - costs[i], "exact cost %s %d" % [family, rank])
			# Duplicate re-delivery: stale terms, or max rank once the family is complete (target-state
			# checks precede term comparison, build plan §3.3). Either way nothing is charged.
			_assert_rejected(GameCommand.TYPE_PURCHASE_UPGRADE, quote,
				FailureCode.UPGRADE_MAX_RANK if rank == costs.size() else FailureCode.STALE_TERMS)
		_assert_rejected(GameCommand.TYPE_PURCHASE_UPGRADE, {"family_id": family, "target_rank": costs.size() + 1, "cost": 1},
			FailureCode.UPGRADE_MAX_RANK)
		assert_eq(PurchaseSystem.quote_upgrade(state, registry, family), {})
	assert_eq(state.upgrades.ranks, {"irrigation": 6, "improved_soil": 5})
	assert_eq(state.player.level, 1, "no level gate beyond 1 (FR-AUD-006)")
	assert_eq(state.validate(registry), PackedStringArray())


func test_deferred_and_unknown_families_rejected() -> void:
	state.player.coins = 1_000_000
	for family: String in ["seed_efficiency", "research_facilities", "growth_booster", "laser_plow"]:
		_assert_rejected(GameCommand.TYPE_PURCHASE_UPGRADE, {"family_id": family, "target_rank": 1, "cost": 100},
			FailureCode.UNKNOWN_UPGRADE)
	state = Fixtures.new_game()
	engine = Fixtures.engine_for(state)
	state.player.coins = 1_000_000
	_assert_rejected(GameCommand.TYPE_PURCHASE_UPGRADE, {"family_id": "irrigation", "target_rank": 1, "cost": 650},
		FailureCode.UNKNOWN_UPGRADE)


func test_av006_03_future_only_effects_with_quote_parity() -> void:
	state.player.coins = 1_000_000
	Fixtures.unlock_crop(state, "tomatoes")
	assert_true(_submit(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("x", 1, FarmSystem.quote_for(state, registry, "tomatoes", "basic")).terms).success)
	var planted: CropCycle = state.plot(1).crop_cycle
	var before: Dictionary = planted.to_primitive()
	assert_true(_submit(GameCommand.TYPE_PURCHASE_UPGRADE, PurchaseSystem.quote_upgrade(state, registry, "irrigation")).success)
	assert_true(_submit(GameCommand.TYPE_PURCHASE_UPGRADE, PurchaseSystem.quote_upgrade(state, registry, "improved_soil")).success)
	assert_eq(state.plot(1).crop_cycle.to_primitive(), before, "growing snapshot unchanged")
	var next: PlantingQuote = FarmSystem.quote_for(state, registry, "tomatoes", "basic")
	assert_eq(next.growth_us, 3_420_000_000, "−5% Irrigation I on future plantings")
	assert_eq(next.gross_coins, 364, "floor(270 × 1.35) with Soil I + Basic")
	var result: CommandResult = _submit(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("y", 2, next).terms)
	assert_true(result.success, "quote and execution agree")
	assert_eq(state.plot(2).crop_cycle.gross_coin_reward, 364)


func test_controller_quotes_and_redelivery() -> void:
	_rich(5, 10_000)
	var controller: GameController = GameController.new(ManifestFixtures.catalog(), CommitSink.new())
	assert_eq(controller.start(state, Fixtures.uuid("B")), PackedStringArray())
	var intent: RawIntent = RawIntent.new("buy-25", GameCommand.TYPE_PURCHASE_PLOT, controller.quote_plot_purchase())
	assert_true(controller.submit_intent(intent).success)
	var coins: int = controller.snapshot().player.coins
	assert_true(controller.submit_intent(intent).success, "re-delivered intent returns its recorded result")
	assert_eq(controller.snapshot().player.coins, coins, "never a second purchase")
	assert_eq(controller.snapshot().unlocked_plot_count(), 25)
	var stale: RawIntent = RawIntent.new("buy-25-again", GameCommand.TYPE_PURCHASE_PLOT, {"plot_id": 25, "cost": 250})
	assert_eq(controller.submit_intent(stale).failure_code, FailureCode.PLOT_UNLOCK_ORDER_REQUIRED, "old terms cannot buy plot 26")
	var replay: Dictionary = CommandReplayer.replay(_started(state), ManifestFixtures.catalog(), controller.accepted_log(), controller.now_us())
	assert_true(replay["ok"], str(replay["errors"]))


func _started(source: GameState) -> GameState:
	var copy: GameState = source.clone()
	copy.allocation_namespace = Fixtures.uuid("B")
	copy.command_replay.start_epoch(Fixtures.uuid("B"))
	return copy
