class_name ContractInstance
extends RefCounted
## Reserved accepted-contract record (TRS §3.5 ContractState, DEC-019/C2). Behavior is M05; M02
## defines the typed, validated, deep-copied schema so M03 can persist it. The objective and reward
## are snapshots taken at acceptance; a claim is a separate credit category, never harvest gross.

const STATUS_ACCEPTED: String = "accepted"
const STATUS_COMPLETED: String = "completed"
const STATUS_CLAIMED: String = "claimed"
const STATUS_ABANDONED: String = "abandoned"
const STATUSES: PackedStringArray = [STATUS_ACCEPTED, STATUS_COMPLETED, STATUS_CLAIMED, STATUS_ABANDONED]

var instance_id: EntityId = null
var offer_id: String = ""
var offer_version: int = 1
var accepted_at_us: int = 0
var accepted_sequence: int = 0
## Snapshotted objective, e.g. {"kind": "quantity", "targets": {"wheat": 20}}.
var objective: Dictionary = {}
var reward_coins: int = 0
var reward_xp: int = 0
var progress: Dictionary[String, int] = {}
var status: String = STATUS_ACCEPTED
## Unique claim identity, present exactly when claimed (one-time claim, replay-safe).
var claim_id: EntityId = null


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var context: String = instance_id.key() if instance_id != null else "?"
	if instance_id == null or not instance_id.is_valid() or offer_id.is_empty() or offer_version < 1:
		errors.append("CONTRACT_INSTANCE_INVALID: %s needs an identity, an offer and version ≥ 1" % context)
	if accepted_at_us < 0 or accepted_sequence < 0 or reward_coins < 0 or reward_xp < 0:
		errors.append("CONTRACT_INSTANCE_NEGATIVE: %s" % context)
	for key: String in progress:
		if progress[key] < 0:
			errors.append("CONTRACT_PROGRESS_NEGATIVE: %s '%s'" % [context, key])
	if not STATUSES.has(status):
		errors.append("CONTRACT_STATUS_UNKNOWN: %s '%s'" % [context, status])
	if (status == STATUS_CLAIMED) != (claim_id != null):
		errors.append("CONTRACT_CLAIM_INCONSISTENT: %s claim identity must exist exactly when claimed" % context)
	return errors


func to_primitive() -> Dictionary:
	return {
		"instance_id": EntityId.nullable_to_primitive(instance_id),
		"offer_id": offer_id,
		"offer_version": offer_version,
		"accepted_at_us": accepted_at_us,
		"accepted_sequence": accepted_sequence,
		"objective": PrimitiveReader.plain(objective),
		"reward_coins": reward_coins,
		"reward_xp": reward_xp,
		"progress": PrimitiveReader.plain(progress),
		"status": status,
		"claim_id": EntityId.nullable_to_primitive(claim_id),
	}


static func from_primitive(value: Variant) -> ContractInstance:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "ContractInstance")
	reader.expect_only(PackedStringArray(["instance_id", "offer_id", "offer_version", "accepted_at_us", "accepted_sequence",
		"objective", "reward_coins", "reward_xp", "progress", "status", "claim_id"]))
	var record: ContractInstance = ContractInstance.new()
	record.instance_id = EntityId.from_primitive(reader.dict_field("instance_id"))
	record.offer_id = reader.string_field("offer_id")
	record.offer_version = reader.int_field("offer_version")
	record.accepted_at_us = reader.int_field("accepted_at_us")
	record.accepted_sequence = reader.int_field("accepted_sequence")
	record.objective = reader.dict_field("objective").duplicate(true)
	record.reward_coins = reader.int_field("reward_coins")
	record.reward_xp = reader.int_field("reward_xp")
	record.progress = reader.int_map_field("progress")
	record.status = reader.string_field("status")
	var claim_value: Variant = reader.nullable_field("claim_id")
	record.claim_id = null if claim_value == null else EntityId.from_primitive(claim_value)
	if not reader.ok() or record.instance_id == null or (claim_value != null and record.claim_id == null):
		return null
	return record
