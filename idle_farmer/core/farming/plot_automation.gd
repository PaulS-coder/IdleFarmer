class_name PlotAutomation
extends RefCounted
## Per-plot automation record: setting overrides, the optional group reference ("" = none; groups
## are M05), the loop authorization (M02 E10/E11) and the reserved rotation record (M05).
## AutomationState serializes only records that differ from the default, so `plot_id` travels with
## the record.

var plot_id: int = 0
var settings: FarmingSettings = FarmingSettings.new()
var group_id: String = ""
var authorization: LoopAuthorization = LoopAuthorization.new()
var rotation: RotationState = RotationState.new()


func _init(p_plot_id: int = 0) -> void:
	plot_id = p_plot_id


## No overrides, no group, not armed.
func is_default() -> bool:
	return group_id.is_empty() and not authorization.armed and settings.is_empty() and rotation.is_empty()


func validate(context: String) -> PackedStringArray:
	var errors: PackedStringArray = settings.validate(context)
	errors.append_array(authorization.validate(context))
	errors.append_array(rotation.validate(context))
	return errors


func to_primitive() -> Dictionary:
	return {"plot_id": plot_id, "settings": settings.to_primitive(), "group_id": group_id, "authorization": authorization.to_primitive(),
		"rotation": rotation.to_primitive()}


static func from_primitive(value: Variant) -> PlotAutomation:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "PlotAutomation")
	reader.expect_only(PackedStringArray(["plot_id", "settings", "group_id", "authorization", "rotation"]))
	var record: PlotAutomation = PlotAutomation.new(reader.int_field("plot_id"))
	record.settings = FarmingSettings.from_primitive(reader.dict_field("settings"))
	record.group_id = reader.string_field("group_id")
	record.authorization = LoopAuthorization.from_primitive(reader.dict_field("authorization"))
	record.rotation = RotationState.from_primitive(reader.dict_field("rotation"))
	if not reader.ok() or record.settings == null or record.authorization == null or record.rotation == null:
		return null
	return record
