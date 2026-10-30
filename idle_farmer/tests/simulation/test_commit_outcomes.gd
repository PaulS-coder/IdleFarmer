extends GutTest
## AV-002-01/02/05 with in-memory commit fakes (build plan I1): UNKNOWN blocks all writes and
## input until read-back settles it; definite NOT_COMMITTED discards; reconciliation reproduces the
## uninterrupted run; checkpoint identity never consumes gameplay IDs.

const CORN_US: int = 1_800_000_000

var sink: FakeCommitSink
var controller: GameController
var published: Array = []


func _start(coins: int = 1_000) -> void:
	var state: GameState = Fixtures.new_game()
	Fixtures.unlock_crop(state, "corn")
	state.player.coins = coins
	sink = FakeCommitSink.new()
	controller = GameController.new(ManifestFixtures.catalog(), sink)
	published = []
	controller.add_commit_listener(func(batch: Array) -> void: published.append_array(batch))
	assert_eq(controller.start(state, Fixtures.uuid("A")), PackedStringArray())


func _plant_corn(intent_id: String, plot_id: int) -> RawIntent:
	return RawIntent.plant(intent_id, plot_id, controller.quote_plant("corn"))


func test_av002_01_lost_receipt_blocks_until_read_back_adopts_revision() -> void:
	_start()
	controller.advance_active(1_000)
	var parent_revision: int = sink.durable_revision()
	var coins_before: int = controller.snapshot().player.coins
	sink.script_modes = [FakeCommitSink.MODE_LOST_ACK]
	var intent: RawIntent = _plant_corn("buy-1", 1)
	var result: CommandResult = controller.submit_intent(intent)
	assert_eq(result.commit_status, CommitSink.UNKNOWN)
	assert_false(result.success)
	assert_true(controller.is_blocked())
	assert_eq(sink.durable_revision(), parent_revision + 1, "durable store did commit (rev 41 case)")
	assert_eq(controller.snapshot().player.coins, coins_before, "memory still at parent (rev 40)")
	assert_eq(published.size(), 0, "nothing published while UNKNOWN")

	var attempts: int = sink.commit_attempts
	assert_eq(controller.submit_intent(intent).failure_code, FailureCode.PERSISTENCE_UNAVAILABLE, "retry blocked")
	assert_eq(controller.submit_intent(_plant_corn("buy-2", 2)).failure_code, FailureCode.PERSISTENCE_UNAVAILABLE, "new purchase blocked")
	assert_eq(controller.advance_active(1_000), GameController.STATUS_BLOCKED, "time-only write blocked")
	assert_eq(sink.commit_attempts, attempts, "no write route reached the sink")

	assert_eq(controller.reconcile(), CommitSink.COMMITTED)
	assert_false(controller.is_blocked())
	var settled: GameState = controller.snapshot()
	assert_eq(settled.durable_revision, parent_revision + 1)
	assert_eq(settled.player.coins, coins_before - 18, "debited exactly once")
	assert_eq(published.size(), 1, "events published once after reconciliation")
	var retry: CommandResult = controller.submit_intent(intent)
	assert_true(retry.success, "lost acknowledgement resolves to the recorded success")
	assert_eq(controller.snapshot().player.coins, coins_before - 18, "never a second debit")
	assert_eq(controller.accepted_log().size(), 1)


func test_av002_02_definite_rollback_and_unreadable_state() -> void:
	_start()
	var parent: GameState = controller.snapshot()
	sink.script_modes = [FakeCommitSink.MODE_UNKNOWN_UNWRITTEN]
	var intent: RawIntent = _plant_corn("buy-1", 1)
	assert_eq(controller.submit_intent(intent).commit_status, CommitSink.UNKNOWN)
	sink.unreadable = true
	assert_eq(controller.reconcile(), CommitSink.UNKNOWN, "a failed read is not a rollback")
	assert_true(controller.is_blocked())
	sink.unreadable = false
	assert_eq(controller.reconcile(), CommitSink.NOT_COMMITTED, "verified unchanged parent")
	assert_false(controller.is_blocked())
	assert_eq(controller.snapshot().digest(), parent.digest())
	assert_eq(published.size(), 0)
	var retried: CommandResult = controller.submit_intent(intent)
	assert_true(retried.success, "definitely not committed: the intent may execute once")
	assert_eq(controller.snapshot().player.coins, parent.player.coins - 18)


