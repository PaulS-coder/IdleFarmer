class_name FakeTimeProvider
extends TimeProvider
## Scripted clock observations for deterministic tests. Models a sleep-exclusive monotonic clock:
## suspended time advances UTC and the suspended partition but not the monotonic counter.

var utc_us: int = 0
var monotonic_us: int = 0
var resume_elapsed_us: int = 0
var _pending_active_us: int = 0
var _pending_suspended_us: int = 0


func _init(start_utc_us: int = 0) -> void:
	utc_us = start_utc_us


func run_active(real_us: int) -> void:
	utc_us += real_us
	monotonic_us += real_us
	_pending_active_us += real_us


func suspend(real_us: int) -> void:
	utc_us += real_us
	resume_elapsed_us = real_us
	_pending_suspended_us += real_us


## Wall-clock edit (forward or backward) without any real elapsed time.
func set_utc(value_us: int) -> void:
	utc_us = value_us


func get_utc_unix_time_us() -> int:
	return utc_us


func get_monotonic_time_us() -> int:
	return monotonic_us


func get_resume_elapsed_us() -> int:
	return resume_elapsed_us


func observe_partition() -> Dictionary:
	var observation: Dictionary = {"active_us": _pending_active_us, "suspended_us": _pending_suspended_us}
	_pending_active_us = 0
	_pending_suspended_us = 0
	return observation
