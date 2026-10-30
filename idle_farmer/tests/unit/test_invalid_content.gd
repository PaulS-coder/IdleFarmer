extends GutTest
## M01-T02 / V05: fail-fast diagnostics for invalid content. Each case corrupts one aspect of an
## otherwise valid manifest and expects a specific error code and an unusable registry.


func _manifest() -> ContentManifest:
	return ContentM01V1.build_manifest()


func _crop(manifest: ContentManifest, crop_id: String) -> CropDefinition:
	for crop: CropDefinition in manifest.crops:
		if crop.id == crop_id:
			return crop
	return null


func _assert_rejected(manifest: ContentManifest, code: String) -> void:
	var registry: ContentRegistry = ContentRegistry.build(manifest)
	assert_false(registry.is_valid(), "%s: registry must be invalid" % code)
	var found: bool = false
	for error: String in registry.errors:
		if error.begins_with(code + ":"):
			found = true
	assert_true(found, "expected %s in %s" % [code, str(registry.errors)])
	assert_null(registry.crop("wheat"), "%s: invalid registry exposes no definitions" % code)
	assert_eq(registry.level_for_xp(0), -1, "%s: invalid registry exposes no curve" % code)


func test_null_manifest() -> void:
	var registry: ContentRegistry = ContentRegistry.build(null)
	assert_false(registry.is_valid())
	assert_string_starts_with(registry.errors[0], "MANIFEST_MISSING")


func test_empty_manifest_id() -> void:
	var m: ContentManifest = _manifest()
	m.manifest_id = ""
	_assert_rejected(m, "MANIFEST_ID_EMPTY")


func test_duplicate_crop_id() -> void:
	var m: ContentManifest = _manifest()
	var dup: CropDefinition = _crop(m, "corn").duplicate() as CropDefinition
	m.crops.append(dup)
	_assert_rejected(m, "CROP_DUPLICATE_ID")


func test_invalid_crop_id_format() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").id = "Corn Field"
	_assert_rejected(m, "CROP_ID_INVALID")


func test_nonpositive_duration() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").base_growth_us = 0
	_assert_rejected(m, "CROP_NONPOSITIVE_DURATION")


func test_negative_value() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").base_coins = -1
	_assert_rejected(m, "CROP_NEGATIVE_VALUE")


func test_basic_crop_with_seed_cost() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "carrots").seed_cost = 5
	_assert_rejected(m, "CROP_BASIC_SEED_NOT_FREE")


func test_unknown_crop_class() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").crop_class = "legendary"
	_assert_rejected(m, "CROP_CLASS_INVALID")


func test_stage_reference_count() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").stage_art = PackedStringArray(["a", "b", "c", "d"])
	_assert_rejected(m, "CROP_STAGE_COUNT")


func test_empty_stage_reference() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").stage_art = PackedStringArray(["a", "b", "", "d", "e"])
	_assert_rejected(m, "CROP_STAGE_REF_EMPTY")


func test_level_gate_out_of_range() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").required_level = 0
	_assert_rejected(m, "CROP_LEVEL_GATE_INVALID")


func test_missing_research_reference() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").research_id = "unlock_nothing"
	_assert_rejected(m, "CROP_RESEARCH_MISSING")


func test_research_unlocking_another_crop() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").research_id = "unlock_carrots"
	_assert_rejected(m, "CROP_RESEARCH_MISMATCH")


func test_research_for_unknown_crop() -> void:
	var m: ContentManifest = _manifest()
	m.research[0].crop_id = "mango"
	_assert_rejected(m, "RESEARCH_CROP_MISSING")


func test_research_nonpositive_duration() -> void:
	var m: ContentManifest = _manifest()
	m.research[0].duration_us = 0
	_assert_rejected(m, "RESEARCH_NONPOSITIVE_DURATION")


func test_start_unlock_unknown_or_researched() -> void:
	var m: ContentManifest = _manifest()
	m.start_unlocked_crop_ids = PackedStringArray(["wheat", "mango"])
	_assert_rejected(m, "START_UNLOCK_UNKNOWN")
	var m2: ContentManifest = _manifest()
	m2.start_unlocked_crop_ids = PackedStringArray(["wheat", "corn"])
	_assert_rejected(m2, "START_UNLOCK_HAS_RESEARCH")


func test_crop_without_research_must_be_start_unlocked() -> void:
	var m: ContentManifest = _manifest()
	_crop(m, "corn").research_id = ""
	_assert_rejected(m, "CROP_UNREACHABLE")


func test_curve_level_one_not_zero() -> void:
	var m: ContentManifest = _manifest()
	m.level_curve.explicit_thresholds[0] = 5
	_assert_rejected(m, "CURVE_LEVEL1_NOT_ZERO")


func test_curve_not_strictly_increasing() -> void:
	var m: ContentManifest = _manifest()
	m.level_curve.explicit_thresholds[13] = m.level_curve.explicit_thresholds[12]
	_assert_rejected(m, "CURVE_NOT_INCREASING")


func test_curve_continuation_invalid() -> void:
	var m: ContentManifest = _manifest()
	m.level_curve.continuation_first_increment = 0
	_assert_rejected(m, "CURVE_CONTINUATION_INVALID")


func test_missing_curve() -> void:
	var m: ContentManifest = _manifest()
	m.level_curve = null
	_assert_rejected(m, "CURVE_MISSING")


func test_skill_missing_prerequisite() -> void:
	var m: ContentManifest = _manifest()
	m.skills[1].prerequisite_id = "unknown_skill"
	_assert_rejected(m, "SKILL_PREREQUISITE_MISSING")


func test_skill_prerequisite_cycle() -> void:
	var m: ContentManifest = _manifest()
	m.skills[0].prerequisite_id = "climate_control"
	_assert_rejected(m, "SKILL_PREREQUISITE_CYCLE")


func test_duplicate_skill() -> void:
	var m: ContentManifest = _manifest()
	m.skills.append(m.skills[0].duplicate() as SkillDefinition)
	_assert_rejected(m, "SKILL_DUPLICATE_ID")
