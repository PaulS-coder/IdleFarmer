class_name HarvestCropCommand
extends GameCommand
## Manual harvest of one plot's current cycle. The confirmed term is the exact cycle identity, so a
## stale command can never harvest a later cycle on the same plot or repay a terminated one (T-020).

var _plot_id: int
var _cycle_id: EntityId


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_plot_id: int, p_cycle_id: EntityId) -> void:
	super(p_command_id, GameCommand.TYPE_HARVEST_CROP, p_accepted_time_us, p_accepted_order)
	_plot_id = p_plot_id
	_cycle_id = p_cycle_id


func plot_id() -> int:
	return _plot_id


func cycle_id() -> EntityId:
	return null if _cycle_id == null else EntityId.new(_cycle_id.save_id, _cycle_id.allocation_namespace, _cycle_id.counter)


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> HarvestCropCommand:
	var reader: PrimitiveReader = PrimitiveReader.new(args, "HarvestCrop.args")
	reader.expect_only(PackedStringArray(["plot_id", "cycle_id"]))
	var plot: int = reader.int_field("plot_id")
	var cycle: EntityId = EntityId.from_primitive(reader.dict_field("cycle_id"))
	if not reader.ok() or cycle == null:
		return null
	return HarvestCropCommand.new(id, time_us, order, plot, cycle)


func _args_valid() -> bool:
	return _cycle_id != null and _cycle_id.is_valid()


func _args_primitive() -> Dictionary:
	return {"plot_id": _plot_id, "cycle_id": EntityId.nullable_to_primitive(_cycle_id)}
