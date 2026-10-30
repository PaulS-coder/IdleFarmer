extends GutTest


func test_deliberate_failure() -> void:
	assert_eq(1, 2, "S0 deliberate failing assertion")
