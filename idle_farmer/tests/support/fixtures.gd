class_name Fixtures
extends RefCounted
## Deterministic test fixtures: injected identity tokens, the shared registry and direct-state
## builders. Builders write state explicitly (they are fixtures, not gameplay paths) and always
## allocate IDs through GameState so allocator counters stay consistent.

const SAVE_ID: String = "save-test-0001"
const PLAYER_ID: String = "player-test-0001"
const CREATED_UTC_US: int = 1_790_000_000_000_000

static var _registry: ContentRegistry = null
static var _registry_v2: ContentRegistry = null


## Fixed UUID-shaped token, e.g. uuid("A") → "00000000-0000-4000-8000-00000000000A".
static func uuid(tag: String) -> String:
	return "00000000-0000-4000-8000-%s" % tag.lpad(12, "0")


static func registry() -> ContentRegistry:
	if _registry == null:
		_registry = ContentM01V1.build_registry()
	return _registry


static func new_game(epoch_tag: String = "A") -> GameState:
	return GameState.new_game(SAVE_ID, PLAYER_ID, uuid(epoch_tag), CREATED_UTC_US, registry())


## content_m02_v1: the M02 manifest (skill effects, equipment, fertilizers, expansion, economy).
static func registry_v2() -> ContentRegistry:
	if _registry_v2 == null:
		_registry_v2 = ContentM02V1.build_registry()
	return _registry_v2


static func new_game_v2(epoch_tag: String = "A") -> GameState:
	return GameState.new_game(SAVE_ID, PLAYER_ID, uuid(epoch_tag), CREATED_UTC_US, registry_v2())


## Registry bound to `state` (v1 or v2).
static func registry_for(state: GameState) -> ContentRegistry:
	return registry_v2() if state.content_version == ContentM02V1.MANIFEST_ID else registry()


## Places a cycle on `plot_id` exactly as planting would record it (identity modifiers).
static func add_cycle(state: GameState, plot_id: int, crop_id: String, planted_at_us: int, status: String = CropCycle.STATUS_GROWING) -> CropCycle:
	var crop: CropDefinition = registry().crop(crop_id)
	var cycle: CropCycle = CropCycle.new()
	cycle.cycle_id = state.allocate_entity_id()
	cycle.planting_transaction_id = state.allocate_entity_id()
	cycle.maturity_insertion_seq = state.allocate_insertion_sequence()
	cycle.plot_id = plot_id
	cycle.crop_id = crop_id
	cycle.status = status
	cycle.planted_at_us = planted_at_us
	cycle.effective_growth_us = crop.base_growth_us
	cycle.matures_at_us = planted_at_us + crop.base_growth_us
	cycle.seed_cost_paid = crop.seed_cost
	cycle.gross_coin_reward = crop.base_coins
	cycle.xp_reward = crop.base_xp
	cycle.modifier_snapshot = {"growth_reduction_bp": 0, "coin_bonus_bp": 0, "fertilizer_bonus_bp": 0}
	cycle.content_version = state.content_version
	state.plot(plot_id).crop_cycle = cycle
	return cycle


## Sets XP and the derived level, giving all earned points as unspent (no allocations).
static func set_xp(state: GameState, xp: int) -> void:
	state.player.total_xp = xp
	state.player.level = registry().level_for_xp(xp)
	state.player.available_skill_points = state.player.level - 1
	state.player.skill_ranks = {}


## Unlocks plots 1..count (contiguous prefix), as an explicit fixture pre-unlock.
static func unlock_prefix(state: GameState, count: int) -> void:
	for p: PlotState in state.plots:
		p.unlocked = p.plot_id <= count


## True when any error string carries `code` as its "CODE:" prefix.
static func has_code(errors: PackedStringArray, code: String) -> bool:
	for error: String in errors:
		if error.begins_with(code + ":"):
			return true
	return false


## Makes `crop_id` plantable: completes its research (if any) and raises XP to its level gate.
static func unlock_crop(state: GameState, crop_id: String) -> void:
	var crop: CropDefinition = registry().crop(crop_id)
	if not crop.research_id.is_empty() and not state.research.completed.has(crop.research_id):
		state.research.completed.append(crop.research_id)
		state.research.completed.sort()
	if state.player.level < crop.required_level:
		set_xp(state, registry().threshold_for_level(crop.required_level))


## Accepted PlantCrop at the state's current time, carrying the current quote's exact terms.
static func plant_cmd(state: GameState, plot_id: int, crop_id: String, counter: int = 1,
		fertilizer_id: String = FertilizerDefinition.NONE_ID) -> PlantCropCommand:
	var q: PlantingQuote = FarmSystem.quote_for(state, registry_for(state), crop_id, fertilizer_id)
	return PlantCropCommand.new(CommandId.new(state.save_id, state.command_replay.current_epoch, counter),
		state.simulation_time_us, counter, plot_id, crop_id, state.content_version, q.seed_cost, q.growth_us,
		q.gross_coins, q.xp, fertilizer_id, q.fertilizer_cost)


## Accepted HarvestCrop naming the plot's current cycle.
static func harvest_cmd(state: GameState, plot_id: int, counter: int = 2) -> HarvestCropCommand:
	var cycle: CropCycle = state.plot(plot_id).crop_cycle
	return HarvestCropCommand.new(CommandId.new(state.save_id, state.command_replay.current_epoch, counter),
		state.simulation_time_us, counter, plot_id, cycle.cycle_id if cycle != null else null)


## Minimal stand-in for the S4 engine advance: fires due maturity events in key order, then sets
## the target time. Returns the emitted CropMatured events.
static func advance(state: GameState, scheduler: EventScheduler, target_us: int) -> Array[SimulationEvent]:
	var emitted: Array[SimulationEvent] = []
	while scheduler.peek_time() != -1 and scheduler.peek_time() <= target_us:
		var event: ScheduledEvent = scheduler.pop_next()
		state.simulation_time_us = event.time_us
		var outcome: SimulationEvent = FarmSystem.mark_mature(state, event)
		if outcome != null:
			emitted.append(outcome)
	state.simulation_time_us = target_us
	return emitted
