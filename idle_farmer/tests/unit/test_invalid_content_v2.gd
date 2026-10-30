extends GutTest
## M02-T01: fail-fast diagnostics for the M02 tables, including DEC-008 deferred content.


func _manifest() -> ContentManifest:
	return ContentM02V1.build_manifest()


func _assert_rejected(manifest: ContentManifest, code: String) -> void:
	var registry: ContentRegistry = ContentRegistry.build(manifest)
	assert_false(registry.is_valid(), code)
	assert_true(Fixtures.has_code(registry.errors, code), "expected %s in %s" % [code, str(registry.errors)])
	assert_eq(registry.upgrade_family_ids().size(), 0, "%s: invalid registry exposes no upgrades" % code)
	assert_null(registry.economy(), "%s: invalid registry exposes no economy" % code)


func _skill(m: ContentManifest, id: String) -> SkillDefinition:
	for s: SkillDefinition in m.skills:
		if s.id == id:
			return s
	return null


func test_incomplete_tables() -> void:
	var m: ContentManifest = _manifest()
	m.fertilizers.clear()
	_assert_rejected(m, "ECONOMY_TABLES_INCOMPLETE")
	var m2: ContentManifest = _manifest()
	m2.economy = null
	_assert_rejected(m2, "ECONOMY_TABLES_INCOMPLETE")


func test_deferred_families_rejected() -> void:
	var m: ContentManifest = _manifest()
	var seed_eff: UpgradeDefinition = m.upgrades[0].duplicate() as UpgradeDefinition
	seed_eff.family_id = "seed_efficiency"
	m.upgrades.append(seed_eff)
	_assert_rejected(m, "DEFERRED_CONTENT")
	var m2: ContentManifest = _manifest()
	var booster: FertilizerDefinition = m2.fertilizers[1].duplicate() as FertilizerDefinition
	booster.id = "growth_booster"
	booster.tier = 9
	m2.fertilizers.append(booster)
	_assert_rejected(m2, "DEFERRED_CONTENT")


func test_upgrade_ranks_must_be_contiguous() -> void:
	var m: ContentManifest = _manifest()
	m.upgrades[2].rank = 9
	_assert_rejected(m, "UPGRADE_RANKS_NOT_CONTIGUOUS")


func test_upgrade_values() -> void:
	var m: ContentManifest = _manifest()
	m.upgrades[0].cost = 0
	_assert_rejected(m, "UPGRADE_VALUE_INVALID")
	var m2: ContentManifest = _manifest()
	m2.upgrades[0].effect_kind = "xp_bonus"
	_assert_rejected(m2, "UPGRADE_EFFECT_INVALID")


func test_fertilizer_rules() -> void:
	var m: ContentManifest = _manifest()
	m.fertilizers.remove_at(0)
	_assert_rejected(m, "FERTILIZER_NONE_MISSING")
	var m2: ContentManifest = _manifest()
	m2.fertilizers[0].coin_bonus_bp = 100
	_assert_rejected(m2, "FERTILIZER_NONE_INVALID")
	var m3: ContentManifest = _manifest()
	m3.fertilizers[2].tier = 1
	_assert_rejected(m3, "FERTILIZER_DUPLICATE")
	var m4: ContentManifest = _manifest()
	m4.fertilizers[1].price_coef_bp = -1
	_assert_rejected(m4, "FERTILIZER_VALUE_INVALID")


func test_expansion_bands() -> void:
	var m: ContentManifest = _manifest()
	m.expansion_bands.remove_at(1)
	_assert_rejected(m, "EXPANSION_BANDS_NOT_CONTIGUOUS")
	var m2: ContentManifest = _manifest()
	m2.expansion_bands[3].last_plot = 31
	_assert_rejected(m2, "EXPANSION_BANDS_INCOMPLETE")
	var m3: ContentManifest = _manifest()
	m3.expansion_bands[0].cost = 0
	_assert_rejected(m3, "EXPANSION_BAND_INVALID")


func test_economy_ranges() -> void:
	var m: ContentManifest = _manifest()
	m.economy.growth_cap_bp = 10_001
	_assert_rejected(m, "ECONOMY_GROWTH_CAP_RANGE")
	var m2: ContentManifest = _manifest()
	m2.economy.budget_protection_percent_default = 101
	_assert_rejected(m2, "ECONOMY_BUDGET_DEFAULT_RANGE")


func test_skill_effect_rules() -> void:
	var m: ContentManifest = _manifest()
	_skill(m, "faster_germination").effect_kind = "teleport"
	_assert_rejected(m, "SKILL_EFFECT_INVALID")
	var m2: ContentManifest = _manifest()
	_skill(m2, "batch_planting").capability_id = ""
	_assert_rejected(m2, "SKILL_CAPABILITY_MISSING")
	var m3: ContentManifest = _manifest()
	_skill(m3, "faster_germination").capability_id = "x"
	_assert_rejected(m3, "SKILL_CAPABILITY_UNEXPECTED")
