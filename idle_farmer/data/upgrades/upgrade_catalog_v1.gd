class_name UpgradeCatalogV1
extends RefCounted
## Required equipment families (FRS §6.1, FR-AUD-006). Provisional costs/effects. Seed Efficiency
## and Research Facilities are deferred (DEC-008) and deliberately absent.

## [family id, display name, effect kind, [[cost, effect bp], ...] for ranks 1..n]
const FAMILIES: Array[Array] = [
	["irrigation", "Irrigation", "growth_reduction",
		[[650, 500], [2100, 500], [12000, 500], [60000, 500], [300000, 500], [1500000, 500]]],
	["improved_soil", "Improved Soil", "coin_bonus",
		[[900, 1000], [3000, 1000], [20000, 1500], [110000, 1500], [650000, 2000]]],
]
