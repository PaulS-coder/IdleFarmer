extends GutTest
## M01-T09: snapshotted cost/reward/XP/maturity from definitions with identity modifiers, plus
## modifier extension inputs (rounding, cap) without implementing skills or fertilizer policies.

var registry: ContentRegistry


func before_all() -> void:
	registry = Fixtures.registry()


func _quote(crop_id: String, reduction: int = 0, bonus: int = 0) -> PlantingQuote:
	return EconomySystem.quote_planting(registry.crop(crop_id), registry.manifest_id(),
		{EconomySystem.MOD_GROWTH_REDUCTION_BP: reduction, EconomySystem.MOD_COIN_BONUS_BP: bonus})


func test_wheat_base_quote() -> void:
	var q: PlantingQuote = _quote("wheat")
	assert_true(q.ok)
	assert_eq([q.growth_us, q.seed_cost, q.gross_coins, q.xp], [480_000_000, 0, 16, 6])
	assert_eq(q.manifest_id, "content_m01_v1")


func test_corn_base_quote() -> void:
	var q: PlantingQuote = _quote("corn")
	assert_eq([q.growth_us, q.seed_cost, q.gross_coins, q.xp], [1_800_000_000, 18, 110, 32])


func test_identity_modifiers_reproduce_every_definition() -> void:
	var state: GameState = Fixtures.new_game()
	for crop_id: String in registry.crop_ids():
		var crop: CropDefinition = registry.crop(crop_id)
		var q: PlantingQuote = FarmSystem.quote_for(state, registry, crop_id)
		assert_eq([q.growth_us, q.seed_cost, q.gross_coins, q.xp], [crop.base_growth_us, crop.seed_cost, crop.base_coins, crop.base_xp], crop_id)


func test_modifier_inputs_follow_rounding_rules() -> void:
	assert_eq(_quote("tomatoes", 0, 2_500).gross_coins, 337, "floor(270 × 1.25)")
	assert_eq(_quote("wheat", 0, 1_000).gross_coins, 17, "floor(16 × 1.1 = 17.6)")
	assert_eq(_quote("tomatoes", 6_000).growth_us, 1_440_000_000, "60% cap = 24 minutes")
	assert_eq(_quote("tomatoes", 9_000).growth_us, 1_440_000_000, "beyond cap clamps")
	assert_eq(_quote("wheat", 3_333).growth_us, 320_016_000, "ceil(480,000,000 × 0.6667)")
	assert_eq(_quote("tomatoes", 0, 2_500).xp, 70, "coin bonus does not change XP")


func test_invalid_modifier_inputs_fail() -> void:
	assert_false(_quote("wheat", -1).ok)
	assert_false(_quote("wheat", 0, -1).ok)


func test_completed_cycle_profit_from_snapshot() -> void:
	var state: GameState = Fixtures.new_game()
	var cycle: CropCycle = Fixtures.add_cycle(state, 1, "corn", 0)
	assert_eq(EconomySystem.completed_cycle_profit(cycle).value, 92, "110 − 18")
	assert_eq(EconomySystem.harvest_reward(cycle), [110, 32])
