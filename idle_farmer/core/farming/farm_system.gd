class_name FarmSystem
extends RefCounted
## Manual planting, maturity and harvest transitions (M01-T10/T11, TRS §4.3, FR-FARM-03–05; M02
## Q1/E8, FRS §§7.1, 9.2).
##
## Called only by SimulationEngine and the batch pipeline, which own ordering, time and
## state_sequence. Every transition validates and computes all values (including checked arithmetic
## and ID allocation room) before the first mutation, so a rejection or numeric failure leaves the
## state byte-identical. Planting never changes stored settings: selection is configuration, not a
## purchase. A manual Plant arms the plot's loop only when its confirmed terms carry the plot's
## current effective plan digest (Q1).


## Failure code for planting `crop_id` on `plot_id` at player `level`, ignoring the current cycle
## when `ignore_occupied` (a plot being harvested in the same batch). FailureCode.NONE when allowed.
static func check_eligibility(state: GameState, registry: ContentRegistry, plot_id: int, crop_id: String, level: int,
		ignore_occupied: bool = false) -> String:
	var plot: PlotState = state.plot(plot_id)
	if plot == null:
		return FailureCode.UNKNOWN_PLOT
	var crop: CropDefinition = registry.crop(crop_id)
	if crop == null:
		return FailureCode.UNKNOWN_CROP
	if not plot.unlocked:
		return FailureCode.PLOT_LOCKED
	if plot.crop_cycle != null and not ignore_occupied:
		return FailureCode.PLOT_OCCUPIED
	if level < crop.required_level:
		return FailureCode.LEVEL_REQUIRED
	if not crop.research_id.is_empty() and not state.research.completed.has(crop.research_id):
		return FailureCode.RESEARCH_REQUIRED
	return FailureCode.NONE


## Failure code for planting `crop_id` with `fertilizer_id` on `plot_id`, up to (not including)
## term/affordability checks; FailureCode.NONE when the target and gates allow planting.
static func check_plant_target(state: GameState, registry: ContentRegistry, plot_id: int, crop_id: String,
		fertilizer_id: String = FertilizerDefinition.NONE_ID) -> String:
	if state.plot(plot_id) == null:
		return FailureCode.UNKNOWN_PLOT
	if registry.crop(crop_id) == null:
		return FailureCode.UNKNOWN_CROP
	if registry.fertilizer(fertilizer_id) == null:
		return FailureCode.UNKNOWN_FERTILIZER
	return check_eligibility(state, registry, plot_id, crop_id, state.player.level)


## The quote a player would confirm for planting `crop_id` with `fertilizer_id` now (previews and
## execution share it). Not ok for an unknown crop or fertilizer. With a `plot_id`, the quote also
## carries the plan terms: the plot's plan digest when this planting would arm its loop (Q1) and the
## minimum ending balance when the planting would end below the farm reserve (FRS §7.1).
static func quote_for(state: GameState, registry: ContentRegistry, crop_id: String,
		fertilizer_id: String = FertilizerDefinition.NONE_ID, plot_id: int = 0) -> PlantingQuote:
	var crop: CropDefinition = registry.crop(crop_id)
	var fertilizer: FertilizerDefinition = registry.fertilizer(fertilizer_id)
	if crop == null or fertilizer == null:
		return PlantingQuote.new()
	var snapshot: ModifierSnapshot = ModifierSnapshot.for_state(state, registry, fertilizer_id)
	var quote: PlantingQuote = EconomySystem.quote_planting(crop, state.content_version, snapshot, fertilizer)
	if plot_id > 0 and quote.ok and state.plot(plot_id) != null:
		quote.plan_digest = arming_digest(state, registry, plot_id, crop_id, fertilizer_id)
		if not quote.plan_digest.is_empty():
			quote.fallback_accepted = SettingsResolver.effective(state, plot_id).fallback_accepted
		var cost: MathResult = quote.total_cost()
		if cost.ok and state.player.coins >= cost.value and state.player.coins - cost.value < state.automation.budget_reserve:
			quote.min_ending_balance = state.player.coins - cost.value
	return quote


## The plot's effective plan digest when planting `crop_id` + `fertilizer_id` there equals its
## configured plan and Auto Replant is enabled and owned (Q1); "" otherwise. Smart plans are armed
## only through ApplyAndStart.
static func arming_digest(state: GameState, registry: ContentRegistry, plot_id: int, crop_id: String, fertilizer_id: String) -> String:
	var settings: FarmingSettings = SettingsResolver.effective(state, plot_id)
	if not settings.auto_replant or settings.crop_id != crop_id or settings.fertilizer_policy != fertilizer_id:
		return ""
	if not Capabilities.of(state, registry).has(Capabilities.AUTOMATIC_REPLANTING):
		return ""
	return SettingsResolver.plan_digest(settings)


