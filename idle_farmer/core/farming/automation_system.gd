class_name AutomationSystem
extends RefCounted
## Batch manual actions, plan authorization and configuration (M02-T08–T10; FRS §§7.1, 9.2,
## DEC-025, Q1/Q3, E6/E8/E10/E11; build plan §§3.4–3.5).
##
## Every command plans first and mutates only after the whole outcome is known:
## - BatchPlant / ApplyAndStart check members in ascending plot ID against a running wallet and
##   running ID counters; ineligible members are skipped with per-plot codes and the eligible
##   subset is applied as one outcome. No eligible member → the command fails and changes nothing.
## - BatchHarvest and the configuration commands plan their farming batch with BatchPlanner on a
##   scratch copy that already carries the new settings; the real state changes only on success.
## Configuration never arms a loop. A change to a plot's effective plan, or turning its effective
## Auto Replant off, disarms it; re-arming needs ApplyAndStart or a matching Plant.

const OUTCOME_APPLIED: String = "applied"
const OUTCOME_SKIPPED: String = "skipped"


## Disarms every loop (skill reset, E11). Empty stalled plots now report `unarmed`. Returns the
## plot IDs that were armed.
static func disarm_all(state: GameState) -> Array[int]:
	var disarmed: Array[int] = []
	for i: int in state.automation.plots.size():
		var auth: LoopAuthorization = state.automation.plots[i].authorization
		if auth.armed:
			disarmed.append(i + 1)
		auth.disarm()
		var plot: PlotState = state.plots[i]
		if plot.crop_cycle == null and plot.stall_reason != PlotState.STALL_NONE:
			plot.stall_reason = PlotState.STALL_UNARMED
	return disarmed


# --- BatchPlant -------------------------------------------------------------------------------

## Member terms for planting `specs` ([{plot_id, crop_id, fertilizer_id}]) together now, with each
## member's minimum ending balance computed against the running wallet in ascending plot order.
static func quote_batch_plant(state: GameState, registry: ContentRegistry, specs: Array[Dictionary]) -> Array[Dictionary]:
	var ordered: Array[Dictionary] = specs.duplicate(true)
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["plot_id"] < b["plot_id"])
	var coins: int = state.player.coins
	var members: Array[Dictionary] = []
	for spec: Dictionary in ordered:
		var quote: PlantingQuote = FarmSystem.quote_for(state, registry, spec["crop_id"], spec["fertilizer_id"], spec["plot_id"])
		var total: int = quote.seed_cost + quote.fertilizer_cost
		quote.min_ending_balance = coins - total if coins >= total and coins - total < state.automation.budget_reserve else -1
		members.append(RawIntent.plant("", spec["plot_id"], quote).terms)
		coins -= total if coins >= total else 0
	return members


static func batch_plant(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: BatchPlantCommand) -> CommandResult:
	if not Capabilities.of(state, registry).has(Capabilities.BATCH_PLANTING):
		return CommandResult.failed(FailureCode.SKILL_NOT_UNLOCKED, "Batch Planting not owned", command.command_id(), state.state_sequence)
	var coins: int = state.player.coins
	var ids: int = state.next_entity_id
	var seqs: int = state.next_insertion_sequence
	var accepted: Array[Array] = []
	var outcomes: Array[Dictionary] = []
	for member: PlantCropCommand in command.members():
		var quote: PlantingQuote = FarmSystem.quote_for(state, registry, member.crop_id(), member.fertilizer_id(), member.plot_id())
		var code: String = FarmSystem.check_plant_target(state, registry, member.plot_id(), member.crop_id(), member.fertilizer_id())
		var total: int = quote.seed_cost + quote.fertilizer_cost
		var id_need: int = 3 if quote.fertilizer_id != FertilizerDefinition.NONE_ID else 2
		if code == FailureCode.NONE and not quote.ok:
			code = FailureCode.NUMERIC_LIMIT
		elif code == FailureCode.NONE and not quote.matches(member):
			code = FailureCode.STALE_TERMS
		elif code == FailureCode.NONE and coins < total:
			code = FailureCode.INSUFFICIENT_COINS
		elif code == FailureCode.NONE and not FarmSystem.ending_balance_authorized(coins - total, state.automation.budget_reserve,
				member.min_ending_balance()):
			code = FailureCode.STALE_TERMS
		elif code == FailureCode.NONE and not (IntegerMath.add(ids, id_need).ok and IntegerMath.add(seqs, 1).ok
				and IntegerMath.add(state.simulation_time_us, quote.growth_us).ok):
			code = FailureCode.NUMERIC_LIMIT
		outcomes.append(_outcome(member.plot_id(), code))
		if code == FailureCode.NONE:
			coins -= total
			ids += id_need
			seqs += 1
			accepted.append([member, quote])
	if accepted.is_empty():
		return _all_skipped(command, outcomes, state)
	var result: CommandResult = SkillSystem.succeeded(command)
	result.member_outcomes = outcomes
	for pair: Array in accepted:
		var member: PlantCropCommand = pair[0]
		var applied: StateChangeBatch = FarmSystem.apply_planting(state, scheduler, member.plot_id(), pair[1],
			EconomicTransaction.ORIGIN_MANUAL, false)
		if not member.plan_digest().is_empty():
			state.automation.plot(member.plot_id()).authorization.arm(member.plan_digest(), state.state_sequence)
			applied.events.append(SimulationEvent.new(SimulationEvent.LOOP_ARMED, state.simulation_time_us, member.plot_id(), null,
				{"plan_digest": member.plan_digest()}))
		_merge(result, applied, member.plot_id())
	return result


