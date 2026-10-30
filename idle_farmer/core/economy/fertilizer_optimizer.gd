class_name FertilizerOptimizer
extends RefCounted
## Smart Fertilizer group decisions (M02-T13/T14; FRS §§7.2–7.3, DEC-009, Q2; build plan §3.7).
##
## A member is {plot_id, duration_us, options: [[tier, cost, net], ...]} listing the paid tiers with
## their price and incremental net coins per cycle (gross with − gross without − price). None is
## always available and never needs an option row. Only options with cost ≤ funds and net > 0 are
## candidates, so None wins every non-positive comparison.
##
## - Maximum Profit / Budget Protection: the exact rate frontier (RateFrontier) under `funds`
##   (remaining M for MP; min(remaining M, remaining C) for BP, chosen by the caller).
## - Capital Efficiency (Q2): repeatedly take the affordable upgrade step (plot, current → higher
##   tier) with positive Δnet and the highest Δnet/Δcost; ties: higher Δnet/duration, lower Δcost,
##   lower plot ID, lower target tier. Steps without a positive Δcost have no ROI and are skipped.
##
## Results are cached for identical inputs (owner condition on B3). The cache key normalizes
## `funds` down to the most any assignment could spend, which cannot change the answer, so stable
## farms whose wallet keeps growing still hit it. Memoization never changes a result.

const MODE_MP: String = "smart_mp"
const MODE_CE: String = "smart_ce"
const MODE_BP: String = "smart_bp"
const CACHE_CAPACITY: int = 256

static var _cache: Dictionary[String, Dictionary] = {}
static var _cache_order: Array[String] = []
static var cache_hits: int = 0
static var cache_misses: int = 0


## Returns {"tiers": {plot_id: tier}, "spend": int}. `mode` is MODE_MP, MODE_CE or MODE_BP.
static func solve(mode: String, members: Array, funds: int) -> Dictionary:
	var ordered: Array = members.duplicate(true)
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["plot_id"] < b["plot_id"])
	var budget: int = mini(maxi(funds, 0), _max_useful_spend(ordered))
	var key: String = "%s|%d|%s" % [mode, budget, str(ordered)]
	if _cache.has(key):
		cache_hits += 1
		return _cache[key].duplicate(true)
	cache_misses += 1
	var result: Dictionary = _capital_efficiency(ordered, budget) if mode == MODE_CE else _rate_optimum(ordered, budget)
	_cache[key] = result.duplicate(true)
	_cache_order.append(key)
	if _cache_order.size() > CACHE_CAPACITY:
		_cache.erase(_cache_order.pop_front())
	return result


## Smart groups of one logical batch, already in funding order (priority desc, then MP → CE → BP).
## `groups`: [[mode, members], ...]. MP/CE spend from the remaining M; BP from min(remaining M,
## remaining C), and its spend also reduces C (FRS §7.3: C is a ceiling, never reserved money).
## Returns {"tiers": {plot_id: tier}, "spend", "bp_spend"}.
static func solve_groups(groups: Array, smart_funds: int, ceiling: int) -> Dictionary:
	var result: Dictionary = {"tiers": {}, "spend": 0, "bp_spend": 0}
	var remaining_m: int = smart_funds
	var remaining_c: int = ceiling
	for group: Array in groups:
		var mode: String = group[0]
		var funds: int = mini(remaining_m, remaining_c) if mode == MODE_BP else remaining_m
		var solved: Dictionary = solve(mode, group[1], funds)
		result["tiers"].merge(solved["tiers"])
		remaining_m -= solved["spend"]
		result["spend"] += solved["spend"]
		if mode == MODE_BP:
			remaining_c -= solved["spend"]
			result["bp_spend"] += solved["spend"]
	return result


static func clear_cache() -> void:
	_cache.clear()
	_cache_order.clear()
	cache_hits = 0
	cache_misses = 0


static func cache_size() -> int:
	return _cache.size()


## Σ over members of the most expensive positive-net option: no assignment can spend more.
static func _max_useful_spend(members: Array) -> int:
	var total: int = 0
	for member: Dictionary in members:
		var most: int = 0
		for option: Array in member["options"]:
			if option[2] > 0:
				most = maxi(most, option[1])
		total += most
	return total


static func _rate_optimum(members: Array, funds: int) -> Dictionary:
	var plots: Array = []
	for member: Dictionary in members:
		plots.append([member["plot_id"], member["duration_us"], member["options"]])
	var solved: Dictionary = RateFrontier.solve(plots, funds)
	var tiers: Dictionary = {}
	for i: int in members.size():
		tiers[members[i]["plot_id"]] = solved["tiers"][i] if solved.get("ok", false) else 0
	return {"tiers": tiers, "spend": solved["spend"] if solved.get("ok", false) else 0}


static func _capital_efficiency(members: Array, funds: int) -> Dictionary:
	var tiers: Dictionary = {}
	var costs: Dictionary = {}
	var nets: Dictionary = {}
	for member: Dictionary in members:
		tiers[member["plot_id"]] = 0
		costs[member["plot_id"]] = 0
		nets[member["plot_id"]] = 0
	var spent: int = 0
	while true:
		var best: Dictionary = {}
		for member: Dictionary in members:
			var id: int = member["plot_id"]
			for option: Array in member["options"]:
				var delta_cost: int = option[1] - costs[id]
				var delta_net: int = option[2] - nets[id]
				if option[0] <= tiers[id] or option[2] <= 0 or delta_cost <= 0 or delta_net <= 0 or delta_cost > funds - spent:
					continue
				var step: Dictionary = {"plot_id": id, "tier": option[0], "cost": option[1], "net": option[2],
					"delta_cost": delta_cost, "delta_net": delta_net, "duration": member["duration_us"]}
				if best.is_empty() or _ce_better(step, best):
					best = step
		if best.is_empty():
			break
		spent += best["delta_cost"]
		tiers[best["plot_id"]] = best["tier"]
		costs[best["plot_id"]] = best["cost"]
		nets[best["plot_id"]] = best["net"]
	return {"tiers": tiers, "spend": spent}


## True when CE step `a` ranks before `b` (Q2 order).
static func _ce_better(a: Dictionary, b: Dictionary) -> bool:
	var roi: int = compare_products(a["delta_net"], b["delta_cost"], b["delta_net"], a["delta_cost"])
	if roi != 0:
		return roi > 0
	var rate: int = compare_products(a["delta_net"], b["duration"], b["delta_net"], a["duration"])
	if rate != 0:
		return rate > 0
	if a["delta_cost"] != b["delta_cost"]:
		return a["delta_cost"] < b["delta_cost"]
	if a["plot_id"] != b["plot_id"]:
		return a["plot_id"] < b["plot_id"]
	return a["tier"] < b["tier"]


## sign(x1·y1 − x2·y2), exact: checked int64 products, BigInt when either would overflow.
static func compare_products(x1: int, y1: int, x2: int, y2: int) -> int:
	var left: MathResult = IntegerMath.mul(x1, y1)
	var right: MathResult = IntegerMath.mul(x2, y2)
	if left.ok and right.ok:
		return signi(left.value - right.value) if (left.value >= 0) == (right.value >= 0) else (1 if left.value > right.value else -1)
	return BigInt.from_int(x1).mul_int(y1).compare(BigInt.from_int(x2).mul_int(y2))
