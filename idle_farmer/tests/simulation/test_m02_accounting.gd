extends GutTest
## M02-T16 (TRS §§3.5, 10; E13; carry-over 1): every economic path emits its own immutable
## category; cash flow and completed-cycle operating profit stay separate; the committed-harvest
## port publishes typed records only after a durable commit and cannot be used to mutate state.

const MINUTE_US: int = 60_000_000
const CORN_US: int = 30 * MINUTE_US

var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry_v2()


func _level7_corn() -> GameState:
	var state: GameState = Fixtures.new_game_v2()
	Fixtures.unlock_crop(state, "corn")
	AutomationFixtures.level7_automation(state)
	state.player.coins = 10_000
	return state


func test_every_category_with_exact_cash_flow() -> void:
	var state: GameState = _level7_corn()
	var engine: SimulationEngine = Fixtures.engine_for(state)
	var transactions: Array[EconomicTransaction] = []
	var counter: Array[int] = [0]
	var submit: Callable = func(type: String, terms: Dictionary) -> void:
		counter[0] += 1
		var result: CommandResult = engine.submit_command(Fixtures.command(state, type, terms, counter[0]))
		assert_true(result.success, "%s: %s" % [type, result.failure_code])
		transactions.append_array(result.transactions)
	AutomationFixtures.configure_plot(state, 1, "corn", true, true, "basic")
	submit.call(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("p", 1, FarmSystem.quote_for(state, registry, "corn", "basic", 1)).terms)
	assert_true(state.automation.plot(1).authorization.armed, "the matching Plant armed the loop")
	submit.call(GameCommand.TYPE_PURCHASE_UPGRADE, PurchaseSystem.quote_upgrade(state, registry, "irrigation"))
	submit.call(GameCommand.TYPE_PURCHASE_PLOT, PurchaseSystem.quote_plot(state, registry))
	submit.call(GameCommand.TYPE_START_RESEARCH, ResearchSystem.quote_start(registry, "unlock_tomatoes"))
	submit.call(GameCommand.TYPE_ACCELERATE_RESEARCH, ResearchSystem.quote_boost(state))
	transactions.append_array(engine.advance_to(CORN_US).transactions)
	assert_eq(state.player.level, 7)
	submit.call(GameCommand.TYPE_RESET_SKILLS, SkillSystem.quote_reset(state, registry))
	for tx: EconomicTransaction in transactions:
		assert_true(tx.is_consistent(), "%s %s" % [tx.type(), tx.category()])
		assert_not_null(EconomicTransaction.from_primitive(tx.to_primitive()), "round trip %s" % tx.type())
	var flow: Dictionary = Accounting.cash_flow(transactions)
	# Corn 18 seed + Basic 20 at planting and again at the automatic replant; gross ⌊110 × 1.25⌋ = 137.
	assert_eq(flow, {"seeds": -36, "fertilizer": -40, "harvest": 137, "expansion": -250, "equipment": -650,
		"research": -2_800 - 1_400, "reset": -2_450, "contracts": 0, "xp": 32})
	var total: int = 0
	for key: String in flow:
		total += flow[key] if key != "xp" else 0
	assert_eq(state.player.coins, 10_000 + total, "cash flow reconciles with the wallet")
	var origins: Dictionary = {}
	for tx: EconomicTransaction in transactions:
		origins["%s/%s" % [tx.type(), tx.origin()]] = true
	assert_true(origins.has("harvest_credit/automatic") and origins.has("seed_purchase/manual") and origins.has("seed_purchase/automatic"))


func test_transaction_rules_reject_inconsistent_records() -> void:
	var cycle: EntityId = EntityId.new("s", "n", 1)
	var good: EconomicTransaction = EconomicTransaction.new(EntityId.new("s", "n", 2), 5, EconomicTransaction.TYPE_SEED_PURCHASE,
		1, cycle, -18, 0, EconomicTransaction.CATEGORY_SEEDS, "content_m02_v1", EconomicTransaction.ORIGIN_MANUAL)
	assert_not_null(EconomicTransaction.from_primitive(good.to_primitive()))
	var cases: Dictionary = {
		"wrong category": func(p: Dictionary) -> void: p["category"] = "harvest",
		"wrong sign": func(p: Dictionary) -> void: p["coin_delta"] = 18,
		"missing cycle": func(p: Dictionary) -> void: p["cycle_id"] = null,
		"unknown type": func(p: Dictionary) -> void: p["type"] = "gift",
		"negative xp": func(p: Dictionary) -> void: p["xp_delta"] = -1,
	}
	for label: String in cases:
		var primitive: Dictionary = good.to_primitive()
		(cases[label] as Callable).call(primitive)
		assert_null(EconomicTransaction.from_primitive(primitive), label)


