class_name FarmingSettings
extends RefCounted
## Inheritable farming settings with explicit tri-state fields (M02 E10, FRS §7.1, build plan §3.4).
## Each field has a `<name>_set` flag: unset inherits Plot > Group > Farm; an explicit false, "" or 0
## that is set stays set. Farm defaults have every field set. Budget fields are farm-only and live in
## AutomationState, never here.

const CROP_ID: String = "crop_id"
const AUTO_HARVEST: String = "auto_harvest"
const AUTO_REPLANT: String = "auto_replant"
const FERTILIZER_POLICY: String = "fertilizer_policy"
const FALLBACK_ACCEPTED: String = "fallback_accepted"
## Custom spending priority (Enhanced Budget Management). Fixture-only in M02 (Q3); default 0.
const PRIORITY: String = "priority"
const FIELDS: PackedStringArray = [CROP_ID, AUTO_HARVEST, AUTO_REPLANT, FERTILIZER_POLICY, FALLBACK_ACCEPTED, PRIORITY]

const POLICY_SMART_MP: String = "smart_mp"
const POLICY_SMART_CE: String = "smart_ce"
const POLICY_SMART_BP: String = "smart_bp"
const SMART_POLICIES: PackedStringArray = [POLICY_SMART_MP, POLICY_SMART_CE, POLICY_SMART_BP]
const PRIMITIVE_KEYS: PackedStringArray = [
	"crop_id", "crop_id_set", "auto_harvest", "auto_harvest_set", "auto_replant", "auto_replant_set",
	"fertilizer_policy", "fertilizer_policy_set", "fallback_accepted", "fallback_accepted_set", "priority", "priority_set",
]

var crop_id_set: bool = false
var crop_id: String = ""
var auto_harvest_set: bool = false
var auto_harvest: bool = false
var auto_replant_set: bool = false
var auto_replant: bool = false
var fertilizer_policy_set: bool = false
var fertilizer_policy: String = FertilizerDefinition.NONE_ID
var fallback_accepted_set: bool = false
var fallback_accepted: bool = false
var priority_set: bool = false
var priority: int = 0


## Farm defaults: every field set; no crop, automation off, policy none, no fallback, priority 0.
static func farm_defaults() -> FarmingSettings:
	var settings: FarmingSettings = FarmingSettings.new()
	for field: String in FIELDS:
		settings.set(field + "_set", true)
	return settings


static func is_smart(policy: String) -> bool:
	return SMART_POLICIES.has(policy)


## Expected Variant type of a field's value.
static func field_type(field: String) -> int:
	match field:
		CROP_ID, FERTILIZER_POLICY:
			return TYPE_STRING
		AUTO_HARVEST, AUTO_REPLANT, FALLBACK_ACCEPTED:
			return TYPE_BOOL
		PRIORITY:
			return TYPE_INT
	return TYPE_NIL


func is_set(field: String) -> bool:
	return get(field + "_set")


func value(field: String) -> Variant:
	return get(field)


func set_value(field: String, p_value: Variant) -> void:
	set(field + "_set", true)
	set(field, p_value)


## Unsets a field and restores its neutral value, so equal settings have equal primitives.
func clear(field: String) -> void:
	set(field + "_set", false)
	set(field, FarmingSettings.new().get(field))


func is_empty() -> bool:
	return not (crop_id_set or auto_harvest_set or auto_replant_set or fertilizer_policy_set or fallback_accepted_set or priority_set)


func all_set() -> bool:
	for field: String in FIELDS:
		if not is_set(field):
			return false
	return true


func validate(context: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	for field: String in FIELDS:
		if not is_set(field) and value(field) != FarmingSettings.new().get(field):
			errors.append("SETTINGS_UNSET_VALUE: %s field '%s' is unset but carries a value" % [context, field])
	return errors


func to_primitive() -> Dictionary:
	var result: Dictionary = {}
	for field: String in FIELDS:
		result[field + "_set"] = is_set(field)
		result[field] = value(field)
	return result


static func from_primitive(value_in: Variant) -> FarmingSettings:
	var reader: PrimitiveReader = PrimitiveReader.new(value_in, "FarmingSettings")
	reader.expect_only(PRIMITIVE_KEYS)
	var settings: FarmingSettings = FarmingSettings.new()
	settings.crop_id_set = reader.bool_field("crop_id_set")
	settings.crop_id = reader.string_field("crop_id")
	settings.auto_harvest_set = reader.bool_field("auto_harvest_set")
	settings.auto_harvest = reader.bool_field("auto_harvest")
	settings.auto_replant_set = reader.bool_field("auto_replant_set")
	settings.auto_replant = reader.bool_field("auto_replant")
	settings.fertilizer_policy_set = reader.bool_field("fertilizer_policy_set")
	settings.fertilizer_policy = reader.string_field("fertilizer_policy")
	settings.fallback_accepted_set = reader.bool_field("fallback_accepted_set")
	settings.fallback_accepted = reader.bool_field("fallback_accepted")
	settings.priority_set = reader.bool_field("priority_set")
	settings.priority = reader.int_field("priority")
	return settings if reader.ok() else null
