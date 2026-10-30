extends GutTest
## M01-T08, V06/V10/V12 (time parts): integer debug speed, 1× suspended/offline time, anchor
## credited by real elapsed only, UTC edits ignored by active progression.

const SECOND: int = 1_000_000


func test_speed_range_and_reset() -> void:
	var clock: SimulationClock = SimulationClock.new()
	assert_eq(clock.get_speed_multiplier(), 1, "starts at 1×")
	for bad: int in [0, -1, 61, 1000]:
		assert_false(clock.set_speed_multiplier(bad), "reject %d" % bad)
	assert_eq(clock.get_speed_multiplier(), 1)
	assert_true(clock.set_speed_multiplier(60))
	assert_true(clock.set_speed_multiplier(1))
	assert_true(clock.set_speed_multiplier(37))
	clock.reset_speed()
	assert_eq(clock.get_speed_multiplier(), 1)


func test_v06_480_game_seconds_at_1x_equals_8_real_seconds_at_60x() -> void:
	var normal: SimulationClock = SimulationClock.new()
	var fast: SimulationClock = SimulationClock.new()
	fast.set_speed_multiplier(60)
	var a: AccountedInterval = normal.advance_active(480 * SECOND)
	var b: AccountedInterval = fast.advance_active(8 * SECOND)
	assert_eq(normal.get_simulation_time_us(), 480_000_000)
	assert_eq(fast.get_simulation_time_us(), 480_000_000, "Wheat maturity reached in 8 real seconds")
	assert_eq([a.real_us, a.sim_us], [480 * SECOND, 480 * SECOND])
	assert_eq([b.real_us, b.sim_us], [8 * SECOND, 480 * SECOND], "anchor credit is real time only")


func test_partitioned_intervals_equal_one_combined_interval() -> void:
	var whole: SimulationClock = SimulationClock.new()
	whole.set_speed_multiplier(7)
	whole.advance_active(1_000_003)
	var parts: SimulationClock = SimulationClock.new()
	parts.set_speed_multiplier(7)
	for chunk: int in [1, 2, 999_997, 3]:
		parts.advance_active(chunk)
	assert_eq(parts.get_simulation_time_us(), whole.get_simulation_time_us())


func test_suspended_and_offline_are_1x_despite_debug_speed() -> void:
	var clock: SimulationClock = SimulationClock.new()
	clock.set_speed_multiplier(60)
	var s: AccountedInterval = clock.advance_suspended(3_600 * SECOND)
	var o: AccountedInterval = clock.advance_offline(10 * SECOND)
	assert_eq(s.sim_us, 3_600 * SECOND, "sleep never multiplied by stored debug rate")
	assert_eq(o.sim_us, 10 * SECOND)
	assert_eq(clock.get_simulation_time_us(), 3_610 * SECOND)


func test_trs_trace_10s_at_60x_plus_1h_suspended() -> void:
	# TRS §7.2: 10 real active seconds at 60× plus one real hour suspended = 4,200 simulated seconds,
	# with the suspended interval accounted once and the anchor advanced by 3,610 real seconds.
	var provider: FakeTimeProvider = FakeTimeProvider.new(Fixtures.CREATED_UTC_US)
	var clock: SimulationClock = SimulationClock.new()
	var anchor: TimeAnchor = TimeAnchor.new()
	anchor.credited_through_utc_us = Fixtures.CREATED_UTC_US
	clock.set_speed_multiplier(60)
	provider.run_active(10 * SECOND)
	provider.suspend(3_600 * SECOND)
	for interval: AccountedInterval in clock.consume_observation(provider.observe_partition()):
		assert_true(anchor.credit(interval))
	assert_eq(clock.get_simulation_time_us(), 4_200 * SECOND)
	assert_eq(anchor.credited_through_utc_us - Fixtures.CREATED_UTC_US, 3_610 * SECOND)
	assert_eq(clock.consume_observation(provider.observe_partition()).size(), 0, "nothing credited twice")
	assert_eq(clock.get_simulation_time_us(), 4_200 * SECOND)
	assert_eq(anchor.validate(), PackedStringArray())


