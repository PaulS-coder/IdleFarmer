class_name GroupRecord
extends RefCounted
## Reserved plot-group record (TRS §20.7, AUD-DEC-007 B, AV-007-01/04). Stable dynamic identity
## (AUD-DEC-001 EntityId), display name, revision and inheritable settings. Group commands are M05
## (FEATURE_UNAVAILABLE); in M02 records exist only through fixtures, and the resolver already
## honours them. A rename changes only `name`/`revision` and never the economic plan.

var group_id: EntityId = null
var name: String = ""
var revision: int = 1
var settings: FarmingSettings = FarmingSettings.new()


func key() -> String:
	return group_id.key()


func validate() -> PackedStringArray:
	var context: String = "group '%s'" % (key() if group_id != null else "?")
	var errors: PackedStringArray = PackedStringArray()
	if group_id == null or not group_id.is_valid() or name.is_empty() or revision < 1:
		errors.append("GROUP_RECORD_INVALID: %s needs an identity, a name and revision ≥ 1" % context)
	errors.append_array(settings.validate(context))
	return errors


func to_primitive() -> Dictionary:
	return {"group_id": EntityId.nullable_to_primitive(group_id), "name": name, "revision": revision,
		"settings": settings.to_primitive()}


static func from_primitive(value: Variant) -> GroupRecord:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "GroupRecord")
	reader.expect_only(PackedStringArray(["group_id", "name", "revision", "settings"]))
	var record: GroupRecord = GroupRecord.new()
	record.group_id = EntityId.from_primitive(reader.dict_field("group_id"))
	record.name = reader.string_field("name")
	record.revision = reader.int_field("revision")
	record.settings = FarmingSettings.from_primitive(reader.dict_field("settings"))
	if not reader.ok() or record.group_id == null or record.settings == null:
		return null
	return record
