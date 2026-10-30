extends GutTest
## M02 V08 (DEC-009, FRS §7.2): a 32-plot mixed Smart farm through the batch planner. The proposal
## is valid (budget, authorization, positive-net choices), deterministic across permutations of how
## the farm was built, and a repeat of identical inputs is served from the solver cache. Runtime is
## printed for the evidence; the timing gate lives in balancing/test_smart_benchmark.gd.

const CROPS: PackedStringArray = ["tomatoes", "pumpkins", "sunflowers", "strawberries", "blueberries", "soybeans", "grapes", "coffee"]

var registry: ContentRegistry


func before_each() -> void:
	FertilizerOptimizer.clear_cache()
	registry = Fixtures.registry_v2()


func _farm(order: Array[int], coins: int) -> GameState:
	var state: GameState = Fixtures.new_game_v2()
	state.simulation_time_us = 1_000 * 60_000_000
	Fixtures.unlock_prefix(state, 32)
	for crop: String in CROPS:
		Fixtures.unlock_crop(state, crop)
	var chain: PackedStringArray = AutomationFixtures.AUTOMATION_CHAIN.duplicate()
	chain.append("smart_fertilizer")
	AutomationFixtures.with_skills(state, 20, chain)
	for id: int in order:
		AutomationFixtures.loop_plot(state, id, CROPS[(id - 1) % CROPS.size()], "smart_mp")
		state.plot(id).stall_reason = PlotState.STALL_SEED_FUNDS
	state.player.coins = coins
	return state


func _ascending() -> Array[int]:
	var order: Array[int] = []
	for id: int in range(1, 33):
		order.append(id)
	return order


func _choices(proposal: BatchProposal) -> Array:
	var view: Array = []
	for planting: Dictionary in proposal.plantings:
		view.append([planting["plot_id"], (planting["quote"] as PlantingQuote).fertilizer_id])
	return view


func _assert_valid(state: GameState, proposal: BatchProposal, label: String) -> void:
	assert_eq(proposal.failure_code, FailureCode.NONE, label)
	assert_eq(proposal.plantings.size(), 32, "%s: all 32 planted" % label)
	var fertilizer: int = 0
	for planting: Dictionary in proposal.plantings:
		var quote: PlantingQuote = planting["quote"]
		fertilizer += quote.fertilizer_cost
		if quote.fertilizer_id != FertilizerDefinition.NONE_ID:
			assert_gt(quote.incremental_fertilizer_net(), 0, "%s plot %d: Smart never buys a non-positive option" % [label, planting["plot_id"]])
		assert_true(state.automation.plot(planting["plot_id"]).authorization.armed, label)
	assert_eq(fertilizer, proposal.allocation["smart_spend"], label)
	assert_lte(fertilizer, proposal.allocation["M"], "%s: within M" % label)


func test_v08_ample_and_half_budget() -> void:
	var seeds: int = 0
	for id: int in range(1, 33):
		seeds += registry.crop(CROPS[(id - 1) % CROPS.size()]).seed_cost
	for label: String in ["ample", "half"]:
		FertilizerOptimizer.clear_cache()
		var coins: int = seeds + (100_000 if label == "ample" else 15_000)
		var state: GameState = _farm(_ascending(), coins)
		var start: int = Time.get_ticks_usec()
		var proposal: BatchProposal = BatchPlanner.plan(state, registry, {"retry_all": true})
		var cold_us: int = Time.get_ticks_usec() - start
		_assert_valid(state, proposal, label)
		start = Time.get_ticks_usec()
		var repeat: BatchProposal = BatchPlanner.plan(state, registry, {"retry_all": true})
		var warm_us: int = Time.get_ticks_usec() - start
		assert_eq(_choices(repeat), _choices(proposal), "%s: repeat identical" % label)
		assert_gt(FertilizerOptimizer.cache_hits, 0, "%s: identical inputs served from the cache" % label)
		gut.p("V08 %s: M=%d spend=%d plan cold %.2f ms, warm %.2f ms" % [label, proposal.allocation["M"],
			proposal.allocation["smart_spend"], cold_us / 1000.0, warm_us / 1000.0])
		var reversed: Array[int] = _ascending()
		reversed.reverse()
		FertilizerOptimizer.clear_cache()
		var other: GameState = _farm(reversed, coins)
		assert_eq(_choices(BatchPlanner.plan(other, registry, {"retry_all": true})), _choices(proposal), "%s: permutation" % label)


func test_v08_budget_starved_farm_still_plants_seeds() -> void:
	var seeds: int = 0
	for id: int in range(1, 33):
		seeds += registry.crop(CROPS[(id - 1) % CROPS.size()]).seed_cost
	var state: GameState = _farm(_ascending(), seeds)
	var proposal: BatchProposal = BatchPlanner.plan(state, registry, {"retry_all": true})
	assert_eq(proposal.allocation["M"], 0)
	assert_eq(proposal.plantings.size(), 32)
	assert_eq(proposal.allocation["smart_spend"], 0, "no optional money, no fertilizer")
