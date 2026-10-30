class_name BatchPlantCommand
extends GameCommand
## Manual planting of several selected plots (M02-T08, FRS §9.2, DEC-025). Each member carries the
## same confirmed terms as a PlantCrop. Members are processed in ascending plot ID; ineligible
## members are skipped with per-plot reasons and the eligible subset is one atomic outcome.

const MAX_MEMBERS: int = 32

var _members: Array[PlantCropCommand] = []


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_members: Array[PlantCropCommand]) -> void:
	super(p_command_id, GameCommand.TYPE_BATCH_PLANT, p_accepted_time_us, p_accepted_order)
	_members = p_members.duplicate()


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> BatchPlantCommand:
	var reader: PrimitiveReader = PrimitiveReader.new(args, "BatchPlant.args")
	reader.expect_only(PackedStringArray(["members"]))
	var members: Array[PlantCropCommand] = []
	for item: Variant in reader.array_field("members"):
		var member: PlantCropCommand = PlantCropCommand.from_args(id, time_us, order, item) if item is Dictionary else null
		if member == null:
			return null
		members.append(member)
	return BatchPlantCommand.new(id, time_us, order, members) if reader.ok() else null


## Members in canonical ascending plot ID order.
func members() -> Array[PlantCropCommand]:
	var ordered: Array[PlantCropCommand] = _members.duplicate()
	ordered.sort_custom(func(a: PlantCropCommand, b: PlantCropCommand) -> bool: return a.plot_id() < b.plot_id())
	return ordered


func _args_valid() -> bool:
	return GameCommand.unique_member_plots(_members, MAX_MEMBERS) and _members.all(func(m: PlantCropCommand) -> bool: return m._args_valid())


func _args_primitive() -> Dictionary:
	var items: Array = []
	for member: PlantCropCommand in _members:
		items.append(member._args_primitive())
	return {"members": items}
