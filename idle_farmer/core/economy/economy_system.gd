class_name EconomySystem
extends RefCounted
## Stateless economic formulas (M01-T09, TRS §4.4, DEC-005). Rewards floor, prices ceil,
## durations ceil to whole microseconds with a 1 μs minimum; all arithmetic is checked.
## M01 supplies identity modifiers; M02 skills/equipment/fertilizer feed the same inputs.

const MOD_GROWTH_REDUCTION_BP: String = "growth_reduction_bp"
const MOD_COIN_BONUS_BP: String = "coin_bonus_bp"

## Provisional combined growth-speed cap (FRS §5.2; not final balance).
const GROWTH_CAP_BP: int = 6_000


## Modifiers that apply to a new planting in `state`. Identity in M01 (no skills/equipment yet).
static func current_modifiers(_state: GameState) -> Dictionary[String, int]:
	return {MOD_GROWTH_REDUCTION_BP: 0, MOD_COIN_BONUS_BP: 0}


## Quotes planting `crop` under `modifiers`. `ok == false` when a value is not representable.
static func quote_planting(crop: CropDefinition, manifest_id: String, modifiers: Dictionary[String, int]) -> PlantingQuote:
	var quote: PlantingQuote = PlantingQuote.new()
	quote.crop_id = crop.id
	quote.manifest_id = manifest_id
	quote.modifiers = modifiers.duplicate()
	var reduction: int = modifiers.get(MOD_GROWTH_REDUCTION_BP, 0)
	var coin_bonus: int = modifiers.get(MOD_COIN_BONUS_BP, 0)
	if reduction < 0 or coin_bonus < 0:
		return quote
	var growth: MathResult = IntegerMath.growth_us(crop.base_growth_us, reduction, GROWTH_CAP_BP)
	var multiplier: MathResult = IntegerMath.add(IntegerMath.BASIS_POINTS, coin_bonus)
	var gross: MathResult = IntegerMath.apply_bp_floor(crop.base_coins, multiplier.value) if multiplier.ok else multiplier
	if not growth.ok or not gross.ok:
		return quote
	quote.seed_cost = crop.seed_cost
	quote.growth_us = growth.value
	quote.gross_coins = gross.value
	quote.xp = crop.base_xp
	quote.ok = true
	return quote


## Snapshotted [coins, xp] a cycle pays on harvest. Never recomputed from current content.
static func harvest_reward(cycle: CropCycle) -> Array[int]:
	return [cycle.gross_coin_reward, cycle.xp_reward]


## Completed-cycle profit = gross − seed − fertilizer, from the immutable snapshot.
static func completed_cycle_profit(cycle: CropCycle) -> MathResult:
	var after_seed: MathResult = IntegerMath.sub(cycle.gross_coin_reward, cycle.seed_cost_paid)
	if not after_seed.ok:
		return after_seed
	return IntegerMath.sub(after_seed.value, cycle.fertilizer_cost_paid)
