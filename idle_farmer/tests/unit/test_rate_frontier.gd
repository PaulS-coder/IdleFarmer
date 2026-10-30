extends GutTest
## M02 S0 / DEC-009: the exact rate frontier equals the independent exhaustive oracle on every
## vector (random small sets, identical-plot ties, BigInt-path durations, DVS-010).


func test_matches_exhaustive_oracle() -> void:
	var paths: Dictionary = {}
	for row: Array in M02OracleVectors.FRONTIER:
		var result: Dictionary = RateFrontier.solve(row[2], row[1])
		var name: String = row[0]
		assert_true(result["ok"], name)
		assert_eq(result["tiers"], row[3], "%s tiers" % name)
		assert_eq(result["spend"], row[4], "%s spend" % name)
		# rate_num / rate_den == oracle numerator / denominator  ⇔  cross products equal.
		var lhs: BigInt = (result["rate_num"] as BigInt).mul(BigInt.from_decimal(row[6]))
		var rhs: BigInt = BigInt.from_decimal(row[5]).mul(result["rate_den"] as BigInt)
		assert_true(lhs.equals(rhs), "%s rate %s/%s vs %s/%s" % [name, (result["rate_num"] as BigInt).to_decimal(),
			(result["rate_den"] as BigInt).to_decimal(), row[5], row[6]])
		paths[result["path"]] = true
	assert_true(paths.has(RateFrontier.PATH_APPROX), "integer-approximation decisions exercised")
	assert_true(paths.has(RateFrontier.PATH_EXACT), "exact BigInt fallback exercised (ties)")


func test_dvs010_named_outcomes() -> void:
	var tomato: Array = [[1, 41, 26], [2, 95, 40], [3, 240, 30]]
	var plots: Array = [[1, 3_600_000_000, tomato], [2, 3_600_000_000, tomato]]
	assert_eq(RateFrontier.solve(plots, 95)["tiers"], [1, 1], "MP: Basic twice beats one Premium")
	assert_eq(RateFrontier.solve(plots, 95)["spend"], 82)
	assert_eq(RateFrontier.solve(plots, 23)["tiers"], [0, 0], "BP ceiling 23 buys nothing")
	assert_eq(RateFrontier.solve(plots, 41)["tiers"], [1, 0], "tie: lower plot ID gets Basic")


func test_input_order_does_not_matter() -> void:
	var a: Array = [[3, 1_800_000_000, [[1, 20, 7]]], [1, 3_600_000_000, [[1, 41, 26], [2, 95, 40]]], [2, 480_000_000, [[1, 20, 5]]]]
	var b: Array = [a[1], a[2], a[0]]
	var ra: Dictionary = RateFrontier.solve(a, 100)
	var rb: Dictionary = RateFrontier.solve(b, 100)
	assert_eq(ra["tiers"], rb["tiers"])
	assert_eq(ra["plot_ids"], [1, 2, 3])
	assert_eq(ra["spend"], rb["spend"])


func test_negative_and_unaffordable_options_are_never_chosen() -> void:
	var plots: Array = [[1, 480_000_000, [[1, 20, -16], [2, 75, -67], [3, 240, -224]]]]
	var result: Dictionary = RateFrontier.solve(plots, 10_000)
	assert_eq(result["tiers"], [0], "Wheat: every paid fertilizer loses money -> None")
	assert_eq(result["spend"], 0)
	assert_eq(RateFrontier.solve([[1, 1, [[1, 5, 100]]]], 4)["tiers"], [0], "unaffordable")
	assert_false(RateFrontier.solve(plots, -1)["ok"], "negative budget rejected")
