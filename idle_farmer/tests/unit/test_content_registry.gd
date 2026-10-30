extends GutTest
## M01-T02 / V05: transcription of FRS §4.2 crops, §8 research and §§5.2–5.4 skills; immutability.

const MINUTE_US: int = 60_000_000

## Independent transcription of FRS §4.2: [id, level, minutes, seed, coins, xp, class]
const FRS_CROPS: Array[Array] = [
	["wheat", 1, 8, 0, 16, 6, "basic"], ["carrots", 2, 15, 0, 36, 12, "basic"],
	["corn", 4, 30, 18, 110, 32, "advanced"], ["tomatoes", 7, 60, 55, 270, 70, "advanced"],
	["pumpkins", 10, 180, 300, 1200, 230, "advanced"], ["sunflowers", 12, 90, 230, 810, 125, "advanced"],
	["strawberries", 12, 45, 185, 445, 105, "advanced"], ["blueberries", 15, 120, 450, 1600, 180, "advanced"],
	["soybeans", 15, 60, 300, 785, 185, "advanced"], ["grapes", 18, 240, 2000, 5900, 480, "advanced"],
	["coffee", 18, 180, 1900, 4400, 750, "advanced"], ["cotton", 22, 300, 4500, 12500, 950, "advanced"],
	["rice", 22, 75, 1150, 2900, 370, "advanced"], ["vanilla", 26, 360, 7200, 24500, 1900, "advanced"],
	["saffron", 26, 120, 6000, 10000, 1100, "advanced"],
]

## FRS §8: [crop id, level, cost, minutes]
const FRS_RESEARCH: Array[Array] = [
	["carrots", 2, 150, 8], ["corn", 4, 800, 20], ["tomatoes", 7, 2800, 45], ["pumpkins", 10, 9000, 120],
	["sunflowers", 12, 10000, 60], ["strawberries", 12, 12000, 45], ["blueberries", 15, 24000, 90],
	["soybeans", 15, 26000, 60], ["grapes", 18, 55000, 120], ["coffee", 18, 55000, 120],
	["cotton", 22, 120000, 180], ["rice", 22, 110000, 150], ["vanilla", 26, 300000, 300],
	["saffron", 26, 250000, 240],
]

var registry: ContentRegistry


func before_all() -> void:
	registry = ContentM01V1.build_registry()


func test_manifest_validates_with_stable_id() -> void:
	assert_eq(registry.errors, PackedStringArray())
	assert_eq(registry.manifest_id(), "content_m01_v1")


func test_all_fifteen_crops_match_frs() -> void:
	var ids: PackedStringArray = registry.crop_ids()
	assert_eq(ids.size(), 15)
	for i: int in FRS_CROPS.size():
		var row: Array = FRS_CROPS[i]
		assert_eq(ids[i], row[0], "catalog order")
		var crop: CropDefinition = registry.crop(row[0])
		assert_not_null(crop, row[0])
		assert_eq(crop.required_level, row[1], "%s level" % row[0])
		assert_eq(crop.base_growth_us, row[2] * MINUTE_US, "%s growth" % row[0])
		assert_eq(crop.seed_cost, row[3], "%s seed" % row[0])
		assert_eq(crop.base_coins, row[4], "%s coins" % row[0])
		assert_eq(crop.base_xp, row[5], "%s xp" % row[0])
		assert_eq(crop.crop_class, row[6], "%s class" % row[0])
		assert_eq(crop.stage_art.size(), 5, "%s has five stages" % row[0])


func test_wheat_and_corn_exact_microseconds() -> void:
	assert_eq(registry.crop("wheat").base_growth_us, 480_000_000)
	assert_eq(registry.crop("corn").base_growth_us, 1_800_000_000)


func test_research_rows_and_gates() -> void:
	assert_eq(registry.research_ids().size(), 14)
	for row: Array in FRS_RESEARCH:
		var research_id: String = "unlock_%s" % row[0]
		var research: ResearchDefinition = registry.research(research_id)
		assert_not_null(research, research_id)
		assert_eq(research.crop_id, row[0])
		assert_eq(research.required_level, row[1], "%s level" % research_id)
		assert_eq(research.cost, row[2], "%s cost" % research_id)
		assert_eq(research.duration_us, row[3] * MINUTE_US, "%s duration" % research_id)
		assert_eq(registry.crop(row[0]).research_id, research_id)


func test_wheat_is_the_only_start_unlock() -> void:
	assert_eq(registry.start_unlocked_crop_ids(), PackedStringArray(["wheat"]))
	assert_eq(registry.crop("wheat").research_id, "")


func test_skills_and_point_capacity() -> void:
	assert_eq(registry.skill_ids().size(), 14)
	assert_eq(registry.total_skill_point_capacity(), 34, "34 ranks/nodes (DVS-004)")
	assert_eq(registry.skill("improved_cultivation").prerequisite_id, "faster_germination")
	assert_eq(registry.skill("automatic_replanting").min_level, 7)
	assert_eq(registry.skill("automatic_replanting").prerequisite_id, "automatic_harvesting")


func test_returned_definitions_are_copies() -> void:
	var copy: CropDefinition = registry.crop("wheat")
	copy.base_coins = 999_999
	copy.stage_art[0] = "tampered"
	assert_eq(registry.crop("wheat").base_coins, 16, "registry unaffected by caller mutation")
	assert_eq(registry.crop("wheat").stage_art[0], "placeholder:wheat:planted")


func test_registry_is_isolated_from_later_manifest_edits() -> void:
	var manifest: ContentManifest = ContentM01V1.build_manifest()
	var built: ContentRegistry = ContentRegistry.build(manifest)
	manifest.crops[0].base_coins = 1
	manifest.level_curve.explicit_thresholds[1] = 1
	assert_eq(built.crop("wheat").base_coins, 16)
	assert_eq(built.threshold_for_level(2), 240)


func test_unknown_lookups_return_null() -> void:
	assert_null(registry.crop("mango"))
	assert_null(registry.research("unlock_wheat"))
	assert_null(registry.skill("prestige"))
	assert_false(registry.has_crop("mango"))


func test_manifest_catalog_registers_and_resolves() -> void:
	var catalog: ManifestCatalog = ManifestCatalog.new()
	assert_eq(catalog.register(registry), "")
	assert_true(catalog.is_supported("content_m01_v1"))
	assert_eq(catalog.resolve("content_m01_v1"), registry)
	assert_null(catalog.resolve("content_m99"), "unsupported manifest resolves to null")
	assert_string_starts_with(catalog.register(ContentM01V1.build_registry()), "MANIFEST_ALREADY_REGISTERED")
	var invalid: ContentRegistry = ContentRegistry.build(null)
	assert_string_starts_with(catalog.register(invalid), "MANIFEST_INVALID")
	assert_eq(catalog.supported_ids(), PackedStringArray(["content_m01_v1"]))
