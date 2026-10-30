extends GutTest
## M02 V10 (T-005/T-010, E6): 8+ simulated hours of mixed automation through the controller, with
## manual commands mid-run. A mid-run restart from a clone and a replay of the accepted log both
## reach the identical gameplay digest; pending work stays bounded; nothing is bought, researched
## or allocated automatically.

const MINUTE_US: int = 60_000_000
const STEP_US: int = 7 * MINUTE_US
const STEPS: int = 72  # 8 h 24 min

var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry_v2()


func _initial() -> GameState:
	var state: GameState = Fixtures.new_game_v2()
	Fixtures.unlock_crop(state, "corn")
	AutomationFixtures.level7_automation(state)
	state.player.coins = 160  # four Corn+Basic first plantings (4 × 38); plot 11 Premium is skipped at start
	for id: int in range(1, 7):
		AutomationFixtures.configure_plot(state, id, "wheat", true, true)
	for id: int in range(7, 11):
		AutomationFixtures.configure_plot(state, id, "corn", true, true, "basic", true)
	AutomationFixtures.configure_plot(state, 11, "corn", true, true, "premium", false)
	return state


func _controller(state: GameState, epoch: String) -> GameController:
	var controller: GameController = GameController.new(ManifestFixtures.catalog(), FakeCommitSink.new())
	assert_eq(controller.start(state, Fixtures.uuid(epoch)), PackedStringArray())
	return controller


func _start_specs() -> Array[Dictionary]:
	var specs: Array[Dictionary] = []
	for id: int in range(1, 12):
		var settings: FarmingSettings = SettingsResolver.effective(_initial(), id)
		specs.append({"plot_id": id, "crop_id": settings.crop_id, "fertilizer_policy": settings.fertilizer_policy,
			"fallback_accepted": settings.fallback_accepted})
	return specs


## Runs steps [from, to) with the scripted manual commands. Returns the max pending-event count seen.
func _run(controller: GameController, from: int, to: int) -> int:
	var max_pending: int = 0
	for step: int in range(from, to):
		if step == 0:
			var start: CommandResult = controller.submit_intent(RawIntent.new("start", GameCommand.TYPE_APPLY_AND_START,
				{"members": controller.quote_apply_and_start(_start_specs())}))
			assert_true(start.success, start.failure_code)
		if step == 20:
			assert_true(controller.submit_intent(RawIntent.new("fallback-11", GameCommand.TYPE_CONFIGURE_AUTOMATION,
				{"plot_id": 11, "field": "fallback_accepted", "set": true, "value": true})).success)
		if step == 30:
			var specs: Array[Dictionary] = [{"plot_id": 11, "crop_id": "corn", "fertilizer_policy": "premium", "fallback_accepted": true},
				{"plot_id": 12, "crop_id": "wheat", "fertilizer_policy": "none", "fallback_accepted": false}]
			assert_true(controller.submit_intent(RawIntent.new("rearm", GameCommand.TYPE_APPLY_AND_START,
				{"members": controller.quote_apply_and_start(specs)})).success)
		assert_eq(controller.advance_active(STEP_US), CommitSink.COMMITTED, "step %d" % step)
		max_pending = maxi(max_pending, EventScheduler.rebuild(controller.snapshot()).size())
	return max_pending


func test_v10_long_run_restart_and_replay() -> void:
	var initial: GameState = _initial()
	var controller: GameController = _controller(initial, "B")
	var max_pending: int = _run(controller, 0, STEPS / 2)
	# Restart: the gameplay state reopens on a fresh repository (metadata belongs to the old sink).
	var reopened: GameState = controller.snapshot()
	reopened.durable_revision = 0
	reopened.last_commit_id = null
	var restarted: GameController = _controller(reopened, "B")
	max_pending = maxi(max_pending, _run(controller, STEPS / 2, STEPS))
	_run(restarted, STEPS / 2, STEPS)
	var final: GameState = controller.snapshot()
	assert_gte(final.simulation_time_us, 8 * 60 * MINUTE_US)
	assert_eq(restarted.snapshot().gameplay_digest(), final.gameplay_digest(), "mid-run restart from a clone")

	var replay_start: GameState = initial.clone()
	replay_start.allocation_namespace = Fixtures.uuid("B")
	replay_start.command_replay.start_epoch(Fixtures.uuid("B"))
	var replay: Dictionary = CommandReplayer.replay(replay_start, ManifestFixtures.catalog(), controller.accepted_log(), final.simulation_time_us)
	assert_true(replay["ok"], str(replay["errors"]))
	assert_eq(AutomationFixtures.farm_view(replay["state"]), AutomationFixtures.farm_view(final))
	assert_eq((replay["state"] as GameState).player.to_primitive(), final.player.to_primitive())

	assert_lte(max_pending, PlotState.PLOT_COUNT + 1, "at most one maturity per plot plus research")
	assert_eq(final.player.skill_ranks, initial.player.skill_ranks, "no automatic skill allocation")
	assert_gte(final.player.available_skill_points, initial.player.available_skill_points)
	assert_eq(final.research.to_primitive(), initial.research.to_primitive(), "no automatic research")
	assert_eq(final.upgrades.ranks, initial.upgrades.ranks, "no automatic equipment")
	assert_eq(final.unlocked_plot_count(), 24, "no automatic expansion")
	assert_gt(final.player.coins, 0)
	assert_eq(final.validate(registry), PackedStringArray())
	var growing: int = 0
	for id: int in range(1, 13):
		if final.plot(id).crop_cycle != null:
			growing += 1
	assert_gt(growing, 8, "the loops kept running")
