class_name BigInt
extends RefCounted
## Arbitrary-precision signed integer for exact rate comparisons (M02 build plan E3/B1).
##
## Magnitude is little-endian base-2^24 limbs, so a limb product (< 2^48) plus carries never
## overflows int64. Values are immutable: every operation returns a new BigInt. Zero has no limbs
## and is never negative. Only the operations exact rate arithmetic needs are provided.

const LIMB_BITS: int = 24
const LIMB_BASE: int = 1 << LIMB_BITS
const LIMB_MASK: int = LIMB_BASE - 1

var negative: bool = false
var limbs: Array[int] = []


static func zero() -> BigInt:
	return BigInt.new()


static func from_int(value: int) -> BigInt:
	var result: BigInt = BigInt.new()
	if value == 0:
		return result
	result.negative = value < 0
	if value == IntegerMath.INT64_MIN:
		result.limbs = [0, 0, 1 << 15]  # 2^63 = 2^48 · 2^15
		return result
	var magnitude: int = absi(value)
	while magnitude > 0:
		result.limbs.append(magnitude & LIMB_MASK)
		magnitude >>= LIMB_BITS
	return result


## Parses an optional '-' followed by decimal digits; returns null for malformed text.
static func from_decimal(text: String) -> BigInt:
	var digits: String = text
	var is_negative: bool = false
	if digits.begins_with("-"):
		is_negative = true
		digits = digits.substr(1)
	if digits.is_empty() or not _all_digits(digits):
		return null
	var chunk_size: int = 6
	var first: int = digits.length() % chunk_size
	if first == 0:
		first = chunk_size
	var result: BigInt = BigInt.zero()._mul_small_add(1, digits.substr(0, first).to_int())
	var start: int = first
	while start < digits.length():
		result = result._mul_small_add(1_000_000, digits.substr(start, chunk_size).to_int())
		start += chunk_size
	if not result.is_zero():
		result.negative = is_negative
	return result


func is_zero() -> bool:
	return limbs.is_empty()


func sign() -> int:
	if limbs.is_empty():
		return 0
	return -1 if negative else 1


func add(other: BigInt) -> BigInt:
	if negative == other.negative:
		return _make(negative, _mag_add(limbs, other.limbs))
	var cmp: int = _mag_cmp(limbs, other.limbs)
	if cmp == 0:
		return BigInt.zero()
	if cmp > 0:
		return _make(negative, _mag_sub(limbs, other.limbs))
	return _make(other.negative, _mag_sub(other.limbs, limbs))


func sub(other: BigInt) -> BigInt:
	return add(other.negated())


func negated() -> BigInt:
	return _make(not negative, limbs.duplicate())


func mul(other: BigInt) -> BigInt:
	if is_zero() or other.is_zero():
		return BigInt.zero()
	return _make(negative != other.negative, _mag_mul(limbs, other.limbs))


func mul_int(value: int) -> BigInt:
	return mul(BigInt.from_int(value))


## -1, 0 or 1 as self <, ==, > other.
func compare(other: BigInt) -> int:
	if negative != other.negative:
		if is_zero() and other.is_zero():
			return 0
		return -1 if negative else 1
	var cmp: int = _mag_cmp(limbs, other.limbs)
	return -cmp if negative else cmp


func equals(other: BigInt) -> bool:
	return compare(other) == 0


## Exact int64 value, or a failed MathResult when out of range.
func to_int() -> MathResult:
	if limbs.size() > 3:
		return MathResult.failure()
	if limbs.size() == 3 and limbs[2] >= (1 << 15):
		# Magnitude ≥ 2^63: only −2^63 itself is representable.
		return MathResult.of(IntegerMath.INT64_MIN) if negative and _is_int64_min() else MathResult.failure()
	var magnitude: int = 0
	for i: int in range(limbs.size() - 1, -1, -1):
		magnitude = (magnitude << LIMB_BITS) | limbs[i]
	return MathResult.of(-magnitude if negative else magnitude)


