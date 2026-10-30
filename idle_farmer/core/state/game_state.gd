class_name GameState
extends RefCounted
## The single authoritative runtime state (TRS §3.1). No scene, Resource or live object references:
## every field round-trips through CanonicalCodec primitives, and `clone()` is defined as that
## round-trip, so a copy can never share mutable children with its source (V07).
##
## Two digest projections (build plan P5, TRS §20.2):
## - gameplay: everything mode-equivalence and rejection tests compare exactly;
## - metadata: durable revision, commit identity, time anchor/intervals — checkpoint cadence may differ.

const SCHEMA_VERSION: int = 1

const GAMEPLAY_KEYS: PackedStringArray = [
	"save_id", "schema_version", "content_version", "state_sequence", "simulation_time_us",
	"player", "plots", "upgrades", "research", "contracts", "automation", "statistics", "settings",
	"command_replay", "allocation_namespace", "next_entity_id", "next_insertion_sequence",
]
const METADATA_KEYS: PackedStringArray = ["durable_revision", "last_commit_id", "time_anchor"]

var save_id: String = ""
var schema_version: int = SCHEMA_VERSION
## Immutable manifest binding (FR-AUD-003): resolved via ManifestCatalog before validation.
var content_version: String = ""
var state_sequence: int = 0
var durable_revision: int = 0
## Coordinator commit identity primitive ({"epoch", "counter"}) or null; never an EntityId (§20.2).
var last_commit_id: Variant = null
var simulation_time_us: int = 0
var player: PlayerState = PlayerState.new()
var plots: Array[PlotState] = []
var upgrades: ExtensionState.Upgrades = ExtensionState.Upgrades.new()
var research: ExtensionState.Research = ExtensionState.Research.new()
var contracts: ExtensionState.Contracts = ExtensionState.Contracts.new()
var automation: ExtensionState.Automation = ExtensionState.Automation.new()
var statistics: ExtensionState.Statistics = ExtensionState.Statistics.new()
var settings: GameSettings = GameSettings.new()
var time_anchor: TimeAnchor = TimeAnchor.new()
var command_replay: CommandReplayState = CommandReplayState.new()
var allocation_namespace: String = ""
var next_entity_id: int = 1
var next_insertion_sequence: int = 1


## New-game baseline (DEC-003/020, FR-FARM-01): level 1, zero coins/XP/points, plots 1–24 Empty,
## 25–32 Locked, Wheat the only start unlock, nothing planted or selected. Identity tokens and the
## creation UTC are injected; the core generates no UUIDs and reads no clocks.
static func new_game(p_save_id: String, player_id: String, writer_epoch: String, created_utc_us: int, registry: ContentRegistry) -> GameState:
	var state: GameState = GameState.new()
	state.save_id = p_save_id
	state.content_version = registry.manifest_id()
	state.player.player_id = player_id
	for id: int in range(1, PlotState.PLOT_COUNT + 1):
		var plot: PlotState = PlotState.new()
		plot.plot_id = id
		plot.unlocked = id <= PlotState.INITIAL_UNLOCKED
		state.plots.append(plot)
	state.time_anchor.credited_through_utc_us = created_utc_us
	state.time_anchor.last_observed_utc_us = created_utc_us
	state.allocation_namespace = writer_epoch
	state.command_replay.start_epoch(writer_epoch)
	return state


func plot(plot_id: int) -> PlotState:
	if plot_id < 1 or plot_id > plots.size():
		return null
	return plots[plot_id - 1]


func unlocked_plot_count() -> int:
	var count: int = 0
	for p: PlotState in plots:
		if p.unlocked:
			count += 1
	return count


## Crop is unlocked for planting: start unlock or completed research, plus the level gate.
func is_crop_available(crop_id: String, registry: ContentRegistry) -> bool:
	var definition: CropDefinition = registry.crop(crop_id)
	if definition == null or player.level < definition.required_level:
		return false
	return definition.research_id.is_empty() or research.completed.has(definition.research_id)


func available_crop_ids(registry: ContentRegistry) -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for crop_id: String in registry.crop_ids():
		if is_crop_available(crop_id, registry):
			ids.append(crop_id)
	return ids


## Allocates the next dynamic identity in this state's namespace, or null at the int64 limit
## (DEC-026: the caller rejects the whole operation without partial mutation).
func allocate_entity_id() -> EntityId:
	var next: MathResult = IntegerMath.add(next_entity_id, 1)
	if not next.ok:
		return null
	var id: EntityId = EntityId.new(save_id, allocation_namespace, next_entity_id)
	next_entity_id = next.value
	return id


## Allocates the next scheduler insertion sequence, or -1 at the int64 limit.
func allocate_insertion_sequence() -> int:
	var next: MathResult = IntegerMath.add(next_insertion_sequence, 1)
	if not next.ok:
		return -1
	var seq: int = next_insertion_sequence
	next_insertion_sequence = next.value
	return seq


