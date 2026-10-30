class_name SkillSystem
extends RefCounted
## Skill allocation and paid reset (M02-T04/T05, FRS §§5.2–5.5, DEC-004, FR-AUD-003/004).
## Quotes and execution share one calculation; execution recomputes the quote at acceptance and
## rejects with STALE_TERMS when the confirmed terms differ. Every check runs before any mutation.


## Terms a player would confirm to allocate the next rank of `skill_id` now.
static func quote_allocate(state: GameState, skill_id: String) -> Dictionary:
	return {"skill_id": skill_id, "target_rank": state.player.skill_ranks.get(skill_id, 0) + 1}


## Failure code for allocating the next rank of `skill_id`, before term comparison.
static func check_allocate(state: GameState, registry: ContentRegistry, skill_id: String) -> String:
	var skill: SkillDefinition = registry.skill(skill_id)
	if skill == null:
		return FailureCode.UNKNOWN_SKILL
	if state.player.skill_ranks.get(skill_id, 0) >= skill.max_ranks:
		return FailureCode.SKILL_MAX_RANK
	if state.player.level < skill.min_level:
		return FailureCode.LEVEL_REQUIRED
	if not skill.prerequisite_id.is_empty() and state.player.skill_ranks.get(skill.prerequisite_id, 0) < 1:
		return FailureCode.SKILL_PREREQUISITE_REQUIRED
	if state.player.available_skill_points < SkillDefinition.POINT_COST_PER_RANK:
		return FailureCode.INSUFFICIENT_POINTS
	return FailureCode.NONE


static func allocate(state: GameState, registry: ContentRegistry, command: AllocateSkillCommand) -> CommandResult:
	var failure: String = check_allocate(state, registry, command.skill_id())
	if failure == FailureCode.NONE and command.terms() != quote_allocate(state, command.skill_id()):
		failure = FailureCode.STALE_TERMS
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "skill '%s'" % command.skill_id(), command.command_id(), state.state_sequence)
	var rank: int = state.player.skill_ranks.get(command.skill_id(), 0) + 1
	state.player.skill_ranks[command.skill_id()] = rank
	state.player.available_skill_points -= SkillDefinition.POINT_COST_PER_RANK
	var result: CommandResult = succeeded(command)
	result.events.append(SimulationEvent.new(SimulationEvent.SKILL_ALLOCATED, state.simulation_time_us, 0, null,
		{"skill_id": command.skill_id(), "rank": rank}))
	return result


## Reset price max(minimum, factor × level²) from the profile manifest; fails for manifests
## without economy parameters.
static func reset_price(registry: ContentRegistry, level: int) -> MathResult:
	var economy: EconomyParameters = registry.economy()
	if economy == null:
		return MathResult.failure()
	var squared: MathResult = IntegerMath.mul(level, level)
	var scaled: MathResult = IntegerMath.mul(economy.reset_level_factor, squared.value) if squared.ok else squared
	if not scaled.ok:
		return scaled
	return MathResult.of(maxi(economy.reset_minimum, scaled.value))


## Terms a player would confirm for a reset now: level, exact price and points refunded.
static func quote_reset(state: GameState, registry: ContentRegistry) -> Dictionary:
	var price: MathResult = reset_price(registry, state.player.level)
	return {"level": state.player.level, "price": price.value if price.ok else -1,
		"allocated_points": state.player.allocated_skill_points()}


## Refunds every allocated point for the quoted price. XP, level, plots, equipment, research and
## planted snapshots are untouched. Automation loops are disarmed by the S4 authorization layer.
static func reset(state: GameState, registry: ContentRegistry, command: ResetSkillsCommand) -> CommandResult:
	var failure: String = FailureCode.NONE
	var price: MathResult = reset_price(registry, state.player.level)
	var allocated: int = state.player.allocated_skill_points()
	var id_room: MathResult = IntegerMath.add(state.next_entity_id, 1)
	var refunded: MathResult = IntegerMath.add(state.player.available_skill_points, allocated)
	if not registry.has_economy_tables():
		failure = FailureCode.FEATURE_UNAVAILABLE
	elif allocated <= 0:
		failure = FailureCode.NOTHING_TO_RESET
	elif not price.ok:
		failure = FailureCode.NUMERIC_LIMIT
	elif command.terms() != quote_reset(state, registry):
		failure = FailureCode.STALE_TERMS
	elif state.player.coins < price.value:
		failure = FailureCode.INSUFFICIENT_COINS
	elif not id_room.ok or not refunded.ok:
		failure = FailureCode.NUMERIC_LIMIT
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "reset at level %d" % state.player.level, command.command_id(), state.state_sequence)
	var tx_id: EntityId = state.allocate_entity_id()
	state.player.coins -= price.value
	state.player.available_skill_points = refunded.value
	state.player.skill_ranks = {}
	var result: CommandResult = succeeded(command)
	result.transactions.append(EconomicTransaction.new(tx_id, state.simulation_time_us, EconomicTransaction.TYPE_SKILL_RESET,
		0, null, -price.value, 0, EconomicTransaction.CATEGORY_RESET, state.content_version, EconomicTransaction.ORIGIN_MANUAL))
	result.events.append(SimulationEvent.new(SimulationEvent.SKILLS_RESET, state.simulation_time_us, 0, null,
		{"price": price.value, "refunded_points": allocated}))
	return result


static func succeeded(command: GameCommand) -> CommandResult:
	var result: CommandResult = CommandResult.new()
	result.success = true
	result.command_id = command.command_id()
	return result
