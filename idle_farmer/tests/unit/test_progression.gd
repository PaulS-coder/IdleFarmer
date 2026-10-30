extends GutTest
## M01-T12, V05/V13 (grant parts): one point per crossed level, multi-level awards, surplus points,
## option B beyond 30, and atomic failure at the representation boundary.

var registry: ContentRegistry
var player: PlayerState


func before_each() -> void:
	registry = Fixtures.registry()
	player = Fixtures.new_game().player


func _grant(xp: int) -> XpGrant:
	var grant: XpGrant = ProgressionSystem.prepare_xp(player, registry, xp)
	assert_true(grant.ok)
	ProgressionSystem.apply(player, grant)
	return grant


func test_below_at_above_first_threshold() -> void:
	assert_eq(_grant(239).levels_gained(), 0)
	assert_eq(player.level, 1)
	assert_eq(_grant(1).levels_gained(), 1, "exactly 240")
	assert_eq([player.level, player.available_skill_points], [2, 1])
	assert_eq(_grant(1).levels_gained(), 0, "241 stays level 2")


func test_multi_level_award_grants_every_point_once() -> void:
	var grant: XpGrant = _grant(5_200)
	assert_eq([grant.old_level, grant.new_level, grant.levels_gained()], [1, 7, 6])
	assert_eq([player.total_xp, player.level, player.available_skill_points], [5_200, 7, 6])
	_grant(0)
	assert_eq(player.available_skill_points, 6, "zero XP grants nothing")


func test_every_explicit_threshold_crossing_from_below() -> void:
	for level: int in range(2, 31):
		var p: PlayerState = Fixtures.new_game().player
		var t: int = registry.threshold_for_level(level)
		var below: XpGrant = ProgressionSystem.prepare_xp(p, registry, t - 1)
		var at: XpGrant = ProgressionSystem.prepare_xp(p, registry, t)
		assert_eq(below.new_level, level - 1, "below L%d" % level)
		assert_eq(at.new_level, level, "at L%d" % level)
		assert_eq(at.new_available_points, level - 1, "points at L%d" % level)


func test_option_b_crossings_30_to_35() -> void:
	_grant(519_999)
	assert_eq(player.level, 29)
	_grant(1)
	assert_eq(player.level, 30)
	var grant: XpGrant = _grant(871_045 - 520_000)
	assert_eq([grant.old_level, grant.new_level], [30, 35])
	assert_eq(player.available_skill_points, 34)


func test_surplus_points_persist_after_all_ranks_full() -> void:
	# All 34 ranks/nodes allocated; further levels still grant unallocated points (no cap/discard).
	var state: GameState = Fixtures.new_game()
	Fixtures.set_xp(state, registry.threshold_for_level(40))
	for skill_id: String in registry.skill_ids():
		state.player.skill_ranks[skill_id] = registry.skill(skill_id).max_ranks
	state.player.available_skill_points = 39 - 34
	assert_eq(state.validate(registry), PackedStringArray())
	var grant: XpGrant = ProgressionSystem.prepare_xp(state.player, registry, registry.threshold_for_level(45) - state.player.total_xp)
	ProgressionSystem.apply(state.player, grant)
	assert_eq([state.player.level, state.player.available_skill_points], [45, 10])
	assert_eq(state.validate(registry), PackedStringArray())


func test_max_representable_xp_maps_to_level_349() -> void:
	player.total_xp = IntegerMath.INT64_MAX - 1
	player.level = registry.level_for_xp(player.total_xp)
	player.available_skill_points = player.level - 1
	var grant: XpGrant = _grant(1)
	assert_eq([player.total_xp, player.level, player.available_skill_points], [IntegerMath.INT64_MAX, 349, 348])
	assert_eq(grant.levels_gained(), 0)


func test_xp_overflow_fails_with_nothing_to_apply() -> void:
	player.total_xp = IntegerMath.INT64_MAX - 5
	player.level = registry.level_for_xp(player.total_xp)
	var before: Dictionary = player.to_primitive()
	var grant: XpGrant = ProgressionSystem.prepare_xp(player, registry, 6)
	assert_false(grant.ok)
	assert_eq(player.to_primitive(), before, "prepare never mutates")
	assert_false(ProgressionSystem.prepare_xp(player, registry, -1).ok, "negative XP rejected")


func test_harvest_crossing_levels_emits_level_gained() -> void:
	var state: GameState = Fixtures.new_game()
	var scheduler: EventScheduler = EventScheduler.new()
	Fixtures.set_xp(state, 235)
	FarmSystem.plant(state, registry, scheduler, Fixtures.plant_cmd(state, 1, "wheat"))
	Fixtures.advance(state, scheduler, 480_000_000)
	var result: CommandResult = FarmSystem.harvest(state, registry, Fixtures.harvest_cmd(state, 1))
	assert_eq([state.player.total_xp, state.player.level, state.player.available_skill_points], [241, 2, 1])
	assert_eq(result.events.size(), 2)
	assert_eq(result.events[1].type, SimulationEvent.LEVEL_GAINED)
	assert_eq(result.events[1].data, {"from_level": 1, "to_level": 2, "points_granted": 1})
	assert_eq(state.validate(registry), PackedStringArray())
