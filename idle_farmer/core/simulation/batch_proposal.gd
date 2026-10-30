class_name BatchProposal
extends RefCounted
## Immutable-by-convention result of BatchPlanner.plan (M02 E4, build plan §3.5): every value the
## applier needs, pre-validated with checked arithmetic, in application order. A proposal with a
## failure_code must not be applied (E5).

var failure_code: String = FailureCode.NONE
## [{plot_id, origin}] in ascending plot ID: phases 2b–4 (credits before any spending).
var harvests: Array[Dictionary] = []
## [{plot_id, quote: PlantingQuote, origin, fallback_used}] in allocation order: phases 6–8.
var plantings: Array[Dictionary] = []
## plot_id → stall reason for requests that could not be planted (or loops that cannot run).
var stalls: Dictionary[int, String] = {}
## Allocation summary {S, A, F, M, C, passes, exclusions, wallet}; empty when nothing was requested.
var allocation: Dictionary = {}


func is_empty() -> bool:
	return harvests.is_empty() and plantings.is_empty() and stalls.is_empty()


static func failed(code: String) -> BatchProposal:
	var proposal: BatchProposal = BatchProposal.new()
	proposal.failure_code = code
	return proposal
