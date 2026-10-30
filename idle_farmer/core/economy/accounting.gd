class_name Accounting
extends RefCounted
## Accounting views over committed outcomes (TRS §10, M02-T16, E13). Cash flow sums transaction
## coin deltas by category at their payment/collection time; operating profit attaches each
## completed cycle's own seed and fertilizer costs at its harvest. The two are kept separate: a
## cycle planted in one period and harvested in the next moves cash in both but has one profit.


## {category: Σ coin_delta, "xp": Σ xp_delta} over `transactions`; every category is present.
static func cash_flow(transactions: Array[EconomicTransaction]) -> Dictionary:
	var totals: Dictionary = {"xp": 0}
	for type: String in EconomicTransaction.TYPE_RULES:
		totals[EconomicTransaction.TYPE_RULES[type][0]] = 0
	for tx: EconomicTransaction in transactions:
		totals[tx.category()] += tx.coin_delta()
		totals["xp"] += tx.xp_delta()
	return totals


## {"harvests", "gross", "seed_costs", "fertilizer_costs", "operating_profit", "manual", "automatic"}
## over committed harvest records.
static func operating(harvests: Array[CommittedHarvest]) -> Dictionary:
	var totals: Dictionary = {"harvests": 0, "gross": 0, "seed_costs": 0, "fertilizer_costs": 0, "operating_profit": 0,
		"manual": 0, "automatic": 0}
	for harvest: CommittedHarvest in harvests:
		totals["harvests"] += harvest.quantity()
		totals["gross"] += harvest.gross()
		totals["seed_costs"] += harvest.seed_cost()
		totals["fertilizer_costs"] += harvest.fertilizer_cost()
		totals["operating_profit"] += harvest.operating_profit()
		totals[harvest.origin()] += 1
	return totals
