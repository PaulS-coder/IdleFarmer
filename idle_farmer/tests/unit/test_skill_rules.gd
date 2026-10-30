extends GutTest
## M02-T04, V01/V12: one point per rank/node, level gates, rank ≥ 1 predecessor (never full-tier),
## max ranks, derived capabilities, and the four-point basic automation path by level 7.

var state: GameState
var engine: SimulationEngine
var registry: ContentRegistry
var counter: int = 0


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	engine = Fixtures.engine_for(state)
	counter = 0


func _allocate(skill_id: String) -> CommandResult:
	counter += 1
	return engine.submit_command(Fixtures.command(state, GameCommand.TYPE_ALLOCATE_SKILL,
		SkillSystem.quote_allocate(state, skill_id), counter))


func _assert_rejected(skill_id: String, code: String, terms: Dictionary = {}) -> void:
	var before: String = state.digest()
	counter += 1
	var used: Dictionary = terms if not terms.is_empty() else SkillSystem.quote_allocate(state, skill_id)
	var result: CommandResult = engine.submit_command(Fixtures.command(state, GameCommand.TYPE_ALLOCATE_SKILL, used, counter))
	assert_eq(result.failure_code, code, skill_id)
	assert_eq(state.digest(), before, "%s leaves state unchanged" % code)


func test_v01_four_point_automation_by_level_7() -> void:
	Fixtures.set_xp(state, 5_200)
	assert_eq([state.player.level, state.player.available_skill_points], [7, 6])
	for skill_id: String in ["batch_planting", "batch_harvesting", "automatic_harvesting", "automatic_replanting"]:
		assert_true(_allocate(skill_id).success, skill_id)
	var caps: Capabilities = Capabilities.of(state, registry)
	assert_eq(caps.owned(), PackedStringArray(["automatic_harvesting", "automatic_replanting", "batch_harvesting", "batch_planting"]))
	assert_eq(state.player.available_skill_points, 2)
	assert_false(caps.has(Capabilities.SMART_FERTILIZER))
	_assert_rejected("smart_fertilizer", FailureCode.LEVEL_REQUIRED)
	assert_eq(state.validate(registry), PackedStringArray(), "level−1 = unspent + allocated")


func test_automation_chain_requires_immediate_predecessor_and_level() -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(20))
	_assert_rejected("batch_harvesting", FailureCode.SKILL_PREREQUISITE_REQUIRED)
	_assert_rejected("crop_rotation", FailureCode.SKILL_PREREQUISITE_REQUIRED)
	Fixtures.set_xp(state, registry.threshold_for_level(5))
	assert_true(_allocate("batch_planting").success)
	assert_true(_allocate("batch_harvesting").success)
	_assert_rejected("automatic_harvesting", FailureCode.LEVEL_REQUIRED)


func test_v12_one_preceding_rank_is_enough_for_tier_entry() -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(10))
	_assert_rejected("improved_cultivation", FailureCode.SKILL_PREREQUISITE_REQUIRED)
	assert_true(_allocate("faster_germination").success)
	assert_true(_allocate("improved_cultivation").success, "rank 1 of the previous tier suffices")
	assert_true(_allocate("efficient_harvest").success)
	assert_true(_allocate("soil_productivity").success)
	_assert_rejected("premium_produce", FailureCode.LEVEL_REQUIRED)


func test_max_rank_points_and_unknown() -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(30))
	for i: int in 5:
		assert_true(_allocate("faster_germination").success)
	_assert_rejected("faster_germination", FailureCode.SKILL_MAX_RANK)
	_assert_rejected("teleport", FailureCode.UNKNOWN_SKILL)
	state.player.available_skill_points = 0
	state.player.skill_ranks["improved_cultivation"] = 0
	state.player.skill_ranks.erase("improved_cultivation")
	_assert_rejected("improved_cultivation", FailureCode.INSUFFICIENT_POINTS)


func test_stale_target_rank_and_redelivery() -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(10))
	var quote: Dictionary = SkillSystem.quote_allocate(state, "faster_germination")
	assert_true(_allocate("faster_germination").success)
	_assert_rejected("faster_germination", FailureCode.STALE_TERMS, quote)
	assert_eq(state.player.skill_ranks["faster_germination"], 1, "re-delivery never allocates twice")


func test_capabilities_are_derived_not_stored() -> void:
	Fixtures.set_xp(state, 5_200)
	_allocate("batch_planting")
	assert_true(Capabilities.of(state, registry).has(Capabilities.BATCH_PLANTING))
	state.player.skill_ranks = {}
	state.player.available_skill_points = 6
	assert_false(Capabilities.of(state, registry).has(Capabilities.BATCH_PLANTING), "removing ranks removes the capability")
	assert_false(state.to_primitive().has("capabilities"))


func test_growth_skills_feed_future_quotes() -> void:
	Fixtures.set_xp(state, registry.threshold_for_level(10))
	assert_true(_allocate("faster_germination").success)
	assert_eq(FarmSystem.quote_for(state, registry, "wheat").growth_us, 460_800_000, "−4% at rank 1")
