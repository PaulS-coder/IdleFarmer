extends GutTest
## M01-T03/T05, V01 and V11: approved new-game baseline (DEC-003/020) and plot geometry/prefix.

var state: GameState
var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry()
	state = Fixtures.new_game()


func test_new_game_is_valid() -> void:
	assert_eq(state.validate(registry), PackedStringArray())


func test_v01_plots_ids_and_unlocks() -> void:
	assert_eq(state.plots.size(), 32)
	for i: int in 32:
		var p: PlotState = state.plots[i]
		assert_eq(p.plot_id, i + 1, "unique ordered ID")
		assert_eq(p.unlocked, p.plot_id <= 24, "plot %d unlock state" % p.plot_id)
		assert_null(p.crop_cycle, "plot %d has no cycle" % p.plot_id)
		assert_eq(p.selected_crop_id, "", "no crop preselected")
	assert_eq(state.unlocked_plot_count(), 24)


func test_v01_player_baseline() -> void:
	assert_eq(state.player.level, 1)
	assert_eq(state.player.total_xp, 0)
	assert_eq(state.player.coins, 0)
	assert_eq(state.player.available_skill_points, 0)
	assert_eq(state.player.skill_ranks.size(), 0)
	assert_eq(state.research.completed.size(), 0, "no post-start research")
	assert_eq(state.upgrades.ranks.size(), 0, "no upgrades")
	assert_eq(state.contracts.instances.size(), 0, "no contracts")
	assert_eq(state.available_crop_ids(registry), PackedStringArray(["wheat"]), "Wheat is the only eligible crop")


func test_v01_identity_and_counters() -> void:
	assert_eq(state.content_version, "content_m01_v1")
	assert_eq(state.allocation_namespace, Fixtures.uuid("A"))
	assert_eq(state.command_replay.current_epoch, Fixtures.uuid("A"), "P10: one UUID per writer epoch")
	assert_eq(state.next_entity_id, 1)
	assert_eq(state.next_insertion_sequence, 1)
	assert_eq(state.state_sequence, 0)
	assert_eq(state.durable_revision, 0)
	assert_eq(state.simulation_time_us, 0)
	assert_eq(state.time_anchor.credited_through_utc_us, Fixtures.CREATED_UTC_US)


func test_g3_budget_defaults_are_inert() -> void:
	assert_eq(state.automation.budget_reserve, 0)
	assert_eq(state.automation.budget_protection_percent, 25)
	assert_false(state.automation.budget_seed_protection)


func test_v11_fixed_eight_column_coordinates() -> void:
	for id: int in range(1, 33):
		assert_eq(PlotState.row_of(id), 1 + (id - 1) / 8, "row of %d" % id)
		assert_eq(PlotState.column_of(id), 1 + (id - 1) % 8, "column of %d" % id)
	assert_eq([PlotState.row_of(1), PlotState.column_of(1)], [1, 1])
	assert_eq([PlotState.row_of(8), PlotState.column_of(8)], [1, 8])
	assert_eq([PlotState.row_of(9), PlotState.column_of(9)], [2, 1])
	assert_eq([PlotState.row_of(24), PlotState.column_of(24)], [3, 8])
	assert_eq([PlotState.row_of(25), PlotState.column_of(25)], [4, 1])
	assert_eq([PlotState.row_of(32), PlotState.column_of(32)], [4, 8])


func test_v11_hole_bearing_unlock_is_rejected() -> void:
	state.plot(26).unlocked = true
	var errors: PackedStringArray = state.validate(registry)
	assert_true(Fixtures.has_code(errors, "PLOT_UNLOCK_GAP"), str(errors))


func test_v11_contiguous_expansion_is_valid() -> void:
	for n: int in range(24, 33):
		Fixtures.unlock_prefix(state, n)
		assert_eq(state.validate(registry), PackedStringArray(), "prefix 1..%d" % n)


func test_unlock_count_below_24_is_rejected() -> void:
	Fixtures.unlock_prefix(state, 23)
	assert_true(Fixtures.has_code(state.validate(registry), "PLOT_UNLOCK_COUNT"))


func test_locked_plot_cannot_hold_a_cycle() -> void:
	Fixtures.add_cycle(state, 25, "wheat", 0)
	assert_true(Fixtures.has_code(state.validate(registry), "PLOT_LOCKED_HAS_CYCLE"))


func test_scattered_occupancy_is_valid() -> void:
	Fixtures.add_cycle(state, 1, "wheat", 0)
	Fixtures.add_cycle(state, 7, "wheat", 0)
	Fixtures.add_cycle(state, 24, "wheat", 0)
	assert_eq(state.validate(registry), PackedStringArray(), "prefix rule is about unlocks, not occupancy")