# --- BatchHarvest -----------------------------------------------------------------------------

static func batch_harvest(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: BatchHarvestCommand) -> CommandResult:
	if not Capabilities.of(state, registry).has(Capabilities.BATCH_HARVESTING):
		return CommandResult.failed(FailureCode.SKILL_NOT_UNLOCKED, "Batch Harvesting not owned", command.command_id(), state.state_sequence)
	var outcomes: Array[Dictionary] = []
	var selected: Array[int] = []
	for member: HarvestCropCommand in command.members():
		var code: String = FarmSystem.check_harvest(state, member.plot_id(), member.cycle_id())
		outcomes.append(_outcome(member.plot_id(), code))
		if code == FailureCode.NONE:
			selected.append(member.plot_id())
	if selected.is_empty():
		return _all_skipped(command, outcomes, state)
	var proposal: BatchProposal = BatchPlanner.plan(state, registry, {"harvest_plot_ids": selected})
	if proposal.failure_code != FailureCode.NONE:
		return CommandResult.failed(proposal.failure_code, "batch values not representable", command.command_id(), state.state_sequence)
	var result: CommandResult = SkillSystem.succeeded(command)
	result.member_outcomes = outcomes
	_merge(result, BatchApplier.apply(state, registry, scheduler, proposal), -1)
	result.affected_plot_ids = selected
	return result


# --- ApplyAndStart ----------------------------------------------------------------------------

## Member terms for applying-and-starting `specs` ([{plot_id, crop_id, fertilizer_policy,
## fallback_accepted}]) now. Empty plots carry their first planting's exact costs; occupied plots
## carry zero costs (future settings only). Smart policies plant their first cycle with None in S4.
static func quote_apply_and_start(state: GameState, registry: ContentRegistry, specs: Array[Dictionary]) -> Array[Dictionary]:
	var ordered: Array[Dictionary] = specs.duplicate(true)
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["plot_id"] < b["plot_id"])
	var coins: int = state.player.coins
	var members: Array[Dictionary] = []
	for spec: Dictionary in ordered:
		var member: Dictionary = _apply_member_terms(state, registry, spec, coins)
		coins -= member["seed_cost"] + member["fertilizer_cost"] if coins >= member["seed_cost"] + member["fertilizer_cost"] else 0
		member.erase("quote")
		members.append(member)
	return members


