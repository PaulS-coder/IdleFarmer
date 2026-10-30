class_name CropCycle
extends RefCounted
## One planted crop cycle with its immutable economic snapshot (TRS §3.4, FRS §4.1).
## Everything that decides the payout is recorded at planting; later upgrades, resets or content
## changes never alter it. Harvest terminates the cycle and removes it from its plot.

const STATUS_GROWING: String = "growing"
const STATUS_READY: String = "ready"

const STAGE_COUNT: int = 5
const STAGE_READY: int = 4

var cycle_id: EntityId
var plot_id: int = 0
var crop_id: String = ""
var status: String = STATUS_GROWING
var planted_at_us: int = 0
var matures_at_us: int = 0
var effective_growth_us: int = 0
var seed_cost_paid: int = 0
var fertilizer_id: String = ""
var fertilizer_cost_paid: int = 0
var gross_coin_reward: int = 0
var xp_reward: int = 0
## Applied modifier results at planting, e.g. {"growth_reduction_bp": 0, "coin_bonus_bp": 0}.
var modifier_snapshot: Dictionary[String, int] = {}
var content_version: String = ""
var planting_transaction_id: EntityId
## Insertion sequence of this cycle's maturity event, so a rebuilt queue reproduces exact keys (B2).
var maturity_insertion_seq: int = 0


## Derived visual stage (build plan P8): 0..3 while growing, 4 when elapsed ≥ growth. Never stored.
func stage_at(time_us: int) -> int:
	var elapsed: int = time_us - planted_at_us
	if elapsed >= effective_growth_us:
		return STAGE_READY
	if elapsed <= 0:
		return 0
	return mini(3, IntegerMath.mul_div_floor(elapsed, 4, effective_growth_us).value)


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	var label: String = "cycle on plot %d" % plot_id
	if cycle_id == null or not cycle_id.is_valid():
		errors.append("CYCLE_ID_INVALID: %s" % label)
	if planting_transaction_id == null or not planting_transaction_id.is_valid():
		errors.append("CYCLE_TRANSACTION_ID_INVALID: %s" % label)
	if status != STATUS_GROWING and status != STATUS_READY:
		errors.append("CYCLE_STATUS_INVALID: %s has '%s'" % [label, status])
	if effective_growth_us <= 0:
		errors.append("CYCLE_DURATION_NONPOSITIVE: %s" % label)
	var maturity: MathResult = IntegerMath.add(planted_at_us, effective_growth_us)
	if planted_at_us < 0 or not maturity.ok or maturity.value != matures_at_us:
		errors.append("CYCLE_MATURITY_MISMATCH: %s" % label)
	if seed_cost_paid < 0 or fertilizer_cost_paid < 0 or gross_coin_reward < 0 or xp_reward < 0:
		errors.append("CYCLE_NEGATIVE_VALUE: %s" % label)
	if content_version.is_empty():
		errors.append("CYCLE_CONTENT_VERSION_EMPTY: %s" % label)
	if maturity_insertion_seq < 1:
		errors.append("CYCLE_INSERTION_SEQ_INVALID: %s" % label)
	return errors


func to_primitive() -> Dictionary:
	return {
		"cycle_id": EntityId.nullable_to_primitive(cycle_id),
		"plot_id": plot_id,
		"crop_id": crop_id,
		"status": status,
		"planted_at_us": planted_at_us,
		"matures_at_us": matures_at_us,
		"effective_growth_us": effective_growth_us,
		"seed_cost_paid": seed_cost_paid,
		"fertilizer_id": fertilizer_id,
		"fertilizer_cost_paid": fertilizer_cost_paid,
		"gross_coin_reward": gross_coin_reward,
		"xp_reward": xp_reward,
		"modifier_snapshot": PrimitiveReader.plain(modifier_snapshot),
		"content_version": content_version,
		"planting_transaction_id": EntityId.nullable_to_primitive(planting_transaction_id),
		"maturity_insertion_seq": maturity_insertion_seq,
	}


static func from_primitive(value: Variant) -> CropCycle:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "CropCycle")
	reader.expect_only(PackedStringArray([
		"cycle_id", "plot_id", "crop_id", "status", "planted_at_us", "matures_at_us", "effective_growth_us",
		"seed_cost_paid", "fertilizer_id", "fertilizer_cost_paid", "gross_coin_reward", "xp_reward",
		"modifier_snapshot", "content_version", "planting_transaction_id", "maturity_insertion_seq",
	]))
	var cycle: CropCycle = CropCycle.new()
	cycle.cycle_id = EntityId.from_primitive(reader.dict_field("cycle_id"))
	cycle.plot_id = reader.int_field("plot_id")
	cycle.crop_id = reader.string_field("crop_id")
	cycle.status = reader.string_field("status")
	cycle.planted_at_us = reader.int_field("planted_at_us")
	cycle.matures_at_us = reader.int_field("matures_at_us")
	cycle.effective_growth_us = reader.int_field("effective_growth_us")
	cycle.seed_cost_paid = reader.int_field("seed_cost_paid")
	cycle.fertilizer_id = reader.string_field("fertilizer_id")
	cycle.fertilizer_cost_paid = reader.int_field("fertilizer_cost_paid")
	cycle.gross_coin_reward = reader.int_field("gross_coin_reward")
	cycle.xp_reward = reader.int_field("xp_reward")
	cycle.modifier_snapshot = reader.int_map_field("modifier_snapshot")
	cycle.content_version = reader.string_field("content_version")
	cycle.planting_transaction_id = EntityId.from_primitive(reader.dict_field("planting_transaction_id"))
	cycle.maturity_insertion_seq = reader.int_field("maturity_insertion_seq")
	if not reader.ok() or cycle.cycle_id == null or cycle.planting_transaction_id == null:
		return null
	return cycle
