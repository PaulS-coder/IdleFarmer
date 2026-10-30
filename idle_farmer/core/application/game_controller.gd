class_name GameController
extends RefCounted
## In-memory application controller (build plan I2; TRS §§2, 4.1, 20.1–20.4). It owns ordering
## and the commit boundary, never gameplay rules:
##
## - Every operation runs the engine on a clone of the committed state; the clone becomes
##   committed only when the CommitSink answers COMMITTED (build plan B4).
## - Due work at the current time runs before an intent is stamped; the controller issues the
##   command counter and accepted order, so rejected input never changes GameState (B5).
## - Commit identities come from a separate attempt counter, never from `next_entity_id` (B3).
## - UNKNOWN blocks all further writes and input until `reconcile()` settles it by read-back;
##   NOT_COMMITTED discards the candidate. Events are published only after a commit.
## - A repeated pending intent returns its recorded result instead of executing again (AV-004-05).

const INTENT_CACHE_CAPACITY: int = 1024

const STATUS_NOT_STARTED: String = "NOT_STARTED"
const STATUS_INVALID: String = "INVALID"
const STATUS_BLOCKED: String = "BLOCKED"
const STATUS_NUMERIC_LIMIT: String = "NUMERIC_LIMIT"

var _catalog: ManifestCatalog
var _sink: CommitSink
var _committed: GameState = null
var _speed: int = SimulationClock.MIN_SPEED
var _issue_counter: int = 0
var _commit_counter: int = 0
var _accepted_order: int = 0
var _intent_results: Dictionary[String, Dictionary] = {}
var _intent_order: Array[String] = []
var _accepted_log: Array[Dictionary] = []
## Set while a commit outcome is UNKNOWN: {"prepared", "events", "intent_id", "result", "command"}.
var _pending: Dictionary = {}
var _listeners: Array[Callable] = []


func _init(catalog: ManifestCatalog, sink: CommitSink) -> void:
	_catalog = catalog
	_sink = sink


## Owned-profile startup: validates `state` against its bound manifest, establishes the injected
## writer epoch (retiring the previous one) as the allocation namespace and commits a startup
## checkpoint before any input. Returns errors; an UNKNOWN startup leaves the controller blocked.
func start(state: GameState, writer_epoch: String) -> PackedStringArray:
	if writer_epoch.is_empty():
		return PackedStringArray(["EPOCH_EMPTY: a writer epoch must be injected"])
	if state == null:
		return PackedStringArray(["STATE_MISSING: no state supplied"])
	var parent: GameState = state.clone()
	var working: GameState = state.clone()
	if parent == null or working == null:
		return PackedStringArray(["STATE_MALFORMED: state does not round-trip"])
	var engine: SimulationEngine = SimulationEngine.new()
	var errors: PackedStringArray = engine.initialize(working, _catalog)
	if not errors.is_empty():
		return errors
	if working.command_replay.current_epoch != writer_epoch:
		working.command_replay.start_epoch(writer_epoch)
	working.allocation_namespace = writer_epoch
	_committed = parent
	_issue_counter = 0
	_commit_counter = 0
	_accepted_order = 0
	_speed = SimulationClock.MIN_SPEED
	var status: String = _commit(working, [], "", null, null)
	if status == CommitSink.NOT_COMMITTED or status == STATUS_INVALID:
		_committed = null
		return PackedStringArray(["STARTUP_NOT_COMMITTED: startup checkpoint was not written (%s)" % status])
	return PackedStringArray()


func is_started() -> bool:
	return _committed != null


func is_blocked() -> bool:
	return not _pending.is_empty()


func now_us() -> int:
	return _committed.simulation_time_us


## Deep copy of the last committed state.
func snapshot() -> GameState:
	return _committed.clone()


## Accepted command records in acceptance order (immutable replay log).
func accepted_log() -> Array[Dictionary]:
	return _accepted_log.duplicate(true)


func add_commit_listener(listener: Callable) -> void:
	_listeners.append(listener)


func set_speed_multiplier(speed: int) -> bool:
	if speed < SimulationClock.MIN_SPEED or speed > SimulationClock.MAX_SPEED:
		return false
	_speed = speed
	return true


