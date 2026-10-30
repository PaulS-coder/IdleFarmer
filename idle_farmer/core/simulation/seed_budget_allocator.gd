class_name SeedBudgetAllocator
extends RefCounted
## Seed-first shared-wallet allocation with fixed-fertilizer replan (M02-T11/T12/T15; FRS §7.1,
## FR-AUD-005, AV-005-01–04; build plan §3.6). Pure integer function: it never touches GameState.
##
## Candidates are ordered by priority (desc) then plot ID (asc). Each pass funds seeds in order,
## skipping an unaffordable one (B6), then funds fixed fertilizer in order from A = max(0, W−S−R).
## The first unaffordable fixed request without accepted fallback is excluded for this batch, all
## tentative reservations are discarded and the pass restarts. At most N exclusions, N+1 passes.
## M and the single protection ceiling C are computed once, from the final feasible plan.
##
## Candidate: {plot_id, priority, seed_cost, fertilizer_id, fertilizer_price, fixed, fallback}.
## `fixed` is false for None and Smart policies (Smart is decided later from M and C).


## Returns {funded: Array[Dictionary] (with "fertilizer_id"/"fertilizer_price" resolved and
## "fallback_used"), stalls: {plot_id: reason}, S, A, F, M, C, passes, exclusions}.
static func allocate(wallet: int, reserve: int, protection_percent: int, seed_protection: bool, candidates: Array[Dictionary]) -> Dictionary:
	var ordered: Array[Dictionary] = candidates.duplicate(true)
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["priority"] > b["priority"] or (a["priority"] == b["priority"] and a["plot_id"] < b["plot_id"]))
	var excluded: Dictionary[int, bool] = {}
	var passes: int = 0
	var funded: Array[Dictionary] = []
	var seed_stalled: Array[int] = []
	var seeds: int = 0
	var available: int = 0
	var fixed_total: int = 0
	while true:
		passes += 1
		funded = []
		seed_stalled = []
		seeds = 0
		for candidate: Dictionary in ordered:
			if excluded.has(candidate["plot_id"]):
				continue
			var seed_cost: int = candidate["seed_cost"]
			var limit: int = maxi(0, wallet - reserve) if seed_protection and seed_cost > 0 else wallet
			if seed_cost <= limit - seeds:
				seeds += seed_cost
				funded.append(candidate.duplicate())
			else:
				seed_stalled.append(candidate["plot_id"])
		available = maxi(0, wallet - seeds - reserve)
		fixed_total = 0
		var restart: bool = false
		for member: Dictionary in funded:
			member["fallback_used"] = false
			if not member["fixed"]:
				continue
			var price: int = member["fertilizer_price"]
			if price <= available - fixed_total:
				fixed_total += price
			elif member["fallback"]:
				member["fertilizer_id"] = FertilizerDefinition.NONE_ID
				member["fertilizer_price"] = 0
				member["fallback_used"] = true
			else:
				excluded[member["plot_id"]] = true
				restart = true
				break
		if not restart:
			break
	var stalls: Dictionary[int, String] = {}
	for plot_id: int in seed_stalled:
		stalls[plot_id] = PlotState.STALL_SEED_FUNDS
	for plot_id: int in excluded:
		stalls[plot_id] = PlotState.STALL_FERTILIZER_FUNDS
	var smart_funds: int = available - fixed_total
	var ceiling: MathResult = IntegerMath.mul_div_floor(smart_funds, protection_percent, 100)
	return {
		"funded": funded, "stalls": stalls, "S": seeds, "A": available, "F": fixed_total, "M": smart_funds,
		"C": ceiling.value, "passes": passes, "exclusions": excluded.size(),
	}
