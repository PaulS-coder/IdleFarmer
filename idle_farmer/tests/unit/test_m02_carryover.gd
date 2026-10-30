extends GutTest
## M02 S0 carry-over fixes (M02_Readiness_Findings §5): failure propagation, nullable transaction
## cycle + origin, compact replay-cache entries, single command factory.


func test_batch_append_keeps_first_failure() -> void:
	var total: StateChangeBatch = StateChangeBatch.new()
	var failed: StateChangeBatch = StateChangeBatch.new()
	failed.failure_code = FailureCode.NUMERIC_LIMIT
	var later: StateChangeBatch = StateChangeBatch.new()
	later.failure_code = FailureCode.INVALID_COMMAND_TIME
	total.append(StateChangeBatch.new())
	assert_eq(total.failure_code, FailureCode.NONE)
	total.append(failed)
	total.append(later)
	assert_eq(total.failure_code, FailureCode.NUMERIC_LIMIT, "first failure kept, never cleared")


func test_transaction_without_cycle_and_with_origin_round_trips() -> void:
	var tx: EconomicTransaction = EconomicTransaction.new(EntityId.new("s", "n", 3), 10, "research_purchase", 0, null,
		-150, 0, "research", "content_m02_v1", EconomicTransaction.ORIGIN_MANUAL)
	var back: EconomicTransaction = EconomicTransaction.from_primitive(tx.to_primitive())
	assert_not_null(back)
	assert_null(back.cycle_id())
	assert_eq(back.origin(), EconomicTransaction.ORIGIN_MANUAL)
	var bad_origin: Dictionary = tx.to_primitive()
	bad_origin["origin"] = "ui"
	assert_null(EconomicTransaction.from_primitive(bad_origin), "unknown origin rejected")
	var bad_cycle: Dictionary = tx.to_primitive()
	bad_cycle["cycle_id"] = {"save_id": "s"}
	assert_null(EconomicTransaction.from_primitive(bad_cycle), "malformed non-null cycle rejected")


func test_harvest_transactions_record_origin() -> void:
	var state: GameState = Fixtures.new_game()
	var scheduler: EventScheduler = EventScheduler.new()
	var planted: CommandResult = FarmSystem.plant(state, Fixtures.registry(), scheduler, Fixtures.plant_cmd(state, 1, "wheat"))
	assert_eq(planted.transactions[0].origin(), EconomicTransaction.ORIGIN_MANUAL)
	Fixtures.advance(state, scheduler, 480_000_000)
	var harvested: CommandResult = FarmSystem.harvest(state, Fixtures.registry(), Fixtures.harvest_cmd(state, 1))
	assert_eq(harvested.transactions[0].origin(), EconomicTransaction.ORIGIN_MANUAL)


func test_replay_cache_entries_are_compact() -> void:
	var state: GameState = Fixtures.new_game()
	var engine: SimulationEngine = SimulationEngine.new()
	assert_eq(engine.initialize(state, ManifestFixtures.catalog()), PackedStringArray())
	var command: PlantCropCommand = Fixtures.plant_cmd(state, 1, "wheat", 1)
	assert_true(engine.submit_command(command).success)
	var cached: Dictionary = state.command_replay.cached_result(command.command_id())
	assert_eq(cached.keys().size(), 4)
	for key: String in ["success", "failure_code", "command_id", "state_sequence"]:
		assert_true(cached.has(key), key)
	assert_false(cached.has("events"), "no full event/transaction payload stored in state")


func test_command_factory_is_the_single_type_map() -> void:
	var id: CommandId = CommandId.new(Fixtures.SAVE_ID, Fixtures.uuid("A"), 1)
	assert_true(CommandFactory.is_known(GameCommand.TYPE_PLANT_CROP))
	assert_true(CommandFactory.is_known(GameCommand.TYPE_HARVEST_CROP))
	assert_false(CommandFactory.is_known("Teleport"))
	assert_null(CommandFactory.build("Teleport", id, 0, 1, {}))
	assert_null(CommandFactory.build("PurchaseUpgrade", id, 0, 1, {}), "malformed terms decode to null")
	var intent: RawIntent = RawIntent.plant("i", 3, FarmSystem.quote_for(Fixtures.new_game(), Fixtures.registry(), "wheat"))
	var command: GameCommand = intent.to_command(id, 0, 1)
	assert_not_null(command)
	var decoded: GameCommand = GameCommand.from_primitive(command.to_primitive())
	assert_eq(CanonicalCodec.digest(decoded.to_primitive()), CanonicalCodec.digest(command.to_primitive()))
	assert_null(RawIntent.harvest("h", 1, null).to_command(id, 0, 1), "harvest without a cycle is malformed")