func reset_speed() -> void:
	_speed = SimulationClock.MIN_SPEED


## Planting quote against committed state, for UI confirmation (same calculation as execution).
func quote_plant(crop_id: String) -> PlantingQuote:
	return FarmSystem.quote_for(_committed, _catalog.resolve(_committed.content_version), crop_id)


## Active foreground real time at the current debug speed.
func advance_active(real_us: int) -> String:
	return _advance(AccountedInterval.KIND_ACTIVE, real_us)


## Suspended real time inside a session (credited once, at 1×).
func advance_suspended(real_us: int) -> String:
	return _advance(AccountedInterval.KIND_SUSPENDED, real_us)


## Closed-application real time at restart (always 1×).
func advance_offline(real_us: int) -> String:
	return _advance(AccountedInterval.KIND_OFFLINE, real_us)


## Turns a raw intent into an accepted command at the current time after due work, executes it on
## a clone and commits. See class notes for UNKNOWN/NOT_COMMITTED handling.
func submit_intent(intent: RawIntent) -> CommandResult:
	if _intent_results.has(intent.intent_id):
		return CommandResult.from_primitive(_intent_results[intent.intent_id])
	if is_blocked() or not is_started():
		return CommandResult.failed(FailureCode.PERSISTENCE_UNAVAILABLE, "commit outcome unresolved", null, 0)
	var working: GameState = _committed.clone()
	var engine: SimulationEngine = SimulationEngine.new()
	var errors: PackedStringArray = engine.initialize(working, _catalog)
	if not errors.is_empty():
		push_error("GameController: committed state failed validation: %s" % str(errors))
		return CommandResult.failed(FailureCode.PERSISTENCE_UNAVAILABLE, "committed state invalid", null, working.state_sequence)
	var due: StateChangeBatch = engine.advance_to(working.simulation_time_us)
	var counter: MathResult = IntegerMath.add(_issue_counter, 1)
	var order: MathResult = IntegerMath.add(_accepted_order, 1)
	if not counter.ok or not order.ok:
		return CommandResult.failed(FailureCode.NUMERIC_LIMIT, "command counter exhausted", null, working.state_sequence)
	_issue_counter = counter.value
	_accepted_order = order.value
	var id: CommandId = CommandId.new(working.save_id, working.command_replay.current_epoch, _issue_counter)
	var command: GameCommand = intent.to_command(id, working.simulation_time_us, _accepted_order)
	if command == null:
		return CommandResult.failed(FailureCode.MALFORMED_ENVELOPE, "unknown intent type '%s'" % intent.type, id, working.state_sequence)
	var result: CommandResult = engine.submit_command(command)
	if not result.success:
		if due.changed():
			_commit(working, due.events, "", null, null)
		_remember_intent(intent.intent_id, result)
		return result
	var events: Array[SimulationEvent] = due.events.duplicate()
	events.append_array(result.events)
	var status: String = _commit(working, events, intent.intent_id, result, command)
	result.commit_status = status
	if status != CommitSink.COMMITTED:
		result.success = false
		result.failure_code = FailureCode.PERSISTENCE_UNAVAILABLE
		result.failure_detail = "commit %s" % status
	return result


## Settles an UNKNOWN commit by reading back the durable checkpoint. Returns COMMITTED when the
## pending commit is found (its outcome is adopted from the read-back state), NOT_COMMITTED when
## the parent is verifiably unchanged, or UNKNOWN when neither can be established (still blocked).
func reconcile() -> String:
	if not is_blocked():
		return CommitSink.COMMITTED
	var prepared: Dictionary = _pending["prepared"]
	var read: Dictionary = _sink.read_back()
	if read.is_empty():
		return CommitSink.UNKNOWN
	if read["durable_revision"] == prepared["new_revision"] and read["commit_id"] == prepared["commit_id"]:
		var settled: GameState = GameState.from_primitive(read["state"])
		var registry: ContentRegistry = _catalog.resolve(settled.content_version) if settled != null else null
		if settled == null or not settled.validate(registry).is_empty():
			return CommitSink.UNKNOWN
		_committed = settled
		var pending: Dictionary = _pending
		_pending = {}
		_on_committed(pending["events"], pending["intent_id"], pending["result"], pending["command"])
		return CommitSink.COMMITTED
	var parent_revision: int = prepared["expected_parent_revision"]
	if read["durable_revision"] == parent_revision and read["commit_id"] == _committed.last_commit_id:
		_pending = {}
		return CommitSink.NOT_COMMITTED
	return CommitSink.UNKNOWN


