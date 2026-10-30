class_name ContentM02V1
extends RefCounted
## Builds manifest `content_m02_v1` (M02 build plan E1): every content_m01_v1 row unchanged, plus
## skill effects, equipment, fertilizers, expansion bands and economy parameters. Draft until
## M02-T18 freezes it; after that it is never edited in place (TRS §20.3).

const MANIFEST_ID: String = "content_m02_v1"


static func build_manifest() -> ContentManifest:
	var manifest: ContentManifest = ContentM01V1.build_manifest()
	manifest.manifest_id = MANIFEST_ID

	var effects: Dictionary = {}
	for row: Array in SkillCatalogV2.EFFECTS:
		effects[row[0]] = row
	for skill: SkillDefinition in manifest.skills:
		var row: Array = effects[skill.id]
		skill.effect_kind = row[1]
		skill.effect_bp_per_rank = row[2]
		skill.capability_id = row[3]

	for family: Array in UpgradeCatalogV1.FAMILIES:
		var ranks: Array = family[3]
		for i: int in ranks.size():
			var upgrade: UpgradeDefinition = UpgradeDefinition.new()
			upgrade.family_id = family[0]
			upgrade.display_name = "%s %d" % [family[1], i + 1]
			upgrade.effect_kind = family[2]
			upgrade.rank = i + 1
			upgrade.cost = ranks[i][0]
			upgrade.effect_bp = ranks[i][1]
			upgrade.min_level = 1
			manifest.upgrades.append(upgrade)

	for row: Array in FertilizerCatalogV1.FERTILIZERS:
		var fertilizer: FertilizerDefinition = FertilizerDefinition.new()
		fertilizer.id = row[0]
		fertilizer.display_name = row[1]
		fertilizer.tier = row[2]
		fertilizer.coin_bonus_bp = row[3]
		fertilizer.price_coef_bp = row[4]
		fertilizer.price_floor = row[5]
		manifest.fertilizers.append(fertilizer)

	for row: Array in ExpansionV1.BANDS:
		var band: ExpansionBand = ExpansionBand.new()
		band.first_plot = row[0]
		band.last_plot = row[1]
		band.required_level = row[2]
		band.cost = row[3]
		manifest.expansion_bands.append(band)

	var economy: EconomyParameters = EconomyParameters.new()
	economy.growth_cap_bp = EconomyParametersV1.GROWTH_CAP_BP
	economy.reset_minimum = EconomyParametersV1.RESET_MINIMUM
	economy.reset_level_factor = EconomyParametersV1.RESET_LEVEL_FACTOR
	economy.budget_reserve_default = EconomyParametersV1.BUDGET_RESERVE_DEFAULT
	economy.budget_protection_percent_default = EconomyParametersV1.BUDGET_PROTECTION_PERCENT_DEFAULT
	economy.budget_seed_protection_default = EconomyParametersV1.BUDGET_SEED_PROTECTION_DEFAULT
	manifest.economy = economy
	return manifest


static func build_registry() -> ContentRegistry:
	return ContentRegistry.build(build_manifest())
