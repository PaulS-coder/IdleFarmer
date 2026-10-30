extends GutTest
## M02-T16 / V15 AV-007-01 and AV-007-04 contract fixtures, plus reserved rotation and contract
## records: typed, validated, round-tripped. Group commands remain FEATURE_UNAVAILABLE (M05).

var state: GameState
var registry: ContentRegistry


func before_each() -> void:
	registry = Fixtures.registry_v2()
	state = Fixtures.new_game_v2()


func _codes() -> PackedStringArray:
	return state.validate(registry)


func test_av007_01_group_identity_membership_and_references() -> void:
	var a: String = AutomationFixtures.add_group(state, "Field A", [1, 2])
	var b: String = AutomationFixtures.add_group(state, "Field B", [3])
	assert_ne(a, b, "unique group identities")
	assert_eq(_codes(), PackedStringArray())
	assert_eq(GameState.from_primitive(state.to_primitive()).digest(), state.digest(), "round trip")
	# Zero or one membership is structural: a plot holds one reference or none.
	assert_eq(state.automation.plot(4).group_id, "")
	state.automation.plot(4).group_id = "missing"
	assert_true(Fixtures.has_code(_codes(), "GROUP_UNKNOWN"), "dangling reference rejected")
	state.automation.plot(4).group_id = ""
	state.automation.groups[a].name = ""
	assert_true(Fixtures.has_code(_codes(), "GROUP_RECORD_INVALID"))
	state.automation.groups[a].name = "Field A"
	state.automation.groups[a].group_id = EntityId.new(state.save_id, state.allocation_namespace, 999)
	assert_true(Fixtures.has_code(_codes(), "GROUP_ID_FOREIGN"))
	assert_true(Fixtures.has_code(_codes(), "GROUP_KEY_MISMATCH"))


func test_av007_01_malformed_group_lists_are_rejected() -> void:
	AutomationFixtures.add_group(state, "Field A", [1])
	AutomationFixtures.add_group(state, "Field B", [2])
	var primitive: Dictionary = state.to_primitive()
	var unordered: Dictionary = primitive.duplicate(true)
	unordered["automation"]["groups"].reverse()
	assert_null(GameState.from_primitive(unordered), "groups serialize in ascending identity order")
	var duplicate: Dictionary = primitive.duplicate(true)
	duplicate["automation"]["groups"].append(duplicate["automation"]["groups"][0])
	assert_null(GameState.from_primitive(duplicate), "duplicate identity rejected")


func test_av007_04_rename_and_overridden_fields_keep_authorization() -> void:
	AutomationFixtures.level7_automation(state)
	var g: String = AutomationFixtures.add_group(state, "Field A", [1])
	AutomationFixtures.group_settings(state, g).set_value(FarmingSettings.CROP_ID, "wheat")
	AutomationFixtures.group_settings(state, g).set_value(FarmingSettings.AUTO_REPLANT, true)
	AutomationFixtures.arm(state, 1)
	var caps: Capabilities = Capabilities.of(state, registry)
	assert_eq(SettingsResolver.loop_status(state, caps, 1), SettingsResolver.LOOP_RUNNABLE)
	state.automation.groups[g].name = "North field"
	state.automation.groups[g].revision += 1
	assert_eq(SettingsResolver.loop_status(state, caps, 1), SettingsResolver.LOOP_RUNNABLE, "rename keeps authorization")
	state.automation.plot(1).settings.set_value(FarmingSettings.FERTILIZER_POLICY, "none")
	AutomationFixtures.group_settings(state, g).set_value(FarmingSettings.FERTILIZER_POLICY, "advanced")
	assert_eq(SettingsResolver.loop_status(state, caps, 1), SettingsResolver.LOOP_RUNNABLE,
		"a group field the plot overrides leaves its plan unchanged")
	state.automation.plot(1).settings.set_value(FarmingSettings.FALLBACK_ACCEPTED, false)
	AutomationFixtures.group_settings(state, g).set_value(FarmingSettings.FALLBACK_ACCEPTED, true)
	assert_false(SettingsResolver.effective(state, 1).fallback_accepted, "explicit false remains an override")
	assert_eq(SettingsResolver.loop_status(state, caps, 1), SettingsResolver.LOOP_RUNNABLE)
	AutomationFixtures.group_settings(state, g).set_value(FarmingSettings.CROP_ID, "carrots")
	assert_eq(SettingsResolver.loop_status(state, caps, 1), PlotState.STALL_UNARMED, "a real plan change does not run")