func _controller(state: GameState, sink: FakeCommitSink) -> GameController:
	var controller: GameController = GameController.new(ManifestFixtures.catalog(), sink)
	assert_eq(controller.start(state, Fixtures.uuid("B")), PackedStringArray())
	return controller


func test_committed_harvest_port_publishes_after_commit_only() -> void:
	var state: GameState = _level7_corn()
	AutomationFixtures.configure_plot(state, 1, "corn", true, true, "basic")
	AutomationFixtures.configure_plot(state, 2, "wheat", false, false)
	var sink: FakeCommitSink = FakeCommitSink.new()
	var controller: GameController = _controller(state, sink)
	var records: Array[CommittedHarvest] = []
	controller.add_committed_harvest_observer(func(h: CommittedHarvest) -> void: records.append(h))
	controller.add_commit_listener(func(events: Array) -> void:
		for event: SimulationEvent in events:
			event.data["coins"] = -1)  # a misbehaving presentation listener
	assert_true(controller.submit_intent(RawIntent.plant("p1", 1, controller.quote_plant_on(1, "corn", "basic"))).success)
	assert_true(controller.submit_intent(RawIntent.plant("p2", 2, controller.quote_plant("wheat"))).success)
	assert_eq(records.size(), 0, "planting publishes no harvest")
	# A NOT_COMMITTED advance publishes nothing, and the harvest is not lost: it commits next time.
	sink.script_modes = [FakeCommitSink.MODE_REJECT]
	assert_eq(controller.advance_active(CORN_US), CommitSink.NOT_COMMITTED)
	assert_eq(records.size(), 0, "no observer call for an uncommitted candidate")
	# A lost acknowledgement publishes only after reconcile confirms the commit.
	sink.script_modes = [FakeCommitSink.MODE_LOST_ACK]
	assert_eq(controller.advance_active(CORN_US), CommitSink.UNKNOWN)
	assert_eq(records.size(), 0, "UNKNOWN is not published")
	assert_eq(controller.reconcile(), CommitSink.COMMITTED)
	assert_eq(records.size(), 1, "published once the commit is confirmed")
	var corn: CommittedHarvest = records[0]
	var committed: GameState = controller.snapshot()
	assert_eq([corn.time_us(), corn.state_sequence(), corn.ordinal(), corn.plot_id(), corn.crop_id(), corn.quantity()],
		[CORN_US, committed.state_sequence, 0, 1, "corn", 1])
	assert_eq([corn.gross(), corn.xp(), corn.origin(), corn.seed_cost(), corn.fertilizer_id(), corn.fertilizer_cost()],
		[137, 32, EconomicTransaction.ORIGIN_AUTOMATIC, 18, "basic", 20], "built before the listener mutated the event")
	assert_eq(corn.operating_profit(), 137 - 18 - 20)
	# Plot 2 Wheat is Ready but manual: its harvest arrives through a command.
	var wheat_cycle: EntityId = committed.plot(2).crop_cycle.cycle_id
	assert_true(controller.submit_intent(RawIntent.harvest("h2", 2, wheat_cycle)).success)
	assert_eq(records.size(), 2)
	assert_eq([records[1].origin(), records[1].gross(), records[1].cycle_id().key()], [EconomicTransaction.ORIGIN_MANUAL, 16, wheat_cycle.key()])
	var rejected: CommandResult = controller.submit_intent(RawIntent.harvest("h2-again", 2, wheat_cycle))
	assert_false(rejected.success)
	assert_eq(records.size(), 2, "a rejected command publishes nothing")
	var totals: Dictionary = Accounting.operating(records)
	assert_eq(totals, {"harvests": 2, "gross": 153, "seed_costs": 18, "fertilizer_costs": 20, "operating_profit": 115,
		"manual": 1, "automatic": 1})


func test_observers_cannot_mutate_state() -> void:
	var state: GameState = _level7_corn()
	AutomationFixtures.configure_plot(state, 1, "wheat", true, false)
	var controller: GameController = _controller(state, FakeCommitSink.new())
	var seen: Array[String] = []
	# The observer receives only an immutable record; mutating what it returns changes nothing.
	controller.add_committed_harvest_observer(func(h: CommittedHarvest) -> void:
		var id: EntityId = h.cycle_id()
		id.counter = 999
		seen.append(h.cycle_id().key()))
	assert_true(controller.submit_intent(RawIntent.plant("p", 1, controller.quote_plant("wheat"))).success)
	assert_eq(controller.advance_active(8 * MINUTE_US), CommitSink.COMMITTED)
	assert_eq(controller.snapshot().player.coins, 10_016, "only the committed harvest credit")
	assert_eq(seen.size(), 1)
	assert_false(seen[0].ends_with("/999"), "cycle_id() returns a copy")
