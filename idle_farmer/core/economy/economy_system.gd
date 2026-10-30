class_name EconomySystem
extends RefCounted
## Stateless economic formulas (M01-T09, M02-T02; TRS §4.4, DEC-005). Rewards floor, prices ceil,
## durations ceil to whole microseconds with a 1 μs minimum; all arithmetic is checked. Modifiers
## come from ModifierSnapshot (skills, equipment, fertilizer) under the profile's bound manifest.


## Quotes planting `crop` with `fertilizer` under `snapshot`. `ok == false` when a value is not
## representable or the inputs are invalid.
static func quote_planting(crop: CropDefinition, manifest_id: String, snapshot: ModifierSnapshot, fertilizer: FertilizerDefinition) -> PlantingQuote:
	var quote: PlantingQuote = PlantingQuote.new()
	quote.crop_id = crop.id
	quote.manifest_id = manifest_id
	if not snapshot.ok or fertilizer == null or fertilizer.id != snapshot.fertilizer_id:
		return quote
	quote.fertilizer_id = fertilizer.id
	# The snapshot's reduction is already capped; pass the full basis-point range as cap here.
	var growth: MathResult = IntegerMath.growth_us(crop.base_growth_us, snapshot.growth_reduction_bp, IntegerMath.BASIS_POINTS)
	var gross: MathResult = _gross(crop.base_coins, snapshot.total_coin_bonus_bp())
	var gross_plain: MathResult = _gross(crop.base_coins, snapshot.coin_bonus_bp)
	var price: MathResult = FertilizerPricing.price(fertilizer, crop.base_coins)
	if not (growth.ok and gross.ok and gross_plain.ok and price.ok):
		return quote
	quote.seed_cost = crop.seed_cost
	quote.fertilizer_cost = price.value
	quote.growth_us = growth.value
	quote.gross_coins = gross.value
	quote.gross_without_fertilizer = gross_plain.value
	quote.xp = crop.base_xp
	quote.modifiers = snapshot.to_dict()
	quote.cap_waste_bp = snapshot.cap_waste_bp()
	quote.ok = quote.total_cost().ok
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


## floor(base × (10,000 + bonus) / 10,000).
static func _gross(base_coins: int, bonus_bp: int) -> MathResult:
	var multiplier: MathResult = IntegerMath.add(IntegerMath.BASIS_POINTS, bonus_bp)
	if not multiplier.ok:
		return multiplier
	return IntegerMath.apply_bp_floor(base_coins, multiplier.value)
