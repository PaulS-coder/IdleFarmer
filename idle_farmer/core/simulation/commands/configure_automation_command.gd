class_name ConfigureAutomationCommand
extends GameCommand
## Set or clear one inheritable farming setting (M02-T09/T10, FRS §7.1, E10). `plot_id` 0 targets
## the farm defaults (which can be changed but never cleared). The value's type must match the field.

var _plot_id: int
var _field: String
var _set: bool
var _value: Variant


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_plot_id: int, p_field: String,
		p_set: bool, p_value: Variant) -> void:
	super(p_command_id, GameCommand.TYPE_CONFIGURE_AUTOMATION, p_accepted_time_us, p_accepted_order)
	_plot_id = p_plot_id
	_field = p_field
	_set = p_set
	_value = p_value


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> ConfigureAutomationCommand:
	var reader: PrimitiveReader = PrimitiveReader.new(args, "ConfigureAutomation.args")
	reader.expect_only(PackedStringArray(["plot_id", "field", "set", "value"]))
	var field: String = reader.string_field("field")
	var value: Variant = args.get("value")
	if not reader.ok() or typeof(value) != FarmingSettings.field_type(field):
		return null
	return ConfigureAutomationCommand.new(id, time_us, order, reader.int_field("plot_id"), field, reader.bool_field("set"), value)


func plot_id() -> int:
	return _plot_id


func field() -> String:
	return _field


func is_set() -> bool:
	return _set


func value() -> Variant:
	return _value


func _args_valid() -> bool:
	return FarmingSettings.FIELDS.has(_field) and typeof(_value) == FarmingSettings.field_type(_field) and _plot_id >= 0


func _args_primitive() -> Dictionary:
	return {"plot_id": _plot_id, "field": _field, "set": _set, "value": _value}
