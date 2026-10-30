class_name SimulationEngine
extends RefCounted
## The sole authoritative mutation orchestrator (M01-T13, TRS §§2, 4–5). Pure: no I/O, no clock
## reads, no scene access. It mutates only the GameState it was initialized with — the controller
## always passes a working clone and decides whether that clone becomes committed.
##
## Ordering contract (DEC-006): due events at a timestamp are processed, in scheduler key order,
## before any command at that timestamp; commands carry a controller-stamped accepted time equal to
## the engine's current time after due work. Rejections change nothing.

## Upper bound on processing rounds at one timestamp; a round without state progress ends it
## (no infinite zero-time loops, TRS §4.2).
const MAX_ROUNDS_PER_TIMESTAMP: int = 64

var _state: GameState = null
var _registry: ContentRegistry = null
var _scheduler: EventScheduler = null


## Binds `state` (resolved through its own manifest) and rebuilds the pending queue.
## Returns validation errors; on any error the engine stays uninitialized.
func initialize(state: GameState, catalog: ManifestCatalog) -> PackedStringArray:
	_state = null
	_registry = null
	_scheduler = null
	if state == null:
		return PackedStringArray(["STATE_MISSING: no state supplied"])
	var registry: ContentRegistry = catalog.resolve(state.content_version)
	if registry == null:
		return PackedStringArray(["MANIFEST_UNRESOLVED: '%s' is not supported by this build" % state.content_version])
	var errors: PackedStringArray = state.validate(registry)
	if not errors.is_empty():
		return errors
	_state = state
	_registry = registry
	_scheduler = EventScheduler.rebuild(state)
	return PackedStringArray()


func is_initialized() -> bool:
	return _state != null


func registry() -> ContentRegistry:
	return _registry


func current_time_us() -> int:
	return _state.simulation_time_us


func validate_state() -> PackedStringArray:
	return _state.validate(_registry)


## Deep copy of the engine's current state (never the live object).
func get_state_snapshot() -> GameState:
	return _state.clone()


## Earliest pending event time, or -1 when nothing is scheduled.
func get_next_event_time() -> int:
	return _scheduler.peek_time()


## Advances event by event to `target_us` (never frame by frame). Each timestamp with outcomes is
## one logical batch and increments state_sequence once. Returns all outcomes; a target in the past
## returns a batch with INVALID_COMMAND_TIME and changes nothing.
func advance_to(target_us: int) -> StateChangeBatch:
	var total: StateChangeBatch = StateChangeBatch.new()
	total.time_us = _state.simulation_time_us
	if target_us < _state.simulation_time_us:
		total.failure_code = FailureCode.INVALID_COMMAND_TIME
		return total
	while _scheduler.peek_time() != -1 and _scheduler.peek_time() <= target_us:
		var time_us: int = _scheduler.peek_time()
		_state.simulation_time_us = time_us
		var batch: StateChangeBatch = _process_timestamp(time_us)
		total.append(batch)
		if batch.failure_code != FailureCode.NONE:
			# DEC-026 / M02 E5: stop at the failing timestamp; the caller must not commit this state.
			return total
		if batch.changed():
			_state.state_sequence += 1
	_state.simulation_time_us = target_us
	total.time_us = target_us
	return total


