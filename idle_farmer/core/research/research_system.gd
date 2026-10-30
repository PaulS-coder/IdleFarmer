class_name ResearchSystem
extends RefCounted
## Manual research and the one-time boost (M02-T07; FRS §8, DEC-007/G3, TRS §5, AV-004-03; build
## plan §3.8). One run may be active. Its completion is a phase-1 scheduled event keyed
## (completes_us, 1, 0, run counter, insertion seq). A boost charges ceil(C/2) of the paid cost and
## sets the remaining time to ceil(remaining/2), cancelling the old event and inserting a new one, so a
## stale event can never complete the run. Completion only unlocks: it never starts another project,
## assigns a crop or buys a boost. Every check precedes mutation; failures change nothing.


## Terms a player would confirm to start `project_id` now ({} for an unknown project).
static func quote_start(registry: ContentRegistry, project_id: String) -> Dictionary:
	var project: ResearchDefinition = registry.research(project_id)
	if project == null:
		return {}
	return {"project_id": project_id, "cost": project.cost, "duration_us": project.duration_us}


## Failure code for starting `project_id`, before term comparison.
static func check_start(state: GameState, registry: ContentRegistry, project_id: String) -> String:
	var project: ResearchDefinition = registry.research(project_id)
	if project == null:
		return FailureCode.UNKNOWN_RESEARCH
	if state.research.is_active():
		return FailureCode.RESEARCH_ACTIVE
	if state.research.completed.has(project_id):
		return FailureCode.RESEARCH_DONE
	if state.player.level < project.required_level:
		return FailureCode.LEVEL_REQUIRED
	return FailureCode.NONE


static func start(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: StartResearchCommand) -> CommandResult:
	var failure: String = check_start(state, registry, command.project_id())
	var project: ResearchDefinition = registry.research(command.project_id())
	var completes: MathResult = IntegerMath.add(state.simulation_time_us, project.duration_us) if project != null else MathResult.failure()
	var id_room: MathResult = IntegerMath.add(state.next_entity_id, 2)
	var seq_room: MathResult = IntegerMath.add(state.next_insertion_sequence, 1)
	if failure == FailureCode.NONE and command.terms() != quote_start(registry, command.project_id()):
		failure = FailureCode.STALE_TERMS
	if failure == FailureCode.NONE and state.player.coins < project.cost:
		failure = FailureCode.INSUFFICIENT_COINS
	if failure == FailureCode.NONE and (not completes.ok or not id_room.ok or not seq_room.ok):
		failure = FailureCode.NUMERIC_LIMIT
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "research '%s'" % command.project_id(), command.command_id(), state.state_sequence)
	var research: ResearchState = state.research
	research.active_project_id = project.id
	research.active_run_id = state.allocate_entity_id()
	var tx_id: EntityId = state.allocate_entity_id()
	research.active_paid_cost = project.cost
	research.active_started_us = state.simulation_time_us
	research.active_original_duration_us = project.duration_us
	research.active_completes_us = completes.value
	research.active_insertion_seq = state.allocate_insertion_sequence()
	research.boost_used = false
	state.player.coins -= project.cost
	scheduler.push(completion_event(research))
	var result: CommandResult = SkillSystem.succeeded(command)
	result.transactions.append(EconomicTransaction.new(tx_id, state.simulation_time_us, EconomicTransaction.TYPE_RESEARCH_PURCHASE,
		0, null, -project.cost, 0, EconomicTransaction.CATEGORY_RESEARCH, state.content_version, EconomicTransaction.ORIGIN_MANUAL))
	result.events.append(SimulationEvent.new(SimulationEvent.RESEARCH_STARTED, state.simulation_time_us, 0, null,
		{"project_id": project.id, "run_id": research.active_run_id.key(), "cost": project.cost,
			"completes_us": research.active_completes_us}))
	return result


## Terms a player would confirm to boost the active run ({} when nothing is active): the run, the
## fixed charge ceil(C/2) of the paid cost and the half-remaining rule.
static func quote_boost(state: GameState) -> Dictionary:
	if not state.research.is_active():
		return {}
	return {"run_id": state.research.active_run_id.key(), "charge": boost_charge(state.research.active_paid_cost).value,
		"rule": AccelerateResearchCommand.RULE_HALVE_REMAINING}


## Exact boost outcome as of the state's current time (AV-004-03 preview). Labelled with `as_of_us`;
## the accepted-time result is recomputed at acceptance. {} when nothing is active.
static func preview_boost(state: GameState) -> Dictionary:
	if not state.research.is_active():
		return {}
	var remaining: int = state.research.active_completes_us - state.simulation_time_us
	var halved: int = halve_remaining(remaining).value
	return {"as_of_us": state.simulation_time_us, "remaining_us": remaining, "new_remaining_us": halved,
		"saved_us": remaining - halved, "new_completes_us": state.simulation_time_us + halved}


