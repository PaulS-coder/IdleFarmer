class_name EntityId
extends RefCounted
## Dynamic entity identity (save_id, allocation_namespace, checked counter) — TRS §3.1/§20.1, AUD-001.
## Equality uses all three components; ordering uses only the retained-history numeric counter,
## never UUID/string order. Plot IDs and authored content IDs are not EntityIds.

var save_id: String
var allocation_namespace: String
var counter: int


func _init(p_save_id: String, p_namespace: String, p_counter: int) -> void:
	save_id = p_save_id
	allocation_namespace = p_namespace
	counter = p_counter


func is_valid() -> bool:
	return not save_id.is_empty() and not allocation_namespace.is_empty() and counter >= 1


func equals(other: EntityId) -> bool:
	return other != null and save_id == other.save_id and allocation_namespace == other.allocation_namespace and counter == other.counter


func key() -> String:
	return "%s/%s/%d" % [save_id, allocation_namespace, counter]


func to_primitive() -> Dictionary:
	return {"save_id": save_id, "namespace": allocation_namespace, "counter": counter}


## Decodes a primitive identity; returns null for any missing, mistyped, extra or invalid component.
static func from_primitive(value: Variant) -> EntityId:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "EntityId")
	reader.expect_only(PackedStringArray(["save_id", "namespace", "counter"]))
	var id: EntityId = EntityId.new(reader.string_field("save_id"), reader.string_field("namespace"), reader.int_field("counter"))
	if not reader.ok() or not id.is_valid():
		return null
	return id


static func nullable_to_primitive(id: EntityId) -> Variant:
	return null if id == null else id.to_primitive()
