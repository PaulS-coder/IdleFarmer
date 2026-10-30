class_name SkillCatalogV1
extends RefCounted
## Skill ranks/nodes from FRS §§5.2–5.4 with DEC-004 prerequisites. Data only in M01 (build plan I3).

## [id, branch, minimum level, max ranks, prerequisite id]
const SKILLS: Array[Array] = [
	["faster_germination", "growth", 2, 5, ""],
	["improved_cultivation", "growth", 10, 5, "faster_germination"],
	["climate_control", "growth", 18, 3, "improved_cultivation"],
	["efficient_harvest", "profit", 2, 5, ""],
	["soil_productivity", "profit", 10, 5, "efficient_harvest"],
	["premium_produce", "profit", 18, 3, "soil_productivity"],
	["batch_planting", "automation", 3, 1, ""],
	["batch_harvesting", "automation", 4, 1, "batch_planting"],
	["automatic_harvesting", "automation", 6, 1, "batch_harvesting"],
	["automatic_replanting", "automation", 7, 1, "automatic_harvesting"],
	["smart_fertilizer", "automation", 9, 1, "automatic_replanting"],
	["farm_presets", "automation", 12, 1, "smart_fertilizer"],
	["enhanced_budget_management", "automation", 15, 1, "farm_presets"],
	["crop_rotation", "automation", 20, 1, "enhanced_budget_management"],
]