static func apply_and_start(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: ApplyAndStartCommand) -> CommandResult:
	var caps: Capabilities = Capabilities.of(state, registry)
	var members: Array[Dictionary] = command.members()
	if members.size() > 1 and not caps.has(Capabilities.BATCH_PLANTING):
		return CommandResult.failed(FailureCode.SKILL_NOT_UNLOCKED, "Batch Planting not owned", command.command_id(), state.state_sequence)
	var coins: int = state.player.coins
	var ids: int = state.next_entity_id
	var seqs: int = state.next_insertion_sequence
	var accepted: Array[Array] = []
	var outcomes: Array[Dictionary] = []
	for member: Dictionary in members:
		var code: String = _check_apply_member(state, registry, caps, member)
		var expected: Dictionary = _apply_member_terms(state, registry, member, coins) if code == FailureCode.NONE else {}
		var quote: PlantingQuote = expected.get("quote")
		var total: int = member["seed_cost"] + member["fertilizer_cost"]
		var plants: bool = code == FailureCode.NONE and state.plot(member["plot_id"]).crop_cycle == null
		var id_need: int = (3 if quote.fertilizer_id != FertilizerDefinition.NONE_ID else 2) if plants else 0
		if code == FailureCode.NONE and not _same_terms(member, expected):
			code = FailureCode.STALE_TERMS
		elif plants and coins < total:
			code = FailureCode.INSUFFICIENT_COINS
		elif plants and not FarmSystem.ending_balance_authorized(coins - total, state.automation.budget_reserve, member["min_ending_balance"]):
			code = FailureCode.STALE_TERMS
		elif plants and not (IntegerMath.add(ids, id_need).ok and IntegerMath.add(seqs, 1).ok
				and IntegerMath.add(state.simulation_time_us, quote.growth_us).ok):
			code = FailureCode.NUMERIC_LIMIT
		outcomes.append(_outcome(member["plot_id"], code))
		if code == FailureCode.NONE:
			if plants:
				coins -= total
				ids += id_need
				seqs += 1
			accepted.append([member, quote if plants else null])
	if accepted.is_empty():
		return _all_skipped(command, outcomes, state)
	var result: CommandResult = SkillSystem.succeeded(command)
	result.member_outcomes = outcomes
	for pair: Array in accepted:
		var member: Dictionary = pair[0]
		var plot_id: int = member["plot_id"]
		var record: PlotAutomation = state.automation.plot(plot_id)
		record.settings.set_value(FarmingSettings.CROP_ID, member["crop_id"])
		record.settings.set_value(FarmingSettings.FERTILIZER_POLICY, member["fertilizer_policy"])
		record.settings.set_value(FarmingSettings.FALLBACK_ACCEPTED, member["fallback_accepted"])
		record.settings.set_value(FarmingSettings.AUTO_REPLANT, true)
		record.authorization.arm(member["plan_digest"], state.state_sequence)
		var applied: StateChangeBatch = StateChangeBatch.new()
		applied.events.append(SimulationEvent.new(SimulationEvent.LOOP_ARMED, state.simulation_time_us, plot_id, null,
			{"plan_digest": member["plan_digest"], "crop_id": member["crop_id"], "fertilizer_policy": member["fertilizer_policy"]}))
		if pair[1] != null:
			applied.append(FarmSystem.apply_planting(state, scheduler, plot_id, pair[1], EconomicTransaction.ORIGIN_MANUAL, false))
		_merge(result, applied, plot_id)
	return result


static func _check_apply_member(state: GameState, registry: ContentRegistry, caps: Capabilities, member: Dictionary) -> String:
	var plot: PlotState = state.plot(member["plot_id"])
	var policy: String = member["fertilizer_policy"]
	if plot == null:
		return FailureCode.UNKNOWN_PLOT
	if registry.crop(member["crop_id"]) == null:
		return FailureCode.UNKNOWN_CROP
	if not FarmingSettings.is_smart(policy) and registry.fertilizer(policy) == null:
		return FailureCode.UNKNOWN_FERTILIZER
	var eligibility: String = FarmSystem.check_eligibility(state, registry, member["plot_id"], member["crop_id"], state.player.level, true)
	if eligibility != FailureCode.NONE:
		return eligibility
	if not caps.has(Capabilities.AUTOMATIC_REPLANTING) or (FarmingSettings.is_smart(policy) and not caps.has(Capabilities.SMART_FERTILIZER)):
		return FailureCode.SKILL_NOT_UNLOCKED
	return FailureCode.NONE


