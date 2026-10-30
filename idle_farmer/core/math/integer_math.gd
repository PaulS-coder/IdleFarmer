class_name IntegerMath
extends RefCounted
## Checked signed 64-bit arithmetic for all authoritative economics (TRS §4.4, DEC-005/026).
##
## GDScript `int` wraps silently on overflow, so authoritative coins, XP, microseconds and
## counters must go through these helpers. Every helper either returns the exact result or a
## failed MathResult; nothing is wrapped, saturated or routed through floating point.

const INT64_MAX: int = 9223372036854775807
const INT64_MIN: int = -9223372036854775807 - 1
const BASIS_POINTS: int = 10_000


static func add(a: int, b: int) -> MathResult:
	if b > 0 and a > INT64_MAX - b:
		return MathResult.failure()
	if b < 0 and a < INT64_MIN - b:
		return MathResult.failure()
	return MathResult.of(a + b)


static func sub(a: int, b: int) -> MathResult:
	if b < 0 and a > INT64_MAX + b:
		return MathResult.failure()
	if b > 0 and a < INT64_MIN + b:
		return MathResult.failure()
	return MathResult.of(a - b)


static func mul(a: int, b: int) -> MathResult:
	if a == 0 or b == 0:
		return MathResult.of(0)
	if a > 0:
		if b > 0:
			if a > INT64_MAX / b:
				return MathResult.failure()
		elif b < INT64_MIN / a:
			return MathResult.failure()
	else:
		if b > 0:
			if a < INT64_MIN / b:
				return MathResult.failure()
		elif b < INT64_MAX / a:
			return MathResult.failure()
	return MathResult.of(a * b)


## Quotient rounded toward negative infinity. GDScript `/` truncates toward zero.
static func floor_div(a: int, d: int) -> MathResult:
	if d == 0 or (a == INT64_MIN and d == -1):
		return MathResult.failure()
	var q: int = a / d
	var r: int = a % d
	if r != 0 and ((r < 0) != (d < 0)):
		q -= 1
	return MathResult.of(q)


## Quotient rounded toward positive infinity.
static func ceil_div(a: int, d: int) -> MathResult:
	if d == 0 or (a == INT64_MIN and d == -1):
		return MathResult.failure()
	var q: int = a / d
	var r: int = a % d
	if r != 0 and ((r < 0) == (d < 0)):
		q += 1
	return MathResult.of(q)


## floor(a × b / d) for a ≥ 0, b ≥ 0, d > 0, exact even when a × b exceeds int64.
static func mul_div_floor(a: int, b: int, d: int) -> MathResult:
	var parts: Array[int] = _mul_div_parts(a, b, d)
	if parts.is_empty():
		return MathResult.failure()
	return MathResult.of(parts[0])


## ceil(a × b / d) for a ≥ 0, b ≥ 0, d > 0, exact even when a × b exceeds int64.
static func mul_div_ceil(a: int, b: int, d: int) -> MathResult:
	var parts: Array[int] = _mul_div_parts(a, b, d)
	if parts.is_empty():
		return MathResult.failure()
	if parts[1] == 0:
		return MathResult.of(parts[0])
	return add(parts[0], 1)


static func apply_bp_floor(value: int, basis_points: int) -> MathResult:
	return mul_div_floor(value, basis_points, BASIS_POINTS)


static func apply_bp_ceil(value: int, basis_points: int) -> MathResult:
	return mul_div_ceil(value, basis_points, BASIS_POINTS)


## Effective growth duration: max(1, ceil(base × (10_000 − min(reduction, cap)) / 10_000)).
static func growth_us(base_us: int, reduction_bp: int, cap_bp: int) -> MathResult:
	if base_us <= 0 or reduction_bp < 0 or cap_bp < 0 or cap_bp > BASIS_POINTS:
		return MathResult.failure()
	var applied: int = mini(reduction_bp, cap_bp)
	var scaled: MathResult = apply_bp_ceil(base_us, BASIS_POINTS - applied)
	if not scaled.ok:
		return scaled
	return MathResult.of(maxi(1, scaled.value))


## Next option B level increment: p + ceil(p × percent / 100) (DEC-002/C1; 10% gives p + ceil(p/10)).
static func next_increasing_increment(previous: int, growth_percent: int) -> MathResult:
	if previous <= 0 or growth_percent <= 0:
		return MathResult.failure()
	var growth: MathResult = mul_div_ceil(previous, growth_percent, 100)
	if not growth.ok:
		return growth
	return add(previous, growth.value)


## Returns [quotient, remainder] of a × b / d, or [] when invalid or not representable.
## Uses a = qa·d + ra and b = qb·d + rb so that
## a·b = (qa·b + ra·qb)·d + ra·rb, then divides ra·rb (both < d) by doubling.
static func _mul_div_parts(a: int, b: int, d: int) -> Array[int]:
	if a < 0 or b < 0 or d <= 0:
		return []
	var direct: MathResult = mul(a, b)
	if direct.ok:
		return [direct.value / d, direct.value % d]
	var qa: int = a / d
	var ra: int = a % d
	var qb: int = b / d
	var rb: int = b % d
	var high: MathResult = mul(qa, b)
	if not high.ok:
		return []
	# ra < d, so ra × qb < d × qb ≤ b: always representable.
	var total: MathResult = add(high.value, ra * qb)
	if not total.ok:
		return []
	var small: Array[int] = _mul_div_small(ra, rb, d)
	total = add(total.value, small[0])
	if not total.ok:
		return []
	return [total.value, small[1]]


## [floor(x × y / d), (x × y) mod d] for 0 ≤ x, y < d without forming x × y.
static func _mul_div_small(x: int, y: int, d: int) -> Array[int]:
	var q: int = 0
	var r: int = 0
	var bit: int = 62
	while bit >= 0:
		# Double (q, r): r stays < d without computing r + r directly.
		q += q
		if r >= d - r:
			r = r - (d - r)
			q += 1
		else:
			r += r
		if (y >> bit) & 1 == 1:
			if r >= d - x:
				r = r - (d - x)
				q += 1
			else:
				r += x
		bit -= 1
	return [q, r]