## All invariants of TRS §3 against the profile's bound registry. Empty result means valid.
func validate(registry: ContentRegistry) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if registry == null or not registry.is_valid():
		errors.append("MANIFEST_UNRESOLVED: no valid registry for '%s'" % content_version)
		return errors
	if registry.manifest_id() != content_version:
		errors.append("MANIFEST_MISMATCH: state bound to '%s', registry is '%s'" % [content_version, registry.manifest_id()])
		return errors
	if save_id.is_empty():
		errors.append("SAVE_ID_EMPTY: save_id is required")
	if schema_version != SCHEMA_VERSION:
		errors.append("SCHEMA_UNSUPPORTED: %d" % schema_version)
	if allocation_namespace.is_empty():
		errors.append("NAMESPACE_EMPTY: allocation_namespace is required")
	if state_sequence < 0 or durable_revision < 0 or simulation_time_us < 0:
		errors.append("COUNTER_NEGATIVE: sequence/revision/time must be nonnegative")
	if next_entity_id < 1 or next_insertion_sequence < 1:
		errors.append("ALLOCATOR_INVALID: allocation counters start at 1")
	errors.append_array(player.validate(registry))
	errors.append_array(_validate_plots(registry))
	errors.append_array(_validate_research(registry))
	errors.append_array(upgrades.validate())
	errors.append_array(research.validate())
	errors.append_array(contracts.validate())
	errors.append_array(automation.validate())
	errors.append_array(statistics.validate())
	errors.append_array(settings.validate())
	errors.append_array(time_anchor.validate())
	errors.append_array(command_replay.validate())
	return errors


func _validate_plots(registry: ContentRegistry) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if plots.size() != PlotState.PLOT_COUNT:
		errors.append("PLOT_COUNT: %d plots, expected %d" % [plots.size(), PlotState.PLOT_COUNT])
		return errors
	var unlocked_prefix_ended: bool = false
	var seen_cycles: Dictionary[String, bool] = {}
	var seen_sequences: Dictionary[int, bool] = {}
	for i: int in plots.size():
		var p: PlotState = plots[i]
		if p.plot_id != i + 1:
			errors.append("PLOT_ORDER: index %d holds plot %d" % [i, p.plot_id])
			continue
		errors.append_array(p.validate())
		if p.unlocked and unlocked_prefix_ended:
			errors.append("PLOT_UNLOCK_GAP: plot %d unlocked after a locked plot" % p.plot_id)
		if not p.unlocked:
			unlocked_prefix_ended = true
		if not p.selected_crop_id.is_empty() and not registry.has_crop(p.selected_crop_id):
			errors.append("PLOT_SELECTED_CROP_UNKNOWN: plot %d '%s'" % [p.plot_id, p.selected_crop_id])
		var cycle: CropCycle = p.crop_cycle
		if cycle == null or cycle.cycle_id == null:
			continue
		if not registry.has_crop(cycle.crop_id):
			errors.append("CYCLE_CROP_UNKNOWN: plot %d '%s'" % [p.plot_id, cycle.crop_id])
		if seen_cycles.has(cycle.cycle_id.key()):
			errors.append("CYCLE_ID_COLLISION: %s" % cycle.cycle_id.key())
		seen_cycles[cycle.cycle_id.key()] = true
		if cycle.cycle_id.save_id != save_id or cycle.cycle_id.counter >= next_entity_id:
			errors.append("CYCLE_ID_FOREIGN: %s not allocated by this save" % cycle.cycle_id.key())
		if cycle.planting_transaction_id != null and cycle.planting_transaction_id.counter >= next_entity_id:
			errors.append("CYCLE_TRANSACTION_ID_FOREIGN: plot %d" % p.plot_id)
		if seen_sequences.has(cycle.maturity_insertion_seq) or cycle.maturity_insertion_seq >= next_insertion_sequence:
			errors.append("CYCLE_INSERTION_SEQ_INVALID: plot %d seq %d" % [p.plot_id, cycle.maturity_insertion_seq])
		seen_sequences[cycle.maturity_insertion_seq] = true
		if cycle.status == CropCycle.STATUS_GROWING and cycle.matures_at_us <= simulation_time_us:
			errors.append("CYCLE_OVERDUE: plot %d matured at %d but is still growing at %d" % [p.plot_id, cycle.matures_at_us, simulation_time_us])
		if cycle.status == CropCycle.STATUS_READY and cycle.matures_at_us > simulation_time_us:
			errors.append("CYCLE_READY_EARLY: plot %d ready before maturity" % p.plot_id)
		if cycle.planted_at_us > simulation_time_us:
			errors.append("CYCLE_PLANTED_IN_FUTURE: plot %d" % p.plot_id)
	var unlocked: int = unlocked_plot_count()
	if unlocked < PlotState.INITIAL_UNLOCKED:
		errors.append("PLOT_UNLOCK_COUNT: %d unlocked, minimum %d" % [unlocked, PlotState.INITIAL_UNLOCKED])
	return errors


