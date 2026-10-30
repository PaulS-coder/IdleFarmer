class_name AccountedInterval
extends RefCounted
## One already-credited real-time interval (DEC-013): its classification, the real elapsed time
## credited to the anchor and the simulation advancement it produced. Real and simulated deltas
## differ only for active debug speed; suspended and offline intervals always advance at 1×.

const KIND_ACTIVE: String = "active"
const KIND_SUSPENDED: String = "suspended"
const KIND_OFFLINE: String = "offline"
const KINDS: PackedStringArray = ["active", "suspended", "offline"]

var kind: String
var real_us: int
var sim_us: int


func _init(p_kind: String, p_real_us: int, p_sim_us: int) -> void:
	kind = p_kind
	real_us = p_real_us
	sim_us = p_sim_us


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if not KINDS.has(kind):
		errors.append("INTERVAL_KIND_INVALID: '%s'" % kind)
	if real_us < 0 or sim_us < 0:
		errors.append("INTERVAL_NEGATIVE: %s real=%d sim=%d" % [kind, real_us, sim_us])
	if kind != KIND_ACTIVE and real_us != sim_us:
		errors.append("INTERVAL_NOT_1X: %s real=%d sim=%d" % [kind, real_us, sim_us])
	return errors


func to_primitive() -> Dictionary:
	return {"kind": kind, "real_us": real_us, "sim_us": sim_us}


static func from_primitive(value: Variant) -> AccountedInterval:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "AccountedInterval")
	reader.expect_only(PackedStringArray(["kind", "real_us", "sim_us"]))
	var interval: AccountedInterval = AccountedInterval.new(reader.string_field("kind"), reader.int_field("real_us"), reader.int_field("sim_us"))
	if not reader.ok():
		return null
	return interval
