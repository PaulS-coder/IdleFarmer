extends GutTest
## M02-T02 execution side: manual planting with a fertilizer charges seed + fertilizer atomically,
## records separate transactions (E13), snapshots the boosted reward, and rejects changed terms,
## unknown fertilizers and unaffordable totals without any state change.

var state: GameState
var registry: ContentRegistry
var scheduler: EventScheduler


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	Fixtures.unlock_crop(state, "tomatoes")
	state.player.coins = 1_000
	scheduler = EventScheduler.new()


func _assert_rejected(command: PlantCropCommand, code: String) -> void:
	var before: String = state.digest()
	var result: CommandResult = FarmSystem.plant(state, registry, scheduler, command)
	assert_eq(result.failure_code, code)
	assert_eq(state.digest(), before, "%s leaves state unchanged" % code)


func test_tomatoes_with_basic() -> void:
	var result: CommandResult = FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "tomatoes", 1, "basic"))
	assert_true(result.success, result.failure_code)
	var cycle: CropCycle = state.plot(1).crop_cycle
	assert_eq(state.player.coins, 1_000 - 55 - 41, "seed + fertilizer charged together")
	assert_eq([cycle.fertilizer_id, cycle.fertilizer_cost_paid, cycle.gross_coin_reward], ["basic", 41, 337])
	assert_eq(cycle.modifier_snapshot, {"growth_reduction_bp": 0, "coin_bonus_bp": 0, "fertilizer_bonus_bp": 2500})
	assert_not_null(cycle.fertilizer_transaction_id)
	assert_eq(result.transactions.size(), 2)
	assert_eq([result.transactions[0].type(), result.transactions[0].coin_delta()], ["seed_purchase", -55])
	assert_eq([result.transactions[1].type(), result.transactions[1].coin_delta(), result.transactions[1].category()],
		["fertilizer_purchase", -41, "fertilizer"])
	assert_true(result.transactions[1].transaction_id().equals(cycle.fertilizer_transaction_id))
	assert_eq(state.validate(registry), PackedStringArray())
	Fixtures.advance(state, scheduler, 3_600_000_000)
	FarmSystem.harvest(state, registry, Fixtures.harvest_cmd(state, 1))
	assert_eq(state.player.coins, 1_000 - 96 + 337, "T-004: net completed-cycle profit 241")


func test_snapshot_survives_later_equipment_purchase() -> void:
	FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "tomatoes", 1, "basic"))
	state.upgrades.ranks["improved_soil"] = 5
	assert_eq(state.plot(1).crop_cycle.gross_coin_reward, 337, "planted economics are immutable")
	var later: PlantingQuote = FarmSystem.quote_for(state, registry, "tomatoes", "basic")
	assert_gt(later.gross_coins, 337, "only future plantings see the new rank")


func test_unknown_fertilizer() -> void:
	var command: PlantCropCommand = PlantCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 1,
		"tomatoes", "content_m02_v1", 55, 3_600_000_000, 270, 70, "growth_booster", 0)
	_assert_rejected(command, FailureCode.UNKNOWN_FERTILIZER)


func test_unknown_fertilizer_precedes_locked_plot() -> void:
	var command: PlantCropCommand = PlantCropCommand.new(CommandId.new(state.save_id, Fixtures.uuid("A"), 1), 0, 1, 25,
		"tomatoes", "content_m02_v1", 55, 3_600_000_000, 270, 70, "growth_booster", 0)
	_assert_rejected(command, FailureCode.UNKNOWN_FERTILIZER)


func test_changed_fertilizer_terms_are_stale() -> void:
	var id: CommandId = CommandId.new(state.save_id, Fixtures.uuid("A"), 1)
	_assert_rejected(PlantCropCommand.new(id, 0, 1, 1, "tomatoes", "content_m02_v1", 55, 3_600_000_000, 337, 70, "basic", 40), FailureCode.STALE_TERMS)
	_assert_rejected(PlantCropCommand.new(id, 0, 1, 1, "tomatoes", "content_m02_v1", 55, 3_600_000_000, 337, 70, "premium", 41), FailureCode.STALE_TERMS)
	_assert_rejected(PlantCropCommand.new(id, 0, 1, 1, "tomatoes", "content_m02_v1", 55, 3_600_000_000, 270, 70, "basic", 41), FailureCode.STALE_TERMS)


func test_insufficient_coins_covers_seed_plus_fertilizer() -> void:
	state.player.coins = 95
	_assert_rejected(Fixtures.plant_cmd(state, 1, "tomatoes", 1, "basic"), FailureCode.INSUFFICIENT_COINS)
	state.player.coins = 96
	assert_true(FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "tomatoes", 1, "basic")).success)
	assert_eq(state.player.coins, 0)


func test_numeric_room_for_fertilizer_transaction() -> void:
	state.next_entity_id = IntegerMath.INT64_MAX - 2
	_assert_rejected(Fixtures.plant_cmd(state, 1, "tomatoes", 1, "basic"), FailureCode.NUMERIC_LIMIT)
	assert_true(FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "tomatoes", 1)).success,
		"without fertilizer two IDs still fit")


func test_inconsistent_fertilizer_records_are_invalid() -> void:
	FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "tomatoes", 1, "basic"))
	state.plot(1).crop_cycle.fertilizer_transaction_id = null
	assert_true(Fixtures.has_code(state.validate(registry), "CYCLE_FERTILIZER_INCONSISTENT"))


func test_v1_profile_cannot_buy_v2_fertilizer() -> void:
	var v1_state: GameState = Fixtures.new_game()
	var before: String = v1_state.digest()
	var command: PlantCropCommand = PlantCropCommand.new(CommandId.new(v1_state.save_id, Fixtures.uuid("A"), 1), 0, 1, 1,
		"wheat", "content_m01_v1", 0, 480_000_000, 20, 6, "basic", 20)
	assert_eq(FarmSystem.plant(v1_state, Fixtures.registry(), EventScheduler.new(), command).failure_code, FailureCode.UNKNOWN_FERTILIZER)
	assert_eq(v1_state.digest(), before)


func test_controller_round_trip_with_fertilizer() -> void:
	var controller: GameController = GameController.new(ManifestFixtures.catalog(), CommitSink.new())
	assert_eq(controller.start(state, Fixtures.uuid("B")), PackedStringArray())
	var quote: PlantingQuote = FarmSystem.quote_for(controller.snapshot(), registry, "tomatoes", "premium")
	var result: CommandResult = controller.submit_intent(RawIntent.plant("p", 2, quote))
	assert_true(result.success, result.failure_code)
	var log: Array[Dictionary] = controller.accepted_log()
	assert_eq(log[0]["args"]["fertilizer_id"], "premium")
	assert_eq(log[0]["args"]["fertilizer_cost"], 95)
	var replay: Dictionary = CommandReplayer.replay(state_after_start(controller), ManifestFixtures.catalog(), log, controller.now_us())
	assert_true(replay["ok"], str(replay["errors"]))


func state_after_start(controller: GameController) -> GameState:
	var restarted: GameState = state.clone()
	restarted.allocation_namespace = Fixtures.uuid("B")
	restarted.command_replay.start_epoch(Fixtures.uuid("B"))
	return restarted
