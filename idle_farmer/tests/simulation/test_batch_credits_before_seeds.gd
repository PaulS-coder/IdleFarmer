extends GutTest
## M02 V03 / E4 / E8 (TRS §4.2, FRS §7.1): every harvest credit in a logical batch precedes seed
## reservation; one wallet funds all 32 plots; the order in which cycles were created (and so
## their scheduler insertion order) does not change the outcome; the planner never mutates its
## input; BatchHarvest pools only its own credits.

const MINUTE_US: int = 60_000_000
const T_US: int = 500 * MINUTE_US

var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry_v2()


## 32 armed loops whose cycles all mature at T, created in `order`. Plot 1 harvests Wheat (16) but
## replants Tomatoes (seed 55); plot 32 harvests Pumpkins (1,200); the rest harvest and replant Wheat.
func _farm(order: Array[int]) -> GameState:
	var state: GameState = Fixtures.new_game_v2()
	state.simulation_time_us = T_US - 1
	Fixtures.unlock_prefix(state, 32)
	Fixtures.unlock_crop(state, "tomatoes")
	Fixtures.unlock_crop(state, "pumpkins")
	AutomationFixtures.with_skills(state, 10, AutomationFixtures.AUTOMATION_CHAIN)
	for plot_id: int in order:
		var crop: String = "pumpkins" if plot_id == 32 else "wheat"
		Fixtures.add_cycle(state, plot_id, crop, T_US - registry.crop(crop).base_growth_us)
		AutomationFixtures.loop_plot(state, plot_id, "tomatoes" if plot_id == 1 else "wheat")
	return state


func _ascending() -> Array[int]:
	var order: Array[int] = []
	for id: int in range(1, 33):
		order.append(id)
	return order


func test_v03_credits_precede_seed_reservation() -> void:
	var state: GameState = _farm(_ascending())
	assert_eq(state.player.coins, 0, "nothing in the wallet before the batch")
	var engine: SimulationEngine = Fixtures.engine_for(state)
	var batch: StateChangeBatch = engine.advance_to(T_US)
	var harvests: int = 0
	var plantings: int = 0
	var last_credit: int = -1
	var first_purchase: int = -1
	for i: int in batch.transactions.size():
		var tx: EconomicTransaction = batch.transactions[i]
		if tx.type() == EconomicTransaction.TYPE_HARVEST_CREDIT:
			harvests += 1
			last_credit = i
		else:
			plantings += 1
			first_purchase = i if first_purchase == -1 else first_purchase
	assert_eq(harvests, 32)
	assert_eq(plantings, 32, "one wallet funds all 32 replants")
	assert_lt(last_credit, first_purchase, "all credits are recorded before any seed purchase")
	# Plot 1's own credit (16) cannot pay its Tomatoes seed (55): only the pooled batch credits can.
	assert_eq(state.plot(1).crop_cycle.crop_id, "tomatoes")
	assert_eq(state.player.coins, 31 * 16 + 1200 - 55)
	assert_eq(state.state_sequence, 1, "one logical batch")
	assert_eq(state.validate(registry), PackedStringArray())


func test_planner_does_not_mutate_its_input() -> void:
	var state: GameState = _farm(_ascending())
	state.simulation_time_us = T_US
	for plot: PlotState in state.plots:
		plot.crop_cycle.status = CropCycle.STATUS_READY
	var before: String = state.digest()
	var proposal: BatchProposal = BatchPlanner.plan(state, registry, {"auto_harvest": true})
	assert_eq(state.digest(), before)
	assert_eq([proposal.harvests.size(), proposal.plantings.size()], [32, 32])
	assert_eq(proposal.allocation["wallet"], 31 * 16 + 1200, "W includes every credit of the batch")


func test_v03_creation_order_does_not_change_the_outcome() -> void:
	var descending: Array[int] = _ascending()
	descending.reverse()
	var shuffled: Array[int] = _ascending()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	for i: int in range(shuffled.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var tmp: int = shuffled[i]
		shuffled[i] = shuffled[j]
		shuffled[j] = tmp
	var views: Array[String] = []
	for order: Array[int] in [_ascending(), descending, shuffled]:
		var state: GameState = _farm(order)
		Fixtures.engine_for(state).advance_to(T_US + 8 * MINUTE_US)
		var view: Array = AutomationFixtures.farm_view(state)
		view.append([state.player.total_xp, state.player.level])
		views.append(CanonicalCodec.digest(view))
	assert_eq(views[1], views[0], "descending creation order")
	assert_eq(views[2], views[0], "shuffled creation order")


func test_e8_batch_harvest_pools_only_its_own_credits() -> void:
	var state: GameState = Fixtures.new_game_v2()
	state.simulation_time_us = T_US
	Fixtures.unlock_crop(state, "tomatoes")
	Fixtures.unlock_crop(state, "pumpkins")
	AutomationFixtures.with_skills(state, 10, AutomationFixtures.AUTOMATION_CHAIN)
	AutomationFixtures.ready_cycle(state, 1, "wheat")
	AutomationFixtures.ready_cycle(state, 2, "pumpkins")
	AutomationFixtures.ready_cycle(state, 3, "pumpkins")
	AutomationFixtures.configure_plot(state, 1, "tomatoes", false, true)
	AutomationFixtures.arm(state, 1)
	var engine: SimulationEngine = Fixtures.engine_for(state)
	var members: Array = [{"plot_id": 1, "cycle_id": state.plot(1).crop_cycle.cycle_id.to_primitive()},
		{"plot_id": 2, "cycle_id": state.plot(2).crop_cycle.cycle_id.to_primitive()}]
	var result: CommandResult = engine.submit_command(Fixtures.command(state, GameCommand.TYPE_BATCH_HARVEST, {"members": members}, 1))
	assert_true(result.success, result.failure_code)
	assert_eq(state.plot(1).crop_cycle.crop_id, "tomatoes", "plot 2's credit in the same command funds plot 1's seed")
	assert_eq(state.plot(3).crop_cycle.status, CropCycle.STATUS_READY, "unselected plot untouched")
	assert_eq(state.player.coins, 16 + 1200 - 55)
	assert_eq(result.member_outcomes.size(), 2)
