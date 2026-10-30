extends GutTest
## M02-T13/T14 (FRS §§7.2–7.3, DEC-009, Q2, E15): Smart group decisions against the independent
## Python oracle (M02OracleVectors.SMART), a GDScript brute force for groups of 8 plots or fewer,
## Capital Efficiency tie rules, exact comparisons and identical-input caching.

const MINUTE_US: int = 60_000_000


func before_each() -> void:
	FertilizerOptimizer.clear_cache()


func _members(plots: Array) -> Array:
	var members: Array = []
	for plot: Array in plots:
		members.append({"plot_id": plot[0], "duration_us": plot[1], "options": plot[2]})
	return members


func _groups(row_groups: Array) -> Array:
	var groups: Array = []
	for group: Array in row_groups:
		groups.append([group[0], _members(group[1])])
	return groups


func _tier_view(tiers: Dictionary) -> Array:
	var view: Array = []
	for plot_id: int in tiers:
		view.append([plot_id, tiers[plot_id]])
	view.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	return view


func test_v07_matches_oracle() -> void:
	for row: Array in M02OracleVectors.SMART:
		var result: Dictionary = FertilizerOptimizer.solve_groups(_groups(row[3]), row[1], row[2])
		assert_eq(_tier_view(result["tiers"]), row[4], "%s tiers" % row[0])
		assert_eq([result["spend"], result["bp_spend"]], [row[5], row[6]], "%s spend" % row[0])
		assert_lte(result["spend"], row[1], "%s within M" % row[0])
		assert_lte(result["bp_spend"], row[2], "%s within C" % row[0])


func test_v07_dvs010_named_outcomes() -> void:
	var plots: Array = []
	for row: Array in M02OracleVectors.SMART:
		if row[0] == "dvs010_mp":
			plots = row[3][0][1]
	var members: Array = _members(plots)
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 95), {"tiers": {1: 1, 2: 1}, "spend": 82},
		"MP: Basic + Basic, 52 coins/h")
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_BP, members, 23)["spend"], 0, "BP at 25%: C = 23 buys nothing")
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 41)["tiers"], {1: 1, 2: 0}, "plot 1 gets Basic")
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, members, 95)["tiers"], {1: 1, 2: 1}, "CE: Basic first")


## Exhaustive GDScript enumeration (E15 cross-check): maximize Σ net·(L/d) over all assignments with
## Σ cost ≤ budget, None for non-positive nets; ties: lower spend, then the higher tier on the
## lower plot ID. Durations come from a set whose lcm L keeps every numerator in int64.
func _brute_force(members: Array, budget: int) -> Array:
	var lcm_minutes: int = 720
	var choices: Array = []
	for member: Dictionary in members:
		var usable: Array = [[0, 0, 0]]
		for option: Array in member["options"]:
			if option[1] <= budget and option[2] > 0:
				usable.append(option)
		choices.append(usable)
	var best: Array = []
	var best_key: Array = []
	var index: PackedInt32Array = PackedInt32Array()
	index.resize(members.size())
	while true:
		var spend: int = 0
		var rate: int = 0
		var tiers: Array = []
		for i: int in members.size():
			var option: Array = choices[i][index[i]]
			spend += option[1]
			rate += option[2] * (lcm_minutes * MINUTE_US / members[i]["duration_us"])
			tiers.append(option[0])
		if spend <= budget:
			var key: Array = [rate, -spend]
			var better: bool = best.is_empty() or rate > best_key[0] or (rate == best_key[0] and -spend > best_key[1])
			if not better and rate == best_key[0] and -spend == best_key[1]:
				for i: int in tiers.size():
					if tiers[i] != best[i]:
						better = tiers[i] > best[i]
						break
			if better:
				best = tiers
				best_key = key
		var position: int = 0
		while position < members.size():
			index[position] += 1
			if index[position] < choices[position].size():
				break
			index[position] = 0
			position += 1
		if position == members.size():
			break
	return best


func test_e15_brute_force_cross_check_up_to_8_plots() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 20261030
	var minutes: Array[int] = [8, 15, 30, 45, 60, 90, 120, 180, 240]
	for case: int in 14:
		var count: int = 3 + case % 6 if case < 12 else 8
		var members: Array = []
		var duration_choice: int = minutes[rng.randi_range(0, minutes.size() - 1)]
		for plot_id: int in range(1, count + 1):
			if case % 3 != 0:
				duration_choice = minutes[rng.randi_range(0, minutes.size() - 1)]
			var options: Array = []
			for tier: int in [1, 2, 3]:
				options.append([tier, rng.randi_range(0, 900), rng.randi_range(-100, 700)])
			members.append({"plot_id": plot_id, "duration_us": duration_choice * MINUTE_US, "options": options})
		var budget: int = rng.randi_range(0, 2500)
		var expected: Array = _brute_force(members, budget)
		for mode: String in [FertilizerOptimizer.MODE_MP, FertilizerOptimizer.MODE_BP]:
			var tiers: Dictionary = FertilizerOptimizer.solve(mode, members, budget)["tiers"]
			assert_eq(_tier_view(tiers).map(func(pair: Array) -> int: return pair[1]), expected, "case %d (%d plots) %s" % [case, count, mode])


