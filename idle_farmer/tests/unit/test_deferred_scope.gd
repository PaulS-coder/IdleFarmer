extends GutTest
## M02 V14 (DEC-008, G5): the deferred Seed Efficiency, Research Facilities and Growth Booster
## families exist nowhere in content_m02_v1. Every command surface that names one rejects it
## uncharged with its UNKNOWN_* code, and exactly four fertilizers remain.

const DEFERRED: PackedStringArray = ["seed_efficiency", "research_facilities", "growth_booster"]

var state: GameState
var registry: ContentRegistry
var engine: SimulationEngine


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()
	AutomationFixtures.level7_automation(state)
	state.player.coins = 1_000_000  # level 7 with four automation ranks leaves two unspent points
	engine = Fixtures.engine_for(state)


func _assert_rejected(type: String, terms: Dictionary, code: String) -> void:
	var before: String = state.digest()
	var result: CommandResult = engine.submit_command(Fixtures.command(state, type, terms, 1))
	assert_eq(result.failure_code, code, "%s %s" % [type, terms])
	assert_eq(result.transactions.size(), 0, "uncharged")
	assert_eq(state.digest(), before, "state unchanged")


func test_deferred_families_absent_from_content() -> void:
	assert_eq(registry.fertilizer_ids(), PackedStringArray(["none", "basic", "premium", "advanced"]), "exactly four fertilizers")
	assert_eq(registry.upgrade_family_ids(), PackedStringArray(["irrigation", "improved_soil"]))
	for id: String in DEFERRED:
		assert_null(registry.upgrade(id, 1), id)
		assert_null(registry.fertilizer(id), id)
		assert_null(registry.skill(id), id)
		assert_null(registry.research(id), id)
		assert_null(registry.research("unlock_" + id), id)
		assert_false(registry.has_crop(id), id)


func test_every_command_surface_rejects_deferred_ids_uncharged() -> void:
	for id: String in DEFERRED:
		_assert_rejected(GameCommand.TYPE_PURCHASE_UPGRADE, {"family_id": id, "target_rank": 1, "cost": 100}, FailureCode.UNKNOWN_UPGRADE)
		_assert_rejected(GameCommand.TYPE_START_RESEARCH, {"project_id": id, "cost": 100, "duration_us": 60_000_000},
			FailureCode.UNKNOWN_RESEARCH)
		_assert_rejected(GameCommand.TYPE_ALLOCATE_SKILL, {"skill_id": id, "target_rank": 1}, FailureCode.UNKNOWN_SKILL)
		var plant: Dictionary = RawIntent.plant("", 1, FarmSystem.quote_for(state, registry, "wheat")).terms
		plant["fertilizer_id"] = id
		_assert_rejected(GameCommand.TYPE_PLANT_CROP, plant, FailureCode.UNKNOWN_FERTILIZER)
		_assert_rejected(GameCommand.TYPE_CONFIGURE_AUTOMATION, {"plot_id": 1, "field": FarmingSettings.FERTILIZER_POLICY,
			"set": true, "value": id}, FailureCode.UNKNOWN_FERTILIZER)
		var specs: Array[Dictionary] = [{"plot_id": 1, "crop_id": "wheat", "fertilizer_policy": id, "fallback_accepted": false}]
		var members: Array[Dictionary] = AutomationSystem.quote_apply_and_start(state, registry, specs)
		var result: CommandResult = engine.submit_command(Fixtures.command(state, GameCommand.TYPE_APPLY_AND_START, {"members": members}, 1))
		assert_false(result.success, "ApplyAndStart %s" % id)
		assert_eq(result.member_outcomes[0]["failure_code"] if not result.member_outcomes.is_empty() else result.failure_code,
			FailureCode.UNKNOWN_FERTILIZER)