func test_definite_not_committed_is_discarded_and_not_cached() -> void:
	_start()
	var parent: GameState = controller.snapshot()
	sink.script_modes = [FakeCommitSink.MODE_REJECT]
	var intent: RawIntent = _plant_corn("buy-1", 1)
	var result: CommandResult = controller.submit_intent(intent)
	assert_eq(result.commit_status, CommitSink.NOT_COMMITTED)
	assert_eq(result.failure_code, FailureCode.PERSISTENCE_UNAVAILABLE)
	assert_false(controller.is_blocked())
	assert_eq(controller.snapshot().digest(), parent.digest())
	assert_true(controller.submit_intent(intent).success)


func test_unknown_on_time_only_checkpoint_blocks_and_reconciles() -> void:
	_start()
	assert_true(controller.submit_intent(_plant_corn("buy-1", 1)).success)
	sink.script_modes = [FakeCommitSink.MODE_LOST_ACK]
	assert_eq(controller.advance_active(CORN_US), CommitSink.UNKNOWN)
	assert_eq(controller.submit_intent(RawIntent.harvest("h-1", 1, null)).failure_code, FailureCode.PERSISTENCE_UNAVAILABLE)
	assert_eq(controller.reconcile(), CommitSink.COMMITTED)
	assert_eq(controller.snapshot().plot(1).crop_cycle.status, CropCycle.STATUS_READY)
	assert_eq(published.size(), 2, "planting, then maturity after reconciliation")


func test_av002_05_reconciled_run_equals_uninterrupted_run() -> void:
	var script: Array[Array] = [
		[0, "plant", 1, "corn"], [0, "plant", 2, "wheat"], [480_000_000, "harvest", 2, ""],
		[480_000_000, "plant", 2, "wheat"], [CORN_US, "harvest", 1, ""], [CORN_US, "plant", 1, "corn"],
	]
	var initial: GameState = Fixtures.new_game()
	Fixtures.unlock_crop(initial, "corn")
	initial.player.coins = 1_000
	var clean: ScenarioDriver = ScenarioDriver.new(initial, Fixtures.uuid("A"), ScenarioDriver.MODE_ACTIVE_1X, 11)
	clean.run(script, 3_600_000_000)

	var faulty: ScenarioDriver = ScenarioDriver.new(initial, Fixtures.uuid("A"), ScenarioDriver.MODE_ACTIVE_1X, 11)
	# Lose the receipt of the script's first purchase (driver intent "intent-1").
	faulty.sink.script_modes = [FakeCommitSink.MODE_LOST_ACK]
	faulty.controller.submit_intent(RawIntent.plant("intent-1", 1, faulty.controller.quote_plant("corn")))
	assert_true(faulty.controller.is_blocked(), "fault injected")
	assert_eq(faulty.controller.reconcile(), CommitSink.COMMITTED)
	# Continue the same script; already-recorded intents return their recorded results.
	faulty.run(script, 3_600_000_000)

	var a: GameState = clean.final_state()
	var b: GameState = faulty.final_state()
	assert_eq(b.gameplay_digest(), a.gameplay_digest(), "full gameplay state, replay marks and IDs match")
	assert_eq(CanonicalCodec.digest(faulty.controller.accepted_log()), CanonicalCodec.digest(clean.controller.accepted_log()))
	assert_eq(b.time_anchor.credited_through_utc_us, a.time_anchor.credited_through_utc_us, "real-time accounting matches")


func test_checkpoint_cadence_never_changes_gameplay_ids() -> void:
	var script: Array[Array] = [[0, "plant", 1, "wheat"], [480_000_000, "harvest", 1, ""], [480_000_000, "plant", 1, "wheat"]]
	var many: ScenarioDriver = ScenarioDriver.new(Fixtures.new_game(), Fixtures.uuid("A"), ScenarioDriver.MODE_ACTIVE_1X, 1)
	many.run(script, 960_000_000)
	var few: ScenarioDriver = ScenarioDriver.new(Fixtures.new_game(), Fixtures.uuid("A"), ScenarioDriver.MODE_OFFLINE, 1)
	few.run(script, 960_000_000)
	assert_eq(many.final_state().gameplay_digest(), few.final_state().gameplay_digest())
	assert_ne(many.final_state().durable_revision, few.final_state().durable_revision, "different checkpoint counts")
	assert_eq(many.final_state().next_entity_id, few.final_state().next_entity_id)


func test_startup_unknown_blocks_until_reconciled() -> void:
	sink = FakeCommitSink.new()
	sink.script_modes = [FakeCommitSink.MODE_LOST_ACK]
	controller = GameController.new(ManifestFixtures.catalog(), sink)
	assert_eq(controller.start(Fixtures.new_game(), Fixtures.uuid("A")), PackedStringArray())
	assert_true(controller.is_blocked())
	assert_eq(controller.advance_active(1), GameController.STATUS_BLOCKED)
	assert_eq(controller.reconcile(), CommitSink.COMMITTED)
	assert_eq(controller.snapshot().durable_revision, 1)
