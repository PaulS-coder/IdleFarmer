class_name BatchPlanner
extends RefCounted
## Pure planner for one logical farming batch (M02 E4/E6/E8, TRS §4.2, FRS §§7.1, 9.2; build plan
## §3.5). It reads GameState and never mutates it; the BatchApplier applies the proposal.
##
## Phases: harvest set (explicit manual harvests plus, when requested, Ready plots whose Auto
## Harvest is active) → all credits and XP with checked math → replant requests (harvested plots
## with runnable loops; stalled runnable loops when the batch has a wallet credit or a command
## touched them) → seeds and fixed fertilizer (SeedBudgetAllocator) → plantings. Smart policies are
## planted with None here; the Smart phase over M and C is S5.
##
## Inputs: {"harvest_plot_ids": Array[int] (manual, pre-validated Ready), "auto_harvest": bool (every
## Ready plot with active Auto Harvest), "auto_harvest_plot_ids": Array[int] (only these, e.g. Ready
## on enable), "touched_plot_ids": Array[int] (configuration commands), "retry_all": bool}.

const ORIGIN_MANUAL: String = EconomicTransaction.ORIGIN_MANUAL
const ORIGIN_AUTOMATIC: String = EconomicTransaction.ORIGIN_AUTOMATIC


static func plan(state: GameState, registry: ContentRegistry, inputs: Dictionary) -> BatchProposal:
	var proposal: BatchProposal = BatchProposal.new()
	var caps: Capabilities = Capabilities.of(state, registry)
	var manual: Array = inputs.get("harvest_plot_ids", [])
	var touched: Array = inputs.get("touched_plot_ids", [])
	var auto_only: Array = inputs.get("auto_harvest_plot_ids", [])

	# Phase 2b: harvest set in ascending plot ID.
	for plot: PlotState in state.plots:
		var cycle: CropCycle = plot.crop_cycle
		if not plot.unlocked or cycle == null or cycle.status != CropCycle.STATUS_READY:
			continue
		if manual.has(plot.plot_id):
			proposal.harvests.append({"plot_id": plot.plot_id, "origin": ORIGIN_MANUAL})
		elif (inputs.get("auto_harvest", false) or auto_only.has(plot.plot_id)) \
				and SettingsResolver.auto_harvest_active(state, caps, plot.plot_id):
			proposal.harvests.append({"plot_id": plot.plot_id, "origin": ORIGIN_AUTOMATIC})

	# Phases 3–4: credits and XP, exactly as the applier's harvest transitions will apply them.
	var player: PlayerState = PlayerState.from_primitive(state.player.to_primitive())
	var harvested: Dictionary[int, bool] = {}
	for harvest: Dictionary in proposal.harvests:
		var reward: Array[int] = EconomySystem.harvest_reward(state.plot(harvest["plot_id"]).crop_cycle)
		var coins: MathResult = IntegerMath.add(player.coins, reward[0])
		var grant: XpGrant = ProgressionSystem.prepare_xp(player, registry, reward[1])
		if not coins.ok or not grant.ok:
			return BatchProposal.failed(FailureCode.NUMERIC_LIMIT)
		player.coins = coins.value
		ProgressionSystem.apply(player, grant)
		harvested[harvest["plot_id"]] = true
	var has_credit: bool = not proposal.harvests.is_empty()

	# Phase 5: replant and retry requests.
	var candidates: Array[Dictionary] = []
	var quotes: Dictionary[int, Array] = {}
	for plot: PlotState in state.plots:
		var id: int = plot.plot_id
		var stalled: bool = plot.crop_cycle == null and plot.unlocked and plot.stall_reason != PlotState.STALL_NONE
		var considered: bool = harvested.has(id) or (stalled and (has_credit or inputs.get("retry_all", false) or touched.has(id)))
		if not considered:
			continue
		var status: String = SettingsResolver.loop_status(state, caps, id)
		if status != SettingsResolver.LOOP_RUNNABLE:
			# A harvested plot whose configured loop cannot run, or a touched stalled plot, reports why.
			if (harvested.has(id) and SettingsResolver.effective(state, id).auto_replant) or stalled:
				proposal.stalls[id] = status
			continue
		var settings: FarmingSettings = SettingsResolver.effective(state, id)
		if FarmSystem.check_eligibility(state, registry, id, settings.crop_id, player.level, harvested.has(id)) != FailureCode.NONE:
			proposal.stalls[id] = PlotState.STALL_INELIGIBLE
			continue
		var fixed: bool = not FarmingSettings.is_smart(settings.fertilizer_policy) and settings.fertilizer_policy != FertilizerDefinition.NONE_ID
		var with_fertilizer: PlantingQuote = FarmSystem.quote_for(state, registry, settings.crop_id,
			settings.fertilizer_policy if fixed else FertilizerDefinition.NONE_ID)
		var without: PlantingQuote = FarmSystem.quote_for(state, registry, settings.crop_id)
		if not with_fertilizer.ok or not without.ok:
			return BatchProposal.failed(FailureCode.NUMERIC_LIMIT)
		quotes[id] = [with_fertilizer, without]
		candidates.append({
			"plot_id": id, "priority": settings.priority, "seed_cost": with_fertilizer.seed_cost,
			"fertilizer_id": with_fertilizer.fertilizer_id, "fertilizer_price": with_fertilizer.fertilizer_cost,
			"fixed": fixed, "fallback": settings.fallback_accepted,
		})

	# Phases 6–7: seeds, fixed fertilizer and replan; one M and one C for the batch.
	if not candidates.is_empty():
		var budget: AutomationState = state.automation
		var allocation: Dictionary = SeedBudgetAllocator.allocate(player.coins, budget.budget_reserve,
			budget.budget_protection_percent, budget.budget_seed_protection, candidates)
		for plot_id: int in allocation["stalls"]:
			proposal.stalls[plot_id] = allocation["stalls"][plot_id]
		for member: Dictionary in allocation["funded"]:
			var pair: Array = quotes[member["plot_id"]]
			var quote: PlantingQuote = pair[1] if member["fertilizer_id"] == FertilizerDefinition.NONE_ID else pair[0]
			proposal.plantings.append({"plot_id": member["plot_id"], "quote": quote, "origin": ORIGIN_AUTOMATIC,
				"fallback_used": member["fallback_used"]})
		proposal.allocation = {"wallet": player.coins}
		for key: String in ["S", "A", "F", "M", "C", "passes", "exclusions"]:
			proposal.allocation[key] = allocation[key]

	# Phase 8 room: identities, insertion sequences and maturity times must all be representable.
	var ids: int = proposal.harvests.size()
	for planting: Dictionary in proposal.plantings:
		var quote: PlantingQuote = planting["quote"]
		ids += 3 if quote.fertilizer_id != FertilizerDefinition.NONE_ID else 2
		if not IntegerMath.add(state.simulation_time_us, quote.growth_us).ok:
			return BatchProposal.failed(FailureCode.NUMERIC_LIMIT)
	if not IntegerMath.add(state.next_entity_id, ids).ok \
			or not IntegerMath.add(state.next_insertion_sequence, proposal.plantings.size()).ok:
		return BatchProposal.failed(FailureCode.NUMERIC_LIMIT)
	return proposal
