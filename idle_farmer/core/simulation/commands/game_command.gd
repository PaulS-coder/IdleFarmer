class_name GameCommand
extends RefCounted
## Accepted, controller-stamped command envelope (TRS §4.1/§20.4, AUD-004). Fields are private and
## set once at construction, so an accepted envelope cannot be edited afterwards; replay uses the
## recorded accepted time/order and never restamps. Raw UI intents are a separate type (RawIntent).

const TYPE_PLANT_CROP: String = "PlantCrop"
const TYPE_HARVEST_CROP: String = "HarvestCrop"

var _command_id: CommandId
var _type: String
var _accepted_time_us: int
var _accepted_order: int


func _init(p_command_id: CommandId, p_type: String, p_accepted_time_us: int, p_accepted_order: int) -> void:
	_command_id = p_command_id
	_type = p_type
	_accepted_time_us = p_accepted_time_us
	_accepted_order = p_accepted_order


func command_id() -> CommandId:
	return CommandId.new(_command_id.save_id, _command_id.writer_epoch, _command_id.counter) if _command_id != null else null


func type() -> String:
	return _type


func accepted_time_us() -> int:
	return _accepted_time_us


func accepted_order() -> int:
	return _accepted_order


## Envelope well-formedness only (MALFORMED_ENVELOPE); time/replay/state checks belong to the engine.
func envelope_failure(expected_save_id: String) -> String:
	if _command_id == null or not _command_id.is_valid() or _command_id.save_id != expected_save_id:
		return FailureCode.MALFORMED_ENVELOPE
	if _accepted_time_us < 0 or _accepted_order < 1:
		return FailureCode.MALFORMED_ENVELOPE
	if not _args_valid():
		return FailureCode.MALFORMED_ENVELOPE
	return FailureCode.NONE


func to_primitive() -> Dictionary:
	return {
		"command_id": null if _command_id == null else _command_id.to_primitive(),
		"type": _type,
		"accepted_time_us": _accepted_time_us,
		"accepted_order": _accepted_order,
		"args": _args_primitive(),
	}


## Decodes a recorded accepted command (replay logs). Returns null when malformed or unknown type.
static func from_primitive(value: Variant) -> GameCommand:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "GameCommand")
	reader.expect_only(PackedStringArray(["command_id", "type", "accepted_time_us", "accepted_order", "args"]))
	var id: CommandId = CommandId.from_primitive(reader.dict_field("command_id"))
	var command_type: String = reader.string_field("type")
	var time_us: int = reader.int_field("accepted_time_us")
	var order: int = reader.int_field("accepted_order")
	var args: Dictionary = reader.dict_field("args")
	if not reader.ok() or id == null:
		return null
	return CommandFactory.build(command_type, id, time_us, order, args)


func _args_valid() -> bool:
	return false


func _args_primitive() -> Dictionary:
	return {}
