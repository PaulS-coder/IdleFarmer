class_name FertilizerPricing
extends RefCounted
## Fertilizer price from the crop's unmodified base coins B (FRS §6.2, DEC-005: prices round up):
## max(price_floor, ceil(B × price_coef_bp / 10,000)). `none` costs 0.


static func price(fertilizer: FertilizerDefinition, base_coins: int) -> MathResult:
	if fertilizer == null or base_coins < 0:
		return MathResult.failure()
	if fertilizer.id == FertilizerDefinition.NONE_ID:
		return MathResult.of(0)
	var scaled: MathResult = IntegerMath.mul_div_ceil(base_coins, fertilizer.price_coef_bp, IntegerMath.BASIS_POINTS)
	if not scaled.ok:
		return scaled
	return MathResult.of(maxi(fertilizer.price_floor, scaled.value))
