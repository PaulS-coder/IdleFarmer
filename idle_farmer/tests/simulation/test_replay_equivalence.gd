extends GutTest
## M01-T14, V06/V08, T-002 core / T-021, AV-001-03, C1: the same accepted inputs at the same
## simulated times give identical gameplay state, IDs, ordering and events across 1×, 60×, offline,
## mixed random partitions and direct engine replay — and across XP crossings 30/31/32/35.
## Only checkpoint/clock metadata may differ; economics, IDs and order are never normalized away.

const MIN_US: int = 60_000_000
const FINAL_US: int = 240 * MIN_US

var catalog: ManifestCatalog


func before_all() -> void:
	catalog = ManifestFixtures.catalog()


## All 32 plots unlocked (explicit fixture), four crops with different maturities, staggered
## planting, tied manual inputs, harvest + replant, and level gains from harvest XP.
func _initial(xp: int) -> GameState:
	var state: GameState = Fixtures.new_game()
	Fixtures.unlock_prefix(state, 32)
	for crop_id: String in ["carrots", "corn", "tomatoes"]:
		Fixtures.unlock_crop(state, crop_id)
	Fixtures.set_xp(state, maxi(xp, state.player.total_xp))
	state.player.coins = 100_000
	return state


func _script() -> Array[Array]:
	var script: Array[Array] = []
	for plot_id: int in range(1, 5):
		script.append([0, "plant", plot_id, "wheat"])
	for plot_id: int in range(9, 17):
		script.append([0, "plant", plot_id, "carrots"])
	for plot_id: int in range(17, 25):
		script.append([0, "plant", plot_id, "corn"])
	for plot_id: int in range(25, 33):
		script.append([0, "plant", plot_id, "tomatoes"])
	for plot_id: int in range(5, 9):
		script.append([2 * MIN_US, "plant", plot_id, "wheat"])  # staggered: matures at 10 min
	for plot_id: int in range(1, 5):
		script.append([8 * MIN_US, "harvest", plot_id, ""])
		script.append([8 * MIN_US, "plant", plot_id, "wheat"])  # tied inputs at one timestamp
	for plot_id: int in range(5, 9):
		script.append([10 * MIN_US, "harvest", plot_id, ""])
	for plot_id: int in range(9, 17):
		script.append([15 * MIN_US, "harvest", plot_id, ""])
	for plot_id: int in range(1, 5):
		script.append([30 * MIN_US, "harvest", plot_id, ""])
	for plot_id: int in range(17, 25):
		script.append([30 * MIN_US, "harvest", plot_id, ""])
		script.append([30 * MIN_US, "plant", plot_id, "corn"])
	for plot_id: int in range(25, 33):
		script.append([60 * MIN_US, "harvest", plot_id, ""])
	return script


func _run(mode: String, seed: int, xp: int) -> ScenarioDriver:
	var driver: ScenarioDriver = ScenarioDriver.new(_initial(xp), Fixtures.uuid("A"), mode, seed, catalog)
	driver.run(_script(), FINAL_US)
	for result: CommandResult in driver.results:
		assert_true(result.success, "%s step failed: %s" % [mode, result.failure_code])
	return driver


func _assert_equivalent(reference: ScenarioDriver, other: ScenarioDriver, label: String) -> void:
	assert_eq(other.final_state().gameplay_digest(), reference.final_state().gameplay_digest(), "%s gameplay state" % label)
	assert_eq(other.events_digest(), reference.events_digest(), "%s event sequence" % label)
	assert_eq(CanonicalCodec.digest(other.controller.accepted_log()), CanonicalCodec.digest(reference.controller.accepted_log()), "%s accepted log" % label)


func test_t021_modes_are_equivalent_across_32_plots() -> void:
	var reference: ScenarioDriver = _run(ScenarioDriver.MODE_ACTIVE_1X, 1, 0)
	var s: GameState = reference.final_state()
	assert_gt(s.player.level, 1, "scenario gains levels")
	assert_eq(s.player.available_skill_points, s.player.level - 1)
	for other: Array in [[ScenarioDriver.MODE_ACTIVE_60X, 2], [ScenarioDriver.MODE_OFFLINE, 3],
			[ScenarioDriver.MODE_MIXED, 4], [ScenarioDriver.MODE_MIXED, 5], [ScenarioDriver.MODE_ACTIVE_1X, 6]]:
		_assert_equivalent(reference, _run(other[0], other[1], 0), "%s/seed %d" % other)


