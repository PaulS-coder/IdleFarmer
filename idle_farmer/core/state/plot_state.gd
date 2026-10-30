class_name PlotState
extends RefCounted
## One of the 32 fixed plots (TRS §3.3, DEC-020). Coordinates derive from the ID on a fixed
## eight-column row-major map and never change. Locked plots hold no cycle; unlocked plots hold
## zero or one active cycle. Runtime fields only (M02 E10): farming settings and loop authorization
## live in AutomationState; `stall_reason` records why an automated request last failed.

const PLOT_COUNT: int = 32
const COLUMNS: int = 8
const INITIAL_UNLOCKED: int = 24

const STALL_NONE: String = "none"
const STALL_SEED_FUNDS: String = "seed_funds"
const STALL_FERTILIZER_FUNDS: String = "fertilizer_funds"
const STALL_CAPABILITY: String = "capability"
const STALL_UNARMED: String = "unarmed"
const STALL_INELIGIBLE: String = "ineligible"
const STALL_REASONS: PackedStringArray = [STALL_NONE, STALL_SEED_FUNDS, STALL_FERTILIZER_FUNDS, STALL_CAPABILITY,
	STALL_UNARMED, STALL_INELIGIBLE]

var plot_id: int = 0
var unlocked: bool = false
var crop_cycle: CropCycle = null
var stall_reason: String = STALL_NONE


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
	if not STALL_REASONS.has(stall_reason) or (crop_cycle != null and stall_reason != STALL_NONE):
		errors.append("PLOT_STALL_REASON_INVALID: plot %d '%s'" % [plot_id, stall_reason])
	return errors


func to_primitive() -> Dictionary:
	return {
		"plot_id": plot_id,
		"unlocked": unlocked,
		"crop_cycle": null if crop_cycle == null else crop_cycle.to_primitive(),
		"stall_reason": stall_reason,
	}


static func from_primitive(value: Variant) -> PlotState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "PlotState")
	reader.expect_only(PackedStringArray(["plot_id", "unlocked", "crop_cycle", "stall_reason"]))
	var plot: PlotState = PlotState.new()
	plot.plot_id = reader.int_field("plot_id")
	plot.unlocked = reader.bool_field("unlocked")
	var cycle_value: Variant = reader.nullable_field("crop_cycle")
	if cycle_value != null:
		plot.crop_cycle = CropCycle.from_primitive(cycle_value)
		if plot.crop_cycle == null:
			reader.absorb(PackedStringArray(["PlotState: malformed crop_cycle"]))
	plot.stall_reason = reader.string_field("stall_reason")
	return plot if reader.ok() else null
