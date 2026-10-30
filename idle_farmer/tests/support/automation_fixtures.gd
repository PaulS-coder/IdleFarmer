class_name AutomationFixtures
extends RefCounted
## Test builders for M02 automation (S4). They write state directly (fixtures, not gameplay paths)
## or submit real commands through an engine where the behavior under test is the command.

const AUTOMATION_CHAIN: PackedStringArray = ["batch_planting", "batch_harvesting", "automatic_harvesting", "automatic_replanting"]


## Sets the level and allocates `skills` (fixture), leaving the remaining earned points unspent.
static func with_skills(state: GameState, level: int, skills: PackedStringArray) -> void:
	Fixtures.set_xp(state, Fixtures.registry_v2().threshold_for_level(level))
	for skill_id: String in skills:
		state.player.skill_ranks[skill_id] = 1
	state.player.available_skill_points = level - 1 - skills.size()


## Level 7 with the four basic automation nodes.
static func level7_automation(state: GameState) -> void:
	with_skills(state, 7, AUTOMATION_CHAIN)


## Writes plot overrides for a recurring plan (fixture).
static func configure_plot(state: GameState, plot_id: int, crop_id: String, auto_harvest: bool, auto_replant: bool,
		policy: String = FertilizerDefinition.NONE_ID, fallback: bool = false) -> void:
	var settings: FarmingSettings = state.automation.plot(plot_id).settings
	settings.set_value(FarmingSettings.CROP_ID, crop_id)
	settings.set_value(FarmingSettings.AUTO_HARVEST, auto_harvest)
	settings.set_value(FarmingSettings.AUTO_REPLANT, auto_replant)
	settings.set_value(FarmingSettings.FERTILIZER_POLICY, policy)
	settings.set_value(FarmingSettings.FALLBACK_ACCEPTED, fallback)


## Arms the plot's loop for its current effective plan (fixture for an earlier ApplyAndStart).
static func arm(state: GameState, plot_id: int) -> void:
	state.automation.plot(plot_id).authorization.arm(SettingsResolver.effective_plan_digest(state, plot_id), 0)


## A configured, armed automatic plot (fixture).
static func loop_plot(state: GameState, plot_id: int, crop_id: String, policy: String = FertilizerDefinition.NONE_ID,
		fallback: bool = false) -> void:
	configure_plot(state, plot_id, crop_id, true, true, policy, fallback)
	arm(state, plot_id)


## Places a Ready cycle of `crop_id` on `plot_id` at the state's current time.
static func ready_cycle(state: GameState, plot_id: int, crop_id: String) -> CropCycle:
	var crop: CropDefinition = Fixtures.registry().crop(crop_id)
	var cycle: CropCycle = Fixtures.add_cycle(state, plot_id, crop_id, state.simulation_time_us - crop.base_growth_us
		if state.simulation_time_us >= crop.base_growth_us else 0, CropCycle.STATUS_READY)
	return cycle


## Accepted ConfigureAutomation command.
static func configure_cmd(state: GameState, plot_id: int, field: String, value: Variant, counter: int, set_flag: bool = true) -> GameCommand:
	return Fixtures.command(state, GameCommand.TYPE_CONFIGURE_AUTOMATION, {"plot_id": plot_id, "field": field, "set": set_flag,
		"value": value}, counter)


## Coins + every plot's (crop, status, fertilizer, stall) — a compact farm view for assertions.
static func farm_view(state: GameState) -> Array:
	var view: Array = [state.player.coins]
	for plot: PlotState in state.plots:
		var cycle: CropCycle = plot.crop_cycle
		view.append([plot.plot_id, "" if cycle == null else cycle.crop_id, "" if cycle == null else cycle.status,
			"" if cycle == null else cycle.fertilizer_id, plot.stall_reason])
	return view
