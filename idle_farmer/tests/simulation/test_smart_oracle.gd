extends GutTest
## M02 V07 / V13 / AV-005-05 through the batch planner (FRS §§7.1–7.3, DVS-008/010): Smart
## policies choose fertilizer from the one M and C of the batch after seeds and fixed rules; the
## Budget Protection ceiling is shared and never reserved; stall events never schedule work.

const MINUTE_US: int = 60_000_000

var state: GameState
var registry: ContentRegistry


func before_each() -> void:
	FertilizerOptimizer.clear_cache()
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	state.simulation_time_us = 500 * MINUTE_US
	Fixtures.unlock_crop(state, "tomatoes")
	Fixtures.unlock_crop(state, "pumpkins")
	var chain: PackedStringArray = AutomationFixtures.AUTOMATION_CHAIN.duplicate()
	chain.append("smart_fertilizer")
	AutomationFixtures.with_skills(state, 10, chain)


## Empty armed stalled loops (as after an earlier unfunded batch), retried by a budget change.
func _loops(plans: Array, coins: int) -> BatchProposal:
	for plan: Array in plans:
		AutomationFixtures.loop_plot(state, plan[0], plan[1], plan[2])
		state.plot(plan[0]).stall_reason = PlotState.STALL_SEED_FUNDS
	state.player.coins = coins
	return BatchPlanner.plan(state, registry, {"retry_all": true})


func _fertilizers(proposal: BatchProposal) -> Dictionary:
	var chosen: Dictionary = {}
	for planting: Dictionary in proposal.plantings:
		chosen[planting["plot_id"]] = (planting["quote"] as PlantingQuote).fertilizer_id
	return chosen


func test_v07_dvs010_maximum_profit() -> void:
	# W = 205, R = 0: seeds 2 × 55 leave 95 for fertilizer.
	var proposal: BatchProposal = _loops([[1, "tomatoes", "smart_mp"], [2, "tomatoes", "smart_mp"]], 205)
	assert_eq(_fertilizers(proposal), {1: "basic", 2: "basic"})
	assert_eq([proposal.allocation["M"], proposal.allocation["smart_spend"]], [95, 82])
	BatchApplier.apply(state, registry, EventScheduler.new(), proposal)
	assert_eq(state.player.coins, 205 - 110 - 82)
	assert_eq(state.plot(1).crop_cycle.gross_coin_reward, 337, "Tomatoes with Basic: floor(270 × 1.25)")


func test_v07_dvs010_budget_protection_25_percent() -> void:
	var proposal: BatchProposal = _loops([[1, "tomatoes", "smart_bp"], [2, "tomatoes", "smart_bp"]], 205)
	assert_eq(proposal.allocation["C"], 23)
	assert_eq(_fertilizers(proposal), {1: "none", 2: "none"}, "C = 23 cannot buy Basic (41)")


func test_v07_dvs010_budget_41_and_capital_efficiency() -> void:
	var proposal: BatchProposal = _loops([[1, "tomatoes", "smart_mp"], [2, "tomatoes", "smart_mp"]], 151)
	assert_eq(_fertilizers(proposal), {1: "basic", 2: "none"}, "tie: the lower plot ID gets Basic")
	state = Fixtures.new_game_v2()
	before_each()
	proposal = _loops([[1, "tomatoes", "smart_ce"], [2, "tomatoes", "smart_ce"]], 205)
	assert_eq(_fertilizers(proposal), {1: "basic", 2: "basic"}, "CE takes the best ROI (Basic) first")


func test_v13_one_ceiling_after_seeds_and_fixed() -> void:
	state.automation.budget_reserve = 100
	# Plots 1–2 fixed Basic (F = 82); plots 3–5 Budget Protection. W = 1,000, S = 5 × 55 = 275.
	var proposal: BatchProposal = _loops([[1, "tomatoes", "basic"], [2, "tomatoes", "basic"], [3, "tomatoes", "smart_bp"],
		[4, "tomatoes", "smart_bp"], [5, "tomatoes", "smart_bp"]], 1_000)
	var a: Dictionary = proposal.allocation
	assert_eq([a["S"], a["A"], a["F"], a["M"], a["C"]], [275, 625, 82, 543, 135], "A = W−S−R, M = A−F, C = ⌊M·25/100⌋ once")
	assert_lte(a["bp_spend"], a["C"])
	assert_eq(a["bp_spend"], 123, "three Basics (123) fit under C; a Premium + Basic (136) does not")
	BatchApplier.apply(state, registry, EventScheduler.new(), proposal)
	assert_eq(state.player.coins, 1_000 - 275 - 82 - 123)
	assert_gte(state.player.coins, 1_000 - 275 - 82 - 135, "wallet never below W − S − F − C")