func to_decimal() -> String:
	if is_zero():
		return "0"
	var parts: PackedStringArray = PackedStringArray()
	var current: Array[int] = limbs.duplicate()
	while not current.is_empty():
		var remainder: int = _mag_divmod_small_in_place(current, 1_000_000)
		parts.append(str(remainder))
	var text: String = parts[parts.size() - 1]
	for i: int in range(parts.size() - 2, -1, -1):
		text += parts[i].lpad(6, "0")
	return ("-" if negative else "") + text


func _is_int64_min() -> bool:
	return limbs.size() == 3 and limbs[0] == 0 and limbs[1] == 0 and limbs[2] == (1 << 15)


func _mul_small_add(factor: int, addend: int) -> BigInt:
	var out: Array[int] = []
	var carry: int = addend
	for limb: int in limbs:
		var t: int = limb * factor + carry
		out.append(t & LIMB_MASK)
		carry = t >> LIMB_BITS
	while carry > 0:
		out.append(carry & LIMB_MASK)
		carry >>= LIMB_BITS
	return _make(false, out)


static func _all_digits(text: String) -> bool:
	for i: int in text.length():
		var c: int = text.unicode_at(i)
		if c < 48 or c > 57:
			return false
	return true


static func _make(is_negative: bool, magnitude: Array[int]) -> BigInt:
	while not magnitude.is_empty() and magnitude[magnitude.size() - 1] == 0:
		magnitude.pop_back()
	var result: BigInt = BigInt.new()
	result.limbs = magnitude
	result.negative = is_negative and not magnitude.is_empty()
	return result


static func _mag_cmp(a: Array[int], b: Array[int]) -> int:
	if a.size() != b.size():
		return 1 if a.size() > b.size() else -1
	for i: int in range(a.size() - 1, -1, -1):
		if a[i] != b[i]:
			return 1 if a[i] > b[i] else -1
	return 0


static func _mag_add(a: Array[int], b: Array[int]) -> Array[int]:
	var out: Array[int] = []
	var carry: int = 0
	var n: int = maxi(a.size(), b.size())
	for i: int in n:
		var t: int = carry + (a[i] if i < a.size() else 0) + (b[i] if i < b.size() else 0)
		out.append(t & LIMB_MASK)
		carry = t >> LIMB_BITS
	if carry > 0:
		out.append(carry)
	return out


## |a| − |b| for |a| ≥ |b|.
static func _mag_sub(a: Array[int], b: Array[int]) -> Array[int]:
	var out: Array[int] = []
	var borrow: int = 0
	for i: int in a.size():
		var t: int = a[i] - borrow - (b[i] if i < b.size() else 0)
		if t < 0:
			t += LIMB_BASE
			borrow = 1
		else:
			borrow = 0
		out.append(t)
	return out


static func _mag_mul(a: Array[int], b: Array[int]) -> Array[int]:
	var out: Array[int] = []
	out.resize(a.size() + b.size())
	out.fill(0)
	for i: int in a.size():
		var carry: int = 0
		var ai: int = a[i]
		if ai == 0:
			continue
		for j: int in b.size():
			var t: int = out[i + j] + ai * b[j] + carry
			out[i + j] = t & LIMB_MASK
			carry = t >> LIMB_BITS
		var k: int = i + b.size()
		while carry > 0:
			var t2: int = out[k] + carry
			out[k] = t2 & LIMB_MASK
			carry = t2 >> LIMB_BITS
			k += 1
	return out


## Divides the magnitude in place by a small positive divisor (< 2^30); returns the remainder.
static func _mag_divmod_small_in_place(mag: Array[int], divisor: int) -> int:
	var remainder: int = 0
	for i: int in range(mag.size() - 1, -1, -1):
		var current: int = (remainder << LIMB_BITS) | mag[i]
		mag[i] = current / divisor
		remainder = current % divisor
	while not mag.is_empty() and mag[mag.size() - 1] == 0:
		mag.pop_back()
	return remainder
