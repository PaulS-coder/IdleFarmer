extends GutTest
## M01-T06, V03/V10 (contract part): immutable accepted envelopes, lossless replay records,
## envelope well-formedness, result cache semantics and epoch retirement.

var epoch: String = Fixtures.uuid("A")


func _id(counter: int) -> CommandId:
	return CommandId.new(Fixtures.SAVE_ID, epoch, counter)


func _plant(counter: int = 1, time_us: int = 0, order: int = 1) -> PlantCropCommand:
	return PlantCropCommand.new(_id(counter), time_us, order, 3, "wheat", "content_m01_v1", 0, 480_000_000, 16, 6)


func _harvest(counter: int = 2) -> HarvestCropCommand:
	return HarvestCropCommand.new(_id(counter), 480_000_000, 2, 3, EntityId.new(Fixtures.SAVE_ID, epoch, 1))


func test_commands_round_trip_through_replay_records() -> void:
	for command: GameCommand in [_plant(), _harvest()]:
		var decoded: Dictionary = CanonicalCodec.decode(CanonicalCodec.encode(command.to_primitive()))
		var back: GameCommand = GameCommand.from_primitive(decoded["value"])
		assert_not_null(back, command.type())
		assert_eq(CanonicalCodec.digest(back.to_primitive()), CanonicalCodec.digest(command.to_primitive()))
		assert_eq(back.type(), command.type())


func test_accepted_envelope_cannot_be_edited_through_accessors() -> void:
	var plant: PlantCropCommand = _plant(7, 100, 3)
	var before: String = CanonicalCodec.digest(plant.to_primitive())
	plant.command_id().counter = 99
	plant.to_primitive()["args"]["seed_cost"] = 5
	var harvest: HarvestCropCommand = _harvest()
	var harvest_before: String = CanonicalCodec.digest(harvest.to_primitive())
	harvest.cycle_id().counter = 42
	assert_eq(CanonicalCodec.digest(plant.to_primitive()), before)
	assert_eq(CanonicalCodec.digest(harvest.to_primitive()), harvest_before)
	assert_eq(plant.accepted_time_us(), 100)
	assert_eq(plant.accepted_order(), 3)


func test_envelope_well_formedness() -> void:
	assert_eq(_plant().envelope_failure(Fixtures.SAVE_ID), FailureCode.NONE)
	assert_eq(_harvest().envelope_failure(Fixtures.SAVE_ID), FailureCode.NONE)
	var malformed: Array[GameCommand] = [
		PlantCropCommand.new(null, 0, 1, 3, "wheat", "content_m01_v1", 0, 1, 16, 6),
		PlantCropCommand.new(_id(0), 0, 1, 3, "wheat", "content_m01_v1", 0, 1, 16, 6),
		PlantCropCommand.new(_id(1), -1, 1, 3, "wheat", "content_m01_v1", 0, 1, 16, 6),
		PlantCropCommand.new(_id(1), 0, 0, 3, "wheat", "content_m01_v1", 0, 1, 16, 6),
		PlantCropCommand.new(_id(1), 0, 1, 3, "", "content_m01_v1", 0, 1, 16, 6),
		PlantCropCommand.new(_id(1), 0, 1, 3, "wheat", "content_m01_v1", -1, 1, 16, 6),
		PlantCropCommand.new(_id(1), 0, 1, 3, "wheat", "content_m01_v1", 0, 0, 16, 6),
		HarvestCropCommand.new(_id(1), 0, 1, 3, null),
		HarvestCropCommand.new(_id(1), 0, 1, 3, EntityId.new("s", "", 1)),
	]
	for i: int in malformed.size():
		assert_eq(malformed[i].envelope_failure(Fixtures.SAVE_ID), FailureCode.MALFORMED_ENVELOPE, "malformed %d" % i)
	assert_eq(_plant().envelope_failure("other-save"), FailureCode.MALFORMED_ENVELOPE, "foreign save")