func _validate_research(registry: ContentRegistry) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	for research_id: String in research.completed:
		if registry.research(research_id) == null:
			errors.append("RESEARCH_UNKNOWN: '%s'" % research_id)
	if not research.active_project_id.is_empty() and registry.research(research.active_project_id) == null:
		errors.append("RESEARCH_UNKNOWN: active '%s'" % research.active_project_id)
	return errors


func to_primitive() -> Dictionary:
	var result: Dictionary = gameplay_primitive()
	result.merge(metadata_primitive())
	return result


func gameplay_primitive() -> Dictionary:
	var plot_items: Array = []
	for p: PlotState in plots:
		plot_items.append(p.to_primitive())
	return {
		"save_id": save_id,
		"schema_version": schema_version,
		"content_version": content_version,
		"state_sequence": state_sequence,
		"simulation_time_us": simulation_time_us,
		"player": player.to_primitive(),
		"plots": plot_items,
		"upgrades": upgrades.to_primitive(),
		"research": research.to_primitive(),
		"contracts": contracts.to_primitive(),
		"automation": automation.to_primitive(),
		"statistics": statistics.to_primitive(),
		"settings": settings.to_primitive(),
		"command_replay": command_replay.to_primitive(),
		"allocation_namespace": allocation_namespace,
		"next_entity_id": next_entity_id,
		"next_insertion_sequence": next_insertion_sequence,
	}


func metadata_primitive() -> Dictionary:
	return {
		"durable_revision": durable_revision,
		"last_commit_id": PrimitiveReader.plain(last_commit_id),
		"time_anchor": time_anchor.to_primitive(),
	}


func gameplay_digest() -> String:
	return CanonicalCodec.digest(gameplay_primitive())


func metadata_digest() -> String:
	return CanonicalCodec.digest(metadata_primitive())


func digest() -> String:
	return CanonicalCodec.digest(to_primitive())


## Deep copy by primitive round-trip: no mutable child can be shared with the source.
func clone() -> GameState:
	return GameState.from_primitive(to_primitive())


## Strict decoder; returns null for any malformed or unexpected field. Semantic invariants are
## checked separately by `validate(registry)` after the manifest is resolved.
static func from_primitive(value: Variant) -> GameState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "GameState")
	var allowed: PackedStringArray = GAMEPLAY_KEYS.duplicate()
	allowed.append_array(METADATA_KEYS)
	reader.expect_only(allowed)
	var state: GameState = GameState.new()
	state.save_id = reader.string_field("save_id")
	state.schema_version = reader.int_field("schema_version")
	state.content_version = reader.string_field("content_version")
	state.state_sequence = reader.int_field("state_sequence")
	state.durable_revision = reader.int_field("durable_revision")
	state.last_commit_id = reader.nullable_field("last_commit_id")
	if state.last_commit_id is Dictionary:
		state.last_commit_id = (state.last_commit_id as Dictionary).duplicate(true)
	state.simulation_time_us = reader.int_field("simulation_time_us")
	state.allocation_namespace = reader.string_field("allocation_namespace")
	state.next_entity_id = reader.int_field("next_entity_id")
	state.next_insertion_sequence = reader.int_field("next_insertion_sequence")
	state.player = PlayerState.from_primitive(reader.dict_field("player"))
	state.upgrades = ExtensionState.Upgrades.from_primitive(reader.dict_field("upgrades"))
	state.research = ExtensionState.Research.from_primitive(reader.dict_field("research"))
	state.contracts = ExtensionState.Contracts.from_primitive(reader.dict_field("contracts"))
	state.automation = ExtensionState.Automation.from_primitive(reader.dict_field("automation"))
	state.statistics = ExtensionState.Statistics.from_primitive(reader.dict_field("statistics"))
	state.settings = GameSettings.from_primitive(reader.dict_field("settings"))
	state.time_anchor = TimeAnchor.from_primitive(reader.dict_field("time_anchor"))
	state.command_replay = CommandReplayState.from_primitive(reader.dict_field("command_replay"))
	for item: Variant in reader.array_field("plots"):
		var p: PlotState = PlotState.from_primitive(item)
		if p == null:
			reader.absorb(PackedStringArray(["GameState: malformed plot"]))
			continue
		state.plots.append(p)
	var parts: Array = [state.player, state.upgrades, state.research, state.contracts, state.automation,
		state.statistics, state.settings, state.time_anchor, state.command_replay]
	if not reader.ok() or parts.has(null):
		return null
	return state
