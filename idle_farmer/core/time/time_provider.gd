class_name TimeProvider
extends RefCounted
## Injectable source of clock observations (TRS §5/§7, DEC-013/014). The core never calls OS or
## Godot time APIs; a platform adapter (selected by M03 measurement) or a test fake supplies these.
## This base class is abstract: every method must be overridden.


## Wall-clock UTC in integer microseconds. May jump backward/forward (user edits, DST is irrelevant).
func get_utc_unix_time_us() -> int:
	push_error("TimeProvider.get_utc_unix_time_us is abstract")
	return 0


## In-session monotonic microseconds; never decreases while the process runs.
func get_monotonic_time_us() -> int:
	push_error("TimeProvider.get_monotonic_time_us is abstract")
	return 0


## Real elapsed microseconds across the last resume, when the platform can report it (else 0).
func get_resume_elapsed_us() -> int:
	push_error("TimeProvider.get_resume_elapsed_us is abstract")
	return 0


## Real time elapsed since the previous call, partitioned into active and suspended portions:
## {"active_us": int, "suspended_us": int}. Suspended time is credited at 1×, never at debug speed.
func observe_partition() -> Dictionary:
	push_error("TimeProvider.observe_partition is abstract")
	return {"active_us": 0, "suspended_us": 0}
