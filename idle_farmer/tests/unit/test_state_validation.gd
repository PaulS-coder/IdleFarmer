extends GutTest
## M01-T05: every TRS §3 invariant rejects a targeted corruption; AV-003-01/03 data-side checks.

var state: GameState
var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry()
	state = Fixtures.new_game()


func _expect(code: String) -> void:
	var errors: PackedStringArray = state.validate(registry)
	assert_true(Fixtures.has_code(errors, code), "expected %s in %s" % [code, str(errors)])


func test_level_must_match_xp() -> void:
	state.player.total_xp = 240
	_expect("PLAYER_LEVEL_MISMATCH")


func test_negative_wallet() -> void:
	state.player.coins = -1
	_expect("PLAYER_NEGATIVE")


func test_points_must_be_conserved() -> void:
	Fixtures.set_xp(state, 5_200)
	state.player.available_skill_points = 5
	_expect("SKILL_POINTS_NOT_CONSERVED")


func test_unknown_skill_and_rank_range() -> void:
	Fixtures.set_xp(state, 40_000)
	state.player.skill_ranks = {"prestige": 1}
	_expect("SKILL_UNKNOWN")
	state.player.skill_ranks = {"faster_germination": 6}
	_expect("SKILL_RANK_RANGE")


func test_skill_prerequisite_and_level_gate() -> void:
	Fixtures.set_xp(state, 40_000)  # level 15
	state.player.available_skill_points = 13
	state.player.skill_ranks = {"improved_cultivation": 1}
	_expect("SKILL_PREREQUISITE_UNMET")
	state.player.skill_ranks = {"faster_germination": 1, "improved_cultivation": 1, "climate_control": 1}
	state.player.available_skill_points = 11
	_expect("SKILL_LEVEL_GATE")


func test_av003_01_level7_auto_replant_profile_is_valid_on_its_manifest() -> void:
	# AV-003-01 data side: XP 5,200 = level 7, six earned points; four buy the automation chain.
	state.player.total_xp = 5_200
	state.player.level = 7
	state.player.skill_ranks = {"batch_planting": 1, "batch_harvesting": 1, "automatic_harvesting": 1, "automatic_replanting": 1}
	state.player.available_skill_points = 2
	assert_eq(state.validate(registry), PackedStringArray())


func test_state_bound_to_another_manifest_is_not_validated_with_this_registry() -> void:
	state.content_version = "content_other"
	_expect("MANIFEST_MISMATCH")
	assert_true(Fixtures.has_code(state.validate(null), "MANIFEST_UNRESOLVED"))


func test_cycle_identity_collision_and_foreign_ids() -> void:
	var first: CropCycle = Fixtures.add_cycle(state, 1, "wheat", 0)
	var second: CropCycle = Fixtures.add_cycle(state, 2, "wheat", 0)
	second.cycle_id = EntityId.new(first.cycle_id.save_id, first.cycle_id.allocation_namespace, first.cycle_id.counter)
	_expect("CYCLE_ID_COLLISION")
	second.cycle_id = EntityId.new(Fixtures.SAVE_ID, Fixtures.uuid("A"), state.next_entity_id)
	_expect("CYCLE_ID_FOREIGN")


func test_cycle_timing_invariants() -> void:
	var cycle: CropCycle = Fixtures.add_cycle(state, 1, "wheat", 0)
	state.simulation_time_us = cycle.matures_at_us
	_expect("CYCLE_OVERDUE")
	state.simulation_time_us = 0
	cycle.status = CropCycle.STATUS_READY
	_expect("CYCLE_READY_EARLY")
	cycle.status = CropCycle.STATUS_GROWING
	cycle.matures_at_us += 1
	_expect("CYCLE_MATURITY_MISMATCH")


func test_cycle_unknown_crop_and_plot_mismatch() -> void:
	var cycle: CropCycle = Fixtures.add_cycle(state, 1, "wheat", 0)
	cycle.crop_id = "mango"
	_expect("CYCLE_CROP_UNKNOWN")
	cycle.crop_id = "wheat"
	cycle.plot_id = 2
	_expect("CYCLE_PLOT_MISMATCH")


func test_duplicate_insertion_sequence() -> void:
	Fixtures.add_cycle(state, 1, "wheat", 0)
	var second: CropCycle = Fixtures.add_cycle(state, 2, "wheat", 0)
	second.maturity_insertion_seq = state.plot(1).crop_cycle.maturity_insertion_seq
	_expect("CYCLE_INSERTION_SEQ_INVALID")


func test_selected_crop_must_exist() -> void:
	state.plot(3).selected_crop_id = "mango"
	_expect("PLOT_SELECTED_CROP_UNKNOWN")


func test_schema_and_save_identity() -> void:
	state.schema_version = 2
	_expect("SCHEMA_UNSUPPORTED")
	state.schema_version = GameState.SCHEMA_VERSION
	state.save_id = ""
	_expect("SAVE_ID_EMPTY")


func test_replay_state_invariants() -> void:
	state.command_replay.retired_epochs.append(state.command_replay.current_epoch)
	_expect("REPLAY_EPOCH_RETIRED")


func test_unknown_research_reference() -> void:
	state.research.completed = PackedStringArray(["unlock_mango"])
	_expect("RESEARCH_UNKNOWN")


func test_settings_and_budget_ranges() -> void:
	state.settings.music_volume = 101
	_expect("SETTINGS_VOLUME_RANGE")
	state.settings.music_volume = 80
	state.automation.budget_protection_percent = 101
	_expect("BUDGET_PERCENT_RANGE")


func test_anchor_intervals_are_bounded_and_1x_outside_active() -> void:
	state.time_anchor.intervals.append(AccountedInterval.new(AccountedInterval.KIND_SUSPENDED, 10, 600))
	_expect("INTERVAL_NOT_1X")
	state.time_anchor.intervals.clear()
	for i: int in TimeAnchor.MAX_INTERVALS + 1:
		state.time_anchor.intervals.append(AccountedInterval.new(AccountedInterval.KIND_ACTIVE, 1, 60))
	_expect("ANCHOR_INTERVALS_UNBOUNDED")