func _advance(kind: String, real_us: int) -> String:
	if not is_started():
		return STATUS_NOT_STARTED
	if is_blocked():
		return STATUS_BLOCKED
	var working: GameState = _committed.clone()
	var engine: SimulationEngine = SimulationEngine.new()
	if not engine.initialize(working, _catalog).is_empty():
		return STATUS_INVALID
	var clock: SimulationClock = SimulationClock.new(working.simulation_time_us)
	clock.set_speed_multiplier(_speed)
	var interval: AccountedInterval = null
	match kind:
		AccountedInterval.KIND_ACTIVE:
			interval = clock.advance_active(real_us)
		AccountedInterval.KIND_SUSPENDED:
			interval = clock.advance_suspended(real_us)
		AccountedInterval.KIND_OFFLINE:
			interval = clock.advance_offline(real_us)
	if interval == null:
		return STATUS_NUMERIC_LIMIT
	var batch: StateChangeBatch = engine.advance_to(clock.get_simulation_time_us())
	if not working.time_anchor.credit(interval):
		return STATUS_NUMERIC_LIMIT
	return _commit(working, batch.events, "", null, null)


## Validates, prepares and commits `working`. Applies the outcome to controller state.
func _commit(working: GameState, events: Array[SimulationEvent], intent_id: String, result: CommandResult, command: GameCommand) -> String:
	var registry: ContentRegistry = _catalog.resolve(working.content_version)
	var errors: PackedStringArray = working.validate(registry)
	if not errors.is_empty():
		push_error("GameController: prepared state violates invariants: %s" % str(errors))
		return STATUS_INVALID
	var next_commit: MathResult = IntegerMath.add(_commit_counter, 1)
	var parent_revision: int = _committed.durable_revision
	var new_revision: MathResult = IntegerMath.add(parent_revision, 1)
	if not next_commit.ok or not new_revision.ok:
		return STATUS_NUMERIC_LIMIT
	_commit_counter = next_commit.value
	var commit_id: Dictionary = {"epoch": working.command_replay.current_epoch, "counter": _commit_counter}
	working.durable_revision = new_revision.value
	working.last_commit_id = commit_id.duplicate()
	var prepared: Dictionary = {
		"commit_id": commit_id,
		"expected_parent_revision": parent_revision,
		"new_revision": new_revision.value,
		"state": working.to_primitive(),
	}
	if result != null:
		result.commit_status = CommitSink.COMMITTED
	var status: String = _sink.commit(prepared)
	match status:
		CommitSink.COMMITTED:
			_committed = working
			_on_committed(events, intent_id, result, command)
		CommitSink.UNKNOWN:
			# Keep an independent copy: the caller reports UNKNOWN on its own result object.
			var pending_result: CommandResult = CommandResult.from_primitive(result.to_primitive()) if result != null else null
			_pending = {"prepared": prepared, "events": events, "intent_id": intent_id, "result": pending_result, "command": command}
	return status


func _on_committed(events: Array[SimulationEvent], intent_id: String, result: CommandResult, command: GameCommand) -> void:
	if command != null:
		_accepted_log.append(command.to_primitive())
	if result != null:
		result.commit_status = CommitSink.COMMITTED
		_remember_intent(intent_id, result)
	if not events.is_empty():
		for listener: Callable in _listeners:
			listener.call(events.duplicate())


func _remember_intent(intent_id: String, result: CommandResult) -> void:
	if intent_id.is_empty():
		return
	_intent_results[intent_id] = result.to_primitive()
	_intent_order.append(intent_id)
	while _intent_order.size() > INTENT_CACHE_CAPACITY:
		_intent_results.erase(_intent_order.pop_front())
