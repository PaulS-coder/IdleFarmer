extends GutTest
## M02 V04 and AV-005-01/03/04 at engine level (FRS §§7.1, 9.2, E6): unfunded seeds and fixed
## fertilizer without fallback stall uncharged, fallback plants with None, R ≥ W still funds seeds,
## and a stalled authorized loop retries once on the next wallet credit, never on its own.

const MINUTE_US: int = 60_000_000
const CORN_US: int = 30 * MINUTE_US
const WHEAT_US: int = 8 * MINUTE_US

var state: GameState
var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	state.simulation_time_us = 500 * MINUTE_US
	Fixtures.unlock_crop(state, "corn")
	AutomationFixtures.level7_automation(state)


## Empty, armed, stalled loops (as after an earlier failed batch) with `coins` in the wallet.
func _stalled_loops(plans: Array, coins: int) -> void:
	for plan: Array in plans:
		AutomationFixtures.loop_plot(state, plan[0], "corn", plan[1], plan[2])
		state.plot(plan[0]).stall_reason = PlotState.STALL_SEED_FUNDS
	state.player.coins = coins


func _retry_all() -> BatchProposal:
	return BatchPlanner.plan(state, registry, {"retry_all": true})


func _apply(proposal: BatchProposal) -> void:
	BatchApplier.apply(state, registry, EventScheduler.new(), proposal)


func test_av005_01_premium_without_fallback_stalls() -> void:
	_stalled_loops([[1, "premium", false], [2, "none", false]], 100)
	var proposal: BatchProposal = _retry_all()
	_apply(proposal)
	assert_null(state.plot(1).crop_cycle, "plot 1 stalls")
	assert_eq(state.plot(1).stall_reason, PlotState.STALL_FERTILIZER_FUNDS)
	assert_eq(state.plot(2).crop_cycle.fertilizer_id, "none")
	assert_eq(state.player.coins, 82, "spend 18, end 82")
	assert_eq([proposal.allocation["passes"], proposal.allocation["exclusions"]], [2, 1])


func test_av005_01_with_fallback_plants_none() -> void:
	_stalled_loops([[1, "premium", true], [2, "none", false]], 100)
	_apply(_retry_all())
	assert_eq(state.plot(1).crop_cycle.fertilizer_id, "none", "accepted fallback: Corn without fertilizer")
	assert_eq(state.player.coins, 64)


func test_av005_03_replan_after_exclusion() -> void:
	_stalled_loops([[1, "basic", false], [2, "premium", false], [3, "none", false]], 100)
	var proposal: BatchProposal = _retry_all()
	assert_eq([proposal.allocation["S"], proposal.allocation["A"], proposal.allocation["F"], proposal.allocation["M"]], [36, 64, 20, 44])
	_apply(proposal)
	assert_eq(state.plot(1).crop_cycle.fertilizer_id, "basic")
	assert_null(state.plot(2).crop_cycle)
	assert_eq(state.plot(2).stall_reason, PlotState.STALL_FERTILIZER_FUNDS)
	assert_eq(state.plot(3).crop_cycle.fertilizer_id, "none")
	assert_eq(state.player.coins, 44)


func test_v04_unfunded_seed_stalls_uncharged() -> void:
	_stalled_loops([[1, "none", false], [2, "none", false]], 20)
	_apply(_retry_all())
	assert_not_null(state.plot(1).crop_cycle)
	assert_null(state.plot(2).crop_cycle)
	assert_eq(state.plot(2).stall_reason, PlotState.STALL_SEED_FUNDS)
	assert_eq(state.player.coins, 2)
	assert_eq(SettingsResolver.effective(state, 2).crop_id, "corn", "selected crop and settings kept")


func test_v04_reserve_above_wallet_still_funds_seeds() -> void:
	_stalled_loops([[1, "basic", true], [2, "basic", false]], 40)
	state.automation.budget_reserve = 500
	_apply(_retry_all())
	assert_eq(state.plot(1).crop_cycle.fertilizer_id, "none", "fallback: no optional spend while R ≥ W")
	assert_null(state.plot(2).crop_cycle, "fixed without fallback stalls")
	assert_eq(state.player.coins, 22, "the mandatory seed is still bought below R")


func test_v04_stalled_loop_retries_on_credit_only() -> void:
	AutomationFixtures.loop_plot(state, 3, "corn")
	state.plot(3).stall_reason = PlotState.STALL_SEED_FUNDS
	state.player.coins = 0
	# A manual-only Wheat plot matures: a batch without any wallet credit is not a retry trigger.
	Fixtures.add_cycle(state, 5, "wheat", state.simulation_time_us)
	var engine: SimulationEngine = Fixtures.engine_for(state)
	state.player.coins = 50
	engine.advance_to(state.simulation_time_us + WHEAT_US)
	assert_eq(state.plot(5).crop_cycle.status, CropCycle.STATUS_READY)
	assert_null(state.plot(3).crop_cycle, "maturity alone does not retry a stalled loop, even with funds")
	assert_eq(state.player.coins, 50)
	# Plot 1's automatic Corn harvest credits the wallet: the stalled loop retries inside that batch.
	AutomationFixtures.loop_plot(state, 1, "corn")
	Fixtures.add_cycle(state, 1, "corn", state.simulation_time_us)
	engine = Fixtures.engine_for(state)
	var batch: StateChangeBatch = engine.advance_to(state.simulation_time_us + CORN_US)
	assert_eq(state.plot(1).crop_cycle.planted_at_us, state.simulation_time_us, "plot 1 replanted")
	assert_eq(state.plot(3).crop_cycle.crop_id, "corn", "retried once inside the credit batch")
	assert_eq(state.plot(3).stall_reason, PlotState.STALL_NONE)
	assert_eq(state.player.coins, 50 + 110 - 18 - 18)
	var plantings: int = batch.events.filter(func(e: SimulationEvent) -> bool: return e.type == SimulationEvent.CROP_PLANTED).size()
	assert_eq(plantings, 2)


func test_av005_04_seed_protection_fixture_and_free_seeds() -> void:
	AutomationFixtures.loop_plot(state, 1, "corn")
	AutomationFixtures.loop_plot(state, 2, "corn")
	AutomationFixtures.loop_plot(state, 3, "wheat")
	for id: int in [1, 2, 3]:
		state.plot(id).stall_reason = PlotState.STALL_SEED_FUNDS
	state.player.coins = 30
	state.automation.budget_reserve = 100
	state.automation.budget_seed_protection = true
	_apply(_retry_all())
	assert_null(state.plot(1).crop_cycle, "paid seed protected below R")
	assert_null(state.plot(2).crop_cycle)
	assert_eq(state.plot(3).crop_cycle.crop_id, "wheat", "free seed still eligible below R")
	assert_eq(state.player.coins, 30)