## ceil(C/2) for a paid cost C ≥ 0.
static func boost_charge(paid_cost: int) -> MathResult:
	return IntegerMath.ceil_div(paid_cost, 2)


## ceil(remaining/2) for remaining ≥ 1; equal to `remaining` only when remaining = 1 (no time saved).
static func halve_remaining(remaining_us: int) -> MathResult:
	return IntegerMath.ceil_div(remaining_us, 2)


static func accelerate(state: GameState, scheduler: EventScheduler, command: AccelerateResearchCommand) -> CommandResult:
	var research: ResearchState = state.research
	var failure: String = FailureCode.NONE
	var remaining: int = research.active_completes_us - state.simulation_time_us
	var halved: MathResult = halve_remaining(remaining)
	var charge: MathResult = boost_charge(research.active_paid_cost)
	var id_room: MathResult = IntegerMath.add(state.next_entity_id, 1)
	var seq_room: MathResult = IntegerMath.add(state.next_insertion_sequence, 1)
	if not research.is_active():
		failure = FailureCode.NO_ACTIVE_RESEARCH
	elif research.boost_used:
		failure = FailureCode.BOOST_USED
	elif not halved.ok or halved.value >= remaining:
		failure = FailureCode.NO_TIME_SAVED
	elif command.terms() != quote_boost(state):
		failure = FailureCode.STALE_TERMS  # another run, a different charge, or a re-delivered boost
	elif state.player.coins < charge.value:
		failure = FailureCode.INSUFFICIENT_COINS
	elif not id_room.ok or not seq_room.ok:
		failure = FailureCode.NUMERIC_LIMIT
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "boost run '%s'" % command.run_id(), command.command_id(), state.state_sequence)
	var tx_id: EntityId = state.allocate_entity_id()
	scheduler.cancel(research.active_insertion_seq)
	research.active_completes_us = state.simulation_time_us + halved.value
	research.active_insertion_seq = state.allocate_insertion_sequence()
	research.boost_used = true
	state.player.coins -= charge.value
	scheduler.push(completion_event(research))
	var result: CommandResult = SkillSystem.succeeded(command)
	result.transactions.append(EconomicTransaction.new(tx_id, state.simulation_time_us, EconomicTransaction.TYPE_RESEARCH_BOOST,
		0, null, -charge.value, 0, EconomicTransaction.CATEGORY_RESEARCH, state.content_version, EconomicTransaction.ORIGIN_MANUAL))
	result.events.append(SimulationEvent.new(SimulationEvent.RESEARCH_BOOSTED, state.simulation_time_us, 0, null,
		{"project_id": research.active_project_id, "run_id": research.active_run_id.key(), "charge": charge.value,
			"remaining_before_us": remaining, "remaining_after_us": halved.value, "saved_us": remaining - halved.value,
			"completes_us": research.active_completes_us}))
	return result


## Phase-1 completion. Returns null (and changes nothing) for an event that is not the active run's
## current completion: a cancelled pre-boost event, a duplicate delivery or a finished run.
static func complete(state: GameState, registry: ContentRegistry, event: ScheduledEvent) -> SimulationEvent:
	var research: ResearchState = state.research
	if not research.is_active() or event.target_id == null or not event.target_id.equals(research.active_run_id):
		return null
	if event.insertion_seq != research.active_insertion_seq or event.time_us != research.active_completes_us \
			or state.simulation_time_us != event.time_us:
		return null
	var project_id: String = research.active_project_id
	var run_key: String = research.active_run_id.key()
	research.completed.append(project_id)
	research.completed.sort()
	research.clear_active()
	var project: ResearchDefinition = registry.research(project_id)
	return SimulationEvent.new(SimulationEvent.RESEARCH_COMPLETED, event.time_us, 0, null,
		{"project_id": project_id, "run_id": run_key, "crop_id": project.crop_id if project != null else ""})


## Scheduler entry for the active run; its key is fully determined by the persisted fields, so
## `EventScheduler.rebuild` re-creates it exactly.
static func completion_event(research: ResearchState) -> ScheduledEvent:
	return ScheduledEvent.new(research.active_completes_us, EventPhase.RESEARCH_COMPLETION, EventPhase.DEFAULT_PRIORITY,
		research.active_run_id.counter, research.active_insertion_seq, ScheduledEvent.TYPE_RESEARCH_COMPLETED, 0,
		research.active_run_id)
