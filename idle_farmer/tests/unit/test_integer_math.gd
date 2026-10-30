extends GutTest
## M01-T04 / V05 / V10: checked int64 arithmetic against independent oracle vectors.

const MAX: int = IntegerMath.INT64_MAX
const MIN: int = IntegerMath.INT64_MIN


func _assert_ok(result: MathResult, expected: int, label: String) -> void:
	assert_true(result.ok, "%s should be representable" % label)
	assert_eq(result.value, expected, label)


func _assert_fails(result: MathResult, label: String) -> void:
	assert_false(result.ok, "%s should fail" % label)
	assert_eq(result.value, 0, "%s failure carries no wrapped value" % label)


func test_add_and_sub_limits() -> void:
	_assert_ok(IntegerMath.add(MAX - 1, 1), MAX, "MAX-1 + 1")
	_assert_fails(IntegerMath.add(MAX, 1), "MAX + 1")
	_assert_ok(IntegerMath.add(MIN + 1, -1), MIN, "MIN+1 + -1")
	_assert_fails(IntegerMath.add(MIN, -1), "MIN + -1")
	_assert_ok(IntegerMath.add(MAX, MIN), -1, "MAX + MIN")
	_assert_ok(IntegerMath.sub(MIN + 1, 1), MIN, "MIN+1 - 1")
	_assert_fails(IntegerMath.sub(MIN, 1), "MIN - 1")
	_assert_fails(IntegerMath.sub(0, MIN), "0 - MIN")
	_assert_fails(IntegerMath.sub(MAX, -1), "MAX - -1")
	_assert_ok(IntegerMath.sub(-1, MAX), MIN, "-1 - MAX")


func test_mul_limits_all_sign_cases() -> void:
	_assert_ok(IntegerMath.mul(0, MIN), 0, "0 * MIN")
	_assert_ok(IntegerMath.mul(MAX, 1), MAX, "MAX * 1")
	_assert_ok(IntegerMath.mul(MAX, -1), -MAX, "MAX * -1")
	_assert_fails(IntegerMath.mul(MIN, -1), "MIN * -1")
	_assert_fails(IntegerMath.mul(-1, MIN), "-1 * MIN")
	_assert_ok(IntegerMath.mul(MIN, 1), MIN, "MIN * 1")
	_assert_ok(IntegerMath.mul(-4611686018427387904, 2), MIN, "-2^62 * 2")
	_assert_fails(IntegerMath.mul(4611686018427387904, 2), "2^62 * 2")
	_assert_fails(IntegerMath.mul(-4611686018427387904, -2), "-2^62 * -2")
	_assert_fails(IntegerMath.mul(3037000500, 3037000500), "sqrt(MAX)+ squared")
	_assert_ok(IntegerMath.mul(3037000499, 3037000499), 9223372030926249001, "floor(sqrt(MAX)) squared")
	_assert_ok(IntegerMath.mul(15, 60_000_000), 900_000_000, "15 min in us")


func test_floor_and_ceil_div_with_negatives() -> void:
	var cases: Array[Array] = [
		# [a, d, floor, ceil]
		[7, 2, 3, 4], [-7, 2, -4, -3], [7, -2, -4, -3], [-7, -2, 3, 4],
		[6, 3, 2, 2], [-6, 3, -2, -2], [0, 5, 0, 0], [MAX, 1, MAX, MAX], [MIN, 1, MIN, MIN],
		[MIN, 2, -4611686018427387904, -4611686018427387904], [MAX, 10, 922337203685477580, 922337203685477581],
	]
	for c: Array in cases:
		_assert_ok(IntegerMath.floor_div(c[0], c[1]), c[2], "floor(%d/%d)" % [c[0], c[1]])
		_assert_ok(IntegerMath.ceil_div(c[0], c[1]), c[3], "ceil(%d/%d)" % [c[0], c[1]])
	_assert_fails(IntegerMath.floor_div(1, 0), "divide by zero")
	_assert_fails(IntegerMath.ceil_div(1, 0), "divide by zero")
	_assert_fails(IntegerMath.floor_div(MIN, -1), "MIN / -1")