func test_q2_capital_efficiency_ties() -> void:
	# Equal ROI 1/2 on both plots: the higher Δnet/duration wins (plot 2 is faster).
	var faster: Array = [{"plot_id": 1, "duration_us": 60 * MINUTE_US, "options": [[1, 20, 10]]},
		{"plot_id": 2, "duration_us": 30 * MINUTE_US, "options": [[1, 20, 10]]}]
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, faster, 20)["tiers"], {1: 0, 2: 1})
	# Equal ROI and Δrate: lower Δcost wins.
	var cheaper: Array = [{"plot_id": 1, "duration_us": 60 * MINUTE_US, "options": [[1, 40, 20]]},
		{"plot_id": 2, "duration_us": 30 * MINUTE_US, "options": [[1, 20, 10]]}]
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, cheaper, 40)["tiers"], {1: 0, 2: 1})
	# Fully equal steps: lower plot ID, then lower target tier.
	var same: Array = [{"plot_id": 2, "duration_us": 60 * MINUTE_US, "options": [[1, 20, 10], [2, 40, 20]]},
		{"plot_id": 1, "duration_us": 60 * MINUTE_US, "options": [[1, 20, 10], [2, 40, 20]]}]
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, same, 20)["tiers"], {1: 1, 2: 0})
	# Refresh after a pick: upgrading plot 1 from Basic to Premium is a new step with its own ROI.
	var upgrade: Array = [{"plot_id": 1, "duration_us": 60 * MINUTE_US, "options": [[1, 10, 10], [2, 30, 25]]},
		{"plot_id": 2, "duration_us": 60 * MINUTE_US, "options": [[1, 40, 15]]}]
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, upgrade, 30)["tiers"], {1: 2, 2: 0},
		"Basic (1.0), then Basic→Premium (15/20) beats plot 2 (15/40)")
	# None has no ROI: non-positive nets are never bought.
	var losing: Array = [{"plot_id": 1, "duration_us": 60 * MINUTE_US, "options": [[1, 20, 0], [2, 75, -5]]}]
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, losing, 1000), {"tiers": {1: 0}, "spend": 0})


func test_exact_product_comparison_beyond_int64() -> void:
	var big: int = 4_000_000_000_000
	assert_eq(FertilizerOptimizer.compare_products(big, big, big - 1, big), 1)
	assert_eq(FertilizerOptimizer.compare_products(big, big, big, big), 0)
	assert_eq(FertilizerOptimizer.compare_products(-big, big, 1, 1), -1)
	assert_eq(FertilizerOptimizer.compare_products(7, 3, 5, 4), 1)
	assert_eq(FertilizerOptimizer.compare_products(-3, 2, 2, -3), 0)


func test_identical_inputs_are_cached_without_changing_results() -> void:
	var members: Array = _members(M02OracleVectors.SMART[0][3][0][1])
	var cold: Dictionary = FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 95)
	var warm: Dictionary = FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 95)
	assert_eq(warm, cold)
	assert_eq([FertilizerOptimizer.cache_hits, FertilizerOptimizer.cache_misses], [1, 1])
	# Any funds at or above the most a group could spend give the same answer and the same key.
	var ample: Dictionary = FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 1_000_000)
	FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 2_000_000)
	assert_eq(FertilizerOptimizer.cache_hits, 2, "a growing wallet still hits the cache")
	FertilizerOptimizer.clear_cache()
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 1_000_000), ample, "same result uncached")
	var reversed: Array = members.duplicate(true)
	reversed.reverse()
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, reversed, 95), cold, "member order is irrelevant")
	for budget: int in FertilizerOptimizer.CACHE_CAPACITY + 10:
		FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, members, budget % 300)
	assert_lte(FertilizerOptimizer.cache_size(), FertilizerOptimizer.CACHE_CAPACITY, "bounded")
	# MP and CE disagree on the same inputs; the cache must keep them apart.
	var split: Array = [{"plot_id": 1, "duration_us": 60 * MINUTE_US, "options": [[1, 10, 10]]},
		{"plot_id": 2, "duration_us": 60 * MINUTE_US, "options": [[1, 95, 60]]}]
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, split, 100)["tiers"], {1: 0, 2: 1}, "MP: best rate")
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_CE, split, 100)["tiers"], {1: 1, 2: 0}, "CE: best ROI first")
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, split, 100)["tiers"], {1: 0, 2: 1}, "cached per mode")
	var returned: Dictionary = FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 95)
	returned["tiers"][1] = 3
	assert_eq(FertilizerOptimizer.solve(FertilizerOptimizer.MODE_MP, members, 95), cold, "callers cannot corrupt the cache")