## Executes an accepted PlantCrop at the state's current simulation time. Seed and fertilizer are
## charged together (all-or-nothing) and recorded as separate transactions (M02 E13).
static func plant(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: PlantCropCommand) -> CommandResult:
	var failure: String = check_plant_target(state, registry, command.plot_id(), command.crop_id(), command.fertilizer_id())
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "plot %d crop '%s' fertilizer '%s'" % [command.plot_id(), command.crop_id(),
			command.fertilizer_id()], command.command_id(), state.state_sequence)
	var quote: PlantingQuote = quote_for(state, registry, command.crop_id(), command.fertilizer_id(), command.plot_id())
	if not quote.ok:
		return CommandResult.failed(FailureCode.NUMERIC_LIMIT, "quote not representable", command.command_id(), state.state_sequence)
	if not quote.matches(command):
		return CommandResult.failed(FailureCode.STALE_TERMS, "confirmed terms differ from current quote", command.command_id(), state.state_sequence)
	var total_cost: MathResult = quote.total_cost()
	if total_cost.ok and state.player.coins < total_cost.value:
		return CommandResult.failed(FailureCode.INSUFFICIENT_COINS, "need %d coins" % total_cost.value, command.command_id(), state.state_sequence)
	if total_cost.ok and not ending_balance_authorized(state.player.coins - total_cost.value, state.automation.budget_reserve,
			command.min_ending_balance()):
		return CommandResult.failed(FailureCode.STALE_TERMS, "ending balance below the confirmed minimum or the reserve",
			command.command_id(), state.state_sequence)
	var failure_room: String = planting_room(state, quote)
	if not total_cost.ok or failure_room != FailureCode.NONE:
		return CommandResult.failed(FailureCode.NUMERIC_LIMIT, "planting values not representable", command.command_id(), state.state_sequence)

	var applied: StateChangeBatch = apply_planting(state, scheduler, command.plot_id(), quote, EconomicTransaction.ORIGIN_MANUAL, false)
	if not command.plan_digest().is_empty():
		state.automation.plot(command.plot_id()).authorization.arm(command.plan_digest(), state.state_sequence)
		applied.events.append(SimulationEvent.new(SimulationEvent.LOOP_ARMED, state.simulation_time_us, command.plot_id(), null,
			{"plan_digest": command.plan_digest()}))
	var result: CommandResult = CommandResult.new()
	result.success = true
	result.command_id = command.command_id()
	result.affected_plot_ids = [command.plot_id()]
	result.events = applied.events
	result.transactions = applied.transactions
	return result


## A manual planting may end below the farm reserve only with a confirmed minimum ending balance
## (reserve override); a confirmed minimum always holds (FR-AUD-004: never a lower balance).
static func ending_balance_authorized(coins_after: int, reserve: int, min_ending_balance: int) -> bool:
	if min_ending_balance >= 0:
		return coins_after >= min_ending_balance
	return coins_after >= reserve


## NUMERIC_LIMIT when the planting's IDs, insertion sequence or maturity time are not representable.
static func planting_room(state: GameState, quote: PlantingQuote) -> String:
	var has_fertilizer: bool = quote.fertilizer_id != FertilizerDefinition.NONE_ID
	if not IntegerMath.add(state.simulation_time_us, quote.growth_us).ok \
			or not IntegerMath.add(state.next_entity_id, 3 if has_fertilizer else 2).ok \
			or not IntegerMath.add(state.next_insertion_sequence, 1).ok:
		return FailureCode.NUMERIC_LIMIT
	return FailureCode.NONE


