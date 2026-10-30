extends GutTest
## M01-T05, V07 and V12: deep clone isolation for every nested container, lossless round-trip,
## strict decoding, and settings without persisted debug speed.

var state: GameState


func before_each() -> void:
	state = _rich_state()


## A state touching every record and container type, including extension stubs.
func _rich_state() -> GameState:
	var s: GameState = Fixtures.new_game_v2()
	Fixtures.set_xp(s, 5_200)
	s.player.skill_ranks = {"batch_planting": 1, "batch_harvesting": 1}
	s.player.available_skill_points = 4
	s.player.coins = 1_234
	s.research.completed = PackedStringArray(["unlock_carrots", "unlock_corn"])
	Fixtures.add_cycle(s, 1, "wheat", 0)
	Fixtures.add_cycle(s, 5, "corn", 0)
	s.plot(9).selected_crop_id = "corn"
	s.upgrades.ranks = {"irrigation": 1}
	s.contracts.instances = [{"offer_id": "Q01", "progress": {"wheat": 3}}]
	s.contracts.claimed_offer_ids = PackedStringArray(["Q00"])
	s.automation.defaults = {"crop": "wheat", "nested": {"list": [1, 2, 3]}}
	s.automation.groups = {"g1": {"plots": [1, 2]}}
	s.statistics.buckets = [{"start_us": 0, "coins": 16}]
	s.statistics.segments = [{"kind": "active", "real_us": 10}]
	s.statistics.lifetime = {"harvests": 2}
	s.time_anchor.intervals.append(AccountedInterval.new(AccountedInterval.KIND_ACTIVE, 10, 600))
	s.command_replay.record_success(CommandId.new(Fixtures.SAVE_ID, Fixtures.uuid("A"), 1), {"success": true, "nested": [1]})
	s.last_commit_id = {"epoch": Fixtures.uuid("A"), "counter": 3}
	s.durable_revision = 3
	return s


func test_rich_state_is_valid_and_round_trips_losslessly() -> void:
	assert_eq(state.validate(Fixtures.registry_v2()), PackedStringArray())
	var copy: GameState = state.clone()
	assert_not_null(copy)
	assert_eq(copy.digest(), state.digest())
	assert_eq(copy.gameplay_digest(), state.gameplay_digest())
	assert_eq(copy.metadata_digest(), state.metadata_digest())
	var decoded: Dictionary = CanonicalCodec.decode(CanonicalCodec.encode(state.to_primitive()))
	assert_true(decoded["ok"])
	assert_eq(GameState.from_primitive(decoded["value"]).digest(), state.digest(), "codec round-trip")


func test_v07_mutating_every_nested_container_leaves_source_unchanged() -> void:
	var source_digest: String = state.digest()
	var mutations: Array[Callable] = [
		func(c: GameState) -> void: c.player.skill_ranks["batch_planting"] = 9,
		func(c: GameState) -> void: c.player.coins += 1,
		func(c: GameState) -> void: c.plots[0].crop_cycle.gross_coin_reward = 999,
		func(c: GameState) -> void: c.plots[0].crop_cycle.modifier_snapshot["coin_bonus_bp"] = 5,
		func(c: GameState) -> void: c.plots[0].crop_cycle.cycle_id.counter = 77,
		func(c: GameState) -> void: c.plots[4].crop_cycle = null,
		func(c: GameState) -> void: c.plots[8].selected_crop_id = "wheat",
		func(c: GameState) -> void: c.plots.pop_back(),
		func(c: GameState) -> void: c.research.completed.append("unlock_tomatoes"),
		func(c: GameState) -> void: c.upgrades.ranks["irrigation"] = 2,
		func(c: GameState) -> void: c.contracts.instances[0]["progress"]["wheat"] = 4,
		func(c: GameState) -> void: c.contracts.claimed_offer_ids.append("Q09"),
		func(c: GameState) -> void: c.automation.defaults["nested"]["list"].append(4),
		func(c: GameState) -> void: c.automation.groups["g1"]["plots"][0] = 9,
		func(c: GameState) -> void: c.statistics.buckets[0]["coins"] = 0,
		func(c: GameState) -> void: c.statistics.segments.clear(),
		func(c: GameState) -> void: c.statistics.lifetime["harvests"] = 5,
		func(c: GameState) -> void: c.settings.music_volume = 1,
		func(c: GameState) -> void: c.time_anchor.intervals[0].real_us = 99,
		func(c: GameState) -> void: c.time_anchor.credited_through_utc_us = 1,
		func(c: GameState) -> void: c.command_replay.response_cache[0]["result"]["nested"].append(2),
		func(c: GameState) -> void: c.command_replay.retired_epochs.append("x"),
		func(c: GameState) -> void: c.last_commit_id["counter"] = 4,
	]
	for i: int in mutations.size():
		var copy: GameState = state.clone()
		mutations[i].call(copy)
		assert_ne(copy.digest(), source_digest, "mutation %d changed the clone" % i)
		assert_eq(state.digest(), source_digest, "mutation %d left the source unchanged" % i)


