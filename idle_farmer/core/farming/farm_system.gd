class_name FarmSystem
extends RefCounted
## Manual planting, maturity and harvest transitions (M01-T10/T11, TRS §4.3, FR-FARM-03–05).
##
## Called only by SimulationEngine, which owns ordering, time and state_sequence. Every transition
## validates and computes all values (including checked arithmetic and ID allocation room) before
## the first mutation, so a rejection or numeric failure leaves the state byte-identical.
## Manual planting does not change `selected_crop_id`: selection is configuration, not a purchase.


## Failure code for planting `crop_id` on `plot_id`, up to (not including) term/affordability
## checks; FailureCode.NONE when the target and gates allow planting.
static func check_plant_target(state: GameState, registry: ContentRegistry, plot_id: int, crop_id: String) -> String:
	var plot: PlotState = state.plot(plot_id)
	if plot == null:
		return FailureCode.UNKNOWN_PLOT
	var crop: CropDefinition = registry.crop(crop_id)
	if crop == null:
		return FailureCode.UNKNOWN_CROP
	if not plot.unlocked:
		return FailureCode.PLOT_LOCKED
	if plot.crop_cycle != null:
		return FailureCode.PLOT_OCCUPIED
	if state.player.level < crop.required_level:
		return FailureCode.LEVEL_REQUIRED
	if not crop.research_id.is_empty() and not state.research.completed.has(crop.research_id):
		return FailureCode.RESEARCH_REQUIRED
	return FailureCode.NONE


## The quote a player would confirm for planting `crop_id` now (previews and execution share it).
static func quote_for(state: GameState, registry: ContentRegistry, crop_id: String) -> PlantingQuote:
	var crop: CropDefinition = registry.crop(crop_id)
	if crop == null:
		return PlantingQuote.new()
	return EconomySystem.quote_planting(crop, state.content_version, EconomySystem.current_modifiers(state))


## Executes an accepted PlantCrop at the state's current simulation time.
static func plant(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: PlantCropCommand) -> CommandResult:
	var now: int = state.simulation_time_us
	var failure: String = check_plant_target(state, registry, command.plot_id(), command.crop_id())
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "plot %d crop '%s'" % [command.plot_id(), command.crop_id()], command.command_id(), state.state_sequence)
	var quote: PlantingQuote = quote_for(state, registry, command.crop_id())
	if not quote.ok:
		return CommandResult.failed(FailureCode.NUMERIC_LIMIT, "quote not representable", command.command_id(), state.state_sequence)
	if not quote.matches(command):
		return CommandResult.failed(FailureCode.STALE_TERMS, "confirmed terms differ from current quote", command.command_id(), state.state_sequence)
	if state.player.coins < quote.seed_cost:
		return CommandResult.failed(FailureCode.INSUFFICIENT_COINS, "need %d coins" % quote.seed_cost, command.command_id(), state.state_sequence)
	var coins_after: MathResult = IntegerMath.sub(state.player.coins, quote.seed_cost)
	var matures_at: MathResult = IntegerMath.add(now, quote.growth_us)
	var id_room: MathResult = IntegerMath.add(state.next_entity_id, 2)
	var seq_room: MathResult = IntegerMath.add(state.next_insertion_sequence, 1)
	if not (coins_after.ok and matures_at.ok and id_room.ok and seq_room.ok):
		return CommandResult.failed(FailureCode.NUMERIC_LIMIT, "planting values not representable", command.command_id(), state.state_sequence)

	# All checks passed: apply atomically.
	var cycle: CropCycle = CropCycle.new()
	cycle.cycle_id = state.allocate_entity_id()
	cycle.planting_transaction_id = state.allocate_entity_id()
	cycle.maturity_insertion_seq = state.allocate_insertion_sequence()
	cycle.plot_id = command.plot_id()
	cycle.crop_id = quote.crop_id
	cycle.status = CropCycle.STATUS_GROWING
	cycle.planted_at_us = now
	cycle.effective_growth_us = quote.growth_us
	cycle.matures_at_us = matures_at.value
	cycle.seed_cost_paid = quote.seed_cost
	cycle.gross_coin_reward = quote.gross_coins
	cycle.xp_reward = quote.xp
	cycle.modifier_snapshot = quote.modifiers.duplicate()
	cycle.content_version = quote.manifest_id
	state.player.coins = coins_after.value
	state.plot(command.plot_id()).crop_cycle = cycle
	scheduler.push(ScheduledEvent.for_maturity(cycle))

	var result: CommandResult = CommandResult.new()
	result.success = true
	result.command_id = command.command_id()
	result.affected_plot_ids = [cycle.plot_id]
	result.transactions.append(EconomicTransaction.new(cycle.planting_transaction_id, now, EconomicTransaction.TYPE_SEED_PURCHASE,
		cycle.plot_id, cycle.cycle_id, -quote.seed_cost, 0, EconomicTransaction.CATEGORY_SEEDS, quote.manifest_id))
	result.events.append(SimulationEvent.new(SimulationEvent.CROP_PLANTED, now, cycle.plot_id, cycle.cycle_id,
		{"crop_id": cycle.crop_id, "matures_at_us": cycle.matures_at_us}))
	return result