func test_v13_earlier_groups_can_leave_budget_protection_less() -> void:
	state.automation.budget_protection_percent = 50
	# M = 1,000 − 4 × 55 = 780, C = 390. MP on plots 1–2 spends first from M.
	var proposal: BatchProposal = _loops([[1, "tomatoes", "smart_mp"], [2, "tomatoes", "smart_mp"], [3, "tomatoes", "smart_bp"],
		[4, "tomatoes", "smart_bp"]], 1_000)
	var a: Dictionary = proposal.allocation
	assert_eq([a["M"], a["C"]], [780, 390])
	var mp_spend: int = a["smart_spend"] - a["bp_spend"]
	assert_gt(mp_spend, 0)
	assert_lte(a["bp_spend"], mini(a["C"], a["M"] - mp_spend), "BP limited by the remaining M and C")
	var alone: BatchProposal = BatchPlanner.plan(state, registry, {"retry_all": true})
	assert_eq(alone.allocation, a, "the planner is deterministic")


func test_v13_group_order_priority_then_mp_ce_bp() -> void:
	state.automation.budget_protection_percent = 100
	# Three Tomatoes loops, one per mode; seeds 165. With M = 41 only one Basic fits: MP goes first.
	var proposal: BatchProposal = _loops([[1, "tomatoes", "smart_bp"], [2, "tomatoes", "smart_ce"], [3, "tomatoes", "smart_mp"]], 206)
	assert_eq(proposal.allocation["M"], 41)
	assert_eq(_fertilizers(proposal), {1: "none", 2: "none", 3: "basic"}, "MP before CE before BP")
	state.player.coins = 247
	proposal = BatchPlanner.plan(state, registry, {"retry_all": true})
	assert_eq(_fertilizers(proposal), {1: "none", 2: "basic", 3: "basic"}, "M = 82: CE next; BP gets what is left (nothing)")
	# Custom priority (fixture-only, Q3) outranks mode order.
	state.automation.plot(1).settings.set_value(FarmingSettings.PRIORITY, 1)
	state.player.coins = 206
	proposal = BatchPlanner.plan(state, registry, {"retry_all": true})
	assert_eq(_fertilizers(proposal), {1: "basic", 2: "none", 3: "none"}, "higher priority group funded first")


func test_smart_without_capability_stays_inactive() -> void:
	AutomationFixtures.with_skills(state, 10, AutomationFixtures.AUTOMATION_CHAIN)
	var proposal: BatchProposal = _loops([[1, "tomatoes", "smart_mp"]], 500)
	assert_eq(proposal.plantings.size(), 0, "a stored Smart rule without the skill never authorizes spending")
	assert_eq(proposal.stalls, {1: PlotState.STALL_CAPABILITY} as Dictionary[int, String])


func test_av005_05_stalls_never_schedule_zero_time_work() -> void:
	# Plot 1's Pumpkins (1,200) matures at t and is harvested automatically; plots 2–6 are stalled
	# Pumpkins loops (seed 300 each). The credit funds four replants; the rest stay stalled.
	AutomationFixtures.loop_plot(state, 1, "pumpkins", "smart_mp")
	var t: int = state.simulation_time_us + MINUTE_US
	Fixtures.add_cycle(state, 1, "pumpkins", t - registry.crop("pumpkins").base_growth_us)
	for id: int in range(2, 7):
		AutomationFixtures.loop_plot(state, id, "pumpkins", "smart_mp")
		state.plot(id).stall_reason = PlotState.STALL_SEED_FUNDS
	state.player.coins = 0
	var engine: SimulationEngine = Fixtures.engine_for(state)
	var batch: StateChangeBatch = engine.advance_to(t)
	var planted: int = 0
	for id: int in range(1, 7):
		planted += 1 if state.plot(id).crop_cycle != null else 0
	assert_eq(planted, 4, "1,200 coins fund four 300-coin seeds")
	assert_eq(state.plot(6).stall_reason, PlotState.STALL_SEED_FUNDS)
	assert_eq(state.state_sequence, 1, "one logical batch")
	assert_ne(engine.get_next_event_time(), t, "a stall schedules nothing at the same time")
	var again: StateChangeBatch = engine.advance_to(t)
	assert_eq(again.events.size(), 0, "re-advancing to the same time does nothing")
	assert_eq(state.state_sequence, 1)
	assert_gt(batch.events.size(), 0)
