extends GutTest
## M01-T16 field review, automated: every script variable of every persisted record appears in its
## primitive form (and nothing else does), so a field added later cannot silently escape cloning,
## digests or snapshots. EntityId maps `allocation_namespace` to the key "namespace".

const RENAMED_KEYS: Dictionary = {"allocation_namespace": "namespace"}


func _script_vars(object: Object) -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for property: Dictionary in object.get_property_list():
		var name: String = property["name"]
		if property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE and not name.begins_with("_"):
			names.append(name)
	names.sort()
	return names


func _primitive_keys(primitive: Dictionary, is_entity_id: bool) -> PackedStringArray:
	var keys: PackedStringArray = PackedStringArray()
	for key: Variant in primitive.keys():
		var mapped: String = key
		if is_entity_id:
			for field: String in RENAMED_KEYS:
				if RENAMED_KEYS[field] == key:
					mapped = field
		keys.append(mapped)
	keys.sort()
	return keys


func _records() -> Array[Object]:
	var state: GameState = Fixtures.new_game()
	var cycle: CropCycle = Fixtures.add_cycle(state, 1, "wheat", 0)
	var result: CommandResult = CommandResult.new()
	return [
		state, state.player, state.plot(1), cycle, cycle.cycle_id, state.settings, state.time_anchor,
		AccountedInterval.new(AccountedInterval.KIND_ACTIVE, 1, 1), state.command_replay,
		state.upgrades, state.research, state.contracts, state.automation, state.statistics,
		CommandId.new("s", "e", 1), result, SimulationEvent.new(SimulationEvent.CROP_PLANTED, 0, 1, null),
		state.automation.plot(1), state.automation.plot(1).settings, state.automation.plot(1).authorization,
		state.automation.defaults, state.automation.plot(1).rotation, _group(state), _contract(state),
	]


func _group(state: GameState) -> GroupRecord:
	var group: GroupRecord = GroupRecord.new()
	group.group_id = state.allocate_entity_id()
	group.name = "g"
	return group


func _contract(state: GameState) -> ContractInstance:
	var contract: ContractInstance = ContractInstance.new()
	contract.instance_id = state.allocate_entity_id()
	contract.offer_id = "Q01"
	return contract


func test_every_record_field_is_serialized() -> void:
	for record: Object in _records():
		var primitive: Dictionary = record.call("to_primitive")
		var label: String = (record.get_script() as Script).resource_path.get_file()
		assert_eq(_primitive_keys(primitive, record is EntityId), _script_vars(record), "%s fields == primitive keys" % label)


func test_immutable_records_round_trip_all_accessors() -> void:
	var tx: EconomicTransaction = EconomicTransaction.new(EntityId.new("s", "n", 2), 5, EconomicTransaction.TYPE_HARVEST_CREDIT,
		3, EntityId.new("s", "n", 1), 16, 6, EconomicTransaction.CATEGORY_HARVEST, "content_m01_v1",
		EconomicTransaction.ORIGIN_AUTOMATIC)
	var back: EconomicTransaction = EconomicTransaction.from_primitive(tx.to_primitive())
	assert_eq(CanonicalCodec.digest(back.to_primitive()), CanonicalCodec.digest(tx.to_primitive()))
	assert_eq([back.time_us(), back.plot_id(), back.coin_delta(), back.xp_delta()], [5, 3, 16, 6])
