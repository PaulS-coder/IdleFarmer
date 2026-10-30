extends GutTest
## M01-T03/T12 data side, V05/V11/V13: full FRS §5.1 table and option B continuation.

var registry: ContentRegistry


func before_all() -> void:
	registry = ContentM01V1.build_registry()


func test_registry_is_valid() -> void:
	assert_eq(registry.errors, PackedStringArray(), "content_m01_v1 validates")


func test_all_representable_thresholds_match_oracle() -> void:
	assert_eq(registry.max_representable_level(), OracleVectors.XP_THRESHOLDS.size())
	assert_eq(registry.max_representable_level(), 349, "last int64-representable level")
	for level: int in range(1, OracleVectors.XP_THRESHOLDS.size() + 1):
		assert_eq(registry.threshold_for_level(level), OracleVectors.XP_THRESHOLDS[level - 1], "threshold L%d" % level)


func test_explicit_table_is_frs_section_5_1_unchanged() -> void:
	assert_eq(registry.explicit_level_count(), 30)
	var frs: Array[int] = [
		0, 240, 650, 1300, 2300, 3600, 5200, 7300, 10000, 13500,
		18000, 24000, 29334, 34667, 40000, 50000, 60000, 70000, 88750, 107500,
		126250, 145000, 181250, 217500, 253750, 290000, 347500, 405000, 462500, 520000,
	]
	for level: int in range(1, 31):
		assert_eq(registry.threshold_for_level(level), frs[level - 1], "FRS L%d" % level)


func test_option_b_vectors_31_to_40() -> void:
	var expected: Dictionary[int, int] = {
		31: 577_500, 32: 640_750, 33: 710_325, 34: 786_858, 35: 871_045,
		36: 963_651, 37: 1_065_518, 38: 1_177_572, 39: 1_300_832, 40: 1_436_418,
	}
	for level: int in expected:
		assert_eq(registry.threshold_for_level(level), expected[level], "option B L%d" % level)


func test_closed_form_adversary_does_not_match() -> void:
	for c: Array in OracleVectors.XP_CLOSED_FORM_ADVERSARY:
		assert_ne(registry.threshold_for_level(c[0]), c[1], "per-step ceil differs from closed form at L%d" % c[0])


func test_below_at_above_every_explicit_threshold() -> void:
	for level: int in range(2, 31):
		var t: int = registry.threshold_for_level(level)
		assert_eq(registry.level_for_xp(t - 1), level - 1, "below L%d" % level)
		assert_eq(registry.level_for_xp(t), level, "at L%d" % level)
		assert_eq(registry.level_for_xp(t + 1), level, "above L%d" % level)


func test_below_at_above_30_to_35() -> void:
	for level: int in range(30, 36):
		var t: int = registry.threshold_for_level(level)
		assert_eq(registry.level_for_xp(t - 1), level - 1, "below L%d" % level)
		assert_eq(registry.level_for_xp(t), level, "at L%d" % level)


func test_lookup_at_representation_boundary() -> void:
	assert_eq(registry.level_for_xp(0), 1, "new game XP")
	assert_eq(registry.level_for_xp(-1), -1, "negative XP is invalid")
	assert_eq(registry.threshold_for_level(349), 9_203_731_170_706_289_434)
	assert_eq(registry.level_for_xp(9_203_731_170_706_289_433), 348)
	assert_eq(registry.level_for_xp(IntegerMath.INT64_MAX), 349, "valid max XP maps to 349")
	assert_eq(registry.level_for_xp(IntegerMath.INT64_MAX) - 1, 348, "348 earned points")
	assert_eq(registry.threshold_for_level(350), -1, "next threshold beyond int64 is a boundary, not a cap")
	assert_eq(registry.threshold_for_level(0), -1)
