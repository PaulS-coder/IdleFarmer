extends GutTest
## M02 S0 / E3: BigInt arithmetic against the independent Python oracle, limb boundaries, int64
## round-trips and algebraic properties.


func _big(text: String) -> BigInt:
	var value: BigInt = BigInt.from_decimal(text)
	assert_not_null(value, "parse %s" % text)
	return value


func test_oracle_vectors() -> void:
	for row: Array in M02OracleVectors.BIGINT:
		var a: BigInt = _big(row[0])
		var b: BigInt = _big(row[1])
		var label: String = "%s ? %s" % [row[0], row[1]]
		assert_eq(a.add(b).to_decimal(), row[2], "add " + label)
		assert_eq(a.sub(b).to_decimal(), row[3], "sub " + label)
		assert_eq(a.mul(b).to_decimal(), row[4], "mul " + label)
		assert_eq(a.compare(b), row[5], "cmp " + label)


func test_decimal_round_trip_and_normal_form() -> void:
	for text: String in ["0", "1", "-1", "16777215", "16777216", "-281474976710656", "9223372036854775807",
			"-9223372036854775808", "123456789012345678901234567890", "-1000000000000000000000000"]:
		assert_eq(_big(text).to_decimal(), text)
	assert_eq(_big("-0").to_decimal(), "0", "negative zero normalizes")
	assert_eq(_big("-0").sign(), 0)
	assert_eq(_big("000123").to_decimal(), "123")
	for bad: String in ["", "-", "12a", "+5", " 1", "1.0"]:
		assert_null(BigInt.from_decimal(bad), "reject '%s'" % bad)


func test_int64_round_trip_and_bounds() -> void:
	for value: int in [0, 1, -1, 16777215, 16777216, IntegerMath.INT64_MAX, IntegerMath.INT64_MIN, -IntegerMath.INT64_MAX]:
		var big: BigInt = BigInt.from_int(value)
		assert_eq(big.to_decimal(), str(value))
		var back: MathResult = big.to_int()
		assert_true(back.ok, "to_int %d" % value)
		assert_eq(back.value, value)
	assert_false(_big("9223372036854775808").to_int().ok, "2^63 does not fit")
	assert_false(_big("-9223372036854775809").to_int().ok)
	assert_false(_big("340282366920938463463374607431768211456").to_int().ok)


func test_algebraic_properties() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7
	for i: int in 200:
		var a: BigInt = BigInt.from_int(rng.randi() - 2147483648).mul_int(rng.randi() + 1).mul_int(rng.randi() - 1000)
		var b: BigInt = BigInt.from_int(rng.randi() - 2147483648).mul_int(rng.randi() + 3)
		assert_true(a.add(b).sub(b).equals(a), "a+b-b = a")
		assert_true(a.mul(b).equals(b.mul(a)), "commutative")
		assert_true(a.sub(a).is_zero(), "a-a = 0")
		assert_eq(a.compare(b), -b.compare(a), "antisymmetric compare")
		assert_true(a.add(b).mul_int(3).equals(a.mul_int(3).add(b.mul_int(3))), "distributive")


func test_immutability() -> void:
	var a: BigInt = BigInt.from_int(5)
	var b: BigInt = a.add(BigInt.from_int(7))
	assert_eq(a.to_decimal(), "5")
	assert_eq(b.to_decimal(), "12")
	b.limbs.clear()
	assert_eq(a.to_decimal(), "5")
