class_name CommandId
extends RefCounted
## Accepted-command identity (save_id, writer_epoch_uuid, in-epoch counter) — TRS §4.1, DEC-016.
## The controller issues counters; the writer epoch UUID is injected from outside the core (P10).

var save_id: String
var writer_epoch: String
var counter: int


func _init(p_save_id: String, p_writer_epoch: String, p_counter: int) -> void:
	save_id = p_save_id
	writer_epoch = p_writer_epoch
	counter = p_counter


func is_valid() -> bool:
	return not save_id.is_empty() and not writer_epoch.is_empty() and counter >= 1


func equals(other: CommandId) -> bool:
	return other != null and save_id == other.save_id and writer_epoch == other.writer_epoch and counter == other.counter


func to_primitive() -> Dictionary:
	return {"save_id": save_id, "writer_epoch": writer_epoch, "counter": counter}


static func from_primitive(value: Variant) -> CommandId:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "CommandId")
	reader.expect_only(PackedStringArray(["save_id", "writer_epoch", "counter"]))
	var id: CommandId = CommandId.new(reader.string_field("save_id"), reader.string_field("writer_epoch"), reader.int_field("counter"))
	if not reader.ok() or not id.is_valid():
		return null
	return id
