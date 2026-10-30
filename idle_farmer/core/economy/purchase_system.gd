class_name PurchaseSystem
extends RefCounted
## Plot expansion and equipment purchases (M02-T03/T06; FR-FARM-06/08, DEC-020, FR-AUD-006).
## Quotes bind the *next* identity (plot N+1, rank owned+1) and its exact cost, so a re-delivered
## intent can never buy twice (E16). All checks precede mutation; failures change nothing.


## Terms a player would confirm to buy the next plot now ({} when none is purchasable).
static func quote_plot(state: GameState, registry: ContentRegistry) -> Dictionary:
	var next_id: int = state.unlocked_plot_count() + 1
	var band: ExpansionBand = registry.expansion_band(next_id)
	if band == null:
		return {}
	return {"plot_id": next_id, "cost": band.cost}


static func purchase_plot(state: GameState, registry: ContentRegistry, command: PurchasePlotCommand) -> CommandResult:
	var failure: String = FailureCode.NONE
	var unlocked: int = state.unlocked_plot_count()
	var band: ExpansionBand = registry.expansion_band(command.plot_id())
	var id_room: MathResult = IntegerMath.add(state.next_entity_id, 1)
	if registry.expansion_band(ExpansionBand.FIRST_PURCHASABLE_PLOT) == null:
		failure = FailureCode.FEATURE_UNAVAILABLE
	elif state.plot(command.plot_id()) == null:
		failure = FailureCode.UNKNOWN_PLOT
	elif unlocked >= PlotState.PLOT_COUNT:
		failure = FailureCode.PLOTS_FULL
	elif command.plot_id() != unlocked + 1 or band == null:
		failure = FailureCode.PLOT_UNLOCK_ORDER_REQUIRED
	elif state.player.level < band.required_level:
		failure = FailureCode.LEVEL_REQUIRED
	elif command.terms() != quote_plot(state, registry):
		failure = FailureCode.STALE_TERMS
	elif state.player.coins < band.cost:
		failure = FailureCode.INSUFFICIENT_COINS
	elif not id_room.ok:
		failure = FailureCode.NUMERIC_LIMIT
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "plot %d" % command.plot_id(), command.command_id(), state.state_sequence)
	var tx_id: EntityId = state.allocate_entity_id()
	state.player.coins -= band.cost
	state.plot(command.plot_id()).unlocked = true
	var result: CommandResult = SkillSystem.succeeded(command)
	result.affected_plot_ids = [command.plot_id()]
	result.transactions.append(EconomicTransaction.new(tx_id, state.simulation_time_us, EconomicTransaction.TYPE_PLOT_PURCHASE,
		command.plot_id(), null, -band.cost, 0, EconomicTransaction.CATEGORY_EXPANSION, state.content_version,
		EconomicTransaction.ORIGIN_MANUAL))
	result.events.append(SimulationEvent.new(SimulationEvent.PLOT_PURCHASED, state.simulation_time_us, command.plot_id(), null,
		{"cost": band.cost}))
	return result


## Terms a player would confirm to buy the next rank of `family_id` now ({} when unavailable).
static func quote_upgrade(state: GameState, registry: ContentRegistry, family_id: String) -> Dictionary:
	var target: int = state.upgrades.ranks.get(family_id, 0) + 1
	var upgrade: UpgradeDefinition = registry.upgrade(family_id, target)
	if upgrade == null:
		return {}
	return {"family_id": family_id, "target_rank": target, "cost": upgrade.cost}


static func purchase_upgrade(state: GameState, registry: ContentRegistry, command: PurchaseUpgradeCommand) -> CommandResult:
	var failure: String = FailureCode.NONE
	var family: String = command.family_id()
	var owned: int = state.upgrades.ranks.get(family, 0)
	var max_rank: int = registry.upgrade_max_rank(family)
	var upgrade: UpgradeDefinition = registry.upgrade(family, command.target_rank())
	var id_room: MathResult = IntegerMath.add(state.next_entity_id, 1)
	if max_rank == 0:
		failure = FailureCode.UNKNOWN_UPGRADE
	elif owned >= max_rank:
		failure = FailureCode.UPGRADE_MAX_RANK
	elif command.target_rank() > owned + 1 or upgrade == null:
		failure = FailureCode.UPGRADE_PREDECESSOR_REQUIRED
	elif state.player.level < upgrade.min_level:
		failure = FailureCode.LEVEL_REQUIRED
	elif command.terms() != quote_upgrade(state, registry, family):
		failure = FailureCode.STALE_TERMS  # includes re-delivery of an already-bought rank
	elif state.player.coins < upgrade.cost:
		failure = FailureCode.INSUFFICIENT_COINS
	elif not id_room.ok:
		failure = FailureCode.NUMERIC_LIMIT
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "upgrade '%s' rank %d" % [family, command.target_rank()], command.command_id(),
			state.state_sequence)
	var tx_id: EntityId = state.allocate_entity_id()
	state.player.coins -= upgrade.cost
	state.upgrades.ranks[family] = command.target_rank()
	var result: CommandResult = SkillSystem.succeeded(command)
	result.transactions.append(EconomicTransaction.new(tx_id, state.simulation_time_us, EconomicTransaction.TYPE_UPGRADE_PURCHASE,
		0, null, -upgrade.cost, 0, EconomicTransaction.CATEGORY_EQUIPMENT, state.content_version, EconomicTransaction.ORIGIN_MANUAL))
	result.events.append(SimulationEvent.new(SimulationEvent.UPGRADE_PURCHASED, state.simulation_time_us, 0, null,
		{"family_id": family, "rank": command.target_rank(), "cost": upgrade.cost}))
	return result
