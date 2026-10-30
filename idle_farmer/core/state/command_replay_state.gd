class_name CommandReplayState
extends RefCounted
## In-memory replay protection (DEC-016, TRS §4.1): current writer epoch, committed-success
## high-water and a bounded response cache. Eviction never restores execution eligibility because
## duplicates are decided by the high-water, not by cache presence. M03 makes this durable.

const DEFAULT_CACHE_CAPACITY: int = 256

var current_epoch: String = ""
var committed_success_counter: int = 0
var retired_epochs: PackedStringArray = PackedStringArray()
var cache_capacity: int = DEFAULT_CACHE_CAPACITY
## Oldest first. Each entry: {"epoch": String, "counter": int, "result": Dictionary}.
var response_cache: Array[Dictionary] = []


## True when the command belongs to a retired or foreign writer epoch (never re-executed).
func is_stale_epoch(command_id: CommandId) -> bool:
	return command_id.writer_epoch != current_epoch


## True when the counter is at or below the current epoch's committed-success high-water.
func is_duplicate(command_id: CommandId) -> bool:
	return command_id.writer_epoch == current_epoch and command_id.counter <= committed_success_counter


## Cached primitive result for a command, or {} if absent (e.g. evicted).
func cached_result(command_id: CommandId) -> Dictionary:
	for entry: Dictionary in response_cache:
		if entry["epoch"] == command_id.writer_epoch and entry["counter"] == command_id.counter:
			return entry["result"].duplicate(true)
	return {}


## Records a committed success: advances the high-water and caches the response (oldest evicted).
func record_success(command_id: CommandId, result_primitive: Dictionary) -> void:
	committed_success_counter = maxi(committed_success_counter, command_id.counter)
	response_cache.append({"epoch": command_id.writer_epoch, "counter": command_id.counter, "result": result_primitive.duplicate(true)})
	while response_cache.size() > cache_capacity:
		response_cache.pop_front()


## Retires the current epoch (restart/recovery/restore) and starts a fresh one.
func start_epoch(new_epoch: String) -> void:
	if not current_epoch.is_empty() and not retired_epochs.has(current_epoch):
		retired_epochs.append(current_epoch)
	current_epoch = new_epoch
	committed_success_counter = 0


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if current_epoch.is_empty():
		errors.append("REPLAY_EPOCH_EMPTY: current writer epoch is required")
	if retired_epochs.has(current_epoch):
		errors.append("REPLAY_EPOCH_RETIRED: current epoch '%s' is retired" % current_epoch)
	if committed_success_counter < 0:
		errors.append("REPLAY_COUNTER_NEGATIVE: %d" % committed_success_counter)
	if cache_capacity < 1 or response_cache.size() > cache_capacity:
		errors.append("REPLAY_CACHE_UNBOUNDED: %d entries, capacity %d" % [response_cache.size(), cache_capacity])
	return errors


func to_primitive() -> Dictionary:
	return {
		"current_epoch": current_epoch,
		"committed_success_counter": committed_success_counter,
		"retired_epochs": Array(retired_epochs),
		"cache_capacity": cache_capacity,
		"response_cache": PrimitiveReader.plain(response_cache),
	}


static func from_primitive(value: Variant) -> CommandReplayState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "CommandReplayState")
	reader.expect_only(PackedStringArray(["current_epoch", "committed_success_counter", "retired_epochs", "cache_capacity", "response_cache"]))
	var state: CommandReplayState = CommandReplayState.new()
	state.current_epoch = reader.string_field("current_epoch")
	state.committed_success_counter = reader.int_field("committed_success_counter")
	state.retired_epochs = reader.string_array_field("retired_epochs")
	state.cache_capacity = reader.int_field("cache_capacity")
	for entry: Variant in reader.array_field("response_cache"):
		var entry_reader: PrimitiveReader = PrimitiveReader.new(entry, "CommandReplayState.response_cache")
		entry_reader.expect_only(PackedStringArray(["epoch", "counter", "result"]))
		var epoch: String = entry_reader.string_field("epoch")
		var counter: int = entry_reader.int_field("counter")
		var result: Dictionary = entry_reader.dict_field("result")
		reader.absorb(entry_reader.errors)
		state.response_cache.append({"epoch": epoch, "counter": counter, "result": result.duplicate(true)})
	if not reader.ok():
		return null
	return state
