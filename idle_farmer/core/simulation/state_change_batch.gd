class_name StateChangeBatch
extends RefCounted
## Outcome of one logical batch (due events at one timestamp, or one accepted command): the
## authoritative events and transactions it produced. Applied atomically by the engine; published
## to presentation only after the controller's commit (TRS §4.2 phases 8–9).

var time_us: int = 0
var events: Array[SimulationEvent] = []
var transactions: Array[EconomicTransaction] = []
## Set when a genuine numeric limit stopped the batch; no part of it was applied (DEC-026).
var failure_code: String = FailureCode.NONE


func changed() -> bool:
	return not events.is_empty() or not transactions.is_empty()


## Merges `other` into this batch. The first failure is kept: a failed batch stays failed (DEC-026).
func append(other: StateChangeBatch) -> void:
	if failure_code == FailureCode.NONE:
		failure_code = other.failure_code
	events.append_array(other.events)
	transactions.append_array(other.transactions)
	time_us = maxi(time_us, other.time_us)
