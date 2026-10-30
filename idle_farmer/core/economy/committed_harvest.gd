class_name CommittedHarvest
extends RefCounted
## One durably committed harvest, as published through the committed-harvest port (M02-T16,
## build plan §3.9; carry-over 1). Immutable value object: observers can read it but cannot reach
## or change GameState. Deterministic order is (time_us, state_sequence, ordinal); quantity is one
## harvested cycle. Gross is the crop payout only; contract claims are never harvest gross (C2).

var _time_us: int
var _state_sequence: int
var _ordinal: int
var _cycle_id: EntityId
var _plot_id: int
var _crop_id: String
var _gross: int
var _xp: int
var _origin: String
var _seed_cost: int
var _fertilizer_cost: int
var _fertilizer_id: String


func _init(p_time_us: int, p_state_sequence: int, p_ordinal: int, p_cycle_id: EntityId, p_plot_id: int, p_crop_id: String,
		p_gross: int, p_xp: int, p_origin: String, p_seed_cost: int, p_fertilizer_id: String, p_fertilizer_cost: int) -> void:
	_time_us = p_time_us
	_state_sequence = p_state_sequence
	_ordinal = p_ordinal
	_cycle_id = EntityId.new(p_cycle_id.save_id, p_cycle_id.allocation_namespace, p_cycle_id.counter)
	_plot_id = p_plot_id
	_crop_id = p_crop_id
	_gross = p_gross
	_xp = p_xp
	_origin = p_origin
	_seed_cost = p_seed_cost
	_fertilizer_id = p_fertilizer_id
	_fertilizer_cost = p_fertilizer_cost


## Record for a committed CropHarvested event; null for any other event.
static func from_event(event: SimulationEvent, state_sequence: int, ordinal: int) -> CommittedHarvest:
	if event.type != SimulationEvent.CROP_HARVESTED or event.cycle_id == null:
		return null
	var data: Dictionary = event.data
	return CommittedHarvest.new(event.time_us, state_sequence, ordinal, event.cycle_id, event.plot_id, data["crop_id"],
		data["coins"], data["xp"], data["origin"], data["seed_cost"], data["fertilizer_id"], data["fertilizer_cost"])


func time_us() -> int:
	return _time_us


func state_sequence() -> int:
	return _state_sequence


func ordinal() -> int:
	return _ordinal


func cycle_id() -> EntityId:
	return EntityId.new(_cycle_id.save_id, _cycle_id.allocation_namespace, _cycle_id.counter)


func plot_id() -> int:
	return _plot_id


func crop_id() -> String:
	return _crop_id


func quantity() -> int:
	return 1


func gross() -> int:
	return _gross


func xp() -> int:
	return _xp


func origin() -> String:
	return _origin


func seed_cost() -> int:
	return _seed_cost


func fertilizer_id() -> String:
	return _fertilizer_id


func fertilizer_cost() -> int:
	return _fertilizer_cost


## Completed-cycle operating profit: gross − this cycle's own seed and fertilizer costs (TRS §10).
func operating_profit() -> int:
	return _gross - _seed_cost - _fertilizer_cost


func to_primitive() -> Dictionary:
	return {
		"time_us": _time_us, "state_sequence": _state_sequence, "ordinal": _ordinal, "cycle_id": _cycle_id.to_primitive(),
		"plot_id": _plot_id, "crop_id": _crop_id, "quantity": 1, "gross": _gross, "xp": _xp, "origin": _origin,
		"seed_cost": _seed_cost, "fertilizer_id": _fertilizer_id, "fertilizer_cost": _fertilizer_cost,
	}
