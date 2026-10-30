class_name FertilizerCatalogV1
extends RefCounted
## The four v1 fertilizers (FRS §6.2). Price = max(floor, ceil(B × coef / 10,000)), B = unmodified
## base coins. Coefficients and floors are provisional. Growth Booster is deferred (DEC-008).

## [id, display name, tier, coin bonus bp, price coefficient bp, price floor]
const FERTILIZERS: Array[Array] = [
	["none", "None", 0, 0, 0, 0],
	["basic", "Basic", 1, 2500, 1500, 20],
	["premium", "Premium", 2, 5000, 3500, 75],
	["advanced", "Advanced", 3, 10000, 7800, 240],
]
