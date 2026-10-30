class_name AutomationState
extends RefCounted
## Automation configuration and the farm budget (DEC-010/011/025; M02 E10/E11, build plan §3.4).
##
## - `defaults`: farm-level settings, every field set.
## - `plots`: one PlotAutomation per plot (overrides, optional group, loop authorization). Only
##   records that differ from the default are serialized, in plot order, so clones and digests stay
##   proportional to what was configured.
## - `groups`: reserved GroupRecords keyed by their EntityId key (AV-007-01/04), serialized in
##   ascending identity order; group commands are M05, so M02 creates them only in fixtures.
## - Budget: reserve R, Budget Protection percent p, automated-seed protection (fixture-only, Q3).
##   Approved defaults R=0, p=25, seed protection Off. Budget fields are farm-only (FRS §7.1).

var defaults: FarmingSettings = FarmingSettings.farm_defaults()
var plots: Array[PlotAutomation] = []
var groups: Dictionary[String, GroupRecord] = {}
var budget_reserve: int = 0
var budget_protection_percent: int = 25
var budget_seed_protection: bool = false


static func new_default() -> AutomationState:
	var state: AutomationState = AutomationState.new()
	for id: int in range(1, PlotState.PLOT_COUNT + 1):
		state.plots.append(PlotAutomation.new(id))
	return state


func plot(plot_id: int) -> PlotAutomation:
	if plot_id < 1 or plot_id > plots.size():
		return null
	return plots[plot_id - 1]


func disarm_all() -> void:
	for record: PlotAutomation in plots:
		record.authorization.disarm()


func validate() -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if budget_reserve < 0:
		errors.append("BUDGET_RESERVE_NEGATIVE: %d" % budget_reserve)
	if budget_protection_percent < 0 or budget_protection_percent > 100:
		errors.append("BUDGET_PERCENT_RANGE: %d" % budget_protection_percent)
	if not defaults.all_set():
		errors.append("SETTINGS_DEFAULTS_UNSET: farm defaults must set every field")
	errors.append_array(defaults.validate("farm"))
	if plots.size() != PlotState.PLOT_COUNT:
		errors.append("AUTOMATION_PLOT_COUNT: %d records, expected %d" % [plots.size(), PlotState.PLOT_COUNT])
	for i: int in plots.size():
		if plots[i].plot_id != i + 1:
			errors.append("AUTOMATION_PLOT_ORDER: index %d holds plot %d" % [i, plots[i].plot_id])
		errors.append_array(plots[i].validate("plot %d" % (i + 1)))
		if not plots[i].group_id.is_empty() and not groups.has(plots[i].group_id):
			errors.append("GROUP_UNKNOWN: plot %d references '%s'" % [i + 1, plots[i].group_id])
	for key: String in groups:
		errors.append_array(groups[key].validate())
		if groups[key].group_id != null and groups[key].key() != key:
			errors.append("GROUP_KEY_MISMATCH: '%s' holds group %s" % [key, groups[key].key()])
	return errors


func to_primitive() -> Dictionary:
	var plot_items: Array = []
	for record: PlotAutomation in plots:
		if not record.is_default():
			plot_items.append(record.to_primitive())
	var ordered: Array[GroupRecord] = groups.values()
	ordered.sort_custom(func(a: GroupRecord, b: GroupRecord) -> bool: return a.group_id.counter < b.group_id.counter)
	var group_items: Array = []
	for group: GroupRecord in ordered:
		group_items.append(group.to_primitive())
	return {
		"defaults": defaults.to_primitive(),
		"plots": plot_items,
		"groups": group_items,
		"budget_reserve": budget_reserve,
		"budget_protection_percent": budget_protection_percent,
		"budget_seed_protection": budget_seed_protection,
	}


static func from_primitive(value: Variant) -> AutomationState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "Automation")
	reader.expect_only(PackedStringArray(["defaults", "plots", "groups", "budget_reserve",
		"budget_protection_percent", "budget_seed_protection"]))
	var record: AutomationState = AutomationState.new()
	record.defaults = FarmingSettings.from_primitive(reader.dict_field("defaults"))
	if record.defaults == null:
		reader.absorb(PackedStringArray(["Automation: malformed defaults"]))
	for id: int in range(1, PlotState.PLOT_COUNT + 1):
		record.plots.append(PlotAutomation.new(id))
	var previous: int = 0
	for item: Variant in reader.array_field("plots"):
		var plot_record: PlotAutomation = PlotAutomation.from_primitive(item)
		if plot_record == null or plot_record.plot_id <= previous or plot_record.plot_id > PlotState.PLOT_COUNT \
				or plot_record.is_default():
			reader.absorb(PackedStringArray(["Automation: malformed, unordered or default plot record"]))
			continue
		previous = plot_record.plot_id
		record.plots[plot_record.plot_id - 1] = plot_record
	var previous_group: int = 0
	for item: Variant in reader.array_field("groups"):
		var group: GroupRecord = GroupRecord.from_primitive(item)
		if group == null or group.group_id.counter <= previous_group:
			reader.absorb(PackedStringArray(["Automation: malformed, duplicate or unordered group record"]))
			continue
		previous_group = group.group_id.counter
		record.groups[group.key()] = group
	record.budget_reserve = reader.int_field("budget_reserve")
	record.budget_protection_percent = reader.int_field("budget_protection_percent")
	record.budget_seed_protection = reader.bool_field("budget_seed_protection")
	return record if reader.ok() else null
