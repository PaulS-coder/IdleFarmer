extends GutTest
## M01-T13/T14 with build plan I2: controller stamping and serial acceptance (AV-004-01/02/05),
## post-commit publication, intent de-duplication and rejection baselines (V03).

const WHEAT_US: int = 480_000_000

var sink: FakeCommitSink
var controller: GameController
var published: Array = []


func before_each() -> void:
	sink = FakeCommitSink.new()
	controller = GameController.new(ManifestFixtures.catalog(), sink)
	published = []
	controller.add_commit_listener(func(batch: Array) -> void: published.append_array(batch))
	assert_eq(controller.start(Fixtures.new_game(), Fixtures.uuid("A")), PackedStringArray())


func _plant(intent_id: String, plot_id: int, crop_id: String = "wheat") -> CommandResult:
	return controller.submit_intent(RawIntent.plant(intent_id, plot_id, controller.quote_plant(crop_id)))


func _harvest(intent_id: String, plot_id: int) -> CommandResult:
	return controller.submit_intent(RawIntent.harvest(intent_id, plot_id, controller.snapshot().plot(plot_id).crop_cycle.cycle_id))


func test_startup_commits_checkpoint_before_input() -> void:
	assert_true(controller.is_started())
	assert_eq(sink.durable_revision(), 1)
	assert_eq(controller.snapshot().durable_revision, 1)
	assert_eq(controller.snapshot().last_commit_id, {"epoch": Fixtures.uuid("A"), "counter": 1})


func test_accepted_command_is_stamped_and_published_after_commit() -> void:
	controller.advance_active(1_000_000)
	var result: CommandResult = _plant("i-1", 3)
	assert_true(result.success)
	assert_eq(result.commit_status, CommitSink.COMMITTED)
	var log: Array[Dictionary] = controller.accepted_log()
	assert_eq(log.size(), 1)
	assert_eq(log[0]["accepted_time_us"], 1_000_000, "stamped at controller's current time")
	assert_eq(log[0]["accepted_order"], 1)
	assert_eq(log[0]["command_id"], {"save_id": Fixtures.SAVE_ID, "writer_epoch": Fixtures.uuid("A"), "counter": 1})
	assert_eq(published.size(), 1)
	assert_eq((published[0] as SimulationEvent).type, SimulationEvent.CROP_PLANTED)


func test_av004_01_click_crossing_due_maturity() -> void:
	_plant("i-1", 1)
	var quote_seen_at: int = controller.now_us()
	var intent: RawIntent = RawIntent.plant("i-2", 2, controller.quote_plant("wheat"))  # quoted before maturity
	controller.advance_active(WHEAT_US - quote_seen_at)
	var revision_after_due: int = sink.durable_revision()
	assert_eq(controller.snapshot().plot(1).crop_cycle.status, CropCycle.STATUS_READY, "due batch committed first")
	var result: CommandResult = controller.submit_intent(intent)
	assert_true(result.success, "unchanged authorized terms execute without backdating")
	assert_eq(controller.accepted_log()[1]["accepted_time_us"], WHEAT_US)
	assert_eq(sink.durable_revision(), revision_after_due + 1)


func test_av004_02_stale_terms_are_rejected_without_charge() -> void:
	var state: GameState = Fixtures.new_game()
	state.player.coins = 1_000
	Fixtures.unlock_crop(state, "corn")
	controller = GameController.new(ManifestFixtures.catalog(), FakeCommitSink.new())
	assert_eq(controller.start(state, Fixtures.uuid("B")), PackedStringArray())
	var quote: PlantingQuote = controller.quote_plant("corn")
	quote.seed_cost = 17
	var before: String = controller.snapshot().gameplay_digest()
	var result: CommandResult = controller.submit_intent(RawIntent.plant("i-stale", 1, quote))
	assert_eq(result.failure_code, FailureCode.STALE_TERMS)
	assert_eq(controller.snapshot().gameplay_digest(), before, "no charge, no substitute purchase")
	assert_eq(controller.accepted_log().size(), 0)