## The single planting transition shared by manual and automatic planting. The caller has validated
## eligibility, funds and representability. Creates the cycle snapshot, charges seed and fertilizer
## as separate transactions, clears the plot's stall and schedules maturity.
static func apply_planting(state: GameState, scheduler: EventScheduler, plot_id: int, quote: PlantingQuote, origin: String,
		fallback_used: bool) -> StateChangeBatch:
	var batch: StateChangeBatch = StateChangeBatch.new()
	var now: int = state.simulation_time_us
	batch.time_us = now
	var has_fertilizer: bool = quote.fertilizer_id != FertilizerDefinition.NONE_ID
	var cycle: CropCycle = CropCycle.new()
	cycle.cycle_id = state.allocate_entity_id()
	cycle.planting_transaction_id = state.allocate_entity_id()
	if has_fertilizer:
		cycle.fertilizer_transaction_id = state.allocate_entity_id()
	cycle.maturity_insertion_seq = state.allocate_insertion_sequence()
	cycle.plot_id = plot_id
	cycle.crop_id = quote.crop_id
	cycle.status = CropCycle.STATUS_GROWING
	cycle.planted_at_us = now
	cycle.effective_growth_us = quote.growth_us
	cycle.matures_at_us = now + quote.growth_us
	cycle.seed_cost_paid = quote.seed_cost
	cycle.fertilizer_id = quote.fertilizer_id
	cycle.fertilizer_cost_paid = quote.fertilizer_cost
	cycle.gross_coin_reward = quote.gross_coins
	cycle.xp_reward = quote.xp
	cycle.modifier_snapshot = quote.modifiers.duplicate()
	cycle.content_version = quote.manifest_id
	state.player.coins -= quote.seed_cost + quote.fertilizer_cost
	var plot: PlotState = state.plot(plot_id)
	plot.crop_cycle = cycle
	plot.stall_reason = PlotState.STALL_NONE
	scheduler.push(ScheduledEvent.for_maturity(cycle))

	batch.transactions.append(EconomicTransaction.new(cycle.planting_transaction_id, now, EconomicTransaction.TYPE_SEED_PURCHASE,
		plot_id, cycle.cycle_id, -quote.seed_cost, 0, EconomicTransaction.CATEGORY_SEEDS, quote.manifest_id, origin))
	if has_fertilizer:
		batch.transactions.append(EconomicTransaction.new(cycle.fertilizer_transaction_id, now,
			EconomicTransaction.TYPE_FERTILIZER_PURCHASE, plot_id, cycle.cycle_id, -quote.fertilizer_cost, 0,
			EconomicTransaction.CATEGORY_FERTILIZER, quote.manifest_id, origin))
	var data: Dictionary = {"crop_id": cycle.crop_id, "fertilizer_id": cycle.fertilizer_id, "matures_at_us": cycle.matures_at_us,
		"origin": origin}
	if fallback_used:
		data["fallback_used"] = true
	batch.events.append(SimulationEvent.new(SimulationEvent.CROP_PLANTED, now, plot_id, cycle.cycle_id, data))
	return batch


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


## Failure code for harvesting `cycle_id` on `plot_id` now; FailureCode.NONE when it is Ready.
static func check_harvest(state: GameState, plot_id: int, cycle_id: EntityId) -> String:
	var plot: PlotState = state.plot(plot_id)
	if plot == null:
		return FailureCode.UNKNOWN_PLOT
	if not plot.unlocked:
		return FailureCode.PLOT_LOCKED
	if plot.crop_cycle == null:
		return FailureCode.NO_CYCLE
	if not plot.crop_cycle.cycle_id.equals(cycle_id):
		return FailureCode.CYCLE_MISMATCH
	if plot.crop_cycle.status != CropCycle.STATUS_READY:
		return FailureCode.CROP_NOT_READY
	return FailureCode.NONE


## Executes an accepted HarvestCrop: the command must name the plot's current Ready cycle. The
## credit and any authorized replant run as one batch (E8): credits first, then automatic budgets.
static func harvest(state: GameState, registry: ContentRegistry, command: HarvestCropCommand, scheduler: EventScheduler = null) -> CommandResult:
	var failure: String = check_harvest(state, command.plot_id(), command.cycle_id())
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "plot %d" % command.plot_id(), command.command_id(), state.state_sequence)
	var proposal: BatchProposal = BatchPlanner.plan(state, registry, {"harvest_plot_ids": [command.plot_id()]})
	if proposal.failure_code != FailureCode.NONE:
		return CommandResult.failed(proposal.failure_code, "harvest values not representable", command.command_id(), state.state_sequence)
	var batch: StateChangeBatch = BatchApplier.apply(state, registry, scheduler if scheduler != null else EventScheduler.new(), proposal)
	var result: CommandResult = CommandResult.new()
	result.success = true
	result.command_id = command.command_id()
	result.affected_plot_ids = [command.plot_id()]
	result.events = batch.events
	result.transactions = batch.transactions
	return result


## The single harvest transition shared by manual and automatic harvesting: credits the
## snapshotted reward once, applies level gains, terminates the cycle. The caller guarantees the
## plot holds a Ready cycle. On numeric failure returns a batch with failure_code and no mutation.
static func harvest_ready_cycle(state: GameState, registry: ContentRegistry, plot_id: int, origin: String) -> StateChangeBatch:
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
		cycle.cycle_id, reward[0], reward[1], EconomicTransaction.CATEGORY_HARVEST, cycle.content_version, origin))
	batch.events.append(SimulationEvent.new(SimulationEvent.CROP_HARVESTED, now, plot_id, cycle.cycle_id,
		{"crop_id": cycle.crop_id, "coins": reward[0], "xp": reward[1], "origin": origin, "seed_cost": cycle.seed_cost_paid,
			"fertilizer_id": cycle.fertilizer_id, "fertilizer_cost": cycle.fertilizer_cost_paid}))
	if grant.levels_gained() > 0:
		batch.events.append(SimulationEvent.new(SimulationEvent.LEVEL_GAINED, now, plot_id, null,
			{"from_level": grant.old_level, "to_level": grant.new_level, "points_granted": grant.levels_gained()}))
	return batch
