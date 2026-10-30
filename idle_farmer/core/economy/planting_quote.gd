class_name PlantingQuote
extends RefCounted
## Exact economic terms of planting one crop with one fertilizer (TRS §4.4, §20.4; M02 build plan
## §3.2). The same calculation backs UI previews and execution, so a confirmed quote is compared
## term-by-term at acceptance (STALE_TERMS on any difference).

var ok: bool = false
var crop_id: String = ""
var manifest_id: String = ""
var fertilizer_id: String = FertilizerDefinition.NONE_ID
var seed_cost: int = 0
var fertilizer_cost: int = 0
var growth_us: int = 0
var gross_coins: int = 0
var xp: int = 0
## Gross without the fertilizer bonus (same skills/equipment); basis of incremental gain.
var gross_without_fertilizer: int = 0
## Stored on the cycle: {growth_reduction_bp, coin_bonus_bp, fertilizer_bonus_bp}.
var modifiers: Dictionary[String, int] = {}
## Growth reduction lost to the cap (display only).
var cap_waste_bp: int = 0
## Plan terms for a plot-bound manual quote (Q1, FRS §7.1): set by FarmSystem.quote_for with a plot.
var fallback_accepted: bool = false
## Digest of the plot's effective plan when this planting would arm its loop; "" otherwise.
var plan_digest: String = ""
## Confirmed minimum ending balance for a manual planting that ends below the reserve; −1 otherwise.
var min_ending_balance: int = -1


func total_cost() -> MathResult:
	return IntegerMath.add(seed_cost, fertilizer_cost)


## gross − seed − fertilizer (FRS §6.3).
func completed_cycle_profit() -> MathResult:
	var cost: MathResult = total_cost()
	return IntegerMath.sub(gross_coins, cost.value) if cost.ok else cost


## Fertilizer's incremental net coins per cycle: gross(with) − gross(without) − price (FRS §7.2).
func incremental_fertilizer_net() -> int:
	return gross_coins - gross_without_fertilizer - fertilizer_cost


## True when every confirmed term equals this quote. A command without a plan digest is a one-off
## planting (Q1) and carries no fallback; one with a digest must name exactly the current plan.
func matches(command: PlantCropCommand) -> bool:
	var plan_ok: bool = (command.plan_digest().is_empty() and not command.fallback_accepted()) \
		or (command.plan_digest() == plan_digest and command.fallback_accepted() == fallback_accepted)
	return ok and plan_ok and command.crop_id() == crop_id and command.manifest_id() == manifest_id \
		and command.fertilizer_id() == fertilizer_id and command.seed_cost() == seed_cost \
		and command.fertilizer_cost() == fertilizer_cost and command.growth_us() == growth_us \
		and command.gross_coins() == gross_coins and command.xp() == xp
