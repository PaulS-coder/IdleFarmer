class_name ContentM01V1
extends RefCounted
## Builds manifest `content_m01_v1` from the v1 source tables (build plan P7).
## A failed checked conversion yields 0, which ContentRegistry rejects as a nonpositive duration.

const MANIFEST_ID: String = "content_m01_v1"
const MICROSECONDS_PER_MINUTE: int = 60_000_000


static func build_manifest() -> ContentManifest:
	var manifest: ContentManifest = ContentManifest.new()
	manifest.manifest_id = MANIFEST_ID
	manifest.start_unlocked_crop_ids = CropCatalogV1.START_UNLOCKED

	var curve: LevelCurveDefinition = LevelCurveDefinition.new()
	curve.explicit_thresholds = PackedInt64Array(LevelCurveV1.THRESHOLDS)
	curve.continuation_first_increment = LevelCurveV1.CONTINUATION_FIRST_INCREMENT
	curve.continuation_growth_percent = LevelCurveV1.CONTINUATION_GROWTH_PERCENT
	manifest.level_curve = curve

	for row: Array in CropCatalogV1.RESEARCH:
		var research: ResearchDefinition = ResearchDefinition.new()
		research.crop_id = row[0]
		research.id = research_id_for(row[0])
		research.required_level = row[1]
		research.cost = row[2]
		research.duration_us = IntegerMath.mul(row[3], MICROSECONDS_PER_MINUTE).value
		manifest.research.append(research)

	for row: Array in CropCatalogV1.CROPS:
		var crop: CropDefinition = CropDefinition.new()
		crop.id = row[0]
		crop.display_name = row[1]
		crop.crop_class = row[2]
		crop.required_level = row[3]
		crop.base_growth_us = IntegerMath.mul(row[4], MICROSECONDS_PER_MINUTE).value
		crop.seed_cost = row[5]
		crop.base_coins = row[6]
		crop.base_xp = row[7]
		crop.research_id = "" if CropCatalogV1.START_UNLOCKED.has(crop.id) else research_id_for(crop.id)
		crop.stage_art = placeholder_stage_art(crop.id)
		crop.animation_config = "placeholder:%s" % crop.id
		manifest.crops.append(crop)

	for row: Array in SkillCatalogV1.SKILLS:
		var skill: SkillDefinition = SkillDefinition.new()
		skill.id = row[0]
		skill.branch = row[1]
		skill.min_level = row[2]
		skill.max_ranks = row[3]
		skill.prerequisite_id = row[4]
		manifest.skills.append(skill)
	return manifest


static func build_registry() -> ContentRegistry:
	return ContentRegistry.build(build_manifest())


static func research_id_for(crop_id: String) -> String:
	return "unlock_%s" % crop_id


static func placeholder_stage_art(crop_id: String) -> PackedStringArray:
	var refs: PackedStringArray = PackedStringArray()
	for stage: String in CropCatalogV1.STAGE_NAMES:
		refs.append("placeholder:%s:%s" % [crop_id, stage])
	return refs
