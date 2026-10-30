class_name ScheduledEvent
extends RefCounted
## A queued future event. Ordered by the numeric tuple
## (time_us, phase, priority, entity_order, insertion_seq) — TRS §4.2, AUD-001 — compared as ints,
## never by UUID or string. `target_id` guards references; it never affects ordering.

const TYPE_CROP_MATURED: String = "CropMatured"
const TYPE_RESEARCH_COMPLETED: String = "ResearchCompleted"

var time_us: int
var phase: int
var priority: int
var entity_order: int
var insertion_seq: int
var type: String
var plot_id: int
var target_id: EntityId


func _init(p_time_us: int, p_phase: int, p_priority: int, p_entity_order: int, p_insertion_seq: int,
		p_type: String, p_plot_id: int, p_target_id: EntityId) -> void:
	time_us = p_time_us
	phase = p_phase
	priority = p_priority
	entity_order = p_entity_order
	insertion_seq = p_insertion_seq
	type = p_type
	plot_id = p_plot_id
	target_id = p_target_id


## Maturity event for a growing cycle; its key is fully determined by the cycle snapshot (B2).
static func for_maturity(cycle: CropCycle) -> ScheduledEvent:
	return ScheduledEvent.new(cycle.matures_at_us, EventPhase.MATURITY_AND_AUTO_HARVEST, EventPhase.DEFAULT_PRIORITY,
		cycle.cycle_id.counter, cycle.maturity_insertion_seq, TYPE_CROP_MATURED, cycle.plot_id, cycle.cycle_id)


func key() -> Array[int]:
	return [time_us, phase, priority, entity_order, insertion_seq]


func precedes(other: ScheduledEvent) -> bool:
	if time_us != other.time_us:
		return time_us < other.time_us
	if phase != other.phase:
		return phase < other.phase
	if priority != other.priority:
		return priority < other.priority
	if entity_order != other.entity_order:
		return entity_order < other.entity_order
	return insertion_seq < other.insertion_seq
