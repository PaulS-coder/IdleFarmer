class_name BatchHarvestCommand
extends GameCommand
## Manual harvest of several selected Ready plots (M02-T08, FRS §§7.1, 9.2). Each member names the
## exact cycle. All successful credits precede this command's own replant spending (E8).

const MAX_MEMBERS: int = 32

var _members: Array[HarvestCropCommand] = []


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_members: Array[HarvestCropCommand]) -> void:
	super(p_command_id, GameCommand.TYPE_BATCH_HARVEST, p_accepted_time_us, p_accepted_order)
	_members = p_members.duplicate()


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> BatchHarvestCommand:
	var reader: PrimitiveReader = PrimitiveReader.new(args, "BatchHarvest.args")
	reader.expect_only(PackedStringArray(["members"]))
	var members: Array[HarvestCropCommand] = []
	for item: Variant in reader.array_field("members"):
		var member: HarvestCropCommand = HarvestCropCommand.from_args(id, time_us, order, item) if item is Dictionary else null
		if member == null:
			return null
		members.append(member)
	return BatchHarvestCommand.new(id, time_us, order, members) if reader.ok() else null


func members() -> Array[HarvestCropCommand]:
	var ordered: Array[HarvestCropCommand] = _members.duplicate()
	ordered.sort_custom(func(a: HarvestCropCommand, b: HarvestCropCommand) -> bool: return a.plot_id() < b.plot_id())
	return ordered


func _args_valid() -> bool:
	return GameCommand.unique_member_plots(_members, MAX_MEMBERS) and _members.all(func(m: HarvestCropCommand) -> bool: return m._args_valid())


func _args_primitive() -> Dictionary:
	var items: Array = []
	for member: HarvestCropCommand in _members:
		items.append(member._args_primitive())
	return {"members": items}
