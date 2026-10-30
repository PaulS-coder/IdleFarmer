extends GutTest
## M02-T02 / V02 / V09: modifiers from skills + equipment + fertilizer, the 60% cap and its waste,
## fertilizer prices from base coins, quotes against the independent oracle, AV-003 identity for v1.

var registry: ContentRegistry


func before_all() -> void:
	registry = Fixtures.registry_v2()


func _state(ranks: Array, irrigation: int, soil: int) -> GameState:
	var state: GameState = Fixtures.new_game_v2()
	for pair: Array in ranks:
		state.player.skill_ranks[pair[0]] = pair[1]
	if irrigation > 0:
		state.upgrades.ranks["irrigation"] = irrigation
	if soil > 0:
		state.upgrades.ranks["improved_soil"] = soil
	return state


func test_quotes_match_oracle() -> void:
	for row: Array in M02OracleVectors.MODIFIERS:
		var label: String = "%s %s irr%d soil%d %s" % [row[0], str(row[1]), row[2], row[3], row[4]]
		var state: GameState = _state(row[1], row[2], row[3])
		var snapshot: ModifierSnapshot = ModifierSnapshot.for_state(state, registry, row[4])
		assert_true(snapshot.ok, label)
		assert_eq(snapshot.uncapped_growth_reduction_bp, row[5], "uncapped " + label)
		assert_eq(snapshot.growth_reduction_bp, row[6], "capped " + label)
		var quote: PlantingQuote = FarmSystem.quote_for(state, registry, row[0], row[4])
		assert_true(quote.ok, label)
		assert_eq(quote.growth_us, row[7], "growth " + label)
		assert_eq(quote.gross_coins, row[8], "gross " + label)
		assert_eq(quote.gross_without_fertilizer, row[9], "gross w/o fert " + label)
		assert_eq(quote.xp, row[10], "xp " + label)
		assert_eq(quote.fertilizer_cost, row[11], "fert price " + label)
		assert_eq(quote.incremental_fertilizer_net(), row[12], "incremental " + label)
		assert_eq(quote.completed_cycle_profit().value, row[13], "profit " + label)


func test_fertilizer_price_table() -> void:
	for row: Array in M02OracleVectors.PRICES:
		var price: MathResult = FertilizerPricing.price(registry.fertilizer(row[1]), registry.crop(row[0]).base_coins)
		assert_true(price.ok)
		assert_eq(price.value, row[2], "%s/%s" % [row[0], row[1]])


func test_t004_tomatoes_basic() -> void:
	var quote: PlantingQuote = FarmSystem.quote_for(Fixtures.new_game_v2(), registry, "tomatoes", "basic")
	assert_eq([quote.seed_cost, quote.fertilizer_cost, quote.gross_coins, quote.xp], [55, 41, 337, 70])
	assert_eq(quote.completed_cycle_profit().value, 241)


func test_cap_and_waste() -> void:
	var state: GameState = _state([["faster_germination", 5], ["improved_cultivation", 5], ["climate_control", 3]], 6, 0)
	var quote: PlantingQuote = FarmSystem.quote_for(state, registry, "wheat")
	assert_eq(quote.growth_us, 192_000_000, "50% skills + 30% Irrigation capped at 60%")
	assert_eq(quote.cap_waste_bp, 2000, "20% wasted above the cap is visible")
	assert_eq(FarmSystem.quote_for(state, registry, "tomatoes").growth_us, 1_440_000_000)


func test_coin_bonuses_never_change_xp() -> void:
	var state: GameState = _state([["efficient_harvest", 5], ["soil_productivity", 5], ["premium_produce", 3]], 0, 5)
	var quote: PlantingQuote = FarmSystem.quote_for(state, registry, "coffee", "advanced")
	assert_eq(quote.xp, 750)
	assert_gt(quote.gross_coins, 4400)


func test_snapshot_dict_keys() -> void:
	var snapshot: ModifierSnapshot = ModifierSnapshot.for_state(_state([["faster_germination", 2]], 1, 1), registry, "premium")
	assert_eq(snapshot.to_dict(), {"growth_reduction_bp": 1300, "coin_bonus_bp": 1000, "fertilizer_bonus_bp": 5000})


func test_unknown_fertilizer_is_not_ok() -> void:
	assert_false(ModifierSnapshot.for_state(Fixtures.new_game_v2(), registry, "growth_booster").ok)
	assert_false(FarmSystem.quote_for(Fixtures.new_game_v2(), registry, "wheat", "growth_booster").ok)


func test_av003_v1_profile_has_identity_modifiers() -> void:
	# A content_m01_v1 profile keeps its manifest: skill ranks and stored upgrade ranks have no effect,
	# and only `none` fertilizer exists there.
	var state: GameState = Fixtures.new_game()
	state.player.skill_ranks = {"faster_germination": 5}
	state.upgrades.ranks = {"irrigation": 6}
	var snapshot: ModifierSnapshot = ModifierSnapshot.for_state(state, Fixtures.registry(), "none")
	assert_eq(snapshot.to_dict(), {"growth_reduction_bp": 0, "coin_bonus_bp": 0, "fertilizer_bonus_bp": 0})
	assert_false(FarmSystem.quote_for(state, Fixtures.registry(), "wheat", "basic").ok)
