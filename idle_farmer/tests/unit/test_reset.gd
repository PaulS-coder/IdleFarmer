extends GutTest
## M02-T05, V05 / T-008 (reset part), AV-004-04: quadratic reset price, exact refund, everything
## else preserved, and reset quotes bound to level/price/points.

var state: GameState
var engine: SimulationEngine
var registry: ContentRegistry
var counter: int = 0


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	engine = Fixtures.engine_for(state)
	counter = 0


func _submit(type: String, terms: Dictionary) -> CommandResult:
	counter += 1
	return engine.submit_command(Fixtures.command(state, type, terms, counter))


func _assert_reset_rejected(terms: Dictionary, code: String) -> void:
	var before: String = state.digest()
	assert_eq(_submit(GameCommand.TYPE_RESET_SKILLS, terms).failure_code, code)
	assert_eq(state.digest(), before, "%s leaves state unchanged" % code)


func _level7_with_automation() -> void:
	Fixtures.set_xp(state, 5_200)
	for skill_id: String in ["batch_planting", "batch_harvesting", "automatic_harvesting", "automatic_replanting"]:
		assert_true(_submit(GameCommand.TYPE_ALLOCATE_SKILL, SkillSystem.quote_allocate(state, skill_id)).success)


func test_v05_reset_prices() -> void:
	var expected: Dictionary = {1: 250, 2: 250, 3: 450, 7: 2450, 10: 5000, 30: 45000}
	for level: int in expected:
		assert_eq(SkillSystem.reset_price(registry, level).value, expected[level], "level %d" % level)
	assert_false(SkillSystem.reset_price(Fixtures.registry(), 7).ok, "v1 manifest has no reset economy")


func test_t008_reset_preserves_everything_but_skills() -> void:
	_level7_with_automation()
	state.player.coins = 10_000
	Fixtures.unlock_crop(state, "corn")
	state.player.coins = 10_000
	assert_true(_submit(GameCommand.TYPE_PURCHASE_UPGRADE, PurchaseSystem.quote_upgrade(state, registry, "irrigation")).success)
	assert_true(_submit(GameCommand.TYPE_PLANT_CROP, RawIntent.plant("p", 1, FarmSystem.quote_for(state, registry, "corn")).terms).success)
	var cycle_before: Dictionary = state.plot(1).crop_cycle.to_primitive()
	var xp: int = state.player.total_xp
	var coins: int = state.player.coins
	var quote: Dictionary = SkillSystem.quote_reset(state, registry)
	assert_eq(quote, {"level": 7, "price": 2450, "allocated_points": 4})
	var result: CommandResult = _submit(GameCommand.TYPE_RESET_SKILLS, quote)
	assert_true(result.success, result.failure_code)
	assert_eq(state.player.available_skill_points, 6, "all 4 allocated points refunded exactly")
	assert_eq(state.player.skill_ranks.size(), 0)
	assert_eq(state.player.coins, coins - 2450)
	assert_eq([state.player.total_xp, state.player.level], [xp, 7])
	assert_eq(state.upgrades.ranks, {"irrigation": 1}, "equipment kept")
	assert_true(state.research.completed.has("unlock_corn"), "research kept")
	assert_eq(state.plot(1).crop_cycle.to_primitive(), cycle_before, "growing snapshot unchanged")
	assert_eq(Capabilities.of(state, registry).owned().size(), 0, "refunded automation stops")
	assert_eq([result.transactions[0].type(), result.transactions[0].coin_delta()], ["skill_reset", -2450])
	assert_eq(state.validate(registry), PackedStringArray())


func test_nothing_to_reset_and_v1() -> void:
	state.player.coins = 1_000
	_assert_reset_rejected(SkillSystem.quote_reset(state, registry), FailureCode.NOTHING_TO_RESET)
	state = Fixtures.new_game()
	engine = Fixtures.engine_for(state)
	Fixtures.set_xp(state, 240)
	state.player.skill_ranks = {"faster_germination": 1}
	state.player.available_skill_points = 0
	state.player.coins = 1_000
	_assert_reset_rejected({"level": 2, "price": 250, "allocated_points": 1}, FailureCode.FEATURE_UNAVAILABLE)


func test_av004_04_level_change_requires_refresh() -> void:
	_level7_with_automation()
	state.player.coins = 100_000
	var quote: Dictionary = SkillSystem.quote_reset(state, registry)
	Fixtures.set_xp(state, 7_300)  # level 8 reached between quote and acceptance
	state.player.skill_ranks = {"batch_planting": 1, "batch_harvesting": 1, "automatic_harvesting": 1, "automatic_replanting": 1}
	state.player.available_skill_points = 3
	_assert_reset_rejected(quote, FailureCode.STALE_TERMS)
	var fresh: Dictionary = SkillSystem.quote_reset(state, registry)
	assert_eq(fresh["price"], 3200, "level 8 price")
	assert_true(_submit(GameCommand.TYPE_RESET_SKILLS, fresh).success)


func test_av004_04_extra_income_never_raises_the_charge() -> void:
	_level7_with_automation()
	state.player.coins = 3_000
	var quote: Dictionary = SkillSystem.quote_reset(state, registry)
	var confirmed_minimum: int = 3_000 - quote["price"]
	state.player.coins += 500  # unrelated harvest income between quote and acceptance
	assert_true(_submit(GameCommand.TYPE_RESET_SKILLS, quote).success)
	assert_eq(state.player.coins, 3_500 - 2450)
	assert_gte(state.player.coins, confirmed_minimum, "ending balance never below the confirmed minimum")


func test_changed_allocation_and_insufficient_coins() -> void:
	_level7_with_automation()
	state.player.coins = 100_000
	var quote: Dictionary = SkillSystem.quote_reset(state, registry)
	state.player.skill_ranks.erase("automatic_replanting")
	state.player.available_skill_points += 1
	_assert_reset_rejected(quote, FailureCode.STALE_TERMS)
	state.player.coins = 2449
	_assert_reset_rejected(SkillSystem.quote_reset(state, registry), FailureCode.INSUFFICIENT_COINS)
