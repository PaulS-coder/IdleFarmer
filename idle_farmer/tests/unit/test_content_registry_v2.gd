extends GutTest
## M02-T01/T02 data: content_m02_v1 transcribes FRS §§3, 5.2–5.5, 6.1–6.2 exactly, keeps every
## content_m01_v1 row unchanged, and coexists with v1 (E1, AV-003).

var v1: ContentRegistry
var v2: ContentRegistry


func before_all() -> void:
	v1 = Fixtures.registry()
	v2 = Fixtures.registry_v2()


func test_v2_validates_with_its_own_id() -> void:
	assert_eq(v2.errors, PackedStringArray())
	assert_eq(v2.manifest_id(), "content_m02_v1")
	assert_true(v2.has_economy_tables())
	assert_false(v1.has_economy_tables(), "v1 has no M02 tables")


func test_v1_rows_are_unchanged_in_v2() -> void:
	assert_eq(v2.crop_ids(), v1.crop_ids())
	for crop_id: String in v1.crop_ids():
		var a: CropDefinition = v1.crop(crop_id)
		var b: CropDefinition = v2.crop(crop_id)
		for field: String in ["required_level", "research_id", "seed_cost", "base_growth_us", "base_coins", "base_xp", "crop_class"]:
			assert_eq(b.get(field), a.get(field), "%s.%s" % [crop_id, field])
	assert_eq(v2.research_ids(), v1.research_ids())
	assert_eq(v2.max_representable_level(), v1.max_representable_level())
	for level: int in [2, 13, 30, 31, 40, 349]:
		assert_eq(v2.threshold_for_level(level), v1.threshold_for_level(level))
	for skill_id: String in v1.skill_ids():
		var a: SkillDefinition = v1.skill(skill_id)
		var b: SkillDefinition = v2.skill(skill_id)
		assert_eq([b.min_level, b.max_ranks, b.prerequisite_id], [a.min_level, a.max_ranks, a.prerequisite_id], skill_id)


func test_skill_effects_match_frs() -> void:
	var expected: Dictionary = {
		"faster_germination": ["growth_reduction", 400], "improved_cultivation": ["growth_reduction", 300],
		"climate_control": ["growth_reduction", 500], "efficient_harvest": ["coin_bonus", 800],
		"soil_productivity": ["coin_bonus", 1200], "premium_produce": ["coin_bonus", 2000],
	}
	for skill_id: String in v2.skill_ids():
		var skill: SkillDefinition = v2.skill(skill_id)
		if expected.has(skill_id):
			assert_eq([skill.effect_kind, skill.effect_bp_per_rank], expected[skill_id], skill_id)
		else:
			assert_eq(skill.effect_kind, "capability", skill_id)
			assert_eq(skill.capability_id, skill_id)
		assert_eq(v1.skill(skill_id).effect_kind, "", "v1 skills have no effect")


func test_equipment_matches_frs() -> void:
	assert_eq(v2.upgrade_family_ids(), PackedStringArray(["irrigation", "improved_soil"]))
	var irrigation: Array[int] = [650, 2100, 12000, 60000, 300000, 1500000]
	var soil: Array[int] = [900, 3000, 20000, 110000, 650000]
	var soil_bp: Array[int] = [1000, 1000, 1500, 1500, 2000]
	assert_eq(v2.upgrade_max_rank("irrigation"), 6)
	assert_eq(v2.upgrade_max_rank("improved_soil"), 5)
	var total: int = 0
	for rank: int in range(1, 7):
		var u: UpgradeDefinition = v2.upgrade("irrigation", rank)
		assert_eq([u.cost, u.effect_kind, u.effect_bp, u.min_level], [irrigation[rank - 1], "growth_reduction", 500, 1])
		total += u.cost
	assert_eq(total, 1_874_750, "Irrigation total")
	total = 0
	for rank: int in range(1, 6):
		var u: UpgradeDefinition = v2.upgrade("improved_soil", rank)
		assert_eq([u.cost, u.effect_kind, u.effect_bp, u.min_level], [soil[rank - 1], "coin_bonus", soil_bp[rank - 1], 1])
		total += u.cost
	assert_eq(total, 783_900, "Improved Soil total")
	assert_null(v2.upgrade("irrigation", 7))
	assert_null(v2.upgrade("seed_efficiency", 1), "deferred family absent (DEC-008)")


func test_fertilizers_match_frs() -> void:
	assert_eq(v2.fertilizer_ids(), PackedStringArray(["none", "basic", "premium", "advanced"]), "exactly four, by tier")
	var expected: Dictionary = {"none": [0, 0, 0, 0], "basic": [1, 2500, 1500, 20], "premium": [2, 5000, 3500, 75],
		"advanced": [3, 10000, 7800, 240]}
	for id: String in expected:
		var f: FertilizerDefinition = v2.fertilizer(id)
		assert_eq([f.tier, f.coin_bonus_bp, f.price_coef_bp, f.price_floor], expected[id], id)
	assert_null(v2.fertilizer("growth_booster"), "deferred (DEC-008)")
	assert_eq(v1.fertilizer_ids(), PackedStringArray(["none"]), "v1 profiles only have none")
	assert_null(v1.fertilizer("basic"))
	assert_not_null(v1.fertilizer("none"))


func test_expansion_bands_match_frs() -> void:
	var expected: Dictionary = {25: [3, 250], 26: [3, 250], 27: [5, 1000], 28: [5, 1000], 29: [8, 4000], 30: [8, 4000], 31: [12, 12000], 32: [12, 12000]}
	var total: int = 0
	for plot_id: int in expected:
		var band: ExpansionBand = v2.expansion_band(plot_id)
		assert_eq([band.required_level, band.cost], expected[plot_id], "plot %d" % plot_id)
		total += band.cost
	assert_eq(total, 34_500)
	assert_null(v2.expansion_band(24))
	assert_null(v2.expansion_band(33))
	assert_null(v1.expansion_band(25), "v1 has no purchase bands")


func test_economy_parameters() -> void:
	var e: EconomyParameters = v2.economy()
	assert_eq([e.growth_cap_bp, e.reset_minimum, e.reset_level_factor], [6000, 250, 50])
	assert_eq([e.budget_reserve_default, e.budget_protection_percent_default, e.budget_seed_protection_default], [0, 25, false])
	assert_eq(v2.growth_cap_bp(), 6000)
	assert_eq(v1.growth_cap_bp(), 6000, "legacy cap for v1")
	assert_null(v1.economy())


func test_getters_return_copies() -> void:
	v2.upgrade("irrigation", 1).cost = 1
	v2.fertilizer("basic").price_floor = 0
	v2.expansion_band(25).cost = 1
	v2.economy().growth_cap_bp = 0
	assert_eq(v2.upgrade("irrigation", 1).cost, 650)
	assert_eq(v2.fertilizer("basic").price_floor, 20)
	assert_eq(v2.expansion_band(25).cost, 250)
	assert_eq(v2.growth_cap_bp(), 6000)


func test_catalog_supports_both_manifests() -> void:
	var catalog: ManifestCatalog = ManifestFixtures.catalog()
	assert_eq(catalog.supported_ids(), PackedStringArray(["content_m01_v1", "content_m02_v1"]))
