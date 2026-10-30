class_name ResearchState
extends RefCounted
## Research progress (FRS §8, DEC-007, M02 E18 / build plan §3.8). Wheat is a start unlock and is
## never listed. The active run is held as flat `active_*` fields (E18 keeps the M01 primitive keys
## and adds the run identity, original duration and scheduler insertion sequence). `active_paid_cost`
## and `active_original_duration_us` are snapshots taken at start: later content never reprices them,
## and `boost_used` survives save/reload until the run completes.

var completed: PackedStringArray = PackedStringArray()
var active_project_id: String = ""
var active_run_id: EntityId = null
var active_paid_cost: int = 0
var active_started_us: int = 0
var active_original_duration_us: int = 0
var active_completes_us: int = 0
var active_insertion_seq: int = 0
var boost_used: bool = false


func is_active() -> bool:
	return not active_project_id.is_empty()


## Clears the active run (completion). Completed projects are kept.
func clear_active() -> void:
	active_project_id = ""
	active_run_id = null
	active_paid_cost = 0
	active_started_us = 0
	active_original_duration_us = 0
	active_completes_us = 0
	active_insertion_seq = 0
	boost_used = false


## Record-local invariants; references to content, IDs and time are checked by GameState.
func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if active_paid_cost < 0 or active_started_us < 0 or active_completes_us < 0 or active_original_duration_us < 0 \
			or active_insertion_seq < 0:
		errors.append("RESEARCH_STATE_NEGATIVE: research fields must be nonnegative")
	if not is_active():
		if active_run_id != null or active_paid_cost != 0 or active_started_us != 0 or active_original_duration_us != 0 \
				or active_completes_us != 0 or active_insertion_seq != 0 or boost_used:
			errors.append("RESEARCH_STATE_INCONSISTENT: inactive research carries active fields")
	else:
		if active_run_id == null or not active_run_id.is_valid():
			errors.append("RESEARCH_RUN_ID_MISSING: active research needs a run identity")
		if active_original_duration_us < 1 or active_insertion_seq < 1:
			errors.append("RESEARCH_STATE_INCONSISTENT: active research needs a duration and an insertion sequence")
		var unboosted_end: MathResult = IntegerMath.add(active_started_us, active_original_duration_us)
		if not unboosted_end.ok:
			errors.append("RESEARCH_TIMING_INVALID: start plus duration overflows")
		elif boost_used and active_completes_us >= unboosted_end.value:
			errors.append("RESEARCH_TIMING_INVALID: a boosted run must finish before its original end")
		elif not boost_used and active_completes_us != unboosted_end.value:
			errors.append("RESEARCH_TIMING_INVALID: an unboosted run finishes at start + original duration")
		if active_completes_us <= active_started_us:
			errors.append("RESEARCH_TIMING_INVALID: completion must follow the start")
		if completed.has(active_project_id):
			errors.append("RESEARCH_ACTIVE_COMPLETED: '%s' is both active and completed" % active_project_id)
	var sorted: PackedStringArray = completed.duplicate()
	sorted.sort()
	if sorted != completed:
		errors.append("RESEARCH_COMPLETED_UNSORTED: completed IDs must be sorted")
	for i: int in range(1, completed.size()):
		if completed[i] == completed[i - 1]:
			errors.append("RESEARCH_COMPLETED_DUPLICATE: '%s'" % completed[i])
	return errors


func to_primitive() -> Dictionary:
	return {
		"completed": Array(completed),
		"active_project_id": active_project_id,
		"active_run_id": EntityId.nullable_to_primitive(active_run_id),
		"active_paid_cost": active_paid_cost,
		"active_started_us": active_started_us,
		"active_original_duration_us": active_original_duration_us,
		"active_completes_us": active_completes_us,
		"active_insertion_seq": active_insertion_seq,
		"boost_used": boost_used,
	}


static func from_primitive(value: Variant) -> ResearchState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "Research")
	reader.expect_only(PackedStringArray(["completed", "active_project_id", "active_run_id", "active_paid_cost",
		"active_started_us", "active_original_duration_us", "active_completes_us", "active_insertion_seq", "boost_used"]))
	var record: ResearchState = ResearchState.new()
	record.completed = reader.string_array_field("completed")
	record.active_project_id = reader.string_field("active_project_id")
	var run_value: Variant = reader.nullable_field("active_run_id")
	record.active_run_id = null if run_value == null else EntityId.from_primitive(run_value)
	record.active_paid_cost = reader.int_field("active_paid_cost")
	record.active_started_us = reader.int_field("active_started_us")
	record.active_original_duration_us = reader.int_field("active_original_duration_us")
	record.active_completes_us = reader.int_field("active_completes_us")
	record.active_insertion_seq = reader.int_field("active_insertion_seq")
	record.boost_used = reader.bool_field("boost_used")
	if not reader.ok() or (run_value != null and record.active_run_id == null):
		return null
	return record
