class_name Fixtures
extends RefCounted
## Deterministic test fixtures: injected identity tokens, the shared registry and direct-state
## builders. Builders write state explicitly (they are fixtures, not gameplay paths) and always
## allocate IDs through GameState so allocator counters stay consistent.

const SAVE_ID: String = "save-test-0001"
const PLAYER_ID: String = "player-test-0001"
const CREATED_UTC_US: int = 1_790_000_000_000_000

static var _registry: ContentRegistry = null


## Fixed UUID-shaped token, e.g. uuid("A") → "00000000-0000-4000-8000-00000000000A".
static func uuid(tag: String) -> String:
	return "00000000-0000-4000-8000-%s" % tag.lpad(12, "0")


static func registry() -> ContentRegistry:
	if _registry == null:
		_registry = ContentM01V1.build_registry()
	return _registry


static func new_game(epoch_tag: String = "A") -> GameState:
	return GameState.new_game(SAVE_ID, PLAYER_ID, uuid(epoch_tag), CREATED_UTC_US, registry())


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
	cycle.modifier_snapshot = {"growth_reduction_bp": 0, "coin_bonus_bp": 0}
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
