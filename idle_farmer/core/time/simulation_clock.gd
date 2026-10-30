class_name SimulationClock
extends RefCounted
## Simulation time from injected real-time deltas (M01-T08, TRS §7). Independent of OS calls,
## frames and `Engine.time_scale`.
##
## - Active real time advances simulation by real × speed (integer 1–60, debug only).
## - Suspended and offline real time always advance simulation at 1×.
## - Every advance yields an AccountedInterval whose `real_us` is what the credited-through anchor
##   may advance by; debug speed never inflates the anchor.
## Speed and time are integers, so no fractional carry exists (build plan B6).

const MIN_SPEED: int = 1
const MAX_SPEED: int = 60

var _speed: int = MIN_SPEED
var _simulation_time_us: int = 0


func _init(start_time_us: int = 0) -> void:
	_simulation_time_us = start_time_us


func get_simulation_time_us() -> int:
	return _simulation_time_us


func get_speed_multiplier() -> int:
	return _speed


## Sets debug speed; rejects anything outside the integer range 1–60 and keeps the old speed.
func set_speed_multiplier(speed: int) -> bool:
	if speed < MIN_SPEED or speed > MAX_SPEED:
		return false
	_speed = speed
	return true


## Every launch starts at 1× (DEC-021: debug speed is never persisted).
func reset_speed() -> void:
	_speed = MIN_SPEED


## Active foreground time at the current speed. Null (and no change) for negative input or overflow.
func advance_active(real_us: int) -> AccountedInterval:
	if real_us < 0:
		return null
	var sim_delta: MathResult = IntegerMath.mul(real_us, _speed)
	if not sim_delta.ok:
		return null
	return _advance(AccountedInterval.KIND_ACTIVE, real_us, sim_delta.value)


## TRS §5 name for active advancement.
func advance_real_time(real_us: int) -> AccountedInterval:
	return advance_active(real_us)


## Time spent suspended (sleep/hibernate) inside a session: always 1×, regardless of debug speed.
func advance_suspended(real_us: int) -> AccountedInterval:
	if real_us < 0:
		return null
	return _advance(AccountedInterval.KIND_SUSPENDED, real_us, real_us)


## Closed-application interval at restart: always 1×.
func advance_offline(real_us: int) -> AccountedInterval:
	if real_us < 0:
		return null
	return _advance(AccountedInterval.KIND_OFFLINE, real_us, real_us)


## Applies one provider observation: active portion at speed, suspended portion at 1×.
## Returns the produced intervals (empty portions are skipped), or [] with no change on failure.
func consume_observation(observation: Dictionary) -> Array[AccountedInterval]:
	var active: int = observation.get("active_us", -1)
	var suspended: int = observation.get("suspended_us", -1)
	if active < 0 or suspended < 0:
		return []
	var before: int = _simulation_time_us
	var produced: Array[AccountedInterval] = []
	if active > 0:
		var a: AccountedInterval = advance_active(active)
		if a == null:
			return []
		produced.append(a)
	if suspended > 0:
		var s: AccountedInterval = advance_suspended(suspended)
		if s == null:
			_simulation_time_us = before
			return []
		produced.append(s)
	return produced


func _advance(kind: String, real_us: int, sim_us: int) -> AccountedInterval:
	var next: MathResult = IntegerMath.add(_simulation_time_us, sim_us)
	if not next.ok:
		return null
	_simulation_time_us = next.value
	return AccountedInterval.new(kind, real_us, sim_us)
