class_name PlantCropCommand
extends GameCommand
## Manual planting on one plot (FR-FARM-03–05). Carries the confirmed semantic terms the player
## saw (AUD-004 / TRS §20.4): crop, fertilizer, bound manifest, exact seed and fertilizer costs and
## snapshotted growth/reward.
## Execution recomputes these terms and rejects with STALE_TERMS if any differ — never a substitute.

var _plot_id: int
var _crop_id: String
var _manifest_id: String
var _seed_cost: int
var _growth_us: int
var _gross_coins: int
var _xp: int
var _fertilizer_id: String
var _fertilizer_cost: int


func _init(p_command_id: CommandId, p_accepted_time_us: int, p_accepted_order: int, p_plot_id: int, p_crop_id: String,
		p_manifest_id: String, p_seed_cost: int, p_growth_us: int, p_gross_coins: int, p_xp: int,
		p_fertilizer_id: String = FertilizerDefinition.NONE_ID, p_fertilizer_cost: int = 0) -> void:
	super(p_command_id, GameCommand.TYPE_PLANT_CROP, p_accepted_time_us, p_accepted_order)
	_plot_id = p_plot_id
	_crop_id = p_crop_id
	_manifest_id = p_manifest_id
	_seed_cost = p_seed_cost
	_growth_us = p_growth_us
	_gross_coins = p_gross_coins
	_xp = p_xp
	_fertilizer_id = p_fertilizer_id
	_fertilizer_cost = p_fertilizer_cost


func plot_id() -> int:
	return _plot_id


func crop_id() -> String:
	return _crop_id


func manifest_id() -> String:
	return _manifest_id


func seed_cost() -> int:
	return _seed_cost


func growth_us() -> int:
	return _growth_us


func gross_coins() -> int:
	return _gross_coins


func xp() -> int:
	return _xp


func fertilizer_id() -> String:
	return _fertilizer_id


func fertilizer_cost() -> int:
	return _fertilizer_cost


static func from_args(id: CommandId, time_us: int, order: int, args: Dictionary) -> PlantCropCommand:
	var reader: PrimitiveReader = PrimitiveReader.new(args, "PlantCrop.args")
	reader.expect_only(PackedStringArray(["plot_id", "crop_id", "manifest_id", "seed_cost", "growth_us", "gross_coins", "xp",
		"fertilizer_id", "fertilizer_cost"]))
	var command: PlantCropCommand = PlantCropCommand.new(id, time_us, order, reader.int_field("plot_id"), reader.string_field("crop_id"),
		reader.string_field("manifest_id"), reader.int_field("seed_cost"), reader.int_field("growth_us"),
		reader.int_field("gross_coins"), reader.int_field("xp"), reader.string_field("fertilizer_id"),
		reader.int_field("fertilizer_cost"))
	return command if reader.ok() else null


func _args_valid() -> bool:
	return not _crop_id.is_empty() and not _manifest_id.is_empty() and _seed_cost >= 0 and _growth_us > 0 \
		and _gross_coins >= 0 and _xp >= 0 and not _fertilizer_id.is_empty() and _fertilizer_cost >= 0


func _args_primitive() -> Dictionary:
	return {
		"plot_id": _plot_id,
		"crop_id": _crop_id,
		"manifest_id": _manifest_id,
		"seed_cost": _seed_cost,
		"growth_us": _growth_us,
		"gross_coins": _gross_coins,
		"xp": _xp,
		"fertilizer_id": _fertilizer_id,
		"fertilizer_cost": _fertilizer_cost,
	}
