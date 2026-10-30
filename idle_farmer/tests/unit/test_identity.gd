extends GutTest
## M01-T05/T06, AV-001-04 (codec part): namespaced identities, bounds, malformed references and
## allocation without drift.

const MAX: int = IntegerMath.INT64_MAX


func test_entity_id_equality_uses_all_components() -> void:
	var a: EntityId = EntityId.new("s", "ns-1", 5)
	assert_true(a.equals(EntityId.new("s", "ns-1", 5)))
	assert_false(a.equals(EntityId.new("s", "ns-2", 5)), "namespace differs")
	assert_false(a.equals(EntityId.new("t", "ns-1", 5)), "save differs")
	assert_false(a.equals(EntityId.new("s", "ns-1", 6)), "counter differs")
	assert_false(a.equals(null))


func test_entity_id_round_trips_at_int64_bounds() -> void:
	for counter: int in [1, MAX - 1, MAX]:
		var id: EntityId = EntityId.new(Fixtures.SAVE_ID, Fixtures.uuid("F"), counter)
		var decoded: Dictionary = CanonicalCodec.decode(CanonicalCodec.encode(id.to_primitive()))
		var back: EntityId = EntityId.from_primitive(decoded["value"])
		assert_not_null(back)
		assert_true(back.equals(id), "counter %d" % counter)


func test_malformed_entity_ids_are_rejected() -> void:
	var bad: Array = [
		null, 5, {}, {"save_id": "s", "namespace": "n"}, {"save_id": "s", "namespace": "n", "counter": 0},
		{"save_id": "s", "namespace": "", "counter": 1}, {"save_id": "", "namespace": "n", "counter": 1},
		{"save_id": "s", "namespace": "n", "counter": "1"}, {"save_id": "s", "namespace": "n", "counter": 1, "x": 1},
		{"save_id": "s", "namespace": "n", "counter": -3},
	]
	for value: Variant in bad:
		assert_null(EntityId.from_primitive(value), "reject %s" % str(value))


func test_command_id_round_trip_and_rejection() -> void:
	var id: CommandId = CommandId.new(Fixtures.SAVE_ID, Fixtures.uuid("A"), MAX)
	assert_true(CommandId.from_primitive(id.to_primitive()).equals(id))
	assert_null(CommandId.from_primitive({"save_id": "s", "writer_epoch": "e", "counter": 0}))
	assert_null(CommandId.from_primitive({"save_id": "s", "writer_epoch": "", "counter": 1}))


func test_allocation_uses_state_namespace_and_increments() -> void:
	var state: GameState = Fixtures.new_game("B")
	var first: EntityId = state.allocate_entity_id()
	var second: EntityId = state.allocate_entity_id()
	assert_eq(first.allocation_namespace, Fixtures.uuid("B"))
	assert_eq(first.save_id, Fixtures.SAVE_ID)
	assert_eq([first.counter, second.counter], [1, 2])
	assert_eq(state.next_entity_id, 3)


func test_allocation_at_limit_fails_without_drift() -> void:
	var state: GameState = Fixtures.new_game()
	state.next_entity_id = MAX
	assert_null(state.allocate_entity_id(), "MAX cannot be issued because the next counter is unrepresentable")
	assert_eq(state.next_entity_id, MAX, "no counter drift on failure")
	state.next_insertion_sequence = MAX
	assert_eq(state.allocate_insertion_sequence(), -1)
	assert_eq(state.next_insertion_sequence, MAX)


func test_new_namespace_keeps_existing_entity_ids() -> void:
	# AV-001-01 data side: a later epoch allocates in a new namespace; restored entities keep theirs.
	var state: GameState = Fixtures.new_game("A")
	var cycle: CropCycle = Fixtures.add_cycle(state, 1, "wheat", 0)
	var restored: GameState = state.clone()
	restored.allocation_namespace = Fixtures.uuid("B")
	restored.command_replay.start_epoch(Fixtures.uuid("B"))
	var next: EntityId = restored.allocate_entity_id()
	assert_eq(next.allocation_namespace, Fixtures.uuid("B"))
	assert_false(next.equals(EntityId.new(Fixtures.SAVE_ID, Fixtures.uuid("A"), next.counter)), "new identity differs")
	assert_true(restored.plot(1).crop_cycle.cycle_id.equals(cycle.cycle_id), "restored entity keeps its ID")
	assert_eq(restored.validate(Fixtures.registry()), PackedStringArray())
	assert_true(restored.command_replay.retired_epochs.has(Fixtures.uuid("A")))