func test_v06_60x_reaches_the_same_state_in_one_sixtieth_real_time() -> void:
	var normal: ScenarioDriver = _run(ScenarioDriver.MODE_ACTIVE_1X, 7, 0)
	var fast: ScenarioDriver = _run(ScenarioDriver.MODE_ACTIVE_60X, 7, 0)
	_assert_equivalent(normal, fast, "60x")
	var credited_normal: int = normal.final_state().time_anchor.credited_through_utc_us - Fixtures.CREATED_UTC_US
	var credited_fast: int = fast.final_state().time_anchor.credited_through_utc_us - Fixtures.CREATED_UTC_US
	assert_eq(credited_normal, FINAL_US)
	assert_eq(credited_fast, FINAL_US / 60, "anchor advanced by real time only")


func test_c1_xp_crossings_30_31_32_35_are_mode_independent() -> void:
	for start_xp: int in [519_900, 577_400, 640_700, 870_900]:
		var reference: ScenarioDriver = _run(ScenarioDriver.MODE_ACTIVE_1X, 21, start_xp)
		var before_level: int = Fixtures.registry().level_for_xp(start_xp)
		var after: GameState = reference.final_state()
		assert_gt(after.player.level, before_level, "crossing above XP %d" % start_xp)
		assert_eq(after.player.available_skill_points, after.player.level - 1)
		for mode: String in [ScenarioDriver.MODE_ACTIVE_60X, ScenarioDriver.MODE_OFFLINE, ScenarioDriver.MODE_MIXED]:
			_assert_equivalent(reference, _run(mode, 22, start_xp), "%s from XP %d" % [mode, start_xp])


func test_engine_replay_of_accepted_log_matches_controller_run() -> void:
	var driver: ScenarioDriver = _run(ScenarioDriver.MODE_MIXED, 31, 0)
	var initial: GameState = ScenarioDriver.new(_initial(0), Fixtures.uuid("A"), ScenarioDriver.MODE_OFFLINE, 0, catalog).final_state()
	var replay: Dictionary = CommandReplayer.replay(initial, catalog, driver.controller.accepted_log(), FINAL_US)
	assert_true(replay["ok"], str(replay["errors"]))
	assert_eq((replay["state"] as GameState).gameplay_digest(), driver.final_state().gameplay_digest())


func test_scheduler_restore_mid_run_matches_uninterrupted_replay() -> void:
	var driver: ScenarioDriver = _run(ScenarioDriver.MODE_ACTIVE_1X, 41, 0)
	var log: Array[Dictionary] = driver.controller.accepted_log()
	var initial: GameState = ScenarioDriver.new(_initial(0), Fixtures.uuid("A"), ScenarioDriver.MODE_OFFLINE, 0, catalog).final_state()
	var split: int = 50
	var first: Dictionary = CommandReplayer.replay(initial, catalog, log.slice(0, split), log[split]["accepted_time_us"])
	assert_true(first["ok"], str(first["errors"]))
	var restored: GameState = GameState.from_primitive(CanonicalCodec.decode(CanonicalCodec.encode((first["state"] as GameState).to_primitive()))["value"])
	var second: Dictionary = CommandReplayer.replay(restored, catalog, log.slice(split), FINAL_US)
	assert_true(second["ok"], str(second["errors"]))
	assert_eq((second["state"] as GameState).gameplay_digest(), driver.final_state().gameplay_digest(), "queue rebuilt from saved state")


func test_v08_pending_queue_is_bounded_by_growing_cycles() -> void:
	var driver: ScenarioDriver = _run(ScenarioDriver.MODE_MIXED, 51, 0)
	var s: GameState = driver.final_state()
	var growing: int = 0
	for plot: PlotState in s.plots:
		if plot.crop_cycle != null and plot.crop_cycle.status == CropCycle.STATUS_GROWING:
			growing += 1
	assert_eq(EventScheduler.rebuild(s).size(), growing, "no retained history in the queue")
	assert_lte(s.time_anchor.intervals.size(), TimeAnchor.MAX_INTERVALS)


func test_av001_03_fixed_namespace_gives_identical_ids() -> void:
	var a: GameState = _run(ScenarioDriver.MODE_ACTIVE_60X, 61, 0).final_state()
	var b: GameState = _run(ScenarioDriver.MODE_OFFLINE, 62, 0).final_state()
	assert_eq(a.next_entity_id, b.next_entity_id)
	for plot_id: int in range(1, 33):
		var ca: CropCycle = a.plot(plot_id).crop_cycle
		var cb: CropCycle = b.plot(plot_id).crop_cycle
		assert_eq(ca == null, cb == null, "plot %d occupancy" % plot_id)
		if ca != null:
			assert_true(ca.cycle_id.equals(cb.cycle_id), "plot %d cycle identity" % plot_id)
	var different: ScenarioDriver = ScenarioDriver.new(_initial(0), Fixtures.uuid("C"), ScenarioDriver.MODE_OFFLINE, 63, catalog)
	different.run(_script(), FINAL_US)
	assert_ne(different.final_state().gameplay_digest(), a.gameplay_digest(), "a different injected namespace is visible, not normalized")
