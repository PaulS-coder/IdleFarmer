extends GutTest
## S0 smoke test: proves the runner discovers and executes tests under res://tests.


func test_runner_executes_typed_test() -> void:
	var value: int = 1 + 1
	assert_eq(value, 2, "headless GUT runner executes typed tests")
