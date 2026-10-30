class_name PlotState
extends RefCounted
## One of the 32 fixed plots (TRS §3.3, DEC-020). Coordinates derive from the ID on a fixed
## eight-column row-major map and never change. Locked plots hold no cycle; unlocked plots hold
## zero or one active cycle. `selected_crop_id` is configuration, separate from the current cycle.

const PLOT_COUNT: int = 32
const COLUMNS: int = 8
const INITIAL_UNLOCKED: int = 24

const BLOCKED_NONE: String = "none"

var plot_id: int = 0
var unlocked: bool = false
var crop_cycle: CropCycle = null
var selected_crop_id: String = ""
var auto_harvest: bool = false
var auto_replant: bool = false
## "" means no group (nullable group reference, §20.7; groups are M05).
var group_id: String = ""
var spending_priority: int = 0
var blocked_reason: String = BLOCKED_NONE


static func row_of(id: int) -> int:
	return 1 + (id - 1) / COLUMNS


static func column_of(id: int) -> int:
	return 1 + (id - 1) % COLUMNS


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if plot_id < 1 or plot_id > PLOT_COUNT:
		errors.append("PLOT_ID_RANGE: %d" % plot_id)
	if not unlocked and crop_cycle != null:
		errors.append("PLOT_LOCKED_HAS_CYCLE: plot %d" % plot_id)
	if crop_cycle != null:
		if crop_cycle.plot_id != plot_id:
			errors.append("CYCLE_PLOT_MISMATCH: plot %d holds cycle for plot %d" % [plot_id, crop_cycle.plot_id])
		errors.append_array(crop_cycle.validate())
	return errors


func to_primitive() -> Dictionary:
	return {
		"plot_id": plot_id,
		"unlocked": unlocked,
		"crop_cycle": null if crop_cycle == null else crop_cycle.to_primitive(),
		"selected_crop_id": selected_crop_id,
		"auto_harvest": auto_harvest,
		"auto_replant": auto_replant,
		"group_id": group_id,
		"spending_priority": spending_priority,
		"blocked_reason": blocked_reason,
	}


static func from_primitive(value: Variant) -> PlotState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "PlotState")
	reader.expect_only(PackedStringArray([
		"plot_id", "unlocked", "crop_cycle", "selected_crop_id", "auto_harvest", "auto_replant",
		"group_id", "spending_priority", "blocked_reason",
	]))
	var plot: PlotState = PlotState.new()
	plot.plot_id = reader.int_field("plot_id")
	plot.unlocked = reader.bool_field("unlocked")
	var cycle_value: Variant = reader.nullable_field("crop_cycle")
	if cycle_value != null:
		plot.crop_cycle = CropCycle.from_primitive(cycle_value)
		if plot.crop_cycle == null:
			reader.absorb(PackedStringArray(["PlotState: malformed crop_cycle"]))
	plot.selected_crop_id = reader.string_field("selected_crop_id")
	plot.auto_harvest = reader.bool_field("auto_harvest")
	plot.auto_replant = reader.bool_field("auto_replant")
	plot.group_id = reader.string_field("group_id")
	plot.spending_priority = reader.int_field("spending_priority")
	plot.blocked_reason = reader.string_field("blocked_reason")
	return plot if reader.ok() else null
