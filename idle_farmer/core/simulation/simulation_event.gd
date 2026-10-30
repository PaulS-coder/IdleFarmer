class_name SimulationEvent
extends RefCounted
## An authoritative outcome emitted by the engine (planted, matured, harvested, level gained).
## Presentation notifications are derived from these after commit; they are never authoritative.

const CROP_PLANTED: String = "CropPlanted"
const CROP_MATURED: String = "CropMatured"
const CROP_HARVESTED: String = "CropHarvested"
const LEVEL_GAINED: String = "LevelGained"
const RESEARCH_COMPLETED: String = "ResearchCompleted"

var type: String
var time_us: int
var plot_id: int
var cycle_id: EntityId
## Event-specific primitive data, e.g. {"crop_id": "wheat"} or {"from_level": 1, "to_level": 3}.
var data: Dictionary


func _init(p_type: String, p_time_us: int, p_plot_id: int, p_cycle_id: EntityId, p_data: Dictionary = {}) -> void:
	type = p_type
	time_us = p_time_us
	plot_id = p_plot_id
	cycle_id = p_cycle_id
	data = p_data.duplicate(true)


func to_primitive() -> Dictionary:
	return {
		"type": type,
		"time_us": time_us,
		"plot_id": plot_id,
		"cycle_id": EntityId.nullable_to_primitive(cycle_id),
		"data": PrimitiveReader.plain(data),
	}


static func from_primitive(value: Variant) -> SimulationEvent:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "SimulationEvent")
	reader.expect_only(PackedStringArray(["type", "time_us", "plot_id", "cycle_id", "data"]))
	var cycle_value: Variant = reader.nullable_field("cycle_id")
	var cycle: EntityId = null if cycle_value == null else EntityId.from_primitive(cycle_value)
	var event: SimulationEvent = SimulationEvent.new(reader.string_field("type"), reader.int_field("time_us"),
		reader.int_field("plot_id"), cycle, reader.dict_field("data"))
	if not reader.ok() or (cycle_value != null and cycle == null):
		return null
	return event