## Exact member terms (plus the first-planting "quote", null for occupied plots) at running `coins`.
static func _apply_member_terms(state: GameState, registry: ContentRegistry, spec: Dictionary, coins: int) -> Dictionary:
	var plan: FarmingSettings = FarmingSettings.new()
	plan.set_value(FarmingSettings.CROP_ID, spec["crop_id"])
	plan.set_value(FarmingSettings.FERTILIZER_POLICY, spec["fertilizer_policy"])
	plan.set_value(FarmingSettings.FALLBACK_ACCEPTED, spec["fallback_accepted"])
	var terms: Dictionary = {"plot_id": spec["plot_id"], "crop_id": spec["crop_id"], "fertilizer_policy": spec["fertilizer_policy"],
		"fallback_accepted": spec["fallback_accepted"], "plan_digest": SettingsResolver.plan_digest(plan), "seed_cost": 0,
		"fertilizer_cost": 0, "min_ending_balance": -1, "quote": null}
	var plot: PlotState = state.plot(spec["plot_id"])
	if plot == null or plot.crop_cycle != null:
		return terms
	var policy: String = spec["fertilizer_policy"]
	var first: String = FertilizerDefinition.NONE_ID if FarmingSettings.is_smart(policy) else policy
	var quote: PlantingQuote = FarmSystem.quote_for(state, registry, spec["crop_id"], first)
	var total: int = quote.seed_cost + quote.fertilizer_cost
	terms["seed_cost"] = quote.seed_cost
	terms["fertilizer_cost"] = quote.fertilizer_cost
	terms["min_ending_balance"] = coins - total if coins >= total and coins - total < state.automation.budget_reserve else -1
	terms["quote"] = quote
	return terms


## Confirmed member terms equal the current ones; the minimum ending balance is checked separately
## (unrelated income may leave more, never less).
static func _same_terms(member: Dictionary, expected: Dictionary) -> bool:
	for key: String in ApplyAndStartCommand.MEMBER_SCHEMA:
		if key != "min_ending_balance" and member[key] != expected[key]:
			return false
	return expected["quote"] == null or (expected["quote"] as PlantingQuote).ok


# --- Configuration ----------------------------------------------------------------------------

static func configure(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: ConfigureAutomationCommand) -> CommandResult:
	var field: String = command.field()
	var value: Variant = command.value()
	var caps: Capabilities = Capabilities.of(state, registry)
	var failure: String = FailureCode.NONE
	if field == FarmingSettings.PRIORITY:
		failure = FailureCode.FEATURE_UNAVAILABLE  # custom priorities are fixture-only until M05 (Q3)
	elif command.plot_id() != 0 and state.plot(command.plot_id()) == null:
		failure = FailureCode.UNKNOWN_PLOT
	elif command.is_set() and field == FarmingSettings.CROP_ID and not (value as String).is_empty() and registry.crop(value) == null:
		failure = FailureCode.UNKNOWN_CROP
	elif command.is_set() and field == FarmingSettings.FERTILIZER_POLICY and not FarmingSettings.is_smart(value) \
			and registry.fertilizer(value) == null:
		failure = FailureCode.UNKNOWN_FERTILIZER
	elif command.plot_id() == 0 and not command.is_set():
		failure = FailureCode.INVALID_CONFIGURATION  # farm defaults are never unset
	elif command.is_set() and _needs_capability(field, value) != "" and not caps.has(_needs_capability(field, value)):
		failure = FailureCode.SKILL_NOT_UNLOCKED
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "configure '%s' on plot %d" % [field, command.plot_id()], command.command_id(),
			state.state_sequence)
	var scratch: GameState = state.clone()
	var change: Dictionary = _apply_setting(scratch, caps, command)
	var proposal: BatchProposal = BatchPlanner.plan(scratch, registry, {
		"auto_harvest_plot_ids": change["ready_on_enable"], "touched_plot_ids": change["touched"]})
	if proposal.failure_code != FailureCode.NONE:
		return CommandResult.failed(proposal.failure_code, "batch values not representable", command.command_id(), state.state_sequence)
	_apply_setting(state, caps, command)
	var result: CommandResult = SkillSystem.succeeded(command)
	result.affected_plot_ids = change["touched"]
	result.events.append(SimulationEvent.new(SimulationEvent.SETTINGS_CHANGED, state.simulation_time_us, command.plot_id(), null,
		{"field": field, "set": command.is_set(), "value": value}))
	if not change["disarmed"].is_empty():
		result.events.append(SimulationEvent.new(SimulationEvent.LOOPS_DISARMED, state.simulation_time_us, 0, null,
			{"plot_ids": change["disarmed"]}))
	_merge(result, BatchApplier.apply(state, registry, scheduler, proposal), -1)
	return result


## Capability required to enable `field` = `value` ("" when none).
static func _needs_capability(field: String, value: Variant) -> String:
	if field == FarmingSettings.AUTO_HARVEST and value == true:
		return Capabilities.AUTOMATIC_HARVESTING
	if field == FarmingSettings.AUTO_REPLANT and value == true:
		return Capabilities.AUTOMATIC_REPLANTING
	if field == FarmingSettings.FERTILIZER_POLICY and FarmingSettings.is_smart(value):
		return Capabilities.SMART_FERTILIZER
	return ""