func test_unknown_or_malformed_records_do_not_decode() -> void:
	var record: Dictionary = _plant().to_primitive()
	record["type"] = "PurchaseUpgrade"
	assert_null(GameCommand.from_primitive(record), "unknown type")
	var missing: Dictionary = _plant().to_primitive()
	missing["args"].erase("seed_cost")
	assert_null(GameCommand.from_primitive(missing), "missing term")
	var extra: Dictionary = _harvest().to_primitive()
	extra["args"]["bonus"] = 1
	assert_null(GameCommand.from_primitive(extra), "extra term")


func test_command_result_round_trip() -> void:
	var result: CommandResult = CommandResult.new()
	result.success = true
	result.command_id = _id(1)
	result.affected_plot_ids = [3]
	result.events.append(SimulationEvent.new(SimulationEvent.CROP_PLANTED, 0, 3, EntityId.new(Fixtures.SAVE_ID, epoch, 1), {"crop_id": "wheat"}))
	result.transactions.append(EconomicTransaction.new(EntityId.new(Fixtures.SAVE_ID, epoch, 2), 0,
		EconomicTransaction.TYPE_SEED_PURCHASE, 3, EntityId.new(Fixtures.SAVE_ID, epoch, 1), 0, 0,
		EconomicTransaction.CATEGORY_SEEDS, "content_m01_v1", EconomicTransaction.ORIGIN_MANUAL))
	result.state_sequence = 4
	result.commit_status = CommandResult.COMMIT_COMMITTED
	var back: CommandResult = CommandResult.from_primitive(result.to_primitive())
	assert_not_null(back)
	assert_eq(CanonicalCodec.digest(back.to_primitive()), CanonicalCodec.digest(result.to_primitive()))
	var failed: CommandResult = CommandResult.failed(FailureCode.PLOT_LOCKED, "plot 25", _id(2), 4)
	assert_eq(CommandResult.from_primitive(failed.to_primitive()).failure_code, FailureCode.PLOT_LOCKED)


func test_replay_high_water_survives_cache_eviction() -> void:
	var replay: CommandReplayState = CommandReplayState.new()
	replay.start_epoch(epoch)
	replay.cache_capacity = 4
	for counter: int in range(1, 11):
		replay.record_success(_id(counter), {"counter": counter})
	assert_eq(replay.response_cache.size(), 4, "cache bounded")
	assert_eq(replay.cached_result(_id(1)), {}, "oldest evicted")
	assert_eq(replay.cached_result(_id(10)), {"counter": 10})
	assert_true(replay.is_duplicate(_id(1)), "eviction never restores eligibility")
	assert_true(replay.is_duplicate(_id(10)))
	assert_false(replay.is_duplicate(_id(11)))
	assert_eq(replay.validate(), PackedStringArray())


func test_epoch_retirement_makes_old_commands_stale() -> void:
	var replay: CommandReplayState = CommandReplayState.new()
	replay.start_epoch(epoch)
	replay.record_success(_id(3), {})
	replay.start_epoch(Fixtures.uuid("B"))
	assert_true(replay.is_stale_epoch(_id(1)), "retired epoch is stale")
	assert_true(replay.retired_epochs.has(epoch))
	assert_eq(replay.committed_success_counter, 0, "fresh epoch starts its own high-water")
	assert_false(replay.is_duplicate(CommandId.new(Fixtures.SAVE_ID, Fixtures.uuid("B"), 1)))


func test_failure_precedence_lists_every_m01_code_once() -> void:
	var seen: Dictionary[String, bool] = {}
	for code: String in FailureCode.PRECEDENCE:
		assert_false(seen.has(code), "%s listed once" % code)
		seen[code] = true
	assert_eq(FailureCode.PRECEDENCE[0], FailureCode.MALFORMED_ENVELOPE)
	assert_eq(FailureCode.PRECEDENCE[FailureCode.PRECEDENCE.size() - 1], FailureCode.NUMERIC_LIMIT)
