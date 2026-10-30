class_name SkillCatalogV2
extends RefCounted
## Skill effects for content_m02_v1 (FRS §§5.2–5.4, DEC-004). IDs, levels, ranks and prerequisites
## are unchanged from SkillCatalogV1; this adds the per-rank effect and capability.

## [id, effect kind, basis points per rank, capability id]
const EFFECTS: Array[Array] = [
	["faster_germination", "growth_reduction", 400, ""],
	["improved_cultivation", "growth_reduction", 300, ""],
	["climate_control", "growth_reduction", 500, ""],
	["efficient_harvest", "coin_bonus", 800, ""],
	["soil_productivity", "coin_bonus", 1200, ""],
	["premium_produce", "coin_bonus", 2000, ""],
	["batch_planting", "capability", 0, "batch_planting"],
	["batch_harvesting", "capability", 0, "batch_harvesting"],
	["automatic_harvesting", "capability", 0, "automatic_harvesting"],
	["automatic_replanting", "capability", 0, "automatic_replanting"],
	["smart_fertilizer", "capability", 0, "smart_fertilizer"],
	["farm_presets", "capability", 0, "farm_presets"],
	["enhanced_budget_management", "capability", 0, "enhanced_budget_management"],
	["crop_rotation", "capability", 0, "crop_rotation"],
]