func test_mul_div_matches_oracle_including_overflowing_intermediates() -> void:
	for c: Array in OracleVectors.MUL_DIV:
		var label: String = "%d*%d/%d" % [c[0], c[1], c[2]]
		var floor_result: MathResult = IntegerMath.mul_div_floor(c[0], c[1], c[2])
		var ceil_result: MathResult = IntegerMath.mul_div_ceil(c[0], c[1], c[2])
		if c[3]:
			_assert_ok(floor_result, c[4], "floor " + label)
			_assert_ok(ceil_result, c[5], "ceil " + label)
		else:
			_assert_fails(floor_result, "floor " + label)
			_assert_fails(ceil_result, "ceil " + label)


func test_small_remainder_product_exhaustive() -> void:
	# The slow path divides ra × rb (both < d) by doubling; check every x, y < d for small d,
	# which covers the exact r + x == d and 2r == d carry boundaries.
	var mismatches: int = 0
	for d: int in range(1, 25):
		for x: int in d:
			for y: int in d:
				var parts: Array[int] = IntegerMath._mul_div_small(x, y, d)
				if parts[0] != (x * y) / d or parts[1] != (x * y) % d:
					mismatches += 1
	assert_eq(mismatches, 0, "doubling division matches direct division for all x, y < d ≤ 24")


func test_mul_div_rejects_invalid_operands() -> void:
	_assert_fails(IntegerMath.mul_div_floor(-1, 2, 3), "negative a")
	_assert_fails(IntegerMath.mul_div_floor(1, -2, 3), "negative b")
	_assert_fails(IntegerMath.mul_div_floor(1, 2, 0), "zero divisor")


func test_basis_point_rounding_rules() -> void:
	# DEC-005: rewards floor, prices ceil. Tomatoes base 270 with Basic +25% gross 337;
	# Basic fertilizer price ceil(270 × 15%) = 41 (TRS T-004, DVS-003).
	_assert_ok(IntegerMath.apply_bp_floor(270, 12_500), 337, "Tomato gross with +25%")
	_assert_ok(IntegerMath.apply_bp_ceil(270, 1_500), 41, "Basic fertilizer price")
	_assert_ok(IntegerMath.apply_bp_floor(16, 10_000), 16, "Wheat identity reward")


func test_growth_duration_cap_and_minimum() -> void:
	var tomato_us: int = 3_600_000_000
	_assert_ok(IntegerMath.growth_us(tomato_us, 0, 6_000), tomato_us, "no reduction")
	_assert_ok(IntegerMath.growth_us(tomato_us, 5_999, 6_000), 1_440_360_000, "just below cap")
	_assert_ok(IntegerMath.growth_us(tomato_us, 6_000, 6_000), 1_440_000_000, "at cap: 24 minutes")
	_assert_ok(IntegerMath.growth_us(tomato_us, 9_000, 6_000), 1_440_000_000, "above cap clamps")
	_assert_ok(IntegerMath.growth_us(1, 6_000, 6_000), 1, "1 us minimum (ceil)")
	_assert_ok(IntegerMath.growth_us(3, 9_999, 10_000), 1, "ceil fraction to 1 us")
	_assert_ok(IntegerMath.growth_us(7, 10_000, 10_000), 1, "full reduction still 1 us")
	_assert_fails(IntegerMath.growth_us(0, 0, 6_000), "zero base duration")


func test_increasing_increment_recurrence() -> void:
	_assert_ok(IntegerMath.next_increasing_increment(57_500, 10), 63_250, "I(32)")
	_assert_ok(IntegerMath.next_increasing_increment(69_575, 10), 76_533, "I(34) rounds up")
	_assert_fails(IntegerMath.next_increasing_increment(MAX - 10, 10), "increment beyond int64")
	_assert_fails(IntegerMath.next_increasing_increment(0, 10), "nonpositive previous")
