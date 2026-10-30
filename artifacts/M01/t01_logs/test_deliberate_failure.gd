extends GutTest

func test_deliberate_failure() -> void:
	assert_eq(1, 2, "T01 deliberate failing assertion")
