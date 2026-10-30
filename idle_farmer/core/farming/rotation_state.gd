class_name RotationState
extends RefCounted
## Reserved per-plot crop-rotation record (FRS §9.2, TRS §3.5): the explicitly approved crop
## sequence and the cursor of the current entry. Inert until M05 (Crop Rotation is unavailable);
## the cursor will advance only after a successful planting of the current entry.

var entries: PackedStringArray = PackedStringArray()
var cursor: int = 0


func is_empty() -> bool:
	return entries.is_empty() and cursor == 0


func validate(context: String) -> PackedStringArray:
	var errors: PackedStringArray = PackedStringArray()
	if cursor < 0 or (entries.is_empty() and cursor != 0) or (not entries.is_empty() and cursor >= entries.size()):
		errors.append("ROTATION_CURSOR_RANGE: %s cursor %d of %d" % [context, cursor, entries.size()])
	return errors


func to_primitive() -> Dictionary:
	return {"entries": Array(entries), "cursor": cursor}


static func from_primitive(value: Variant) -> RotationState:
	var reader: PrimitiveReader = PrimitiveReader.new(value, "RotationState")
	reader.expect_only(PackedStringArray(["entries", "cursor"]))
	var record: RotationState = RotationState.new()
	record.entries = reader.string_array_field("entries")
	record.cursor = reader.int_field("cursor")
	return record if reader.ok() else null
