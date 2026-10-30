class_name LoopAuthorization
extends RefCounted
## Explicit authorization of one plot's recurring purchase plan (M02 E11, FRS §9.2, Q1). A loop runs
## only while armed, while `plan_digest` equals the plot's current effective plan digest and while
## the capabilities are owned. Reset disarms; re-buying a skill never re-arms. `authorized_revision`
## records the state_sequence at which the plan was authorized (audit only).

var armed: bool = false
var plan_digest: String = ""
var authorized_revision: int = 0


func arm(digest: String, revision: int) -> void:
	armed = true
	plan_digest = digest
	authorized_revision = revision


func disarm() -> void:
	armed = false
	plan_digest = ""
	authorized_revision = 0


func validate(context: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if armed == plan_digest.is_empty() or authorized_revision < 0 or (not armed and authorized_revision != 0):
		errors.append("AUTHORIZATION_INCONSISTENT: %s" % context)
	return errors


func to_primitive() -> Dictionary:
	return {"armed": armed, "plan_digest": plan_digest, "authorized_revision": authorized_revision}


static func from_primitive(value: Variant) -> LoopAuthorization:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "LoopAuthorization")
	reader.expect_only(PackedStringArray(["armed", "plan_digest", "authorized_revision"]))
	var record: LoopAuthorization = LoopAuthorization.new()
	record.armed = reader.bool_field("armed")
	record.plan_digest = reader.string_field("plan_digest")
	record.authorized_revision = reader.int_field("authorized_revision")
	return record if reader.ok() else null