## Marks the targeted cycle Ready when its maturity event fires. Returns the single CropMatured
## outcome, or null for a stale event (cycle harvested/replaced, already ready, or not yet due).
## Maturity never pays anything.
static func mark_mature(state: GameState, event: ScheduledEvent) -> SimulationEvent:
	var plot: PlotState = state.plot(event.plot_id)
	if plot == null or plot.crop_cycle == null:
		return null
	var cycle: CropCycle = plot.crop_cycle
	if not cycle.cycle_id.equals(event.target_id) or cycle.status != CropCycle.STATUS_GROWING:
		return null
	if cycle.matures_at_us != event.time_us or state.simulation_time_us < cycle.matures_at_us:
		return null
	cycle.status = CropCycle.STATUS_READY
	return SimulationEvent.new(SimulationEvent.CROP_MATURED, event.time_us, cycle.plot_id, cycle.cycle_id, {"crop_id": cycle.crop_id})


## Executes an accepted HarvestCrop: the command must name the plot's current Ready cycle.
static func harvest(state: GameState, registry: ContentRegistry, command: HarvestCropCommand) -> CommandResult:
	var plot: PlotState = state.plot(command.plot_id())
	var failure: String = FailureCode.NONE
	if plot == null:
		failure = FailureCode.UNKNOWN_PLOT
	elif not plot.unlocked:
		failure = FailureCode.PLOT_LOCKED
	elif plot.crop_cycle == null:
		failure = FailureCode.NO_CYCLE
	elif not plot.crop_cycle.cycle_id.equals(command.cycle_id()):
		failure = FailureCode.CYCLE_MISMATCH
	elif plot.crop_cycle.status != CropCycle.STATUS_READY:
		failure = FailureCode.CROP_NOT_READY
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "plot %d" % command.plot_id(), command.command_id(), state.state_sequence)
	var batch: StateChangeBatch = harvest_ready_cycle(state, registry, command.plot_id())
	if batch.failure_code != FailureCode.NONE:
		return CommandResult.failed(batch.failure_code, "harvest values not representable", command.command_id(), state.state_sequence)
	var result: CommandResult = CommandResult.new()
	result.success = true
	result.command_id = command.command_id()
	result.affected_plot_ids = [command.plot_id()]
	result.events = batch.events
	result.transactions = batch.transactions
	return result


## The single harvest transition shared by manual and (M02) automatic harvesting: credits the
## snapshotted reward once, applies level gains, terminates the cycle. The caller guarantees the
## plot holds a Ready cycle. On numeric failure returns a batch with failure_code and no mutation.
static func harvest_ready_cycle(state: GameState, registry: ContentRegistry, plot_id: int) -> StateChangeBatch:
	var batch: StateChangeBatch = StateChangeBatch.new()
	var now: int = state.simulation_time_us
	batch.time_us = now
	var cycle: CropCycle = state.plot(plot_id).crop_cycle
	var reward: Array[int] = EconomySystem.harvest_reward(cycle)
	var coins_after: MathResult = IntegerMath.add(state.player.coins, reward[0])
	var grant: XpGrant = ProgressionSystem.prepare_xp(state.player, registry, reward[1])
	var id_room: MathResult = IntegerMath.add(state.next_entity_id, 1)
	if not (coins_after.ok and grant.ok and id_room.ok):
		batch.failure_code = FailureCode.NUMERIC_LIMIT
		return batch

	var tx_id: EntityId = state.allocate_entity_id()
	state.player.coins = coins_after.value
	ProgressionSystem.apply(state.player, grant)
	state.plot(plot_id).crop_cycle = null
	batch.transactions.append(EconomicTransaction.new(tx_id, now, EconomicTransaction.TYPE_HARVEST_CREDIT, plot_id,
		cycle.cycle_id, reward[0], reward[1], EconomicTransaction.CATEGORY_HARVEST, cycle.content_version))
	batch.events.append(SimulationEvent.new(SimulationEvent.CROP_HARVESTED, now, plot_id, cycle.cycle_id,
		{"crop_id": cycle.crop_id, "coins": reward[0], "xp": reward[1]}))
	if grant.levels_gained() > 0:
		batch.events.append(SimulationEvent.new(SimulationEvent.LEVEL_GAINED, now, plot_id, null,
			{"from_level": grant.old_level, "to_level": grant.new_level, "points_granted": grant.levels_gained()}))
	return batch
