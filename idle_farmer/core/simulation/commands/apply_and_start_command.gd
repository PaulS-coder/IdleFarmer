class_name ApplyAndStartCommand
extends GameCommand
## Apply a recurring plan to selected plots and start it (M02-T08/T09, FRS §9.2, DEC-025, Q1).
## Each member binds the plan {crop, fertilizer policy, fallback} by its digest and, for an Empty
## plot, the exact first-planting seed/fertilizer costs and confirmed minimum ending balance
## (−1 when none). Occupied plots get future settings only; their snapshots are kept.

const MAX_MEMBERS: int = 32
const MEMBER_SCHEMA: Dictionary = {
	"plot_id": TYPE_INT, "crop_id": TYPE_STRING, "fertilizer_policy": TYPE_STRING, "fallback_accepted": TYPE_BOOL,
	"plan_digest": TYPE_STRING, "seed_cost": TYPE_INT, "fertilizer_cost": TYPE_INT, "min_ending_balance": TYPE_INT,
}

var _members: Array[Dictionary] = []


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_members: Array[Dictionary]) -> void:
	super(p_command_id, GameCommand.TYPE_APPLY_AND_START, p_accepted_time_us, p_accepted_order)
	_members = p_members.duplicate(true)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> ApplyAndStartCommand:
	var reader: PrimitiveReader = PrimitiveReader.new(args, "ApplyAndStart.args")
	reader.expect_only(PackedStringArray(["members"]))
	var members: Array[Dictionary] = []
	for item: Variant in reader.array_field("members"):
		var terms: Variant = TermsCommand.decode_terms(item, MEMBER_SCHEMA, "ApplyAndStart.member") if item is Dictionary else null
		if terms == null:
			return null
		members.append(terms)
	return ApplyAndStartCommand.new(id, time_us, order, members) if reader.ok() else null


## Member terms in canonical ascending plot ID order (copies).
func members() -> Array[Dictionary]:
	var ordered: Array[Dictionary] = _members.duplicate(true)
	ordered.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["plot_id"] < b["plot_id"])
	return ordered


func _args_valid() -> bool:
	var plots: Dictionary[int, bool] = {}
	for member: Dictionary in _members:
		if plots.has(member["plot_id"]) or (member["crop_id"] as String).is_empty() or (member["plan_digest"] as String).is_empty() \
				or member["seed_cost"] < 0 or member["fertilizer_cost"] < 0 or member["min_ending_balance"] < -1:
			return false
		plots[member["plot_id"]] = true
	return not _members.is_empty() and _members.size() <= MAX_MEMBERS


func _args_primitive() -> Dictionary:
	return {"members": PrimitiveReader.plain(_members)}
