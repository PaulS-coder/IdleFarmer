class_name CommandReplayer
extends RefCounted
## Deterministic replay of an accepted-command log (M01-T14, AUD-004): starting from a recorded
## initial state, advance the same engine to each recorded accepted time, execute the recorded
## immutable envelope (never restamped), then advance to the final time. Used for mode-equivalence
## and recovery comparison; the result must match the original run's gameplay state exactly.


## Returns {"ok": bool, "state": GameState or null, "errors": PackedStringArray}.
static func replay(initial: GameState, catalog: ManifestCatalog, log: Array[Dictionary], final_time_us: int) -> Dictionary:
	var errors: PackedStringArray = PackedStringArray()
	var working: GameState = initial.clone()
	var engine: SimulationEngine = SimulationEngine.new()
	errors.append_array(engine.initialize(working, catalog))
	if not errors.is_empty():
		return {"ok": false, "state": null, "errors": errors}
	for i: int in log.size():
		var command: GameCommand = GameCommand.from_primitive(log[i])
		if command == null:
			errors.append("REPLAY_RECORD_MALFORMED: entry %d" % i)
			break
		var due: StateChangeBatch = engine.advance_to(command.accepted_time_us())
		if due.failure_code != FailureCode.NONE:
			errors.append("REPLAY_TIME_REGRESSION: entry %d at %d" % [i, command.accepted_time_us()])
			break
		var result: CommandResult = engine.submit_command(command)
		if not result.success:
			errors.append("REPLAY_DIVERGED: entry %d failed with %s" % [i, result.failure_code])
			break
	if errors.is_empty():
		var tail: StateChangeBatch = engine.advance_to(final_time_us)
		if tail.failure_code != FailureCode.NONE:
			errors.append("REPLAY_TIME_REGRESSION: final time %d" % final_time_us)
	return {"ok": errors.is_empty(), "state": working if errors.is_empty() else null, "errors": errors}