func test_group_commands_are_unavailable() -> void:
	var engine: SimulationEngine = Fixtures.engine_for(state)
	for type: String in ["CreateGroup", "RenameGroup", "AssignPlotGroup", "DeleteGroup"]:
		var before: String = state.digest()
		assert_eq(engine.submit_command(Fixtures.command(state, type, {"name": "x"}, 1)).failure_code, FailureCode.FEATURE_UNAVAILABLE)
		assert_eq(state.digest(), before)


func test_rotation_record() -> void:
	state.automation.plot(5).rotation.entries = PackedStringArray(["wheat", "carrots"])
	state.automation.plot(5).rotation.cursor = 1
	assert_eq(_codes(), PackedStringArray())
	assert_eq(GameState.from_primitive(state.to_primitive()).digest(), state.digest())
	state.automation.plot(5).rotation.cursor = 2
	assert_true(Fixtures.has_code(_codes(), "ROTATION_CURSOR_RANGE"))
	state.automation.plot(5).rotation.cursor = 0
	state.automation.plot(5).rotation.entries.append("mango")
	assert_true(Fixtures.has_code(_codes(), "ROTATION_CROP_UNKNOWN"))


func _contract(status: String) -> ContractInstance:
	var contract: ContractInstance = ContractInstance.new()
	contract.instance_id = state.allocate_entity_id()
	contract.offer_id = "Q03"
	contract.objective = {"kind": "gross", "target": 500}
	contract.reward_coins = 120
	contract.reward_xp = 40
	contract.progress = {"gross": 80}
	contract.status = status
	if status == ContractInstance.STATUS_CLAIMED:
		contract.claim_id = state.allocate_entity_id()
	return contract


func test_contract_records() -> void:
	state.contracts.instances = [_contract(ContractInstance.STATUS_ACCEPTED), _contract(ContractInstance.STATUS_CLAIMED)]
	state.contracts.claimed_offer_ids = PackedStringArray(["Q03"])
	assert_eq(_codes(), PackedStringArray())
	assert_eq(GameState.from_primitive(state.to_primitive()).digest(), state.digest())
	var cases: Dictionary = {
		"CONTRACT_CLAIM_UNRECORDED": func(s: GameState) -> void: s.contracts.claimed_offer_ids = PackedStringArray(),
		"CONTRACT_CLAIM_INCONSISTENT": func(s: GameState) -> void: s.contracts.instances[0].claim_id = s.contracts.instances[1].claim_id,
		"CONTRACT_STATUS_UNKNOWN": func(s: GameState) -> void: s.contracts.instances[0].status = "won",
		"CONTRACT_INSTANCE_DUPLICATE": func(s: GameState) -> void: s.contracts.instances.append(s.contracts.instances[0]),
		"CONTRACT_PROGRESS_NEGATIVE": func(s: GameState) -> void: s.contracts.instances[0].progress["gross"] = -1,
		"CONTRACT_ID_FOREIGN": func(s: GameState) -> void: s.contracts.instances[0].instance_id = EntityId.new(s.save_id, "other", 999),
		"CONTRACT_CLAIMED_UNSORTED": func(s: GameState) -> void: s.contracts.claimed_offer_ids = PackedStringArray(["Q09", "Q03"]),
	}
	for code: String in cases:
		var broken: GameState = state.clone()
		(cases[code] as Callable).call(broken)
		assert_true(Fixtures.has_code(broken.validate(registry), code), code)
