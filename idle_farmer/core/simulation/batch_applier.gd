class_name BatchApplier
extends RefCounted
## Applies a BatchProposal in proposal order (M02 E4, build plan §3.5): harvest credits first, then
## stall reasons, then plantings with their snapshots and maturity events. Every value was
## pre-validated by the planner, so application cannot fail.


static func apply(state: GameState, registry: ContentRegistry, scheduler: EventScheduler, proposal: BatchProposal) -> StateChangeBatch:
	var batch: StateChangeBatch = StateChangeBatch.new()
	batch.time_us = state.simulation_time_us
	for harvest: Dictionary in proposal.harvests:
		batch.append(FarmSystem.harvest_ready_cycle(state, registry, harvest["plot_id"], harvest["origin"]))
	for plot_id: int in proposal.stalls:
		var plot: PlotState = state.plot(plot_id)
		var reason: String = proposal.stalls[plot_id]
		if plot.stall_reason != reason:
			plot.stall_reason = reason
			if reason != PlotState.STALL_NONE:
				batch.events.append(SimulationEvent.new(SimulationEvent.PLOT_STALLED, state.simulation_time_us, plot_id, null,
					{"reason": reason}))
	for planting: Dictionary in proposal.plantings:
		var quote: PlantingQuote = planting["quote"]
		batch.append(FarmSystem.apply_planting(state, scheduler, planting["plot_id"], quote, planting["origin"],
			planting["fallback_used"]))
	return batch
