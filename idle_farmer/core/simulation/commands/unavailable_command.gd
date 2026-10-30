class_name UnavailableCommand
extends GameCommand
## A recognised TRS command whose behavior belongs to a later milestone (M02 E9, Q3; build plan §6).
## It decodes with any primitive arguments and always fails FEATURE_UNAVAILABLE, uncharged.

const TYPES: PackedStringArray = [
	"SetSpendingPriority", "SetSeedProtection", "SavePreset", "ApplyPreset", "DeletePreset", "ConfigureRotation",
	"CreateGroup", "RenameGroup", "EditGroup", "AssignPlotGroup", "UnassignPlotGroup", "DeleteGroup",
	"AcceptContract", "ClaimContract", "AbandonContract",
]

var _args: Dictionary = {}


func _init(p_command_id: CommandId, p_type: String, p_accepted_time_us: int, p_accepted_order: int, p_args: Dictionary) -> void:
	super(p_command_id, p_type, p_accepted_time_us, p_accepted_order)
	_args = p_args.duplicate(true)


func _args_valid() -> bool:
	return CanonicalCodec.is_encodable(_args)


func _args_primitive() -> Dictionary:
	return PrimitiveReader.plain(_args)
