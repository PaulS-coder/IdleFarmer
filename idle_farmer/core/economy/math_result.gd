class_name MathResult
extends RefCounted
## Outcome of a checked integer operation. `ok == false` means the exact result is not
## representable as a signed 64-bit integer (or the operands were invalid); `value` is then 0
## and must not be used. Never carries a wrapped or saturated value (DEC-026).

var ok: bool
var value: int


func _init(p_ok: bool, p_value: int) -> void:
	ok = p_ok
	value = p_value


static func of(p_value: int) -> MathResult:
	return MathResult.new(true, p_value)


static func failure() -> MathResult:
	return MathResult.new(false, 0)
