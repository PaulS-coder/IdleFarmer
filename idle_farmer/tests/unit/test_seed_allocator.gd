extends GutTest
## M02-T11/T12/T15, FR-AUD-005, AV-005-01–04, DVS-008: the pure seed-first allocator against the
## independent Python oracle (M02OracleVectors.ALLOCATOR), plus termination bounds and permutation
## invariance.


func _candidates(rows: Array) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row: Array in rows:
		result.append({"plot_id": row[0], "priority": row[1], "seed_cost": row[2], "fertilizer_id": "basic" if row[4] else "none",
			"fertilizer_price": row[3], "fixed": row[4], "fallback": row[5]})
	return result


func _funded_view(funded: Array) -> Array:
	var view: Array = []
	for member: Dictionary in funded:
		view.append([member["plot_id"], member["fertilizer_price"], member["fallback_used"]])
	return view


func _stall_view(stalls: Dictionary) -> Array:
	var view: Array = []
	for plot_id: int in stalls:
		view.append([plot_id, stalls[plot_id]])
	view.sort_custom(func(a: Array, b: Array) -> bool: return a[0] < b[0])
	return view


func test_allocator_matches_oracle() -> void:
	for row: Array in M02OracleVectors.ALLOCATOR:
		var result: Dictionary = SeedBudgetAllocator.allocate(row[1], row[2], row[3], row[4], _candidates(row[5]))
		assert_eq(_funded_view(result["funded"]), row[6], "%s funded" % row[0])
		assert_eq(_stall_view(result["stalls"]), row[7], "%s stalls" % row[0])
		assert_eq([result["S"], result["A"], result["F"], result["M"], result["C"], result["passes"], result["exclusions"]],
			[row[8], row[9], row[10], row[11], row[12], row[13], row[14]], "%s totals" % row[0])


func test_av005_02_bounds_and_permutation_invariance() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 20261030
	for row: Array in M02OracleVectors.ALLOCATOR:
		var candidates: Array[Dictionary] = _candidates(row[5])
		var expected: Dictionary = SeedBudgetAllocator.allocate(row[1], row[2], row[3], row[4], candidates)
		assert_lte(expected["exclusions"], candidates.size(), "%s ≤ N exclusions" % row[0])
		assert_lte(expected["passes"], candidates.size() + 1, "%s ≤ N+1 passes" % row[0])
		for _i: int in 3:
			var shuffled: Array[Dictionary] = candidates.duplicate(true)
			for i: int in range(shuffled.size() - 1, 0, -1):
				var j: int = rng.randi_range(0, i)
				var tmp: Dictionary = shuffled[i]
				shuffled[i] = shuffled[j]
				shuffled[j] = tmp
			var again: Dictionary = SeedBudgetAllocator.allocate(row[1], row[2], row[3], row[4], shuffled)
			assert_eq(CanonicalCodec.digest(PrimitiveReader.plain(again)), CanonicalCodec.digest(PrimitiveReader.plain(expected)),
				"%s permutation" % row[0])


func test_wallet_never_negative() -> void:
	for row: Array in M02OracleVectors.ALLOCATOR:
		var result: Dictionary = SeedBudgetAllocator.allocate(row[1], row[2], row[3], row[4], _candidates(row[5]))
		assert_gte(row[1] - result["S"] - result["F"], 0, row[0])
		assert_lte(result["C"], result["M"], row[0])