func test_v06_utc_rollback_and_jump_do_not_change_active_delta() -> void:
	var provider: FakeTimeProvider = FakeTimeProvider.new(Fixtures.CREATED_UTC_US)
	var clock: SimulationClock = SimulationClock.new()
	var anchor: TimeAnchor = TimeAnchor.new()
	anchor.credited_through_utc_us = Fixtures.CREATED_UTC_US
	provider.run_active(5 * SECOND)
	provider.set_utc(Fixtures.CREATED_UTC_US - 3_600 * SECOND)  # wall clock moved back an hour
	provider.run_active(5 * SECOND)
	provider.set_utc(Fixtures.CREATED_UTC_US + 86_400 * SECOND)  # then forward a day (DST/user edit)
	for interval: AccountedInterval in clock.consume_observation(provider.observe_partition()):
		anchor.credit(interval)
	anchor.observe_utc(Fixtures.CREATED_UTC_US - 3_600 * SECOND)
	assert_eq(clock.get_simulation_time_us(), 10 * SECOND, "only monotonic real time advanced simulation")
	assert_eq(anchor.credited_through_utc_us, Fixtures.CREATED_UTC_US + 10 * SECOND, "anchor = real elapsed, not UTC")
	assert_eq(anchor.anomaly_count, 1, "backward UTC recorded as a diagnostic")
	anchor.observe_utc(Fixtures.CREATED_UTC_US + 86_400 * SECOND)
	assert_eq(anchor.credited_through_utc_us, Fixtures.CREATED_UTC_US + 10 * SECOND, "observed UTC never copied into anchor")


func test_overflow_and_negative_input_change_nothing() -> void:
	var clock: SimulationClock = SimulationClock.new(IntegerMath.INT64_MAX - 10)
	clock.set_speed_multiplier(2)
	assert_null(clock.advance_active(6), "12 us would overflow")
	assert_eq(clock.get_simulation_time_us(), IntegerMath.INT64_MAX - 10)
	assert_not_null(clock.advance_active(5))
	assert_null(clock.advance_suspended(-1))
	assert_null(clock.advance_offline(-1))
	var big: SimulationClock = SimulationClock.new()
	big.set_speed_multiplier(60)
	assert_null(big.advance_active(IntegerMath.INT64_MAX / 59), "speed product overflow")
	assert_eq(big.get_simulation_time_us(), 0)
	var partial: SimulationClock = SimulationClock.new(IntegerMath.INT64_MAX - 100)
	assert_eq(partial.consume_observation({"active_us": 50, "suspended_us": 51}).size(), 0, "all-or-nothing")
	assert_eq(partial.get_simulation_time_us(), IntegerMath.INT64_MAX - 100)


func test_anchor_interval_summary_is_bounded() -> void:
	var anchor: TimeAnchor = TimeAnchor.new()
	for i: int in TimeAnchor.MAX_INTERVALS + 10:
		assert_true(anchor.credit(AccountedInterval.new(AccountedInterval.KIND_ACTIVE, 1, 60)))
	assert_eq(anchor.intervals.size(), TimeAnchor.MAX_INTERVALS)
	assert_eq(anchor.credited_through_utc_us, TimeAnchor.MAX_INTERVALS + 10, "compaction keeps credited total")
	assert_false(anchor.credit(AccountedInterval.new(AccountedInterval.KIND_SUSPENDED, 5, 300)), "invalid interval rejected")


func test_v12_provider_exposes_active_suspended_partition() -> void:
	var provider: FakeTimeProvider = FakeTimeProvider.new(0)
	provider.run_active(3)
	provider.suspend(4)
	assert_eq(provider.observe_partition(), {"active_us": 3, "suspended_us": 4})
	assert_eq(provider.get_monotonic_time_us(), 3, "sleep-exclusive monotonic counter")
	assert_eq(provider.get_utc_unix_time_us(), 7)
	assert_eq(provider.get_resume_elapsed_us(), 4)