## Writes the setting into `state` and disarms loops whose effective plan changed or whose effective
## Auto Replant turned off. Returns {touched, disarmed, ready_on_enable} plot ID lists.
static func _apply_setting(state: GameState, caps: Capabilities, command: ConfigureAutomationCommand) -> Dictionary:
	var before: Array[FarmingSettings] = []
	for plot: PlotState in state.plots:
		before.append(SettingsResolver.effective(state, plot.plot_id))
	var target: FarmingSettings = state.automation.defaults if command.plot_id() == 0 else state.automation.plot(command.plot_id()).settings
	if command.is_set():
		target.set_value(command.field(), command.value())
	else:
		target.clear(command.field())
	var touched: Array[int] = []
	var disarmed: Array[int] = []
	var ready_on_enable: Array[int] = []
	for plot: PlotState in state.plots:
		var old: FarmingSettings = before[plot.plot_id - 1]
		var now: FarmingSettings = SettingsResolver.effective(state, plot.plot_id)
		if old.to_primitive() == now.to_primitive():
			continue
		touched.append(plot.plot_id)
		var auth: LoopAuthorization = state.automation.plot(plot.plot_id).authorization
		if auth.armed and (SettingsResolver.plan_digest(old) != SettingsResolver.plan_digest(now) or not now.auto_replant):
			auth.disarm()
			disarmed.append(plot.plot_id)
		if not old.auto_harvest and now.auto_harvest and caps.has(Capabilities.AUTOMATIC_HARVESTING) \
				and plot.crop_cycle != null and plot.crop_cycle.status == CropCycle.STATUS_READY:
			ready_on_enable.append(plot.plot_id)
	return {"touched": touched, "disarmed": disarmed, "ready_on_enable": ready_on_enable}


static func configure_budget(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, command: ConfigureBudgetCommand) -> CommandResult:
	var failure: String = FailureCode.NONE
	if command.reserve() < 0 or command.protection_percent() < 0 or command.protection_percent() > 100:
		failure = FailureCode.INVALID_CONFIGURATION
	elif not Capabilities.of(state, registry).has(Capabilities.SMART_FERTILIZER):
		failure = FailureCode.SKILL_NOT_UNLOCKED
	if failure != FailureCode.NONE:
		return CommandResult.failed(failure, "budget R=%d p=%d" % [command.reserve(), command.protection_percent()],
			command.command_id(), state.state_sequence)
	var scratch: GameState = state.clone()
	scratch.automation.budget_reserve = command.reserve()
	scratch.automation.budget_protection_percent = command.protection_percent()
	var proposal: BatchProposal = BatchPlanner.plan(scratch, registry, {"retry_all": true})
	if proposal.failure_code != FailureCode.NONE:
		return CommandResult.failed(proposal.failure_code, "batch values not representable", command.command_id(), state.state_sequence)
	state.automation.budget_reserve = command.reserve()
	state.automation.budget_protection_percent = command.protection_percent()
	var result: CommandResult = SkillSystem.succeeded(command)
	result.events.append(SimulationEvent.new(SimulationEvent.SETTINGS_CHANGED, state.simulation_time_us, 0, null,
		{"reserve": command.reserve(), "protection_percent": command.protection_percent()}))
	_merge(result, BatchApplier.apply(state, registry, scheduler, proposal), -1)
	return result


# --- helpers ----------------------------------------------------------------------------------

static func _outcome(plot_id: int, code: String) -> Dictionary:
	return {"plot_id": plot_id, "outcome": OUTCOME_APPLIED if code == FailureCode.NONE else OUTCOME_SKIPPED, "failure_code": code}


## A command with no eligible member fails with its first member's code and changes nothing.
static func _all_skipped(command: GameCommand, outcomes: Array[Dictionary], state: GameState) -> CommandResult:
	var result: CommandResult = CommandResult.failed(outcomes[0]["failure_code"], "no eligible member", command.command_id(),
		state.state_sequence)
	result.member_outcomes = outcomes
	return result


static func _merge(result: CommandResult, batch: StateChangeBatch, plot_id: int) -> void:
	result.events.append_array(batch.events)
	result.transactions.append_array(batch.transactions)
	if plot_id > 0 and not result.affected_plot_ids.has(plot_id):
		result.affected_plot_ids.append(plot_id)
