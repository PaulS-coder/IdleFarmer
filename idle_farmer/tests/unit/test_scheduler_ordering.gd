extends GutTest
## M01-T07, V04 (queue part): each tuple field orders independently, permutation-independent pops,
## cancellation with bounded storage, unique sequences and identical keys after rebuild.


func _event(time_us: int, phase: int, priority: int, entity_order: int, seq: int, ns: String = "ns") -> ScheduledEvent:
	return ScheduledEvent.new(time_us, phase, priority, entity_order, seq, ScheduledEvent.TYPE_CROP_MATURED, 1,
		EntityId.new("s", ns, maxi(1, entity_order)))


func _seqs(events: Array[ScheduledEvent]) -> Array[int]:
	var result: Array[int] = []
	for e: ScheduledEvent in events:
		result.append(e.insertion_seq)
	return result


func _drain(scheduler: EventScheduler) -> Array[int]:
	var result: Array[int] = []
	var next: ScheduledEvent = scheduler.pop_next()
	while next != null:
		result.append(next.insertion_seq)
		next = scheduler.pop_next()
	return result


func test_each_tuple_field_orders_independently() -> void:
	# Pairs differ in exactly one field; the event with the smaller field must pop first,
	# even when pushed second and when its later fields are larger.
	var pairs: Array[Array] = [
		[_event(5, 2, 0, 1, 10), _event(4, 9, 9, 9, 20)],
		[_event(5, 2, 0, 1, 10), _event(5, 1, 9, 9, 20)],
		[_event(5, 2, 1, 1, 10), _event(5, 2, 0, 9, 20)],
		[_event(5, 2, 0, 2, 10), _event(5, 2, 0, 1, 20)],
		[_event(5, 2, 0, 1, 20), _event(5, 2, 0, 1, 10)],
	]
	for i: int in pairs.size():
		var scheduler: EventScheduler = EventScheduler.new()
		scheduler.push(pairs[i][0])
		scheduler.push(pairs[i][1])
		assert_eq(_drain(scheduler)[0], pairs[i][1].insertion_seq, "field %d decides order" % i)


func test_entity_order_is_numeric_not_uuid_lexical() -> void:
	var scheduler: EventScheduler = EventScheduler.new()
	scheduler.push(_event(1, 2, 0, 2, 1, "aaaa"))
	scheduler.push(_event(1, 2, 0, 10, 2, "0000"))
	scheduler.push(_event(1, 2, 0, 9, 3, "zzzz"))
	assert_eq(_drain(scheduler), [1, 3, 2], "2 < 9 < 10 numerically; namespaces ignored")


func test_pop_order_is_independent_of_push_permutation() -> void:
	var events: Array[ScheduledEvent] = []
	var seq: int = 1
	for t: int in [0, 7, 7, 7, 3]:
		for phase: int in [2, 1]:
			for order: int in [3, 1, 2]:
				events.append(_event(t, phase, 0, order, seq))
				seq += 1
	var reference: Array[int] = []
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 20261030
	for trial: int in 25:
		var shuffled: Array[ScheduledEvent] = events.duplicate()
		for i: int in range(shuffled.size() - 1, 0, -1):
			var j: int = rng.randi_range(0, i)
			var tmp: ScheduledEvent = shuffled[i]
			shuffled[i] = shuffled[j]
			shuffled[j] = tmp
		var scheduler: EventScheduler = EventScheduler.new()
		for e: ScheduledEvent in shuffled:
			assert_true(scheduler.push(e))
		var order: Array[int] = _drain(scheduler)
		if trial == 0:
			reference = order
		assert_eq(order, reference, "trial %d" % trial)
	for i: int in range(1, reference.size()):
		var a: ScheduledEvent = events[reference[i - 1] - 1]
		var b: ScheduledEvent = events[reference[i] - 1]
		assert_true(a.precedes(b), "sorted pair %d" % i)


func test_pop_at_returns_all_events_at_one_time_in_order() -> void:
	var scheduler: EventScheduler = EventScheduler.new()
	scheduler.push(_event(10, 2, 0, 5, 1))
	scheduler.push(_event(10, 1, 0, 9, 2))
	scheduler.push(_event(11, 1, 0, 1, 3))
	scheduler.push(_event(10, 2, 0, 4, 4))
	assert_eq(scheduler.peek_time(), 10)
	assert_eq(_seqs(scheduler.pop_at(10)), [2, 4, 1], "phase 1 before phase 2, then entity order")
	assert_eq(scheduler.peek_time(), 11)
	assert_eq(scheduler.pop_at(10).size(), 0)


func test_duplicate_insertion_sequence_is_rejected() -> void:
	var scheduler: EventScheduler = EventScheduler.new()
	assert_true(scheduler.push(_event(1, 2, 0, 1, 7)))
	assert_false(scheduler.push(_event(2, 2, 0, 2, 7)))
	assert_eq(scheduler.size(), 1)


func test_cancellation_and_bounded_storage() -> void:
	var scheduler: EventScheduler = EventScheduler.new()
	for seq: int in range(1, 101):
		scheduler.push(_event(seq, 2, 0, seq, seq))
	for seq: int in range(1, 91):
		assert_true(scheduler.cancel(seq))
	assert_false(scheduler.cancel(1), "already cancelled")
	assert_false(scheduler.cancel(999), "never queued")
	assert_eq(scheduler.size(), 10)
	assert_lte(scheduler.storage_size(), 2 * scheduler.size() + 1, "tombstones compacted")
	assert_eq(scheduler.peek_time(), 91)
	assert_eq(_drain(scheduler), Array(range(91, 101)))
	assert_eq(scheduler.peek_time(), -1)
	assert_null(scheduler.pop_next())


func test_rebuild_reproduces_identical_keys_and_order() -> void:
	var state: GameState = Fixtures.new_game()
	var live: EventScheduler = EventScheduler.new()
	# Mixed crops, planting order unrelated to plot order, two maturing at the same time.
	for spec: Array in [[9, "corn"], [2, "wheat"], [17, "wheat"], [5, "corn"], [24, "wheat"]]:
		var cycle: CropCycle = Fixtures.add_cycle(state, spec[0], spec[1], 0)
		live.push(ScheduledEvent.for_maturity(cycle))
	var rebuilt: EventScheduler = EventScheduler.rebuild(state)
	var restored: EventScheduler = EventScheduler.rebuild(state.clone())
	var live_keys: Array = []
	for e: ScheduledEvent in live.pending_in_order():
		live_keys.append(e.key())
	for other: EventScheduler in [rebuilt, restored]:
		var keys: Array = []
		for e: ScheduledEvent in other.pending_in_order():
			keys.append(e.key())
		assert_eq(keys, live_keys, "identical keys in identical order")
	assert_eq(live.size(), 5, "one pending maturity per growing cycle")


func test_rebuild_skips_ready_cycles() -> void:
	var state: GameState = Fixtures.new_game()
	state.simulation_time_us = 480_000_000
	Fixtures.add_cycle(state, 1, "wheat", 0, CropCycle.STATUS_READY)
	Fixtures.add_cycle(state, 2, "corn", 0)
	assert_eq(EventScheduler.rebuild(state).size(), 1)