func test_v07_no_shared_object_references() -> void:
	var copy: GameState = state.clone()
	assert_ne(copy.player, state.player)
	assert_ne(copy.plots[0], state.plots[0])
	assert_ne(copy.plots[0].crop_cycle, state.plots[0].crop_cycle)
	assert_ne(copy.plots[0].crop_cycle.cycle_id, state.plots[0].crop_cycle.cycle_id)
	assert_ne(copy.settings, state.settings)
	assert_ne(copy.time_anchor, state.time_anchor)
	assert_ne(copy.time_anchor.intervals[0], state.time_anchor.intervals[0])
	assert_ne(copy.command_replay, state.command_replay)
	assert_ne(copy.automation, state.automation)
	assert_ne(copy.research, state.research)
	assert_ne(copy.contracts, state.contracts)
	assert_ne(copy.statistics, state.statistics)
	assert_ne(copy.upgrades, state.upgrades)


func test_exported_primitives_contain_no_typed_containers() -> void:
	assert_eq(_typed_paths(state.to_primitive(), "state"), PackedStringArray())


func _typed_paths(value: Variant, path: String) -> PackedStringArray:
	var found: PackedStringArray = PackedStringArray()
	if value is Array:
		if (value as Array).is_typed():
			found.append(path)
		for i: int in (value as Array).size():
			found.append_array(_typed_paths(value[i], "%s[%d]" % [path, i]))
	elif value is Dictionary:
		if (value as Dictionary).is_typed():
			found.append(path)
		for key: Variant in (value as Dictionary).keys():
			found.append_array(_typed_paths(value[key], "%s.%s" % [path, key]))
	return found


func test_v12_settings_never_persist_debug_speed() -> void:
	var keys: Array = state.settings.to_primitive().keys()
	for key: Variant in keys:
		assert_false(str(key).contains("speed"), "settings key '%s'" % key)
	assert_false(state.to_primitive().has("debug_speed"))


func test_gameplay_and_metadata_projections_are_disjoint_and_complete() -> void:
	var gameplay: Dictionary = state.gameplay_primitive()
	var metadata: Dictionary = state.metadata_primitive()
	for key: Variant in metadata:
		assert_false(gameplay.has(key), "'%s' only in metadata" % key)
	assert_eq(gameplay.size() + metadata.size(), state.to_primitive().size())
	var copy: GameState = state.clone()
	copy.durable_revision = 99
	copy.time_anchor.credited_through_utc_us += 1
	assert_eq(copy.gameplay_digest(), state.gameplay_digest(), "checkpoint metadata does not change gameplay digest")
	assert_ne(copy.metadata_digest(), state.metadata_digest())


func test_strict_decoder_rejects_malformed_snapshots() -> void:
	var good: Dictionary = state.to_primitive()
	var cases: Array[Callable] = [
		func(p: Dictionary) -> void: p["unexpected"] = 1,
		func(p: Dictionary) -> void: p.erase("player"),
		func(p: Dictionary) -> void: p["next_entity_id"] = "1",
		func(p: Dictionary) -> void: p["plots"][0]["crop_cycle"]["cycle_id"]["counter"] = 0,
		func(p: Dictionary) -> void: p["plots"][0]["crop_cycle"]["cycle_id"].erase("namespace"),
		func(p: Dictionary) -> void: p["plots"][0]["crop_cycle"]["status"] = 1,
		func(p: Dictionary) -> void: p["player"]["skill_ranks"]["batch_planting"] = "1",
		func(p: Dictionary) -> void: p["time_anchor"]["intervals"][0]["extra"] = true,
		func(p: Dictionary) -> void: p["command_replay"]["response_cache"][0].erase("result"),
		func(p: Dictionary) -> void: p["research"]["completed"].append(5),
		func(p: Dictionary) -> void: p["last_commit_id"] = 3,
	]
	for i: int in cases.size():
		var corrupted: Dictionary = good.duplicate(true)
		cases[i].call(corrupted)
		assert_null(GameState.from_primitive(corrupted), "malformed snapshot %d rejected" % i)