func test_av004_05_duplicate_pending_intent_returns_recorded_result() -> void:
	var intent: RawIntent = RawIntent.plant("i-dup", 4, controller.quote_plant("wheat"))
	var first: CommandResult = controller.submit_intent(intent)
	var revision: int = sink.durable_revision()
	var again: CommandResult = controller.submit_intent(intent)
	assert_true(again.success)
	assert_eq(CanonicalCodec.digest(again.to_primitive()), CanonicalCodec.digest(first.to_primitive()), "same recorded result")
	assert_eq(sink.durable_revision(), revision, "nothing executed or committed again")
	assert_eq(controller.accepted_log().size(), 1)


func test_v03_rejection_baseline_excludes_due_work() -> void:
	_plant("i-1", 1)
	controller.advance_active(WHEAT_US - 1)
	var before: GameState = controller.snapshot()
	controller.advance_active(1)  # maturity becomes due exactly now and commits
	var after_due: String = controller.snapshot().gameplay_digest()
	assert_ne(after_due, before.gameplay_digest(), "due maturity changed state")
	var rejected: CommandResult = _plant("i-occupied", 1)
	assert_eq(rejected.failure_code, FailureCode.PLOT_OCCUPIED)
	assert_eq(controller.snapshot().gameplay_digest(), after_due, "rejection measured after due work")
	var again: CommandResult = _plant("i-occupied", 1)
	assert_eq(again.failure_code, FailureCode.PLOT_OCCUPIED, "re-delivered rejection is the recorded one")


func test_rejected_input_does_not_drift_gameplay_counters() -> void:
	var before: GameState = controller.snapshot()
	for i: int in 5:
		assert_false(_plant("bad-%d" % i, 25).success)
	var after: GameState = controller.snapshot()
	assert_eq(after.gameplay_digest(), before.gameplay_digest())
	assert_eq(after.next_entity_id, before.next_entity_id)
	assert_true(_plant("good", 1).success)
	assert_eq(controller.accepted_log()[0]["command_id"]["counter"], 6, "issue counter is controller metadata")


func test_manual_wheat_farming_from_actual_initial_state() -> void:
	_plant("p1", 1)
	controller.advance_active(WHEAT_US)
	var harvested: CommandResult = _harvest("h1", 1)
	assert_true(harvested.success)
	var s: GameState = controller.snapshot()
	assert_eq([s.player.coins, s.player.total_xp], [16, 6])
	assert_eq(s.validate(Fixtures.registry()), PackedStringArray())


func test_speed_controls() -> void:
	assert_false(controller.set_speed_multiplier(0))
	assert_false(controller.set_speed_multiplier(61))
	assert_true(controller.set_speed_multiplier(60))
	_plant("p1", 1)
	controller.advance_active(8_000_000)
	assert_eq(controller.now_us(), WHEAT_US, "8 real seconds at 60×")
	assert_eq(controller.snapshot().plot(1).crop_cycle.status, CropCycle.STATUS_READY)
	controller.reset_speed()
	controller.advance_active(1)
	assert_eq(controller.now_us(), WHEAT_US + 1)


func test_restart_against_mismatched_durable_parent_is_refused() -> void:
	var fresh: GameController = GameController.new(ManifestFixtures.catalog(), FakeCommitSink.new())
	var errors: PackedStringArray = fresh.start(controller.snapshot(), Fixtures.uuid("B"))
	assert_true(Fixtures.has_code(errors, "STARTUP_NOT_COMMITTED"), "revision-1 state cannot commit onto an empty store")
	assert_false(fresh.is_started())


func test_engine_never_touches_committed_state_directly() -> void:
	var committed_before: GameState = controller.snapshot()
	sink.script_modes = [FakeCommitSink.MODE_REJECT]
	var result: CommandResult = _plant("p1", 1)
	assert_false(result.success)
	assert_eq(result.commit_status, CommitSink.NOT_COMMITTED)
	assert_eq(controller.snapshot().digest(), committed_before.digest(), "candidate discarded")
	assert_eq(published.size(), 0, "nothing published for a candidate")