## Executes one accepted command at the engine's current time. Precedence follows FailureCode.
func submit_command(command: GameCommand) -> CommandResult:
	var id: CommandId = command.command_id()
	var envelope: String = command.envelope_failure(_state.save_id)
	if envelope != FailureCode.NONE:
		return CommandResult.failed(envelope, "malformed accepted envelope", id, _state.state_sequence)
	var now: int = _state.simulation_time_us
	var next_due: int = _scheduler.peek_time()
	if command.accepted_time_us() != now or (next_due != -1 and next_due <= now):
		return CommandResult.failed(FailureCode.INVALID_COMMAND_TIME,
			"accepted at %d, engine at %d" % [command.accepted_time_us(), now], id, _state.state_sequence)
	if _state.command_replay.is_stale_epoch(id):
		return CommandResult.failed(FailureCode.STALE_COMMAND, "epoch '%s' is not current" % id.writer_epoch, id, _state.state_sequence)
	if _state.command_replay.is_duplicate(id):
		return CommandResult.failed(FailureCode.DUPLICATE_COMMAND, "counter %d already committed" % id.counter, id, _state.state_sequence)

	var result: CommandResult
	match command.type():
		GameCommand.TYPE_PLANT_CROP:
			result = FarmSystem.plant(_state, _registry, _scheduler, command as PlantCropCommand)
		GameCommand.TYPE_HARVEST_CROP:
			result = FarmSystem.harvest(_state, _registry, command as HarvestCropCommand, _scheduler)
		GameCommand.TYPE_PURCHASE_PLOT:
			result = PurchaseSystem.purchase_plot(_state, _registry, command as PurchasePlotCommand)
		GameCommand.TYPE_ALLOCATE_SKILL:
			result = SkillSystem.allocate(_state, _registry, command as AllocateSkillCommand)
		GameCommand.TYPE_RESET_SKILLS:
			result = SkillSystem.reset(_state, _registry, command as ResetSkillsCommand)
		GameCommand.TYPE_PURCHASE_UPGRADE:
			result = PurchaseSystem.purchase_upgrade(_state, _registry, command as PurchaseUpgradeCommand)
		GameCommand.TYPE_START_RESEARCH:
			result = ResearchSystem.start(_state, _registry, _scheduler, command as StartResearchCommand)
		GameCommand.TYPE_ACCELERATE_RESEARCH:
			result = ResearchSystem.accelerate(_state, _scheduler, command as AccelerateResearchCommand)
		GameCommand.TYPE_BATCH_PLANT:
			result = AutomationSystem.batch_plant(_state, _registry, _scheduler, command as BatchPlantCommand)
		GameCommand.TYPE_BATCH_HARVEST:
			result = AutomationSystem.batch_harvest(_state, _registry, _scheduler, command as BatchHarvestCommand)
		GameCommand.TYPE_APPLY_AND_START:
			result = AutomationSystem.apply_and_start(_state, _registry, _scheduler, command as ApplyAndStartCommand)
		GameCommand.TYPE_CONFIGURE_AUTOMATION:
			result = AutomationSystem.configure(_state, _registry, _scheduler, command as ConfigureAutomationCommand)
		GameCommand.TYPE_CONFIGURE_BUDGET:
			result = AutomationSystem.configure_budget(_state, _registry, _scheduler, command as ConfigureBudgetCommand)
		_:
			if command is UnavailableCommand:
				return CommandResult.failed(FailureCode.FEATURE_UNAVAILABLE, "'%s' is not available in this milestone" % command.type(),
					id, _state.state_sequence)
			return CommandResult.failed(FailureCode.MALFORMED_ENVELOPE, "unsupported command type", id, _state.state_sequence)
	if not result.success:
		return result
	_state.state_sequence += 1
	result.state_sequence = _state.state_sequence
	_state.command_replay.record_success(id, compact_result(result))
	return result


## Compact replay-cache entry (M02 carry-over 5): enough to answer a duplicate delivery without
## storing whole batch results inside GameState.
static func compact_result(result: CommandResult) -> Dictionary:
	return {
		"success": result.success,
		"failure_code": result.failure_code,
		"command_id": null if result.command_id == null else result.command_id.to_primitive(),
		"state_sequence": result.state_sequence,
	}


## One logical batch at `time_us` (TRS §4.2, build plan §3.5): phase-1 research completions and
## phase-2 maturity markers in key order, then one planned farming batch (auto-harvest, credits,
## replant/retry, seeds, fertilizer, plantings). A failed plan aborts the timestamp (E5).
func _process_timestamp(time_us: int) -> StateChangeBatch:
	var batch: StateChangeBatch = StateChangeBatch.new()
	batch.time_us = time_us
	for _round: int in MAX_ROUNDS_PER_TIMESTAMP:
		var due: Array[ScheduledEvent] = _scheduler.pop_at(time_us)
		if due.is_empty():
			break
		var progressed: bool = false
		for event: ScheduledEvent in due:
			var outcome: SimulationEvent = _dispatch(event)
			if outcome != null:
				batch.events.append(outcome)
				progressed = true
		if not progressed:
			break
	var proposal: BatchProposal = BatchPlanner.plan(_state, _registry, {"auto_harvest": true})
	if proposal.failure_code != FailureCode.NONE:
		batch.failure_code = proposal.failure_code
		return batch
	if not proposal.is_empty():
		batch.append(BatchApplier.apply(_state, _registry, _scheduler, proposal))
	return batch


func _dispatch(event: ScheduledEvent) -> SimulationEvent:
	match event.type:
		ScheduledEvent.TYPE_CROP_MATURED:
			return FarmSystem.mark_mature(_state, event)
		ScheduledEvent.TYPE_RESEARCH_COMPLETED:
			return ResearchSystem.complete(_state, _registry, event)
	return null
